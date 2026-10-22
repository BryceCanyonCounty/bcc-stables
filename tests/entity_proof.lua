local count = 0
local function test(name, run)
    local ok, failure = pcall(run)
    assert(ok, name .. ': ' .. tostring(failure))
    count = count + 1
    print('PASS entity proof ' .. name)
end

local function fixture(mode)
    local env = setmetatable({}, { __index = _G })
    local mock = { now = 0, current = true, bucket = 0, exists = false, deleted = 0, created = 0,
        owner = 12, entityModel = 123, netId = 99, events = {}, commands = {}, routes = {}, handlers = {}, state = {} }
    env.GetGameTimer = function() return mock.now end
    env.Wait = function(ms) mock.now = mock.now + ms; if mock.onWait then mock.onWait() end end
    env.GetCurrentResourceName = function() return 'bcc-stables' end
    env.GetResourceState = function() return 'started' end
    env.GetHashKey = function(model) assert(model == 'a_c_horse_morgan_bay'); return 123 end
    env.GetPlayerPed = function() return 5 end
    env.DoesEntityExist = function(entity) return entity == 5 or entity == 42 and mock.exists end
    env.GetPlayerRoutingBucket = function() return mock.bucket end
    env.GetEntityRoutingBucket = function() return 0 end
    env.GetEntityCoords = function() return { x = 10.0, y = 20.0, z = 30.0 } end
    env.GetEntityHeading = function() return 90.0 end
    env.GetEntityModel = function() return mock.entityModel end
    env.GetEntityScript = function() return 'bcc-stables' end
    env.NetworkGetEntityFromNetworkId = function(netId) return netId == 99 and mock.exists and 42 or 0 end
    env.NetworkGetNetworkIdFromEntity = function() return mock.netId end
    env.NetworkGetEntityOwner = function() return mock.owner end
    env.Entity = function()
        return { state = setmetatable({ set = function(_, key, value) mock.state[key] = value end }, { __index = mock.state }) }
    end
    env.CreatePed = function(model, x, y, z, heading, networked, host, p7, p8)
        assert(model == 123 and x == 13.0 and y == 20.0 and z == 30.0 and heading == 90.0)
        assert(networked and host and not p7 and not p8)
        mock.created, mock.exists = mock.created + 1, true
        if mock.onCreate then mock.onCreate() end
        return 42
    end
    env.DeleteEntity = function(entity)
        assert(entity == 42)
        mock.deleted = mock.deleted + 1
        if not mock.delayDelete then mock.exists = false end
    end
    env.TriggerClientEvent = function(name, target, payload)
        mock.events[#mock.events + 1] = { name = name, target = target, payload = payload }
    end
    env.RegisterCommand = function(name, callback) mock.commands[name] = callback end
    env.AddEventHandler = function(name, callback) mock.handlers[name] = callback end
    env.CreateThread = function() end -- Do not start the periodic scheduler in offline tests.
    env.json = { encode = function() return '{}' end }
    assert(loadfile('config.lua', 't', env))()
    assert(loadfile('shared/contracts.lua', 't', env))()
    env.StablesConfig.entityProof.enabled = true
    env.StablesConfig.entityProof.spawnMode = mode or 'server_rpc'
    local s = env.Stables
    mock.session = { source = 12, sessionId = 's1', characterId = 'c1', accountId = 'a1', state = 'ready' }
    s.Core = {
        IsSessionCurrent = function(session) return mock.current and session.sessionId == mock.session.sessionId end,
        RequireSession = function(source)
            return source == 12 and s.Ok(s.Copy(mock.session)) or s.Err('character_required', 'No character.')
        end,
        Call = function(method, name, callback, options)
            assert(method == 'RegisterRpc')
            mock.routes[name] = { callback = callback, options = options }
            return s.Ok({})
        end,
    }
    s.Foundation = { RequireReady = function() return s.Ok(true) end,
        CheckSession = function(source, context)
            if source ~= 12 or not context or context.sessionId ~= mock.session.sessionId then
                return s.Err('session_stale', 'Stale session.')
            end
            return s.Ok(true)
        end }
    assert(loadfile('server/entity_proof.lua', 't', env))()
    mock.env, mock.proof = env, s.Proof
    assert(mock.proof.Install().ok)
    mock.begin = function()
        local result = mock.proof.Begin(12)
        assert(result.ok)
        return result.value.generation
    end
    mock.spawn = function(generation)
        return mock.proof.Prepared({ generation = generation or mock.begin() }, 12, mock.session)
    end
    return mock
end

test('console lease prepares and creates only the configured model', function()
    local m = fixture()
    local result = m.spawn()
    assert(result.ok and result.value.netId == 99 and m.created == 1)
    assert(m.proof.Inspect().value.exists)
    assert(m.proof.Begin(12).code == 'busy')
    local copy = m.proof.Inspect().value
    copy.generation = 'other'
    assert(m.proof.Inspect().value.generation ~= 'other')
end)

test('no character or foreign route cannot start', function()
    local m = fixture()
    assert(m.proof.Begin(13).code == 'character_required')
    m.bucket = 10
    assert(m.proof.Begin(12).code == 'foreign_route')
    assert(m.created == 0 and #m.events == 0)
end)

test('stale generation and wrong source cannot create', function()
    local m = fixture()
    local generation = m.begin()
    assert(m.proof.Prepared({ generation = 'old' }, 12, m.session).code == 'stale_proof')
    assert(m.proof.Prepared({ generation = generation }, 13, m.session).code == 'session_stale')
    assert(m.created == 0)
end)

test('repeated prepared request cannot duplicate entity', function()
    local m = fixture()
    local generation = m.begin()
    assert(m.spawn(generation).ok)
    assert(m.spawn(generation).code == 'conflict' and m.created == 1)
end)

test('logout cancels matching lease and cleans entity once', function()
    local m = fixture()
    assert(m.spawn().ok)
    m.proof.SessionEvent('leaving', { sessionId = 'other' })
    assert(m.deleted == 0)
    m.proof.SessionEvent('leaving', m.session)
    m.proof.SessionEvent('left', m.session)
    assert(m.deleted == 1 and m.proof.Inspect().value.state == 'empty')
end)

test('session lost during create removes late entity', function()
    local m = fixture()
    m.onCreate = function() m.current = false; m.proof.SessionEvent('leaving', m.session) end
    assert(m.spawn().code == 'session_stale')
    assert(m.deleted == 1 and m.proof.Inspect().value.state == 'empty')
end)

test('delete pending reserves slot until disappearance', function()
    local m = fixture()
    assert(m.spawn().ok)
    m.delayDelete = true
    assert(m.proof.Clear().code == 'cleanup_pending')
    assert(m.proof.Begin(12).code == 'busy')
    m.exists = false
    m.proof.Tick()
    assert(m.proof.Inspect().value.state == 'empty')
end)

test('stop requests asynchronous deletion without falsely clearing a live fixture', function()
    local m = fixture()
    assert(m.spawn().ok)
    m.delayDelete = true
    m.proof.Stop('resource_stopping')
    assert(m.deleted == 1 and m.exists)
    assert(m.proof.Inspect().value.state == 'cleanup_pending')
    assert(m.proof.Begin(12).code == 'disabled')
    m.exists = false
    m.proof.Tick()
    assert(m.proof.Inspect().value.state == 'empty')
end)

test('reused network identity is never deleted', function()
    local m = fixture()
    assert(m.spawn().ok)
    m.netId = 100
    assert(m.proof.Clear().code == 'entity_identity_lost' and m.deleted == 0)
end)

test('changed marker is never deleted', function()
    local m = fixture()
    assert(m.spawn().ok)
    m.state.bccStablesProof = 'another-fixture'
    assert(m.proof.Clear().code == 'entity_identity_lost' and m.deleted == 0)
end)

test('lease expiry and route change clean fixtures', function()
    local m = fixture()
    m.begin()
    m.now = 15001
    m.proof.Tick()
    assert(m.proof.Inspect().value.state == 'empty')
    assert(m.spawn().ok)
    m.bucket = 10
    m.proof.Tick()
    assert(m.deleted == 1)
end)

test('migration owner is observed without transferring character authority', function()
    local m = fixture()
    assert(m.spawn().ok)
    m.owner = 25
    assert(m.proof.Inspect().value.networkOwner == 25)
    assert(m.proof.Inspect().value.source == 12)
    m.proof.Stop('test_stop')
    assert(m.deleted == 1 and m.proof.Begin(12).code == 'disabled')
end)

test('report validators bound observations and reject arbitrary entity IDs', function()
    local m = fixture()
    local validator = m.routes['stables.proof.prepared.v1'].options.validatePayload
    assert(validator({ generation = 'proof' }))
    assert(not validator({ generation = 'proof', netId = 300 }))
    assert(not validator({ generation = string.rep('x', 97) }))
    local report = m.routes['stables.proof.report.v1'].options.validatePayload
    assert(report({ generation = 'proof', found = true, controlled = false, initialized = false, collisionLoaded = false, settled = false }))
    assert(not report({ generation = 'proof', found = 'yes', controlled = true, initialized = true }))
end)

test('unobserved native spawn remains reserved for late cleanup', function()
    local m = fixture()
    m.env.CreatePed = function() return 42 end
    assert(m.spawn().code == 'native_entity_timeout')
    assert(m.now == 10000 and m.proof.Begin(12).code == 'busy')
    m.exists = true
    m.proof.Tick()
    assert(m.deleted == 1 and m.proof.Inspect().value.state == 'empty')
end)

local function clientFixture()
    local m = fixture('client_lease')
    m.generation = m.begin()
    local prepared = m.spawn(m.generation)
    assert(prepared.ok and prepared.value.mode == 'client_lease' and m.created == 0)
    m.exists = true
    m.state.bccStablesProof = m.generation
    m.bind = function() return m.proof.Bind({ generation = m.generation, netId = 99 }, 12, m.session) end
    return m
end

test('client lease accepts newly observed script-owned horse only once', function()
    local m = clientFixture()
    m.proof.Created(42)
    assert(m.bind().ok and m.created == 0)
    assert(m.proof.Inspect().value.mode == 'client_lease')
    assert(m.bind().code == 'conflict')
    assert(m.proof.Clear().ok and m.deleted == 1)
end)

test('preexisting entity cannot be bound without creation evidence', function()
    local m = clientFixture()
    local result = m.bind()
    assert(result.code == 'entity_not_observed' and m.now == 5000)
    assert(result.details.entityExists and not result.details.creationObserved and result.details.scriptMatches)
    assert(result.details.markerMatches and result.details.modelMatches and result.details.ownerMatches)
    assert(m.deleted == 0)
end)

test('binding snapshot survives automatic lease cleanup', function()
    local m = clientFixture()
    assert(m.bind().code == 'entity_not_observed')
    m.exists = false
    m.proof.Clear('test_clear')
    local inspection = m.proof.Inspect().value
    assert(inspection.state == 'empty' and inspection.lastFailure.details.diagnostic == 4)
    inspection.lastFailure.details.scriptMatches = false
    assert(m.proof.Inspect().value.lastFailure.details.scriptMatches)
end)

test('diagnostic distinguishes missing entity from missing metadata', function()
    local m = clientFixture(); m.exists = false
    local missing = m.bind()
    assert(not missing.details.entityExists and missing.details.script == nil)
    m.exists = true; m.proof.Created(42)
    m.env.GetEntityScript = function() return nil end
    m.state.bccStablesProof = 'not-the-current-lease'
    local metadata = m.bind()
    assert(metadata.details.entityExists and metadata.details.creationObserved)
    assert(metadata.details.script == '<none>' and not metadata.details.scriptMatches)
    assert(metadata.details.scriptAllowed and not metadata.details.scriptAvailable)
end)

test('absent script metadata accepts only a fully valid new lease', function()
    for _, empty in ipairs({ false, true }) do
        local m = clientFixture(); m.proof.Created(42)
        m.env.GetEntityScript = function() if empty then return '' end end
        assert(m.bind().ok)
        assert(not m.proof.Inspect().value.scriptMetadataAvailable)
    end
end)

test('absent script metadata does not bypass owner or creation evidence', function()
    local m = clientFixture()
    m.env.GetEntityScript = function() return nil end
    assert(m.bind().code == 'entity_not_observed')
    m.proof.Created(42); m.owner = 25
    assert(m.bind().code == 'invalid_entity')
end)

test('missing script cleanup uses recorded creation owner after disconnect', function()
    local m = clientFixture(); m.proof.Created(42)
    m.env.GetEntityScript = function() return nil end
    m.owner = -1
    m.proof.SessionEvent('leaving', m.session)
    assert(m.deleted == 1 and m.proof.Inspect().value.state == 'empty')
end)

test('numeric native booleans preserve successful bind and deletion confirmation', function()
    local m = clientFixture()
    m.env.DoesEntityExist = function(entity) return (entity == 5 or entity == 42 and m.exists) and 1 or 0 end
    m.proof.Created(42)
    m.env.GetEntityScript = function() return nil end
    assert(m.bind().ok and m.proof.Inspect().value.exists == true)
    assert(m.proof.Clear().ok and not m.exists)
    assert(m.proof.Inspect().value.state == 'empty')
end)

test('foreign script and marker are never accepted', function()
    local m = clientFixture(); m.proof.Created(42)
    m.env.GetEntityScript = function() return 'another-resource' end
    assert(m.bind().code == 'entity_not_observed')
    m.env.GetEntityScript = function() return 'bcc-stables' end
    m.state.bccStablesProof = 'old-generation'
    assert(m.bind().code == 'entity_not_observed' and m.deleted == 0)
end)

test('wrong model owner bucket or distant horse cannot bind', function()
    for _, invalid in ipairs({ 'model', 'owner', 'bucket', 'position' }) do
        local m = clientFixture(); m.proof.Created(42)
        if invalid == 'model' then m.entityModel = 999 end
        if invalid == 'owner' then m.owner = 25 end
        if invalid == 'bucket' then m.bucket = 1 end
        if invalid == 'position' then m.env.GetEntityCoords = function() return { x = 100.0, y = 200.0, z = 300.0 } end end
        assert(m.bind().code == 'invalid_entity', invalid)
    end
end)

test('unbound newly created fixture is recovered for cleanup on logout', function()
    local m = clientFixture(); m.proof.Created(42)
    m.proof.SessionEvent('leaving', m.session)
    assert(m.deleted == 1 and m.proof.Inspect().value.state == 'empty')
end)

test('client binding payload permits only generation and bounded network ID', function()
    local m = fixture('client_lease')
    local validator = m.routes['stables.proof.bind.v1'].options.validatePayload
    assert(validator({ generation = 'proof', netId = 99 }))
    assert(not validator({ generation = 'proof', netId = -1 }))
    assert(not validator({ generation = 'proof', netId = 65536 }))
    assert(not validator({ generation = 'proof', netId = 99, model = 'other' }))
end)

test('optional longer proof lifetime is explicit and expires at its own deadline', function()
    local m = fixture()
    local prepared = m.proof.Begin(12, 600)
    assert(prepared.ok and prepared.value.lifetimeSeconds == 600)
    assert(m.spawn(prepared.value.generation).ok)
    m.now = 300001; m.proof.Tick()
    local active = m.proof.Inspect().value
    assert(active.state == 'active' and active.lifetimeSeconds == 600 and active.remainingSeconds == 300)
    m.now = 600001; m.proof.Tick()
    local cleanup = m.proof.Inspect().value.lastCleanup
    assert(cleanup.reason == 'expired' and cleanup.ageSeconds == 600 and cleanup.lifetimeSeconds == 600)
end)

test('invalid optional lifetime cannot authorize a fixture', function()
    local m = fixture()
    for _, value in ipairs({ 59, 901, -1, 60.5, '600', false, math.huge, 0/0 }) do
        assert(m.proof.Begin(12, value).code == 'invalid_input')
    end
    assert(#m.events == 0 and m.created == 0)
end)

test('owner changes are recorded once without changing the character lease', function()
    local m = fixture(); assert(m.spawn().ok)
    assert(#m.proof.Inspect().value.ownerHistory == 1)
    m.owner = 25; m.now = 1000; m.proof.Tick(); m.proof.Tick()
    local active = m.proof.Inspect().value
    assert(active.source == 12 and active.networkOwner == 25 and active.ownerChanges == 1)
    assert(#active.ownerHistory == 2 and active.ownerHistory[2].ageSeconds == 1)
    for i = 1, 40 do m.owner = 100 + i; m.proof.Tick() end
    assert(#m.proof.Inspect().value.ownerHistory == 16)
end)

test('unexpected disappearance retains a detached terminal reason', function()
    local m = fixture(); assert(m.spawn().ok)
    m.exists = false; m.now = 1000; m.proof.Tick()
    local inspection = m.proof.Inspect().value
    assert(inspection.state == 'empty' and inspection.lastCleanup.reason == 'entity_missing')
    assert(inspection.lastCleanup.lastNetworkOwner == 12 and inspection.lastCleanup.ageSeconds == 1)
    inspection.lastCleanup.reason = 'changed'
    assert(m.proof.Inspect().value.lastCleanup.reason == 'entity_missing')
end)

test('repeated cleanup requests preserve the original reason while waiting', function()
    local m = fixture(); assert(m.spawn().ok)
    m.delayDelete = true
    assert(m.proof.Clear('expired').code == 'cleanup_pending')
    assert(m.proof.Clear('console_clear').code == 'cleanup_pending')
    m.exists = false; m.proof.Tick()
    assert(m.proof.Inspect().value.lastCleanup.reason == 'expired')
end)

local function routingFixture()
    local m = fixture(); assert(m.spawn().ok)
    m.routingCalls = {}
    m.env.exports = { ['feather-routing'] = setmetatable({}, { __index = function(_, method)
        return function(_, ...)
            m.routingCalls[#m.routingCalls + 1] = method
            if m.routingFailure == method then return m.env.Stables.Err('conflict', 'Injected failure.') end
            if method == 'GetCapabilities' then return m.env.Stables.Ok({ contract = m.routingContract or 1,
                state = 'ready', features = { routes = 1, ownership = 1, cleanup = 1, opaqueHandles = 1 } }) end
            if method == 'GetPlayerRoute' then return m.env.Stables.Ok(m.managedRoute) end
            if method == 'CreateRoute' then
                local spec = ...
                assert(spec.mode == 'strict' and spec.populationEnabled == false)
                return m.env.Stables.Ok({ routeId = 'opaque-route' })
            end
            if method == 'JoinRoute' then
                local route, target = ...; assert(route == 'opaque-route' and target == 12)
                m.bucket = 55
            end
            if method == 'DeleteRoute' then
                assert((...) == 'opaque-route'); m.bucket = 0; m.routeDeleted = true
            end
            return m.env.Stables.Ok({})
        end
    end }) }
    m.onWait = function() m.proof.Tick() end
    return m
end

test('route proof uses owned Routing APIs and observes normal lifecycle cleanup', function()
    local m = routingFixture()
    local result = m.proof.RouteTest()
    assert(result.ok and result.value.nativeJoined and result.value.fixtureCleared)
    assert(result.value.returnedToDefault and result.value.sessionCurrent)
    assert(m.bucket == 0 and m.routeDeleted and m.proof.Inspect().value.lastCleanup.reason == 'route_changed')
end)

test('route proof refuses unavailable dependency invalid contract and managed membership', function()
    local m = routingFixture()
    m.env.GetResourceState = function() return 'stopped' end
    assert(m.proof.RouteTest().code == 'dependency_unavailable' and #m.routingCalls == 0)
    m.env.GetResourceState = function() return 'started' end
    m.routingContract = 2
    assert(m.proof.RouteTest().code == 'invalid_contract')
    m.routingContract = 1; m.managedRoute = { routeId = 'another' }
    assert(m.proof.RouteTest().code == 'foreign_route' and m.bucket == 0 and not m.routeDeleted)
end)

test('route proof restores owned route after join refusal or native exception', function()
    for _, failure in ipairs({ 'join', 'native' }) do
        local m = routingFixture()
        if failure == 'join' then m.routingFailure = 'JoinRoute'
        else m.onWait = function() error('native exception') end end
        assert(not m.proof.RouteTest().ok)
        assert(m.routeDeleted and m.bucket == 0)
    end
end)

test('route proof reports pending fixture deletion without claiming cleanup', function()
    local m = routingFixture(); m.delayDelete = true
    local result = m.proof.RouteTest()
    assert(result.ok and not result.value.fixtureCleared and m.bucket == 0)
    assert(m.proof.Inspect().value.state == 'cleanup_pending')
    m.exists = false; m.proof.Tick()
    assert(m.proof.Inspect().value.lastCleanup.reason == 'route_changed')
end)

test('route proof retains restoration diagnostics if route deletion fails', function()
    local m = routingFixture(); m.routingFailure = 'DeleteRoute'
    local result = m.proof.RouteTest()
    assert(result.code == 'route_cleanup_failed' and result.details.routeId == 'opaque-route')
    assert(m.bucket == 55)
end)

assert(loadfile('client/entity_proof.lua', 't', {}))
print(('%d/%d entity proof cases passed; client proof parses under Lua 5.4.'):format(count, count))
