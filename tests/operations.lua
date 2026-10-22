local env = setmetatable({}, { __index = _G })
local commands, output = {}, {}
env.RegisterCommand = function(name, fn) commands[name] = fn end
env.print = function(value) output[#output + 1] = value end
assert(loadfile('shared/contracts.lua', 't', env))()
assert(loadfile('server/operations.lua', 't', env))()
local O, count = env.Stables.Operations, 0
local function test(name, body) body(); count = count + 1; print('PASS operation ' .. name) end
local function terms()
    return { operationId = '10000000-0000-4000-8000-000000000001', characterId = '20000000-0000-4000-8000-000000000002',
        horseId = '30000000-0000-4000-8000-000000000003', quoteId = '40000000-0000-4000-8000-000000000004',
        walletAccountId = '50000000-0000-4000-8000-000000000005', sinkAccountId = '60000000-0000-4000-8000-000000000006',
        catalogId = 'morgan_bay', catalogRevision = 1, currency = 'dollars', amount = 100 }
end
local function pending()
    return O.Advance(O.New(terms()).value, 0, 'payment_pending').value
end
local function payment()
    local t = terms()
    return { transactionId = '70000000-0000-4000-8000-000000000007', operation = 'transfer', sourceResource = 'bcc-stables',
        reasonCode = 'stables.horse_purchase', referenceType = 'stables_order', referenceId = t.operationId,
        fromAccountId = t.walletAccountId, toAccountId = t.sinkAccountId, currency = t.currency, amount = t.amount }
end
local function paid()
    return O.Advance(pending(), 1, 'paid', { paymentReceipt = payment() }).value
end
local function fenced()
    return O.Advance(paid(), 2, 'compensation_pending', { fulfillmentFenced = true }).value
end
local function refund()
    local t = terms()
    return { transactionId = '80000000-0000-4000-8000-000000000008', operation = 'reversal', sourceResource = 'bcc-stables',
        reasonCode = 'stables.payment_reversal', referenceType = 'economy_transaction', referenceId = payment().transactionId,
        fromAccountId = t.sinkAccountId, toAccountId = t.walletAccountId, currency = t.currency, amount = t.amount }
end

test('new operation copies immutable UUID-based terms', function()
    local input = terms(); local record = O.New(input).value
    input.amount = 1
    assert(record.terms.amount == 100 and record.state == 'reserved' and record.revision == 0)
    local bad = terms(); bad.source = 2
    assert(O.New(bad).code == 'invalid_input')
end)
test('invalid money identities catalog and currency are refused', function()
    for _, amount in ipairs({ 0, -1, 1.5, math.huge, 0/0, '100' }) do
        local input = terms(); input.amount = amount; assert(not O.New(input).ok)
    end
    for _, field in ipairs({ 'characterId', 'operationId', 'horseId', 'walletAccountId' }) do
        local input = terms(); input[field] = 2; assert(not O.New(input).ok)
    end
    local input = terms(); input.sinkAccountId = input.walletAccountId; assert(not O.New(input).ok)
    input = terms(); input.currency = 'unknown|payload'; assert(not O.New(input).ok)
    input = terms(); input.catalogRevision = 0; assert(not O.New(input).ok)
end)
test('payment requests are stable detached and only available after pending intent', function()
    local record = pending()
    local a, b = O.PaymentRequest(record).value, O.PaymentRequest(record).value
    assert(a.idempotencyKey == b.idempotencyKey and a.referenceId == record.terms.operationId)
    a.amount = 1; assert(b.amount == 100 and record.terms.amount == 100)
    assert(not O.PaymentRequest(O.New(terms()).value).ok and not O.PaymentRequest(paid()).ok)
end)
test('verified receipt advances to paid without mutating original', function()
    local record, receipt = pending(), payment()
    local nextRecord = O.Advance(record, 1, 'paid', { paymentReceipt = receipt }).value
    receipt.amount = 1
    assert(record.state == 'payment_pending' and record.paymentReceipt == nil)
    assert(nextRecord.state == 'paid' and nextRecord.revision == 2 and nextRecord.paymentReceipt.amount == 100)
end)
test('payment receipt must bind caller operation accounts currency and full amount', function()
    for _, field in ipairs({ 'transactionId', 'operation', 'sourceResource', 'reasonCode', 'referenceType', 'referenceId',
        'fromAccountId', 'toAccountId', 'currency', 'amount' }) do
        local receipt = payment(); receipt[field] = field == 'amount' and 99 or 'wrong'
        assert(O.Advance(pending(), 1, 'paid', { paymentReceipt = receipt }).code == 'invalid_receipt', field)
    end
end)
test('fulfillment requires reserved horse and original character then blocks compensation', function()
    local record, t = paid(), terms()
    assert(O.Advance(record, 2, 'fulfilled', {horseId=t.horseId,ownerCharacterId='another'}).code == 'invalid_fulfillment')
    local fulfilled = O.Advance(record, 2, 'fulfilled', {horseId=t.horseId,ownerCharacterId=t.characterId}).value
    assert(fulfilled.state == 'fulfilled' and not O.Advance(fulfilled, 3, 'compensation_pending', {fulfillmentFenced=true}).ok)
    assert(not O.RefundRequest(fulfilled).ok)
end)
test('compensation requires a creation fence and emits only original transaction UUID', function()
    assert(O.Advance(paid(), 2, 'compensation_pending').code == 'fulfillment_not_fenced')
    local request = O.RefundRequest(fenced()).value
    assert(request.transactionId == payment().transactionId and request.amount == nil and request.idempotencyKey == nil)
end)
test('refund must reverse full payment and only its original accounts', function()
    for _, field in ipairs({ 'transactionId', 'operation', 'sourceResource', 'reasonCode', 'referenceType', 'referenceId',
        'fromAccountId', 'toAccountId', 'currency', 'amount' }) do
        local receipt = refund(); receipt[field] = field == 'amount' and 99 or 'wrong'
        assert(O.Advance(fenced(), 3, 'refunded', {refundReceipt=receipt}).code == 'invalid_receipt', field)
    end
    local record = O.Advance(fenced(), 3, 'refunded', {refundReceipt=refund()}).value
    assert(record.state == 'refunded' and not O.PaymentRequest(record).ok and not O.RefundRequest(record).ok)
end)
test('unknown payment cannot cancel and terminal operations never resubmit payment', function()
    assert(O.Advance(pending(), 1, 'cancelled').code == 'invalid_transition')
    local cancelled = O.Advance(O.New(terms()).value, 0, 'cancelled').value
    assert(not O.PaymentRequest(cancelled).ok and not O.Advance(cancelled, 1, 'payment_pending').ok)
end)
test('reconciliation locks the operation without enabling automatic replay', function()
    assert(O.Advance(pending(), 1, 'reconciliation_required').code == 'invalid_input')
    local record = O.Advance(pending(), 1, 'reconciliation_required', {code='receipt_conflict'}).value
    assert(record.state == 'reconciliation_required' and not O.PaymentRequest(record).ok)
    assert(not O.Advance(record, 2, 'paid', {paymentReceipt=payment()}).ok)
end)
test('revision and changed immutable terms fail closed', function()
    local record = pending()
    assert(O.Advance(record, 0, 'paid', {paymentReceipt=payment()}).code == 'revision_conflict')
    record.terms.amount = 1
    assert(O.Advance(record, 1, 'paid', {paymentReceipt=payment()}).code == 'invalid_operation')
end)
test('console smoke exercises rules without dependency or mutation APIs', function()
    commands.BccStablesOperationSmokeTest(2); assert(#output == 0)
    commands.BccStablesOperationSmokeTest(0)
    assert(output[#output]:find('6/6', 1, true))
end)
print(('%d/%d purchase operation cases passed; pure rules, no persistence or external calls.'):format(count, count))
