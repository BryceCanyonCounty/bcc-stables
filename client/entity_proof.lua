-- Receives a console-authorized fixture request. No player spawn command exists.
local active
local retired, replayRunning
local holdNextBind = false

local function Rpc(name, payload)
    local response, done = nil, false
    exports['feather-core']:CallRPC(name, payload, function(result, failure)
        if done then return end
        response, done = result or { ok = false, code = type(failure) == 'table' and failure.code or 'transport_error' }, true
    end, nil, 15000)
    local started = GetGameTimer()
    while not done and GetGameTimer() - started < 16000 do Wait(25) end
    done = true
    return response or { ok = false, code = 'timeout' }
end

local function Yes(value)
    return value == true or value == 1
end

local function Exists(entity)
    return entity ~= nil and entity ~= 0 and Yes(DoesEntityExist(entity))
end

local function StillControlled(record)
    return not record.cancelled and Exists(record.entity)
        and GetEntityModel(record.entity) == record.hash
        and NetworkGetNetworkIdFromEntity(record.entity) == record.netId
        and Yes(NetworkHasControlOfEntity(record.entity))
end

local function Initialize(record)
    local horse = record.entity
    SetEntityVisible(horse, false)
    FreezeEntityPosition(horse, true)
    SetEntityInvincible(horse, true)
    SetBlockingOfNonTemporaryEvents(horse, true)
    Citizen.InvokeNative(0x283978A15512B2FE, horse, true) -- Random outfit variation.

    local position = GetEntityCoords(horse)
    local started, collision = GetGameTimer(), false
    while StillControlled(record) and GetGameTimer() - started < 5000 do
        RequestCollisionAtCoord(position.x, position.y, position.z)
        collision = Yes(HasCollisionLoadedAroundEntity(horse))
        if collision then break end
        Wait(25)
    end
    if not collision or not StillControlled(record) then return false, collision, false end

    FreezeEntityPosition(horse, false)
    ClearPedTasksImmediately(horse, false, false)
    -- Same RDR3 grounding native used by BCC Horses and Character arrival.
    Citizen.InvokeNative(0x9587913B9E772D29, horse, true)
    TaskStandStill(horse, 2000)

    -- Allow the physics/animation pose to settle before freezing the fixture.
    -- A freeze immediately after creation can retain a visible mid-air pose.
    started = GetGameTimer()
    local stableSince
    while StillControlled(record) and GetGameTimer() - started < 3000 do
        if not Yes(IsEntityInAir(horse)) and not Yes(IsPedFalling(horse)) then
            stableSince = stableSince or GetGameTimer()
            if GetGameTimer() - stableSince >= 750 then
                FreezeEntityPosition(horse, true)
                SetEntityVisible(horse, true)
                return true, true, true
            end
        else stableSince = nil end
        Wait(50)
    end
    -- Do not re-freeze/reveal an unsettled horse as a successful fixture.
    return false, true, false
end

local function Release(record)
    record.cancelled = true
    if record.netId then retired = { generation = record.generation, netId = record.netId } end
    if record.hash then SetModelAsNoLongerNeeded(record.hash); record.hash = nil end
    -- Server owns deletion. On client stop, delete only our recorded fixture if
    -- its network identity still matches and this client currently controls it.
    if Exists(record.entity) and (NetworkGetNetworkIdFromEntity(record.entity) == record.netId
        or record.createdLocally and record.netId == nil)
        and Entity(record.entity).state.bccStablesProof == record.generation
        and Yes(NetworkHasControlOfEntity(record.entity)) then
        DeleteEntity(record.entity)
    end
    if active == record then active = nil end
end

RegisterNetEvent('bcc-stables:proof:cancel', function(generation)
    if source ~= 65535 then return end
    if active and active.generation == generation then Release(active) end
end)

RegisterNetEvent('bcc-stables:proof:prepare', function(spec)
    if source ~= 65535 or type(spec) ~= 'table' or type(spec.generation) ~= 'string'
        or spec.model ~= 'a_c_horse_morgan_bay' then return end
    if active then
        print('[bcc-stables:proof] client busy; clear the previous fixture before retrying.')
        return
    end
    local record = { generation = spec.generation, holdBind = holdNextBind }
    holdNextBind = false
    active = record
    CreateThread(function()
        local ok, failure = pcall(function()
            if GetResourceState('feather-toolkit') ~= 'started' then error('feather-toolkit unavailable') end
            local caps = exports['feather-toolkit']:GetCapabilities()
            if type(caps) ~= 'table' or not caps.ok or type(caps.value) ~= 'table'
                or caps.value.contract ~= 1 or type(caps.value.features) ~= 'table' or caps.value.features.models ~= 1 then
                error('Toolkit model contract unavailable')
            end
            local loaded = exports['feather-toolkit']:LoadModel(spec.model, 5000)
            if type(loaded) ~= 'table' or not loaded.ok or type(loaded.value) ~= 'table' then error('Horse model failed to load') end
            record.hash = loaded.value.hash
            if record.cancelled then SetModelAsNoLongerNeeded(record.hash); record.hash = nil; return end
            local result = Rpc('stables.proof.prepared.v1', { generation = record.generation })
            if type(result) ~= 'table' or not result.ok then
                error('Server spawn rejected: ' .. tostring(type(result) == 'table' and result.code or 'invalid_result'))
            end
            if record.cancelled then return end
            if result.value.mode == 'client_lease' then
                local position = result.value.position
                record.entity = CreatePed(record.hash, position.x + 0.0, position.y + 0.0, position.z + 0.0,
                    position.heading + 0.0, true, true, false, false)
                if not Exists(record.entity) then error('Client CreatePed failed') end
                record.createdLocally = true
                SetEntityVisible(record.entity, false)
                FreezeEntityPosition(record.entity, true)
                SetEntityAsMissionEntity(record.entity, true, true)
                Entity(record.entity).state:set('bccStablesProof', record.generation, true)
                if not Yes(NetworkGetEntityIsNetworked(record.entity)) then NetworkRegisterEntityAsNetworked(record.entity) end
                local started = GetGameTimer()
                repeat
                    if record.cancelled then return end
                    local id = NetworkGetNetworkIdFromEntity(record.entity)
                    if id and id > 0 then record.netId = id; break end
                    if GetGameTimer() - started >= 5000 then error('Client horse did not obtain a network ID') end
                    Wait(25)
                until false
                if record.holdBind then
                    print('[bcc-stables:proof] binding paused for 10 seconds; log out to character selection now.')
                    Wait(10000)
                    if record.cancelled then
                        print('[bcc-stables:proof] paused spawn cancelled; no bind or report sent.')
                        return
                    end
                end
                local bound = Rpc('stables.proof.bind.v1', { generation = record.generation, netId = record.netId })
                if not bound.ok then
                    if type(bound.details) == 'table' then
                        print('[bcc-stables:proof] bind diagnostic: ' .. json.encode(bound.details))
                    end
                    error('Server lease binding rejected: ' .. tostring(bound.code))
                end
                if record.cancelled then return end
                result = bound
            end
            record.netId = result.value.netId
            local started = GetGameTimer()
            while not record.cancelled and GetGameTimer() - started < 8000 do
                local entity = NetworkGetEntityFromNetworkId(record.netId)
                if Exists(entity) then record.entity = entity; break end
                Wait(25)
            end
            if record.cancelled then return end
            local found = Exists(record.entity) and GetEntityModel(record.entity) == record.hash
            local controlled = found and Yes(NetworkHasControlOfEntity(record.entity)) or false
            local initialized, collisionLoaded, settled = false, false, false
            if found and controlled then
                initialized, collisionLoaded, settled = Initialize(record)
            end
            if record.cancelled then return end
            local report = Rpc('stables.proof.report.v1', { generation = record.generation,
                found = found == true, controlled = controlled == true, initialized = initialized,
                collisionLoaded = collisionLoaded, settled = settled })
            print(('[bcc-stables:proof] client found=%s controlled=%s initialized=%s collisionLoaded=%s settled=%s report=%s netId=%s')
                :format(tostring(found), tostring(controlled), tostring(initialized), tostring(collisionLoaded), tostring(settled),
                    tostring(type(report) == 'table' and report.ok == true), tostring(record.netId)))
            record.reported = type(report) == 'table' and report.ok == true
            if record.hash then SetModelAsNoLongerNeeded(record.hash); record.hash = nil end
        end)
        if not ok then
            print('[bcc-stables:proof] ' .. tostring(failure) .. '; inspect/clear from the server console.')
            Release(record)
        end
    end)
end)

RegisterCommand('BccStablesProofHold', function(_, args)
    if args and args[1] == 'cancel' then
        holdNextBind = false
        print('[bcc-stables:proof] next-bind pause disarmed.')
        return
    end
    if active then
        print('[bcc-stables:proof] clear the active fixture before arming next-bind pause.')
        return
    end
    holdNextBind = true
    print('[bcc-stables:proof] next client-lease spawn will pause before binding for 10 seconds.')
end, false)

-- Replays only previously bound fixture identity; never executes a spawn result.
RegisterCommand('BccStablesProofReplay', function(_, args)
    if replayRunning then return end
    local mode = args and args[1]
    local record = mode == 'duplicate' and active or mode == 'stale' and retired or nil
    if not record or not record.netId or mode == 'duplicate' and not record.reported then
        print('[bcc-stables:proof] replay requires duplicate (active reported fixture) or stale (previously cleared fixture).')
        return
    end
    local generation, netId = record.generation, record.netId
    local expected = mode == 'duplicate' and 'conflict' or 'stale_proof'
    replayRunning = true
    CreateThread(function()
        local ok, failure = pcall(function()
            Wait(2100) -- Keep the diagnostic beyond the normal spawn rate window.
            for _, spec in ipairs({ { 'prepared', { generation = generation } },
                { 'bind', { generation = generation, netId = netId } } }) do
                local result = Rpc('stables.proof.' .. spec[1] .. '.v1', spec[2])
                local code = type(result) == 'table' and result.code or 'invalid_result'
                local passed = type(result) == 'table' and result.ok == false and code == expected
                print(('[bcc-stables:proof] replay %s %s %s; expected=%s outcome=%s')
                    :format(mode, spec[1], passed and 'PASS' or 'FAIL', expected, tostring(code or 'unexpected_success')))
            end
        end)
        replayRunning = false
        if not ok then print('[bcc-stables:proof] replay failed: ' .. tostring(failure)) end
    end)
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and active then Release(active) end
end)
