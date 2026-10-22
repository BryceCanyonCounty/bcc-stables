local function fixture(mode)
    local env = setmetatable({}, { __index = _G })
    local m = { now = 0, handlers = {}, commands = {}, output = {}, initialized = 0, deleted = 0, released = 0, rpc = {},
        marker = 'g1', exists = true, control = true, loads = 0 }
    env.source = 65535
    env.RegisterNetEvent = function(name, callback) m.handlers[name] = callback end
    env.RegisterCommand = function(name, callback) m.commands[name] = callback end
    env.print = function(message) m.output[#m.output + 1] = message end
    env.AddEventHandler = function(name, callback) m.handlers[name] = callback end
    env.CreateThread = function(callback) callback() end
    env.GetCurrentResourceName = function() return 'bcc-stables' end
    env.GetResourceState = function() return 'started' end
    env.GetGameTimer = function() return m.now end
    env.Wait = function(ms) m.now = m.now + ms end
    env.GetEntityCoords = function() return { x = 13.0, y = 20.0, z = 30.0 } end
    env.RequestCollisionAtCoord = function() m.collisionRequested = true end
    env.HasCollisionLoadedAroundEntity = function() return not m.noCollision end
    env.ClearPedTasksImmediately = function() m.tasksCleared = true end
    env.TaskStandStill = function() m.standingTask = true end
    env.IsEntityInAir = function() return m.airborne or m.now < (m.airUntil or 0) end
    env.IsPedFalling = function() return false end
    env.DoesEntityExist = function(entity) return entity == 42 and m.exists end
    env.NetworkGetEntityFromNetworkId = function(netId) assert(netId == 99); return 42 end
    env.NetworkGetNetworkIdFromEntity = function(entity) assert(entity == 42); return 99 end
    env.GetEntityModel = function() return 123 end
    env.NetworkHasControlOfEntity = function() return m.control end
    env.Entity = function() return { state = { bccStablesProof = m.marker,
        set = function(_, _, generation) m.marker = generation end } } end
    env.CreatePed = function(hash, x, y, z, heading, networked, host)
        assert(hash == 123 and x == 13.0 and y == 20.0 and z == 30.0 and heading == 90.0)
        assert(networked and host)
        m.created = (m.created or 0) + 1
        return 42
    end
    env.SetEntityAsMissionEntity = function() end
    env.NetworkGetEntityIsNetworked = function() return true end
    env.SetModelAsNoLongerNeeded = function(hash) assert(hash == 123); m.released = m.released + 1 end
    env.DeleteEntity = function() m.deleted = m.deleted + 1; m.exists = false end
    env.SetEntityVisible = function(_, visible) m.visible = visible end
    env.SetEntityInvincible = function() end
    env.SetBlockingOfNonTemporaryEvents = function() end
    env.FreezeEntityPosition = function(_, frozen)
        m.frozen = frozen
        if frozen and m.grounded then m.finalFreezeAt = m.now end
    end
    env.Citizen = { InvokeNative = function(hash, entity, enabled)
        assert(entity == 42 and enabled)
        if hash == 0x283978A15512B2FE then m.initialized = m.initialized + 1
        else assert(hash == 0x9587913B9E772D29); m.grounded = true end
    end }
    env.exports = {
        ['feather-toolkit'] = {
            GetCapabilities = function() return { ok = true, value = { contract = 1, features = { models = 1 } } } end,
            LoadModel = function(_, model, timeout)
                assert(model == 'a_c_horse_morgan_bay' and timeout == 5000)
                m.loads = m.loads + 1
                if m.cancelOnLoad then m.handlers['bcc-stables:proof:cancel']('g1') end
                return { ok = true, value = { hash = 123 } }
            end,
        },
        ['feather-core'] = { CallRPC = function(_, route, payload, callback, source, timeout)
            assert(source == nil and timeout == 15000 and payload.generation == 'g1')
            m.rpc[#m.rpc + 1] = { route = route, payload = payload }
            if m.rpcOverride then m.rpcOverride(route, payload, callback); return end
            if m.noCallback then return end
            if route == 'stables.proof.prepared.v1' then
                callback({ ok = true, value = mode == 'client_lease' and { mode = mode,
                    position = { x = 13.0, y = 20.0, z = 30.0, heading = 90.0 } } or { netId = 99 } })
            elseif route == 'stables.proof.bind.v1' then
                assert(payload.netId == 99)
                callback(m.rejectBind and { ok = false, code = 'invalid_entity' } or { ok = true, value = { netId = 99 } })
            else assert(route == 'stables.proof.report.v1'); callback({ ok = true }) end
        end },
    }
    assert(loadfile('client/entity_proof.lua', 't', env))()
    m.env = env
    m.spawn = function() m.handlers['bcc-stables:proof:prepare']({ generation = 'g1', model = 'a_c_horse_morgan_bay' }) end
    return m
end

local function test(name, body)
    body()
    print('PASS client entity proof ' .. name)
end
test('model preparation initializes known fixture and reports via callback', function()
    local m = fixture(); m.spawn()
    assert(m.initialized == 1 and m.released == 1 and #m.rpc == 2)
    assert(m.rpc[2].payload.found and m.rpc[2].payload.controlled and m.rpc[2].payload.initialized)
end)
test('local forged prepare event cannot create a fixture', function()
    local m = fixture(); m.env.source = 0; m.spawn()
    assert(m.loads == 0 and #m.rpc == 0)
end)
test('cancel deletes only matching known fixture', function()
    local m = fixture(); m.spawn()
    m.handlers['bcc-stables:proof:cancel']('old-generation')
    assert(m.deleted == 0)
    m.handlers['bcc-stables:proof:cancel']('g1')
    assert(m.deleted == 1 and m.released == 1)
end)
test('changed entity marker prevents accidental client deletion', function()
    local m = fixture(); m.spawn(); m.marker = 'different'
    m.handlers.onResourceStop('bcc-stables')
    assert(m.deleted == 0)
end)
test('cancellation while loading releases model and skips server spawn', function()
    local m = fixture(); m.cancelOnLoad = true; m.spawn()
    assert(m.released == 1 and #m.rpc == 0 and m.initialized == 0)
end)
test('missing callback times out and releases model', function()
    local m = fixture(); m.noCallback = true; m.spawn()
    assert(m.now == 16000 and m.released == 1 and m.initialized == 0)
end)
test('client mode creates only after server descriptor and binds before reporting', function()
    local m = fixture('client_lease'); m.spawn()
    assert(m.created == 1 and #m.rpc == 3 and m.rpc[2].route == 'stables.proof.bind.v1')
    assert(m.initialized == 1)
end)
test('binding rejection deletes the locally created horse', function()
    local m = fixture('client_lease'); m.rejectBind = true; m.spawn()
    assert(m.created == 1 and m.deleted == 1 and m.initialized == 0)
end)
test('numeric native true is reported as a boolean true', function()
    local m = fixture('client_lease')
    m.env.DoesEntityExist = function(entity) return entity == 42 and m.exists and 1 or 0 end
    m.env.NetworkGetEntityIsNetworked = function() return 1 end
    m.control = 1
    m.spawn()
    assert(m.initialized == 1 and m.rpc[3].payload.found == true and m.rpc[3].payload.controlled == true)
end)
test('numeric native false cannot initialize or delete an uncontrolled fixture', function()
    local m = fixture('client_lease'); m.control = 0; m.spawn()
    assert(m.initialized == 0 and m.rpc[3].payload.controlled == false)
    m.handlers['bcc-stables:proof:cancel']('g1')
    assert(m.deleted == 0)
end)
test('grounding and idle settling precede final freeze and reveal', function()
    local m = fixture('client_lease'); m.airUntil = 1000; m.spawn()
    assert(m.collisionRequested and m.tasksCleared and m.standingTask and m.grounded)
    assert(m.finalFreezeAt >= 1750 and m.visible and m.frozen)
    assert(m.rpc[3].payload.initialized and m.rpc[3].payload.settled and m.rpc[3].payload.collisionLoaded)
end)
test('collision timeout never reports successful initialization', function()
    local m = fixture('client_lease'); m.noCollision = true; m.spawn()
    assert(m.now == 5000 and not m.grounded and not m.visible)
    assert(not m.rpc[3].payload.initialized and not m.rpc[3].payload.collisionLoaded)
end)
test('airborne fixture is not frozen or revealed as settled', function()
    local m = fixture('client_lease'); m.airborne = true; m.spawn()
    assert(m.now == 3000 and not m.visible and not m.frozen)
    assert(not m.rpc[3].payload.initialized and not m.rpc[3].payload.settled)
end)
test('cancel while settling does not reveal or re-freeze deleted horse', function()
    local m = fixture('client_lease')
    m.env.Wait = function(ms)
        m.now = m.now + ms
        m.handlers['bcc-stables:proof:cancel']('g1')
    end
    m.spawn()
    assert(m.deleted == 1 and not m.visible and m.finalFreezeAt == nil)
    assert(#m.rpc == 2) -- No stale completion report after cancellation.
end)
test('duplicate diagnostic replays existing identity without creating or deleting a horse', function()
    local m = fixture('client_lease'); m.spawn()
    m.rpcOverride = function(_, _, callback) callback({ ok = false, code = 'conflict' }) end
    m.commands.BccStablesProofReplay(0, { 'duplicate' })
    assert(m.created == 1 and m.deleted == 0 and #m.rpc == 5)
    assert(m.rpc[4].route == 'stables.proof.prepared.v1' and m.rpc[5].payload.netId == 99)
    assert(m.output[#m.output]:find('PASS', 1, true))
end)

test('retired fixture diagnostic survives cancellation and replays only old identity', function()
    local m = fixture('client_lease'); m.spawn()
    m.handlers['bcc-stables:proof:cancel']('g1')
    m.rpcOverride = function(_, _, callback) callback(nil, { code = 'stale_proof' }) end
    m.commands.BccStablesProofReplay(0, { 'stale' })
    assert(m.created == 1 and m.deleted == 1 and #m.rpc == 5)
    assert(m.output[#m.output]:find('PASS', 1, true))
end)

test('replay requires recorded fixture and unexpected success cannot initialize an entity', function()
    local m = fixture('client_lease')
    m.commands.BccStablesProofReplay(0, { 'stale' })
    m.commands.BccStablesProofReplay(0, { 'duplicate' })
    assert(#m.rpc == 0)
    m.spawn()
    m.rpcOverride = function(_, _, callback) callback({ ok = true, value = {} }) end
    m.commands.BccStablesProofReplay(0, { 'duplicate' })
    assert(m.created == 1 and m.initialized == 1 and m.deleted == 0)
    assert(m.output[#m.output]:find('FAIL', 1, true))
end)

test('armed bind pause cancels unfinished spawn without a bind or completion report', function()
    local m = fixture('client_lease')
    m.commands.BccStablesProofHold(0, {})
    m.env.Wait = function(ms)
        m.now = m.now + ms
        if ms == 10000 then m.handlers['bcc-stables:proof:cancel']('g1') end
    end
    m.spawn()
    assert(m.created == 1 and m.deleted == 1 and m.initialized == 0 and #m.rpc == 1)
    assert(m.released == 1)
end)

test('bind pause is one-use and normal binding resumes if no cancellation occurs', function()
    local m = fixture('client_lease')
    m.commands.BccStablesProofHold(0, {}); m.spawn()
    assert(m.now >= 10000 and m.initialized == 1)
    m.handlers['bcc-stables:proof:cancel']('g1'); m.exists = true
    local before = m.now; m.spawn()
    assert(m.now - before < 10000 and m.initialized == 2)
end)

test('bind pause can be disarmed before spawn', function()
    local m = fixture('client_lease')
    m.commands.BccStablesProofHold(0, {}); m.commands.BccStablesProofHold(0, { 'cancel' })
    m.spawn()
    assert(m.now < 10000 and m.initialized == 1)
end)

print('20/20 client entity proof cases passed.')
