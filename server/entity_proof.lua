-- Disposable, nonpersistent native experiment. Not a production horse registry.
Stables.Proof = {}
local P = Stables.Proof
local lease, serial, installed = nil, 0, false
local lastFailure
local lastCleanup
local routeTestRunning = false
local MODEL = 'a_c_horse_morgan_bay'
local MARKER = 'bccStablesProof'

local function Exists(entity)
    if not entity or entity == 0 then return false end
    local value = DoesEntityExist(entity)
    return value == true or value == 1
end

local function ScriptAllowed(entity)
    local script = GetEntityScript(entity)
    -- Live RedM evidence: this getter may be nil for a valid replicated horse.
    -- Missing metadata is not positive provenance; all lease checks still apply.
    return script == nil or script == '' or script == GetCurrentResourceName()
end

local function Log(result)
    print('[bcc-stables:proof] ' .. json.encode(result))
end

local function Current(record)
    return lease == record and not record.cancelled and Stables.Core.IsSessionCurrent(record.session)
end

local function SameEntity(record)
    if not Exists(record.entity) then return false end
    if record.netId and NetworkGetNetworkIdFromEntity(record.entity) ~= record.netId then return false end
    if GetEntityModel(record.entity) ~= GetHashKey(MODEL) then return false end
    if record.marked and Entity(record.entity).state[MARKER] ~= record.generation then return false end
    return true
end

local function ObserveOwner(record)
    if not SameEntity(record) then return end
    local owner = NetworkGetEntityOwner(record.entity)
    if owner == record.lastNetworkOwner then return end
    if record.lastNetworkOwner ~= nil then record.ownerChanges = (record.ownerChanges or 0) + 1 end
    record.lastNetworkOwner = owner
    record.ownerHistory = record.ownerHistory or {}
    if #record.ownerHistory >= 16 then table.remove(record.ownerHistory, 1) end
    local sample = { networkOwner = owner, ageSeconds = math.floor((GetGameTimer() - record.started) / 1000) }
    record.ownerHistory[#record.ownerHistory + 1] = sample
    Log(Stables.Ok({ event = 'network_owner', generation = record.generation, source = record.session.source,
        networkOwner = owner, ageSeconds = sample.ageSeconds }))
end

local function Forget(record, outcome)
    lastCleanup = { generation = record.generation, source = record.session.source, netId = record.netId,
        mode = record.mode, reason = record.reason, outcome = outcome or 'cleared',
        ageSeconds = math.floor((GetGameTimer() - record.started) / 1000),
        lifetimeSeconds = record.lifetimeMs / 1000, lastNetworkOwner = record.lastNetworkOwner,
        ownerChanges = record.ownerChanges or 0, ownerHistory = Stables.Copy(record.ownerHistory or {}) }
    Log(Stables.Ok({ event = 'cleanup_finished', cleanup = Stables.Copy(lastCleanup) }))
    if lease == record then lease = nil end
end

function P.Clear(reason)
    local record = lease
    if not record then return Stables.Ok({ cleared = false }) end
    record.cancelled, record.reason = true, record.reason or reason or 'console_clear'
    TriggerClientEvent('bcc-stables:proof:cancel', record.session.source, record.generation)
    if record.creating then
        -- The yielding creator owns final cleanup after its native returns.
        return Stables.Ok({ pending = true, reason = record.reason })
    end
    -- A client may disconnect after creating but before binding. Only recover a
    -- newly observed entity with our script/model/lease marker for cleanup.
    if record.mode == 'client_lease' and not record.entity then
        for entity in pairs(record.candidates or {}) do
            if Exists(entity) and ScriptAllowed(entity)
                and (NetworkGetEntityOwner(entity) == record.session.source
                    or record.candidateOwners[entity] == record.session.source)
                and GetEntityModel(entity) == GetHashKey(MODEL)
                and Entity(entity).state[MARKER] == record.generation then
                record.entity, record.netId = entity, NetworkGetNetworkIdFromEntity(entity)
                record.observed, record.marked = true, true
                break
            end
        end
    end
    if record.entity and not record.observed then
        if not Exists(record.entity) then
            record.state = 'cleanup_pending'
            return Stables.Err('spawn_unresolved', 'Unobserved spawn retained for cleanup; no new proof is allowed.')
        end
        record.observed = true
        record.netId = NetworkGetNetworkIdFromEntity(record.entity)
    end
    if Exists(record.entity) then
        if not SameEntity(record) then
            Forget(record, 'identity_lost') -- Never delete an entity with a reused/mismatched identity.
            return Stables.Err('entity_identity_lost', 'Fixture identity changed; no entity was deleted.')
        end
        DeleteEntity(record.entity)
        if Exists(record.entity) then
            record.state = 'cleanup_pending'
            return Stables.Err('cleanup_pending', 'Deletion requested; waiting for disappearance.')
        end
    end
    Forget(record)
    return Stables.Ok({ cleared = true, reason = record.reason })
end

function P.Begin(target, lifetimeSeconds)
    if not installed or not StablesConfig.entityProof.enabled then return Stables.Err('disabled', 'Entity proof is disabled.') end
    local ready = Stables.Foundation.RequireReady()
    if not ready.ok then return ready end
    if lease then return Stables.Err('busy', 'Clear the existing proof before spawning another.') end
    if lifetimeSeconds == nil then lifetimeSeconds = 300 end
    if type(lifetimeSeconds) ~= 'number' or lifetimeSeconds % 1 ~= 0 or lifetimeSeconds < 60 or lifetimeSeconds > 900 then
        return Stables.Err('invalid_input', 'Proof lifetime must be an integer from 60 to 900 seconds; default 300.')
    end
    if type(target) ~= 'number' or target <= 0 or target % 1 ~= 0 then
        return Stables.Err('invalid_input', 'A connected server source is required.')
    end
    local session = Stables.Core.RequireSession(target)
    if not session.ok then return session end
    local ped = GetPlayerPed(target)
    if not Exists(ped) then return Stables.Err('player_unavailable', 'Player ped is unavailable.') end
    if GetPlayerRoutingBucket(target) ~= 0 then
        return Stables.Err('foreign_route', 'Proof requires the default world; no route will be changed.')
    end
    serial = serial + 1
    lease = { generation = ('proof:%d:%d:%d'):format(os.time(), GetGameTimer(), serial),
        session = session.value, state = 'preparing', started = GetGameTimer(), mode = StablesConfig.entityProof.spawnMode,
        lifetimeMs = lifetimeSeconds * 1000 }
    TriggerClientEvent('bcc-stables:proof:prepare', target, { generation = lease.generation, model = MODEL })
    return Stables.Ok({ state = lease.state, generation = lease.generation, source = target, model = MODEL,
        mode = lease.mode, lifetimeSeconds = lifetimeSeconds })
end

local function ValidateRequest(source, context, generation)
    local ready = Stables.Foundation.CheckSession(source, context)
    if not ready.ok then return nil, ready end
    local record = lease
    if not installed or not StablesConfig.entityProof.enabled or not record
        or record.session.source ~= source or record.session.sessionId ~= context.sessionId
        or record.generation ~= generation or not Current(record) then
        return nil, Stables.Err('stale_proof', 'The disposable proof lease is no longer current.')
    end
    return record
end

function P.Prepared(payload, source, context)
    local record, failure = ValidateRequest(source, context, payload.generation)
    if not record then return failure end
    if record.state ~= 'preparing' then return Stables.Err('conflict', 'Proof spawn has already started.') end
    if GetGameTimer() - record.started > 15000 then P.Clear('prepare_timeout'); return Stables.Err('timeout', 'Preparation expired.') end
    if GetPlayerRoutingBucket(source) ~= 0 then P.Clear('route_changed'); return Stables.Err('foreign_route', 'Player changed route.') end
    local ped = GetPlayerPed(source)
    if not Exists(ped) then P.Clear('ped_missing'); return Stables.Err('player_unavailable', 'Player ped is unavailable.') end
    local pos, heading = GetEntityCoords(ped), GetEntityHeading(ped)
    if record.mode == 'client_lease' then
        record.position = { x = pos.x + 3.0, y = pos.y + 0.0, z = pos.z + 0.0, heading = heading + 0.0 }
        record.state, record.candidates, record.candidateCount = 'client_spawning', {}, 0
        record.candidateOwners = {}
        record.bindStarted = GetGameTimer()
        return Stables.Ok({ generation = record.generation, mode = record.mode,
            model = MODEL, position = Stables.Copy(record.position) })
    end
    -- RDR3 signature, not FiveM's pedType-first signature. Server RPC creation
    -- remains an experiment until observed on the target RedM artifact.
    record.state, record.creating = 'spawning', true
    local called, entity = pcall(CreatePed, GetHashKey(MODEL), pos.x + 3.0, pos.y, pos.z, heading + 0.0,
        true, true, false, false)
    if not called or type(entity) ~= 'number' or entity == 0 then
        record.creating = false
        P.Clear('create_failed')
        return Stables.Err('native_create_failed', 'RedM server CreatePed did not return an entity.', {
            native = 'CreatePed', error = not called and tostring(entity) or nil,
        })
    end
    record.entity = entity
    local started = GetGameTimer()
    while not Exists(entity) and GetGameTimer() - started < 10000 do Wait(25) end
    record.creating = false
    if not Exists(entity) then
        P.Clear('entity_timeout')
        return Stables.Err('native_entity_timeout', 'Created entity did not become visible to the server.')
    end
    record.observed = true
    -- Record identity before any subsequent yield/cancellation.
    record.netId = NetworkGetNetworkIdFromEntity(entity)
    if GetEntityModel(entity) ~= GetHashKey(MODEL) or not record.netId or record.netId <= 0 then
        P.Clear('invalid_entity')
        return Stables.Err('invalid_entity', 'Server could not validate the created horse identity.')
    end
    Entity(entity).state:set(MARKER, record.generation, true)
    record.marked = true
    if not Current(record) or GetPlayerRoutingBucket(source) ~= 0 then
        P.Clear('session_or_route_changed')
        return Stables.Err('session_stale', 'Session or route changed during spawn.')
    end
    record.state = 'active'
    ObserveOwner(record)
    return Stables.Ok({ generation = record.generation, netId = record.netId, model = MODEL })
end

function P.Created(entity)
    local record = lease
    if not record or record.state ~= 'client_spawning' or record.cancelled then return end
    if record.candidateCount >= 128 then return end -- Bound event evidence, never scan world peds.
    if not record.candidates[entity] then
        record.candidates[entity] = true
        if Exists(entity) then record.candidateOwners[entity] = NetworkGetEntityOwner(entity) end
        record.candidateCount = record.candidateCount + 1
    end
end

local function BindingFailure(record, netId, entity, code, message)
    local exists = Exists(entity)
    local observation = {
        diagnostic = 4, generation = record.generation, netId = netId,
        entityExists = exists, creationObserved = record.candidates[entity] == true,
        candidateCount = record.candidateCount, sessionCurrent = Current(record),
    }
    if exists then
        local script = GetEntityScript(entity)
        local marker = Entity(entity).state[MARKER]
        local position = GetEntityCoords(entity)
        local dx, dy, dz = position.x - record.position.x, position.y - record.position.y, position.z - record.position.z
        observation.script = script or '<none>'
        observation.scriptMatches = script == GetCurrentResourceName()
        observation.scriptAvailable = type(script) == 'string' and script ~= ''
        observation.scriptAllowed = ScriptAllowed(entity)
        observation.markerPresent, observation.markerMatches = marker ~= nil, marker == record.generation
        observation.modelMatches = GetEntityModel(entity) == GetHashKey(MODEL)
        observation.networkOwner = NetworkGetEntityOwner(entity)
        observation.ownerMatches = observation.networkOwner == record.session.source
        observation.entityBucket = GetEntityRoutingBucket(entity)
        observation.playerBucket = GetPlayerRoutingBucket(record.session.source)
        observation.distanceSquared = dx * dx + dy * dy + dz * dz
    end
    record.bindObservation = observation
    lastFailure = Stables.Err(code, message, Stables.Copy(observation))
    Log(lastFailure) -- Capture before client rejection cleanup removes the entity.
    return Stables.Copy(lastFailure)
end

function P.Bind(payload, source, context)
    local record, failure = ValidateRequest(source, context, payload.generation)
    if not record then return failure end
    if record.mode ~= 'client_lease' or record.state ~= 'client_spawning' then
        return Stables.Err('conflict', 'No client spawn is awaiting binding.')
    end
    if record.binding then return Stables.Err('conflict', 'Lease binding is already in progress.') end
    if GetGameTimer() - record.bindStarted > 15000 then P.Clear('bind_timeout'); return Stables.Err('timeout', 'Spawn binding expired.') end
    record.binding = true
    local started, entity = GetGameTimer(), 0
    repeat
        entity = NetworkGetEntityFromNetworkId(payload.netId)
        if Exists(entity) and record.candidates[entity]
            and ScriptAllowed(entity)
            and Entity(entity).state[MARKER] == record.generation then break end
        if not Current(record) or GetGameTimer() - started >= 5000 then
            record.binding = false
            return BindingFailure(record, payload.netId, entity, 'entity_not_observed',
                'New leased horse identity has not replicated to the server.')
        end
        Wait(25)
    until false
    local position = GetEntityCoords(entity)
    local dx, dy, dz = position.x - record.position.x, position.y - record.position.y, position.z - record.position.z
    if not Current(record) or GetPlayerRoutingBucket(source) ~= 0
        or GetEntityRoutingBucket(entity) ~= 0 or NetworkGetEntityOwner(entity) ~= source
        or GetEntityModel(entity) ~= GetHashKey(MODEL)
        or NetworkGetNetworkIdFromEntity(entity) ~= payload.netId or dx * dx + dy * dy + dz * dz > 25.0 then
        record.binding = false
        return BindingFailure(record, payload.netId, entity, 'invalid_entity',
            'Leased entity failed owner, model, route or position validation.')
    end
    record.entity, record.netId, record.observed, record.marked = entity, payload.netId, true, true
    -- Replace the client's correlation marker with the server's current value.
    Entity(entity).state:set(MARKER, record.generation, true)
    record.state, record.binding = 'active', false
    ObserveOwner(record)
    return Stables.Ok({ generation = record.generation, netId = record.netId, model = MODEL })
end

function P.Report(payload, source, context)
    local record, failure = ValidateRequest(source, context, payload.generation)
    if not record then return failure end
    record.client = { found = payload.found, controlled = payload.controlled, initialized = payload.initialized,
        collisionLoaded = payload.collisionLoaded, settled = payload.settled }
    return Stables.Ok({ recorded = true }) -- Client observations are not authority.
end

function P.Inspect()
    if not lease then return Stables.Ok({ state = 'empty', enabled = installed,
        lastFailure = Stables.Copy(lastFailure), lastCleanup = Stables.Copy(lastCleanup) }) end
    local record = lease
    local exists = SameEntity(record)
    local script = exists and GetEntityScript(record.entity) or nil
    return Stables.Ok({ state = record.state, generation = record.generation, source = record.session.source,
        model = MODEL, mode = record.mode, netId = record.netId, exists = exists, reason = record.reason,
        ageSeconds = math.floor((GetGameTimer() - record.started) / 1000), lifetimeSeconds = record.lifetimeMs / 1000,
        remainingSeconds = math.max(0, math.ceil((record.lifetimeMs - GetGameTimer() + record.started) / 1000)),
        ownerChanges = record.ownerChanges or 0, ownerHistory = Stables.Copy(record.ownerHistory or {}),
        sessionCurrent = Stables.Core.IsSessionCurrent(record.session),
        networkOwner = exists and NetworkGetEntityOwner(record.entity) or nil,
        entityBucket = exists and GetEntityRoutingBucket(record.entity) or nil,
        script = exists and (script or '<none>') or nil,
        scriptMetadataAvailable = type(script) == 'string' and script ~= '',
        client = Stables.Copy(record.client), bindObservation = Stables.Copy(record.bindObservation) })
end

function P.Tick()
    if not lease then return end
    if lease.cancelled then P.Clear(lease.reason)
    elseif not Current(lease) then P.Clear('session_left')
    elseif GetPlayerRoutingBucket(lease.session.source) ~= 0 then P.Clear('route_changed')
    elseif lease.state == 'client_spawning' and GetGameTimer() - lease.bindStarted > 15000 then P.Clear('bind_timeout')
    elseif GetGameTimer() - lease.started > (lease.state == 'preparing' and 15000 or lease.lifetimeMs) then P.Clear('expired')
    elseif lease.state == 'active' and not SameEntity(lease) then P.Clear('entity_missing')
    elseif lease.state == 'active' then ObserveOwner(lease) end
end

local function RoutingCall(method, ...)
    if GetResourceState('feather-routing') ~= 'started' then
        return Stables.Err('dependency_unavailable', 'Route proof requires feather-routing started.')
    end
    local args = table.pack(...)
    local ok, result = pcall(function()
        local routing = exports['feather-routing']
        return routing[method](routing, table.unpack(args, 1, args.n))
    end)
    if not ok or not Stables.IsResult(result) then
        return Stables.Err('dependency_error', 'Feather Routing operation failed.', { operation = method })
    end
    return result
end

-- Temporary console experiment; Routing owns allocation, membership and restore.
function P.RouteTest()
    local record = lease
    if routeTestRunning then return Stables.Err('busy', 'A route proof is already running.') end
    if not installed or not record or record.state ~= 'active' or not Current(record) or not SameEntity(record) then
        return Stables.Err('active_proof_required', 'Spawn and inspect an active current fixture first.')
    end
    local target = record.session.source
    if GetPlayerRoutingBucket(target) ~= 0 then return Stables.Err('foreign_route', 'Player must be in the default world.') end
    local caps = RoutingCall('GetCapabilities')
    if not caps.ok then return caps end
    local value = caps.value
    if type(value) ~= 'table' or value.contract ~= 1 or value.state ~= 'ready'
        or type(value.features) ~= 'table' or value.features.routes ~= 1
        or value.features.ownership ~= 1 or value.features.cleanup ~= 1 or value.features.opaqueHandles ~= 1 then
        return Stables.Err('invalid_contract', 'Feather Routing Contract 1 is required.')
    end
    local current = RoutingCall('GetPlayerRoute', target)
    if not current.ok then return current end
    if current.value ~= nil then return Stables.Err('foreign_route', 'Player already has managed route membership.') end
    routeTestRunning = true
    local created = RoutingCall('CreateRoute', { key = record.generation .. ':route', mode = 'strict', populationEnabled = false })
    local routeId = created.ok and type(created.value) == 'table' and created.value.routeId
    if type(routeId) ~= 'string' or routeId == '' then
        routeTestRunning = false
        return created.ok and Stables.Err('invalid_contract', 'Routing returned no route ID.') or created
    end
    local ok, result = pcall(function()
        if not Current(record) then return Stables.Err('session_stale', 'Session changed before route proof.') end
        local joined = RoutingCall('JoinRoute', routeId, target)
        if not joined.ok then return joined end
        local nativeJoined = GetPlayerRoutingBucket(target) ~= 0
        Wait(3000) -- Allow the normal one-second lifecycle monitor to observe exit.
        return Stables.Ok({ generation = record.generation, source = target, nativeJoined = nativeJoined,
            fixtureCleared = lease ~= record and lastCleanup ~= nil
                and lastCleanup.generation == record.generation and lastCleanup.reason == 'route_changed'
                and lastCleanup.outcome == 'cleared' })
    end)
    -- Always attempt restore, including failed joins or a native exception.
    local deleted = RoutingCall('DeleteRoute', routeId)
    routeTestRunning = false
    if not deleted.ok then return Stables.Err('route_cleanup_failed', 'Route deletion failed; retry route_return.', { routeId = routeId, cause = deleted.code }) end
    if not ok then return Stables.Err('native_error', 'Route proof failed; owned route was deleted.') end
    if result.ok then
        result.value.returnedToDefault = GetPlayerRoutingBucket(target) == 0
        result.value.sessionCurrent = Stables.Core.IsSessionCurrent(record.session)
    end
    return result
end

function P.SessionEvent(stage, session)
    if lease and (stage == 'leaving' or stage == 'left') and type(session) == 'table'
        and session.sessionId == lease.session.sessionId then P.Clear('session_' .. stage) end
end

function P.Stop(reason)
    local ok, result = pcall(P.Clear, reason)
    if ok and not result.ok and result.code == 'cleanup_pending' then
        print('[bcc-stables:proof] fixture deletion requested; network removal may finish after resource stop.')
    elseif not ok or not result.ok then
        print('[bcc-stables:proof] cleanup incomplete; inspect server entities before retest.')
    elseif result.value and result.value.pending then
        print('[bcc-stables:proof] spawn still in flight during stop; verify no late fixture appears.')
    end
    installed = false
end

local function Payload(payload, kind)
    if type(payload) ~= 'table' or type(payload.generation) ~= 'string' or #payload.generation > 96 then return false end
    for key in pairs(payload) do
        if key ~= 'generation' and not (kind == 'bind' and key == 'netId')
            and not (kind == 'report' and (key == 'found' or key == 'controlled' or key == 'initialized'
                or key == 'collisionLoaded' or key == 'settled')) then return false end
    end
    if kind == 'bind' then return type(payload.netId) == 'number' and payload.netId % 1 == 0 and payload.netId > 0 and payload.netId <= 65535 end
    return kind ~= 'report' or (type(payload.found) == 'boolean' and type(payload.controlled) == 'boolean'
        and type(payload.initialized) == 'boolean' and type(payload.collisionLoaded) == 'boolean' and type(payload.settled) == 'boolean')
end

function P.Install()
    if GetResourceState('feather-toolkit') ~= 'started' then
        return Stables.Err('dependency_unavailable', 'Entity proof requires feather-toolkit for bounded model loading.')
    end
    for _, spec in ipairs({ { 'stables.proof.prepared.v1', P.Prepared, 'prepared' },
        { 'stables.proof.report.v1', P.Report, 'report' }, { 'stables.proof.bind.v1', P.Bind, 'bind' } }) do
        local result = Stables.Core.Call('RegisterRpc', spec[1], spec[2], {
            contract = 1, direction = 'client_to_server', requireCharacter = true,
            windowMs = 2000, maxCalls = 2, maxPayloadBytes = 256, maxDepth = 2, maxNodes = 12,
            validatePayload = function(payload) return Payload(payload, spec[3]), 'Invalid proof payload.' end,
        })
        if not result.ok then return result end
    end
    installed = true
    RegisterCommand('BccStablesProof', function(source, args)
        if source ~= 0 then return end
        CreateThread(function()
            local ok, result = pcall(function()
                if args[1] == 'spawn' then
                    if args[3] and not tonumber(args[3]) then return Stables.Err('invalid_input', 'Lifetime must be a number of seconds.') end
                    return P.Begin(tonumber(args[2]), tonumber(args[3]))
                end
                if args[1] == 'clear' then return P.Clear('console_clear') end
                if args[1] == 'inspect' then return P.Inspect() end
                if args[1] == 'route_test' then return P.RouteTest() end
                if args[1] == 'route_return' then
                    if routeTestRunning then return Stables.Err('busy', 'Wait for the route proof to finish.') end
                    if type(args[2]) ~= 'string' or #args[2] > 256 then return Stables.Err('invalid_input', 'Use route_return <routeId> from the route cleanup failure.') end
                    return RoutingCall('DeleteRoute', args[2])
                end
                return Stables.Err('invalid_input', 'BccStablesProof spawn <source> [lifetimeSeconds] | inspect | clear | route_test | route_return <routeId>')
            end)
            Log(ok and result or Stables.Err('native_error', 'Proof native operation failed; inspect before continuing.'))
        end)
    end, true)
    AddEventHandler('playerDropped', function()
        if lease and lease.session.source == source then P.Clear('disconnect') end
    end)
    AddEventHandler('entityCreated', P.Created)
    CreateThread(function()
        while installed do
            Wait(1000)
            local ok = pcall(P.Tick)
            if not ok then print('[bcc-stables:proof] native inspection failed; console clear required.') end
        end
    end)
    return Stables.Ok({ routes = 3 })
end
