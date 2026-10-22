-- Internal server repository only. No exports/RPC purchase or payment worker.
Stables.Repository = {}
local R, O, P = Stables.Repository, Stables.Operations, Stables.Persistence
local function Key(terms) return 'stables.purchase:' .. terms.operationId end
local function Identity(operationId, characterId)
    if not O.IsUuid(operationId) or not O.IsUuid(characterId) then return nil end
    return operationId:lower(), characterId:lower()
end

local function Decode(row)
    if not row then return Stables.Err('operation_not_found', 'Purchase operation was not found.') end
    if type(row.record_json) ~= 'string' or #row.record_json > 16384 then return Stables.Err('invalid_operation', 'Stored operation is invalid.') end
    local ok, record = pcall(json.decode, row.record_json)
    if not ok or not O.Validate(record).ok then return Stables.Err('invalid_operation', 'Stored operation is invalid.') end
    local terms = record.terms
    for _, pair in ipairs({ { 'operation_id', 'operationId' }, { 'character_id', 'characterId' }, { 'horse_id', 'horseId' },
        { 'quote_id', 'quoteId' }, { 'catalog_id', 'catalogId' }, { 'currency', 'currency' },
        { 'wallet_account_id', 'walletAccountId' }, { 'sink_account_id', 'sinkAccountId' } }) do
        if row[pair[1]] ~= terms[pair[2]] then return Stables.Err('invalid_operation', 'Stored operation identity is inconsistent.') end
    end
    if row.kind ~= 'horse_purchase' or tonumber(row.amount) ~= terms.amount
        or tonumber(row.catalog_revision) ~= terms.catalogRevision or row.fingerprint ~= record.fingerprint
        or row.state ~= record.state or tonumber(row.revision) ~= record.revision or row.payment_key ~= Key(terms)
        or row.payment_transaction_id ~= (record.paymentReceipt and record.paymentReceipt.transactionId or nil)
        or row.refund_transaction_id ~= (record.refundReceipt and record.refundReceipt.transactionId or nil) then
        return Stables.Err('invalid_operation', 'Stored operation columns and receipt snapshot disagree.')
    end
    return Stables.Ok(Stables.Copy(record))
end

-- Pure validation of a row already read from our own table (also used by proof).
R.ValidateSnapshot = Decode

local function Transaction(body)
    -- Foundation includes Core and persistence gates; do this before SQL locks.
    local ready = Stables.Foundation and Stables.Foundation.RequireReady() or P.RequireReady()
    if not ready.ok then return ready end
    local result
    local ok, committed = pcall(DB.transaction, function(tx)
        result = body(tx) -- Capture only the final callback result; no external side effects.
        return result.ok == true
    end)
    if not ok then return P.DatabaseError(committed) end
    if committed ~= true then return result and not result.ok and result or Stables.Err('transaction_rolled_back', 'Stables transaction did not commit.') end
    return result
end

local function LockCharacter(tx, characterId)
    return tx.one('SELECT character_id,revision FROM fs_character_stables WHERE character_id=? FOR UPDATE', characterId)
end

function R.Get(operationId, characterId)
    operationId, characterId = Identity(operationId, characterId)
    if not operationId then return Stables.Err('invalid_input', 'Operation and character UUIDs required.') end
    local ready = P.RequireReady()
    if not ready.ok then return ready end
    local ok, result = pcall(function()
        return Decode(DB.one('SELECT * FROM fs_operations WHERE operation_id=? AND character_id=?', operationId, characterId))
    end)
    return ok and result or P.DatabaseError(result)
end

function R.Reserve(input)
    local candidate = O.New(input)
    if not candidate.ok then return candidate end
    local record, terms = candidate.value, candidate.value.terms
    return Transaction(function(tx)
        tx.exec('INSERT IGNORE INTO fs_character_stables (character_id) VALUES (?)', terms.characterId)
        if not LockCharacter(tx, terms.characterId) then return Stables.Err('character_stable_missing', 'Character stable lock is unavailable.') end
        local existing = tx.one('SELECT * FROM fs_operations WHERE operation_id=? FOR UPDATE', terms.operationId)
        if existing then
            if existing.character_id ~= terms.characterId or existing.fingerprint ~= record.fingerprint then
                return Stables.Err('idempotency_conflict', 'Operation UUID is bound to different purchase terms.')
            end
            local decoded = Decode(existing)
            return decoded.ok and Stables.Ok({ operation = decoded.value, replayed = true }) or decoded
        end
        local owned = tonumber(tx.value('SELECT COUNT(*) FROM fs_horses WHERE owner_character_id=?', terms.characterId))
        local reserved = tonumber(tx.value([[SELECT COUNT(*) FROM fs_operations WHERE character_id=?
            AND state NOT IN ('fulfilled','cancelled','refunded')]], terms.characterId))
        if not owned or not reserved then return Stables.Err('invalid_capacity', 'Capacity counts are unavailable.') end
        if owned + reserved >= StablesConfig.ownedHorseLimit then return Stables.Err('capacity_exceeded', 'Character stable capacity is full.') end
        local encoded = json.encode(record)
        if #encoded > 16384 then return Stables.Err('invalid_operation', 'Operation snapshot exceeds its bound.') end
        local inserted = tx.exec([[INSERT INTO fs_operations
            (operation_id,character_id,horse_id,quote_id,catalog_id,catalog_revision,currency,amount,
             wallet_account_id,sink_account_id,payment_key,fingerprint,state,revision,record_json)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)]],
            terms.operationId, terms.characterId, terms.horseId, terms.quoteId, terms.catalogId, terms.catalogRevision,
            terms.currency, terms.amount, terms.walletAccountId, terms.sinkAccountId, Key(terms), record.fingerprint,
            record.state, record.revision, encoded)
        if inserted ~= 1 then return Stables.Err('operation_not_saved', 'Operation insertion did not complete.') end
        return Stables.Ok({ operation = Stables.Copy(record), replayed = false })
    end)
end

function R.Advance(operationId, characterId, expectedRevision, target, evidence)
    operationId, characterId = Identity(operationId, characterId)
    if not operationId then return Stables.Err('invalid_input', 'Operation and character UUIDs required.') end
    evidence = type(evidence) == 'table' and Stables.Copy(evidence) or {}
    -- Internal evidence must come from trusted Economy results / committed domain facts.
    return Transaction(function(tx)
        if not LockCharacter(tx, characterId) then return Stables.Err('operation_not_found', 'Purchase operation was not found.') end
        local decoded = Decode(tx.one('SELECT * FROM fs_operations WHERE operation_id=? AND character_id=? FOR UPDATE', operationId, characterId))
        if not decoded.ok then return decoded end
        local record = decoded.value
        local advanced = O.Advance(record, expectedRevision, target, evidence)
        if not advanced.ok then return advanced end
        local nextRecord, terms = advanced.value, record.terms
        if target == 'compensation_pending' or target == 'fulfilled' then
            if tx.one('SELECT horse_id FROM fs_horses WHERE origin_operation_id=? FOR UPDATE', operationId) then
                return Stables.Err('fulfillment_exists', 'A committed horse already exists for this operation.')
            end
        end
        if target == 'fulfilled' then
            local horse = tx.exec([[INSERT INTO fs_horses
                (horse_id,owner_character_id,origin_operation_id,catalog_id,catalog_revision)
                VALUES (?,?,?,?,?)]], terms.horseId, terms.characterId, operationId, terms.catalogId, terms.catalogRevision)
            local facts = json.encode({ operationId = operationId, horseId = terms.horseId, ownerCharacterId = terms.characterId })
            local history = tx.exec([[INSERT INTO fs_horse_history (event_id,horse_id,operation_id,event_kind,facts_json)
                VALUES (?,?,?,'acquired',?)]], operationId, terms.horseId, operationId, facts)
            local outbox = tx.exec([[INSERT INTO fs_outbox (event_id,operation_id,event_name,payload_json)
                VALUES (?,?,'stables.horse.acquired.v1',?)]], 'stables.horse.acquired.v1:' .. operationId, operationId, facts)
            if horse ~= 1 or history ~= 1 or outbox ~= 1 then return Stables.Err('fulfillment_not_saved', 'Horse fulfillment writes did not complete.') end
        end
        local encoded = json.encode(nextRecord)
        if #encoded > 16384 then return Stables.Err('invalid_operation', 'Operation snapshot exceeds its bound.') end
        local changed = tx.exec([[UPDATE fs_operations SET state=?,revision=?,payment_transaction_id=?,refund_transaction_id=?,record_json=?
            WHERE operation_id=? AND character_id=? AND revision=? AND state=?]], target, nextRecord.revision,
            nextRecord.paymentReceipt and nextRecord.paymentReceipt.transactionId or nil,
            nextRecord.refundReceipt and nextRecord.refundReceipt.transactionId or nil, encoded,
            operationId, characterId, expectedRevision, record.state)
        if changed ~= 1 then return Stables.Err('revision_conflict', 'Concurrent operation update refused; transaction rolled back.') end
        return Stables.Ok(Stables.Copy(nextRecord))
    end)
end
