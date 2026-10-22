-- Execute the production files in isolated environments. The fake below models
-- Core's public boundary; it does not prove CFX function transport or RedM natives.
local passed = 0
local function test(name, body)
    local ok, failure = pcall(body)
    if not ok then error(name .. ': ' .. tostring(failure), 0) end
    passed = passed + 1
    print('PASS ' .. name)
end

local function fixture(overrides)
    local env = setmetatable({}, { __index = _G })
    local mock = { state = 'started', time = 0, calls = {}, routes = {}, subscriptions = {}, nextToken = 0 }
    env.GetCurrentResourceName = function() return 'bcc-stables' end
    env.GetResourceMetadata = function() return '0.1.0-dev' end
    env.GetResourceState = function() return mock.state end
    env.GetGameTimer = function() return mock.time end
    env.Wait = function(ms) mock.time = mock.time + math.max(1, ms) end
    local session = { source = 12, sessionId = 'session-a', characterId = 'character-a', accountId = 'account-a', state = 'ready' }
    mock.session = session
    mock.current = true
    local methods = {}
    methods.AwaitReady = function() return { ok = true, value = { state = 'ready' } } end
    methods.GetHealth = methods.AwaitReady
    methods.GetCapabilities = function()
        return { ok = true, value = { resource = 'feather-core', contract = 1, version = '1.0.0', state = 'ready', features = {
            lifecycle = 1, health = 1, sessions = 1, rpc = 1, namedRpcAccess = 1, events = 1, localization = 1,
        } } }
    end
    methods.RequireSession = function(_, source)
        if source ~= 12 then return { ok = false, code = 'character_required', message = 'No session.' } end
        return { ok = true, value = session }
    end
    methods.IsSessionCurrent = function(_, source, id, characterId)
        return mock.current and source == session.source and id == session.sessionId and characterId == session.characterId
    end
    methods.RegisterLocale = function(_, locale, translations)
        mock.locale, mock.translations = locale, translations
        return { ok = true, value = { locale = locale } }
    end
    methods.SubscribeEvent = function(_, name, callback)
        mock.nextToken = mock.nextToken + 1
        local token = 'token:' .. mock.nextToken
        mock.subscriptions[token] = { name = name, callback = callback }
        return { ok = true, value = { token = token } }
    end
    methods.UnsubscribeEvent = function(_, token)
        mock.subscriptions[token] = nil
        return { ok = true, value = true }
    end
    methods.RegisterRpc = function(_, name, callback, options)
        mock.routes[name] = { callback = callback, options = options }
        return { ok = true, value = { route = name } }
    end
    for name, implementation in pairs(overrides or {}) do methods[name] = implementation end
    local provider = setmetatable({}, { __index = function(_, method)
        return function(...)
            mock.calls[method] = (mock.calls[method] or 0) + 1
            assert(methods[method], 'Unexpected Core method: ' .. method)
            return methods[method](...)
        end
    end })
    env.exports = { ['feather-core'] = provider }
    for _, file in ipairs({ 'config.lua', 'shared/contracts.lua', 'server/core.lua', 'server/foundation.lua' }) do
        assert(loadfile(file, 't', env))()
    end
    mock.env, mock.stables = env, env.Stables
    env.Stables.Persistence = {
        Start = function() return env.Stables.Ok({ state = 'ready', schemaVersion = 1, applied = 0, resumed = 0 }) end,
        RequireReady = function() return env.Stables.Ok({ state = 'ready' }) end,
        Stop = function() end,
    }
    mock.start = function() return env.Stables.Foundation.Start() end
    return mock
end

test('happy startup registers bounded character RPC and locales', function()
    local m = fixture()
    assert(m.start().ok)
    local route = m.routes['stables.session.check.v1']
    assert(route.options.requireCharacter and route.options.maxPayloadBytes == 64)
    assert(route.options.maxDepth == 2 and route.options.maxNodes == 4)
    assert(route.options.maxCalls == 2 and route.options.windowMs == 2000)
    assert(m.locale == 'en_us' and m.nextToken == 3)
    assert(m.stables.Foundation.Capabilities().value.features.horses == nil)
end)

test('session RPC derives identity and rejects stale request context', function()
    local m = fixture()
    assert(m.start().ok)
    local callback = m.routes['stables.session.check.v1'].callback
    assert(callback({}, 12, m.session).value.characterId == 'character-a')
    local stale = m.stables.Copy(m.session)
    stale.sessionId = 'old-session'
    assert(callback({}, 12, stale).code == 'session_stale')
    stale = m.stables.Copy(m.session)
    stale.accountId = 'other-account'
    assert(callback({}, 12, stale).code == 'session_stale')
    assert(callback({}, 13, m.session).code == 'character_required')
    m.current = false
    assert(callback({}, 12, m.session).code == 'session_stale')
end)

test('RPC payload cannot supply identity or additional data', function()
    local s = fixture().stables
    assert(s.EmptyPayload({}))
    for _, payload in ipairs({ { source = 12 }, { characterId = 'other' }, { { 'nested' } }, 'bad', 2, false }) do
        assert(not s.EmptyPayload(payload))
    end
    assert(not s.EmptyPayload(nil))
end)

test('Core readiness rejection fails startup', function()
    local m = fixture({ AwaitReady = function() return { ok = false, code = 'timeout', message = 'Not ready.' } end })
    assert(m.start().code == 'timeout')
    assert(m.stables.Foundation.Health().value.state == 'failed')
    assert(next(m.routes) == nil)
end)

test('missing and incompatible Core feature contracts fail closed', function()
    for _, bad in ipairs({ false, 0, 2, '1' }) do
        local m = fixture()
        local result = m.stables.Core.Call('GetCapabilities')
        result.value.features.sessions = bad
        assert(m.stables.ValidateCore(result).code == 'unsupported_contract')
    end
    local m = fixture({ GetCapabilities = function() return { ok = true, value = {} } end })
    assert(m.start().code == 'unsupported_contract')
end)

test('exceptions and malformed envelopes are safe failures', function()
    local m = fixture({ GetCapabilities = function() error('private implementation failure') end })
    assert(m.start().code == 'dependency_error')
    m = fixture({ AwaitReady = function() return true end })
    assert(m.start().code == 'invalid_contract')
end)

test('partial registration failure releases owned subscriptions', function()
    local m = fixture({ RegisterRpc = function() return { ok = false, code = 'conflict', message = 'Duplicate.' } end })
    assert(m.start().code == 'conflict')
    assert(next(m.subscriptions) == nil)
end)

test('session lifecycle is observed without a duplicate identity registry', function()
    local m = fixture()
    assert(m.start().ok)
    for _, subscription in pairs(m.subscriptions) do subscription.callback(m.session) end
    local counts = m.stables.Foundation.Health().value.sessionEvents
    assert(counts.ready == 1 and counts.leaving == 1 and counts.left == 1)
end)

test('health and capabilities cannot be mutated by readers', function()
    local m = fixture()
    assert(m.start().ok)
    local health = m.stables.Foundation.Health().value
    health.checks.core.contract = 999
    assert(m.stables.Foundation.Health().value.checks.core.contract == 1)
    local caps = m.stables.Foundation.Capabilities().value
    caps.features.horses = 1
    assert(m.stables.Foundation.Capabilities().value.features.horses == nil)
end)

test('timeouts reject invalid input and bound startup waiting', function()
    local m = fixture()
    for _, timeout in ipairs({ -1, 60001, 1.5, '10', false, math.huge, 0/0 }) do
        assert(m.stables.Foundation.AwaitReady(timeout).code == 'invalid_input')
    end
    assert(m.stables.Foundation.AwaitReady(50).code == 'timeout')
    assert(m.time == 50)
    m.env.StablesConfig.startupTimeoutMs = -1
    assert(m.start().code == 'config_error')
end)

test('Core loss latches failure and never silently reconstructs registration', function()
    local m = fixture()
    assert(m.start().ok)
    m.state = 'stopped'
    assert(m.stables.Foundation.RequireReady().code == 'dependency_unavailable')
    m.state = 'started'
    assert(m.stables.Foundation.RequireReady().code == 'not_ready')
    assert(m.start().code == 'conflict')
end)

test('Core health degradation blocks new session checks', function()
    local m = fixture({ GetHealth = function() return { ok = true, value = { state = 'degraded' } } end })
    assert(m.start().ok)
    assert(m.stables.Foundation.CheckSession(12, m.session).code == 'dependency_unavailable')
end)

test('shutdown releases subscriptions and is idempotent', function()
    local m = fixture()
    assert(m.start().ok)
    m.stables.Foundation.Stop()
    m.stables.Foundation.Stop()
    assert(next(m.subscriptions) == nil)
    assert(m.stables.Foundation.Health().value.state == 'stopped')
end)

test('callable CFX tables accepted', function()
    local s = fixture().stables
    assert(s.IsCallable(function() end))
    assert(s.IsCallable({ __cfx_functionReference = 'ref' }))
    assert(not s.IsCallable({}))
end)

-- Parse every runtime script under Lua 5.4, including CFX entry points.
test('persistence startup refusal prevents RPC registration', function()
    local m = fixture()
    m.stables.Persistence.Start = function() return m.stables.Err('migration_checksum_mismatch', 'Changed migration.') end
    assert(m.start().code == 'migration_checksum_mismatch')
    assert(next(m.routes) == nil and m.stables.Foundation.Health().value.state == 'failed')
end)

test('database loss latches foundation failure and releases subscriptions', function()
    local m = fixture(); assert(m.start().ok)
    m.stables.Foundation.DatabaseStopped()
    assert(m.stables.Foundation.Health().value.reason == 'persistence_unavailable')
    assert(next(m.subscriptions) == nil and not m.stables.Foundation.RequireReady().ok)
end)

test('database health gate prevents otherwise valid session requests', function()
    local m = fixture(); assert(m.start().ok)
    m.stables.Persistence.RequireReady = function() return m.stables.Err('persistence_unavailable', 'Stopped.') end
    assert(m.stables.Foundation.CheckSession(12,m.session).code == 'persistence_unavailable')
end)

for _, file in ipairs({ 'fxmanifest.lua', 'server/main.lua', 'client/diagnostics.lua' }) do
    assert(loadfile(file, 't', {}))
end
print(('%d/%d offline cases passed; runtime entry points parse under Lua 5.4.'):format(passed, passed))
