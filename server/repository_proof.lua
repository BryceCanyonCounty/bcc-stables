-- Isolated development fixture. No Core character/account IDs or Economy calls.
Stables.RepositoryProof = {}
local H, R, O = Stables.RepositoryProof, Stables.Repository, Stables.Operations
local busy, children = false, 0
local CHARACTER = 'bcce0000-0000-4000-8000-000000000001'
local MAX = 11

local function Id(family, index) return ('bcce%04x-0000-4000-8000-%012d'):format(family, index) end
function H.Terms(index)
    assert(type(index) == 'number' and index % 1 == 0 and index >= 1 and index <= MAX)
    return { operationId = Id(1,index), characterId = CHARACTER, horseId = Id(2,index), quoteId = Id(3,index),
        walletAccountId = Id(4,1), sinkAccountId = Id(5,1), catalogId = 'proof.repository',
        catalogRevision = 1, currency = 'dollars', amount = 1 }
end

local function Log(value) print('[bcc-stables:repository-proof] ' .. json.encode(value)) end
local function Check(value, message) if not value then error(message, 0) end end
-- Refuse unfamiliar data, even if someone reused the reserved fixture UUID.
function H.ValidateRows(rows, stable)
    if not stable or stable.character_id ~= CHARACTER or stable.selected_horse_id ~= nil or tonumber(stable.revision) ~= 0 then
        return Stables.Err('fixture_conflict', 'Synthetic stable is missing or has changed; nothing may be deleted.')
    end
    if type(rows) ~= 'table' or #rows == 0 or #rows > MAX then
        return Stables.Err('fixture_conflict', 'Fixture row count is invalid.')
    end
    local known = {}
    for index = 1, MAX do known[Id(1,index)] = index end
    local records = {}
    for _, row in ipairs(rows) do
        local index = known[row.operation_id]
        if not index or records[index] then return Stables.Err('fixture_conflict', 'Unrecognized fixture identity.') end
        local decoded = R.ValidateSnapshot(row)
        local expected = O.New(H.Terms(index)).value
        if not decoded.ok or row.character_id ~= CHARACTER or decoded.value.fingerprint ~= expected.fingerprint
            or (row.state ~= 'reserved' and row.state ~= 'payment_pending')
            or tonumber(row.revision) ~= (row.state == 'reserved' and 0 or 1) then
            return Stables.Err('fixture_conflict', 'Fixture payload/state changed; nothing may be deleted.')
        end
        records[index] = decoded.value
    end
    return Stables.Ok(records)
end

local function Snapshot(db, locked)
    local suffix = locked and ' FOR UPDATE' or ''
    local stable = db.one('SELECT character_id,selected_horse_id,revision FROM fs_character_stables WHERE character_id=?' .. suffix, CHARACTER)
    local rows = db.query('SELECT * FROM fs_operations WHERE character_id=? ORDER BY operation_id LIMIT 12' .. suffix, CHARACTER) or {}
    local count = tonumber(db.value('SELECT COUNT(*) FROM fs_operations WHERE character_id=?', CHARACTER))
    Check(count == #rows and count <= MAX, 'Fixture contains unexpected extra rows; no cleanup allowed.')
    local validated
    if stable or #rows > 0 then
        validated = H.ValidateRows(rows, stable)
        Check(validated.ok, validated.message or 'Fixture conflict.')
    end
    -- Look for all reserved identities, including operations whose current owner changed.
    local slots, horses, operations = {}, {}, {}
    for index = 1, MAX do slots[index],horses[index],operations[index] = '?',Id(2,index),Id(1,index) end
    local placeholders, parameters = table.concat(slots,','), { CHARACTER }
    for _,id in ipairs(horses) do parameters[#parameters+1] = id end
    for _,id in ipairs(operations) do parameters[#parameters+1] = id end
    Check(tonumber(db.value('SELECT COUNT(*) FROM fs_horses WHERE owner_character_id=? OR horse_id IN (' .. placeholders
        .. ') OR origin_operation_id IN (' .. placeholders .. ')',table.unpack(parameters))) == 0, 'Horse data blocks fixture cleanup.')
    Check(tonumber(db.value('SELECT COUNT(*) FROM fs_horse_history WHERE operation_id IN (' .. placeholders .. ')',table.unpack(operations))) == 0,
        'History data blocks fixture cleanup.')
    Check(tonumber(db.value('SELECT COUNT(*) FROM fs_outbox WHERE operation_id IN (' .. placeholders .. ')',table.unpack(operations))) == 0,
        'Outbox data blocks fixture cleanup.')
    return validated and { rows = rows, records = validated.value } or nil
end

local function Inspect()
    local snapshot = Snapshot(DB, false)
    if not snapshot then Log({ ok = true, state = 'empty' }); return end
    local reserved, pending = 0, 0
    for _, record in pairs(snapshot.records) do
        if record.state == 'payment_pending' then pending = pending + 1 else reserved = reserved + 1 end
    end
    local passed = #snapshot.rows == StablesConfig.ownedHorseLimit and pending == 1
    Log({ ok = passed, state = 'retained', rows = #snapshot.rows, reserved = reserved, paymentPending = pending,
        capacity = StablesConfig.ownedHorseLimit, noHorseHistoryOrOutbox = true,
        message = passed and 'Durable fixture retained; no payment was submitted.' or 'Incomplete fixture; inspect/clear before another run.' })
end

local function Clear()
    local before = Snapshot(DB, false)
    if not before then Log({ ok = true, state = 'empty' }); return end
    local removed = 0
    local committed = DB.transaction(function(tx)
        local snapshot = Snapshot(tx, true) -- Character lock then operation locks, all checks repeated.
        Check(snapshot ~= nil, 'Fixture disappeared during cleanup.')
        removed = 0
        for _, row in ipairs(snapshot.rows) do
            local changed = tx.exec([[DELETE FROM fs_operations WHERE operation_id=? AND character_id=?
                AND fingerprint=? AND state=? AND revision=? AND payment_transaction_id IS NULL AND refund_transaction_id IS NULL]],
                row.operation_id,CHARACTER,row.fingerprint,row.state,row.revision)
            Check(changed == 1, 'Fixture changed during deletion; transaction rolled back.')
            removed = removed + 1
        end
        Check(tx.exec('DELETE FROM fs_character_stables WHERE character_id=? AND selected_horse_id IS NULL AND revision=0',CHARACTER) == 1,
            'Synthetic stable changed; transaction rolled back.')
        return true
    end)
    Check(committed == true, 'Fixture cleanup did not commit.')
    Check(Snapshot(DB,false) == nil, 'Fixture cleanup outcome is not confirmed.')
    Log({ ok = true, state = 'empty', removedOperations = removed })
end

local function Run()
    local limit = StablesConfig.ownedHorseLimit
    Check(type(limit) == 'number' and limit % 1 == 0 and limit >= 1 and limit <= 10, 'Proof requires ownedHorseLimit 1..10.')
    Check(Snapshot(DB,false) == nil, 'Fixture already exists; inspect/clear it before running again.')
    for index = 1, limit - 1 do
        local result = R.Reserve(H.Terms(index)); Check(result.ok and not result.value.replayed, 'Filler reservation failed; inspect before retry.')
    end
    local finished, started, peak, active, outcomes = 0, 0, 0, 0, {}
    children = 2
    for index = limit, limit + 1 do
        CreateThread(function()
            started = started + 1
            while started < 2 do Wait(0) end
            active = active + 1; peak = math.max(peak,active)
            local ok, result = pcall(R.Reserve,H.Terms(index))
            outcomes[index] = ok and result or Stables.Err('proof_exception','Reservation raised; inspect durable fixture.')
            active, finished, children = active - 1, finished + 1, children - 1
            Log({ event = 'contender', index = index, ok = outcomes[index].ok, code = outcomes[index].code,
                outcome = outcomes[index].details and outcomes[index].details.outcome })
        end)
    end
    local began = GetGameTimer()
    while finished < 2 and GetGameTimer() - began < 45000 do Wait(25) end
    Check(finished == 2, 'Contenders still pending; do not clear/restart until they finish; then inspect.')
    local admitted, refused, winner = 0, 0, nil
    for index,result in pairs(outcomes) do
        if result.ok and not result.value.replayed then admitted,winner = admitted + 1,index
        elseif result.code == 'capacity_exceeded' then refused = refused + 1 end
    end
    Check(admitted == 1 and refused == 1 and peak == 2, 'Expected two overlapping requests, one admission and one capacity refusal; inspect fixture.')
    local terms = H.Terms(winner)
    local replay = R.Reserve(terms)
    Check(replay.ok and replay.value.replayed == true, 'Identical reservation did not replay.')
    local changed = Stables.Copy(terms); changed.amount = 2
    Check(R.Reserve(changed).code == 'idempotency_conflict', 'Changed purchase terms were not refused.')
    -- Force a known DB rollback using the synthetic stable row only.
    local rolledBack = DB.transaction(function(tx)
        Check(tx.one('SELECT character_id FROM fs_character_stables WHERE character_id=? FOR UPDATE',CHARACTER) ~= nil, 'Fixture lock missing.')
        Check(tx.exec('UPDATE fs_character_stables SET revision=revision+1 WHERE character_id=?',CHARACTER) == 1,'Rollback probe write failed.')
        return false
    end)
    Check(rolledBack == false and tonumber(DB.value('SELECT revision FROM fs_character_stables WHERE character_id=?',CHARACTER)) == 0,
        'Synthetic revision rollback failed; fixture retained for inspection.')
    Check(R.Advance(terms.operationId,CHARACTER,0,'payment_pending').ok, 'Payment intent save failed.')
    Check(R.Advance(terms.operationId,CHARACTER,0,'payment_pending').code == 'revision_conflict', 'Stale revision was not refused.')
    Check(R.Advance(terms.operationId,CHARACTER,1,'cancelled').code == 'invalid_transition', 'Unknown payment was incorrectly cancellable.')
    Log({ ok = true, event = 'run_complete', overlappingRequests = peak, admitted = admitted, capacityRefused = refused,
        identicalReplay = true, changedTermsRefused = true, sqlRollback = true, staleRevisionRefused = true,
        unknownPaymentCancellationRefused = true, fixtureRetainedForRestart = true, noPaymentSubmitted = true })
    Inspect()
end

RegisterCommand('BccStablesRepositoryProof',function(source,args)
    if source ~= 0 then return end
    if StablesConfig.repositoryProof ~= true then Log(Stables.Err('disabled','Set repositoryProof=true temporarily; entityProof stays false.')); return end
    if busy then Log(Stables.Err('busy','Repository proof work is still running; wait for contender completion.')); return end
    if args[1] ~= 'run' and args[1] ~= 'inspect' and args[1] ~= 'clear' then
        Log(Stables.Err('invalid_input','BccStablesRepositoryProof run | inspect | clear')); return
    end
    busy = true
    CreateThread(function()
        local ok, failure = pcall(function()
            local ready = Stables.Foundation.RequireReady(); Check(ready.ok,ready.code or 'not_ready')
            if args[1] == 'run' then Run() elseif args[1] == 'inspect' then Inspect() else Clear() end
        end)
        if children == 0 then busy = false
        else CreateThread(function() while children > 0 do Wait(100) end; busy = false end) end
        if not ok then Log(Stables.Err('proof_failed',tostring(failure),{ fixtureRetained = true })) end
    end)
end,true)
