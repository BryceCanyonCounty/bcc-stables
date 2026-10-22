Stables.Foundation = {}
local F = Stables.Foundation
local health = { state = 'booting', reason = 'waiting_for_core', checks = {}, sessionEvents = {
    ready = 0, leaving = 0, left = 0,
} }
local subscriptions = {}

local function Fail(result)
    health.state, health.reason = 'failed', result.code
    health.failure = Stables.Copy(result)
    for _, token in ipairs(subscriptions) do Stables.Core.Call('UnsubscribeEvent', token) end
    subscriptions = {}
    return result
end

function F.Capabilities()
    return Stables.Ok({
        resource = GetCurrentResourceName(), contract = 1,
        version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0),
        state = health.state,
        -- No horses, purchases, persistence or gameplay capability is advertised.
        features = { lifecycle = 1, health = 1, sessionDiagnostics = 1 },
    })
end

function F.Health()
    return Stables.Ok(Stables.Copy(health))
end

function F.RequireReady()
    if health.state ~= 'ready' then
        return Stables.Err('not_ready', 'BCC Stables is not ready.', { state = health.state, reason = health.reason })
    end
    if GetResourceState('feather-core') ~= 'started' then
        return Fail(Stables.Err('dependency_unavailable', 'Core stopped; restart the framework in dependency order.'))
    end
    if not Stables.Persistence or not Stables.Persistence.RequireReady().ok then
        return Fail(Stables.Err('persistence_unavailable', 'Stables persistence is unavailable; restart in dependency order.'))
    end
    -- Do not accept requests when Core reports migration/failure/degraded state.
    local result = Stables.Core.Call('GetHealth')
    if not result.ok then return Fail(result) end
    if type(result.value) ~= 'table' or result.value.state ~= 'ready' then
        return Fail(Stables.Err('dependency_unavailable', 'Core is no longer ready; restart the framework.'))
    end
    return Stables.Ok(true)
end

function F.AwaitReady(timeoutMs)
    if timeoutMs == nil then timeoutMs = 30000 end
    if not Stables.ValidTimeout(timeoutMs) then
        return Stables.Err('invalid_input', 'timeoutMs must be an integer from 0 to 60000.')
    end
    local started = GetGameTimer()
    while health.state == 'booting' or health.state == 'starting' do
        if GetGameTimer() - started >= timeoutMs then
            return Stables.Err('timeout', 'Timed out waiting for BCC Stables.')
        end
        Wait(25)
    end
    local ready = F.RequireReady()
    if not ready.ok then return ready end
    return F.Health()
end

function F.CheckSession(source, context)
    local ready = F.RequireReady()
    if not ready.ok then return ready end
    local session = Stables.Core.RequireSession(source)
    if not session.ok then return session end
    local current = session.value
    if type(context) ~= 'table' or context.source ~= source
        or context.sessionId ~= current.sessionId or context.characterId ~= current.characterId
        or context.accountId ~= current.accountId then
        return Stables.Err('session_stale', 'The request belongs to an expired character session.')
    end
    return Stables.Ok({ characterId = current.characterId, sessionCurrent = true, gameplayAvailable = false })
end

function F.Stop(reason)
    if health.state == 'stopping' or health.state == 'stopped' then return end
    health.state, health.reason = 'stopping', reason or 'resource_stopping'
    if Stables.Proof then Stables.Proof.Stop('resource_stopping') end
    if Stables.Persistence then Stables.Persistence.Stop() end
    for _, token in ipairs(subscriptions) do Stables.Core.Call('UnsubscribeEvent', token) end
    subscriptions = {}
    health.state = 'stopped'
end

function F.CoreStopped()
    if Stables.Persistence then Stables.Persistence.Stop() end
    if Stables.Proof then Stables.Proof.Stop('core_stopped') end
    if health.state ~= 'stopped' and health.state ~= 'stopping' then
        Fail(Stables.Err('dependency_unavailable', 'Core stopped; a controlled framework restart is required.'))
    end
end

function F.DatabaseStopped()
    if Stables.Persistence then Stables.Persistence.Stop() end
    if Stables.Proof then Stables.Proof.Stop('database_stopped') end
    if health.state ~= 'stopped' and health.state ~= 'stopping' then
        Fail(Stables.Err('persistence_unavailable', 'Database stopped; restart Stables in dependency order.'))
    end
end

function F.Start()
    if health.state ~= 'booting' then return Stables.Err('conflict', 'Startup has already run.') end
    if not Stables.ValidTimeout(StablesConfig.startupTimeoutMs) then
        return Fail(Stables.Err('config_error', 'startupTimeoutMs must be an integer from 0 to 60000.'))
    end
    if type(StablesConfig.entityProof) ~= 'table' or type(StablesConfig.entityProof.enabled) ~= 'boolean' then
        return Fail(Stables.Err('config_error', 'entityProof.enabled must be a boolean.'))
    end
    if StablesConfig.entityProof.spawnMode ~= 'client_lease' and StablesConfig.entityProof.spawnMode ~= 'server_rpc' then
        return Fail(Stables.Err('config_error', 'entityProof.spawnMode must be client_lease or server_rpc.'))
    end
    local ready = Stables.Core.Call('AwaitReady', StablesConfig.startupTimeoutMs)
    if health.state ~= 'booting' then return Stables.Err('startup_cancelled', 'Startup was cancelled.') end
    if not ready.ok then return Fail(ready) end
    local capabilities = Stables.ValidateCore(Stables.Core.Call('GetCapabilities'))
    if not capabilities.ok then return Fail(capabilities) end
    health.checks.core = { ok = true, contract = capabilities.value.contract, version = capabilities.value.version }
    health.state, health.reason = 'starting', 'starting_persistence'
    if not Stables.Persistence then return Fail(Stables.Err('internal_error', 'Persistence module is missing.')) end
    local persisted = Stables.Persistence.Start()
    if not persisted.ok then return Fail(persisted) end
    if health.state ~= 'starting' then return Stables.Err('startup_cancelled', 'Startup was cancelled.') end
    health.checks.persistence = Stables.Copy(persisted.value)
    health.checks.persistence.ok = true
    health.state, health.reason = 'starting', 'registering_contracts'

    local locale = Stables.Core.Call('RegisterLocale', 'en_us', {
        ['bcc_stables.diagnostics_only'] = 'BCC Stables foundation is ready. Horse gameplay is not available yet.',
    })
    if not locale.ok then return Fail(locale) end

    for _, stage in ipairs({ 'ready', 'leaving', 'left' }) do
        local subscription = Stables.Core.Call('SubscribeEvent', 'core.session.' .. stage .. '.v1', function(payload)
            -- Observe lifecycle without maintaining a second character registry.
            health.sessionEvents[stage] = health.sessionEvents[stage] + 1
            if Stables.Proof then Stables.Proof.SessionEvent(stage, payload) end
        end)
        if not subscription.ok then return Fail(subscription) end
        if type(subscription.value) ~= 'table' or type(subscription.value.token) ~= 'string' then
            return Fail(Stables.Err('invalid_contract', 'Core returned an invalid event subscription.'))
        end
        subscriptions[#subscriptions + 1] = subscription.value.token
    end

    local options = {
        contract = 1, direction = 'client_to_server', requireCharacter = true,
        windowMs = 2000, maxCalls = 2, maxPayloadBytes = 64, maxDepth = 2, maxNodes = 4,
        validatePayload = Stables.EmptyPayload,
    }
    local route = Stables.Core.Call('RegisterRpc', 'stables.session.check.v1', function(_, source, context)
        return F.CheckSession(source, context)
    end, options)
    if not route.ok then return Fail(route) end
    local proofRoutes = 0
    if StablesConfig.entityProof.enabled then
        if not Stables.Proof then return Fail(Stables.Err('internal_error', 'Entity proof module is missing.')) end
        local installed = Stables.Proof.Install()
        if not installed.ok then return Fail(installed) end
        proofRoutes = installed.value.routes
    end
    if health.state ~= 'starting' then return Stables.Err('startup_cancelled', 'Startup was cancelled.') end
    health.checks.registrations = { ok = true, subscriptions = #subscriptions, routes = 1 + proofRoutes }
    health.state, health.reason = 'ready', 'foundation_only'
    return F.Health()
end
