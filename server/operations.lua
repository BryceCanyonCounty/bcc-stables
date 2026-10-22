-- Pure purchase rules. Persistence/CAS and external service calls are not enabled.
Stables.Operations = {}
local O = Stables.Operations
local MAX = 9007199254740991
local fields = { 'operationId', 'characterId', 'horseId', 'quoteId', 'catalogId',
    'catalogRevision', 'currency', 'amount', 'walletAccountId', 'sinkAccountId' }
local states = { reserved = true, payment_pending = true, paid = true, fulfilled = true,
    compensation_pending = true, refunded = true, cancelled = true, reconciliation_required = true }
local edges = {
    reserved = { payment_pending = true, cancelled = true },
    payment_pending = { paid = true, reconciliation_required = true },
    paid = { fulfilled = true, compensation_pending = true, reconciliation_required = true },
    compensation_pending = { refunded = true, reconciliation_required = true },
}

local function Integer(value, minimum)
    return type(value) == 'number' and value >= minimum and value <= MAX and value % 1 == 0
end

local function Uuid(value)
    return type(value) == 'string' and value:match(
        '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$') ~= nil
end

local function Terms(input)
    if type(input) ~= 'table' then return nil end
    local known, result = {}, {}
    for _, key in ipairs(fields) do known[key] = true; result[key] = input[key] end
    for key in pairs(input) do if not known[key] then return nil end end
    for _, key in ipairs({ 'operationId', 'characterId', 'horseId', 'quoteId', 'walletAccountId', 'sinkAccountId' }) do
        if not Uuid(result[key]) then return nil end
        result[key] = result[key]:lower()
    end
    if result.walletAccountId == result.sinkAccountId
        or not Integer(result.amount, 1) or not Integer(result.catalogRevision, 1)
        or type(result.currency) ~= 'string' or #result.currency > 32 or not result.currency:match('^[a-z][a-z0-9_]*$')
        or type(result.catalogId) ~= 'string' or #result.catalogId > 64 or not result.catalogId:match('^[a-z0-9][a-z0-9_.:%-]*$') then return nil end
    return result
end

local function Fingerprint(terms)
    local parts = {}
    for _, key in ipairs(fields) do
        local value = terms[key]
        parts[#parts + 1] = type(value) == 'number' and ('%.0f'):format(value) or value
    end
    return table.concat(parts, '|')
end

local function PaymentMatches(terms, value)
    -- Content matching only: the future service must obtain this from Economy,
    -- never accept a client-supplied table as journal authority.
    return type(value) == 'table' and Uuid(value.transactionId) and value.operation == 'transfer'
        and value.sourceResource == 'bcc-stables' and value.reasonCode == 'stables.horse_purchase'
        and value.referenceType == 'stables_order' and value.referenceId == terms.operationId
        and value.fromAccountId == terms.walletAccountId and value.toAccountId == terms.sinkAccountId
        and value.currency == terms.currency and value.amount == terms.amount
end

local function Valid(record)
    if type(record) ~= 'table' or not states[record.state] or not Integer(record.revision, 0) then return false end
    local terms = Terms(record.terms)
    if not terms or record.fingerprint ~= Fingerprint(terms) then return false end
    local state = record.state
    if state == 'reconciliation_required' then
        state = record.reconciliationFrom
        if state ~= 'payment_pending' and state ~= 'paid' and state ~= 'compensation_pending' then return false end
        if type(record.reconciliationCode) ~= 'string' or #record.reconciliationCode > 64
            or not record.reconciliationCode:match('^[a-z][a-z0-9_]*$') then return false end
    elseif record.reconciliationFrom ~= nil or record.reconciliationCode ~= nil then return false end
    if state == 'paid' or state == 'fulfilled' or state == 'compensation_pending' or state == 'refunded' then
        if not PaymentMatches(terms, record.paymentReceipt) then return false end
    elseif record.paymentReceipt ~= nil then return false end
    if state == 'compensation_pending' or state == 'refunded' then
        if record.fulfillmentFenced ~= true then return false end
    elseif record.fulfillmentFenced ~= nil then return false end
    if state == 'fulfilled' then
        if type(record.fulfillment) ~= 'table' or record.fulfillment.horseId ~= terms.horseId
            or record.fulfillment.ownerCharacterId ~= terms.characterId then return false end
    elseif record.fulfillment ~= nil then return false end
    if state == 'refunded' then
        local receipt, payment = record.refundReceipt, record.paymentReceipt
        if type(receipt) ~= 'table' or not Uuid(receipt.transactionId) or receipt.transactionId == payment.transactionId
            or receipt.operation ~= 'reversal' or receipt.sourceResource ~= 'bcc-stables'
            or receipt.reasonCode ~= 'stables.payment_reversal' or receipt.referenceType ~= 'economy_transaction'
            or receipt.referenceId ~= payment.transactionId or receipt.currency ~= terms.currency
            or receipt.amount ~= terms.amount or receipt.fromAccountId ~= terms.sinkAccountId
            or receipt.toAccountId ~= terms.walletAccountId then return false end
    elseif record.refundReceipt ~= nil then return false end
    return true
end

function O.Validate(record)
    return Valid(record) and Stables.Ok(Stables.Copy(record))
        or Stables.Err('invalid_operation', 'Operation record is invalid.')
end

O.IsUuid = Uuid

function O.New(input)
    local terms = Terms(input)
    if not terms then return Stables.Err('invalid_input', 'Immutable server-resolved purchase terms required.') end
    return Stables.Ok({ terms = terms, fingerprint = Fingerprint(terms), state = 'reserved', revision = 0 })
end

function O.PaymentRequest(record)
    if not Valid(record) or record.state ~= 'payment_pending' then
        return Stables.Err('conflict', 'Only a pending payment may be submitted or retried.')
    end
    local terms = record.terms
    return Stables.Ok({ fromAccountId = terms.walletAccountId, toAccountId = terms.sinkAccountId,
        currency = terms.currency, amount = terms.amount, reasonCode = 'stables.horse_purchase',
        referenceType = 'stables_order', referenceId = terms.operationId,
        idempotencyKey = 'stables.purchase:' .. terms.operationId })
end

function O.RefundRequest(record)
    if not Valid(record) or record.state ~= 'compensation_pending' then
        return Stables.Err('conflict', 'Only durably fenced compensation may request a refund.')
    end
    return Stables.Ok({ transactionId = record.paymentReceipt.transactionId })
end

function O.Advance(record, expectedRevision, target, evidence)
    if not Valid(record) then return Stables.Err('invalid_operation', 'Operation record is invalid.') end
    if not Integer(expectedRevision, 0) or record.revision ~= expectedRevision or record.revision >= MAX then
        return Stables.Err('revision_conflict', 'Operation revision changed or cannot advance.')
    end
    if type(target) ~= 'string' or not edges[record.state] or not edges[record.state][target] then
        return Stables.Err('invalid_transition', 'Purchase state does not permit this transition.')
    end
    evidence = type(evidence) == 'table' and evidence or {}
    local result = Stables.Copy(record)
    if target == 'paid' then
        if not PaymentMatches(record.terms, evidence.paymentReceipt) then
            return Stables.Err('invalid_receipt', 'Payment receipt does not match this purchase.')
        end
        result.paymentReceipt = Stables.Copy(evidence.paymentReceipt)
    elseif target == 'fulfilled' then
        if evidence.horseId ~= record.terms.horseId or evidence.ownerCharacterId ~= record.terms.characterId then
            return Stables.Err('invalid_fulfillment', 'Committed horse identity and owner must match the reservation.')
        end
        result.fulfillment = { horseId = evidence.horseId, ownerCharacterId = evidence.ownerCharacterId }
    elseif target == 'compensation_pending' then
        if evidence.fulfillmentFenced ~= true then return Stables.Err('fulfillment_not_fenced', 'Fence horse creation before compensation.') end
        result.fulfillmentFenced = true
    elseif target == 'refunded' then
        local receipt, payment = evidence.refundReceipt, record.paymentReceipt
        if type(receipt) ~= 'table' or not Uuid(receipt.transactionId) or receipt.transactionId == payment.transactionId
            or receipt.operation ~= 'reversal' or receipt.sourceResource ~= 'bcc-stables'
            or receipt.reasonCode ~= 'stables.payment_reversal' or receipt.referenceType ~= 'economy_transaction'
            or receipt.referenceId ~= payment.transactionId or receipt.currency ~= record.terms.currency
            or receipt.amount ~= record.terms.amount or receipt.fromAccountId ~= record.terms.sinkAccountId
            or receipt.toAccountId ~= record.terms.walletAccountId then
            return Stables.Err('invalid_receipt', 'Refund receipt does not reverse the original payment.')
        end
        result.refundReceipt = Stables.Copy(receipt)
    elseif target == 'reconciliation_required' then
        if type(evidence.code) ~= 'string' or #evidence.code > 64 or not evidence.code:match('^[a-z][a-z0-9_]*$') then
            return Stables.Err('invalid_input', 'A bounded reconciliation reason is required.')
        end
        result.reconciliationCode = evidence.code
        result.reconciliationFrom = record.state
    end
    result.state, result.revision = target, result.revision + 1
    return Stables.Ok(result)
end

RegisterCommand('BccStablesOperationSmokeTest', function(source)
    if source ~= 0 then return end
    local terms = { operationId = '10000000-0000-4000-8000-000000000001', characterId = '20000000-0000-4000-8000-000000000002',
        horseId = '30000000-0000-4000-8000-000000000003', quoteId = '40000000-0000-4000-8000-000000000004',
        walletAccountId = '50000000-0000-4000-8000-000000000005', sinkAccountId = '60000000-0000-4000-8000-000000000006',
        catalogId = 'morgan_bay', catalogRevision = 1, currency = 'dollars', amount = 100 }
    local reserved = O.New(terms).value
    local pending = O.Advance(reserved, 0, 'payment_pending').value
    local request = O.PaymentRequest(pending)
    local tests = {
        { 'reserved terms', reserved.state == 'reserved' and reserved.revision == 0 },
        { 'stable payment key', request.ok and request.value.idempotencyKey == 'stables.purchase:' .. terms.operationId },
        { 'no payment before intent', O.PaymentRequest(reserved).code == 'conflict' },
        { 'unknown payment cannot cancel', O.Advance(pending, 1, 'cancelled').code == 'invalid_transition' },
        { 'unverified payment refused', O.Advance(pending, 1, 'paid', { paymentReceipt = {} }).code == 'invalid_receipt' },
        { 'stale revision refused', O.Advance(reserved, 1, 'payment_pending').code == 'revision_conflict' },
    }
    local passed = 0
    for _, test in ipairs(tests) do
        if test[2] then passed = passed + 1 end
        print(('[BccStablesOperationSmokeTest] %s %s'):format(test[1], test[2] and 'PASS' or 'FAIL'))
    end
    print(('[BccStablesOperationSmokeTest] %d/%d; pure rules only, no database/payment/horse mutation'):format(passed, #tests))
end, true)
