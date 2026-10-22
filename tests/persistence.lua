local count = 0
local function test(name, fn) fn(); count = count + 1; print('PASS persistence ' .. name) end
local fixture = assert(loadfile('tests/fixtures/persistence.lua'))()
local function terms(index)
    index = index or 1
    return {operationId=('10000000-0000-4000-8000-%012d'):format(index),characterId='20000000-0000-4000-8000-000000000002',
        horseId=('30000000-0000-4000-8000-%012d'):format(index),quoteId=('40000000-0000-4000-8000-%012d'):format(index),
        walletAccountId='50000000-0000-4000-8000-000000000005',sinkAccountId='60000000-0000-4000-8000-000000000006',
        catalogId='morgan_bay',catalogRevision=1,currency='dollars',amount=100}
end
local function receipt(t)
    return {transactionId='70000000-0000-4000-8000-000000000007',operation='transfer',sourceResource='bcc-stables',
        reasonCode='stables.horse_purchase',referenceType='stables_order',referenceId=t.operationId,
        fromAccountId=t.walletAccountId,toAccountId=t.sinkAccountId,currency=t.currency,amount=t.amount}
end
local function paid(m)
    local t = terms(); assert(m.r.Reserve(t).ok)
    assert(m.r.Advance(t.operationId,t.characterId,0,'payment_pending').ok)
    assert(m.r.Advance(t.operationId,t.characterId,1,'paid',{paymentReceipt=receipt(t)}).ok)
    return t
end

test('clean migration and restart retain checksummed schema',function()
    local m=fixture(); assert(m.start().ok and m.ddl==6)
    m.reload(); local restarted=m.start(); assert(restarted.ok and restarted.value.applied==0 and m.ddl==6)
end)
test('checksum drift and unknown recorded migrations fail closed',function()
    local m=fixture(); assert(m.start().ok)
    m.db.ledger['001_purchase_foundation'].checksum='changed'; m.reload()
    assert(m.start().code=='migration_checksum_mismatch')
    m=fixture(); m.db.ledger.future={id='future',checksum='unknown',state='applied'}
    assert(m.start().code=='schema_newer_than_resource')
end)
test('untracked tables are not silently adopted',function()
    local m=fixture(); m.db.tables.fs_operations=true
    assert(m.start().code=='untracked_schema' and next(m.db.ledger)==nil)
end)
test('interrupted DDL resumes its original intent without dropping data',function()
    local m=fixture(); m.failCreate='fs_horses'
    assert(not m.start().ok and m.db.ledger['001_purchase_foundation'].state=='pending')
    assert(m.db.tables.fs_operations)
    m.failCreate=nil; m.reload(); local resumed=m.start()
    assert(resumed.ok and resumed.value.resumed==1 and m.ddl==6)
end)
test('missing applied table is refused instead of recreated',function()
    local m=fixture(); assert(m.start().ok); m.db.tables.fs_horses=nil; m.reload()
    assert(m.start().code=='schema_incomplete' and not m.db.tables.fs_horses)
end)
test('completion recording failure stays pending for recovery',function()
    local m=fixture(); m.failLedger=true
    assert(m.start().code=='invalid_migration_ledger')
    m.failLedger=false; m.reload(); assert(m.start().ok and m.ddl==6)
end)
test('readiness timeout and invalid capacity run no DDL',function()
    local m=fixture(); m.ready=false
    assert(m.start().code=='database_timeout' and m.ddl==0)
    m=fixture(); m.env.StablesConfig.ownedHorseLimit=0
    assert(m.start().code=='config_error' and m.ddl==0)
end)
test('identical reservation after reload returns durable original; changed terms conflict',function()
    local m=fixture(); assert(m.start().ok)
    local t=terms(); local first=m.r.Reserve(t); assert(first.ok and not first.value.replayed)
    m.reload(); assert(m.start().ok)
    local replay=m.r.Reserve(t); assert(replay.ok and replay.value.replayed)
    t.amount=101; assert(m.r.Reserve(t).code=='idempotency_conflict')
end)
test('capacity serialization retains uncertain reservations and releases cancellation',function()
    local m=fixture(); m.env.StablesConfig.ownedHorseLimit=1; assert(m.start().ok)
    local t=terms(); assert(m.r.Reserve(t).ok)
    assert(m.r.Reserve(terms(2)).code=='capacity_exceeded')
    assert(m.r.Advance(t.operationId,t.characterId,0,'cancelled').ok)
    assert(m.r.Reserve(terms(2)).ok)
end)
test('stored owned horse replaces reservation in capacity accounting',function()
    local m=fixture(); m.env.StablesConfig.ownedHorseLimit=1; assert(m.start().ok)
    local t=paid(m)
    assert(m.r.Advance(t.operationId,t.characterId,2,'fulfilled',{horseId=t.horseId,ownerCharacterId=t.characterId}).ok)
    assert(m.r.Reserve(terms(2)).code=='capacity_exceeded')
end)
test('fulfillment atomically writes horse history outbox and final receipt',function()
    local m=fixture(); assert(m.start().ok); local t=paid(m)
    assert(m.r.Advance(t.operationId,t.characterId,2,'fulfilled',{horseId=t.horseId,ownerCharacterId=t.characterId}).ok)
    assert(m.db.horses[t.horseId].availability=='stored' and m.db.history[t.operationId])
    assert(m.db.outbox['stables.horse.acquired.v1:'..t.operationId])
    assert(m.r.Get(t.operationId,t.characterId).value.state=='fulfilled')
    assert(m.r.Advance(t.operationId,t.characterId,2,'fulfilled',{}).code=='revision_conflict')
end)
test('history write failure rolls back horse and operation',function()
    local m=fixture(); assert(m.start().ok); local t=paid(m); m.failHistory=true
    assert(not m.r.Advance(t.operationId,t.characterId,2,'fulfilled',{horseId=t.horseId,ownerCharacterId=t.characterId}).ok)
    assert(not m.db.horses[t.horseId] and next(m.db.history)==nil and next(m.db.outbox)==nil)
    assert(m.r.Get(t.operationId,t.characterId).value.state=='paid')
end)
test('CAS refusal rolls back all fulfillment side effects',function()
    local m=fixture(); assert(m.start().ok); local t=paid(m); m.failCas=true
    assert(m.r.Advance(t.operationId,t.characterId,2,'fulfilled',{horseId=t.horseId,ownerCharacterId=t.characterId}).code=='revision_conflict')
    assert(next(m.db.horses)==nil and next(m.db.outbox)==nil)
end)
test('compensation cannot adopt or refund an already committed horse',function()
    local m=fixture(); assert(m.start().ok); local t=paid(m)
    m.db.horses[t.horseId]={horse_id=t.horseId,origin_operation_id=t.operationId,owner_character_id=t.characterId}
    assert(m.r.Advance(t.operationId,t.characterId,2,'compensation_pending',{fulfillmentFenced=true}).code=='fulfillment_exists')
end)
test('fenced refund releases capacity and blocks late fulfillment',function()
    local m=fixture(); m.env.StablesConfig.ownedHorseLimit=1; assert(m.start().ok); local t=paid(m)
    assert(m.r.Advance(t.operationId,t.characterId,2,'compensation_pending',{fulfillmentFenced=true}).ok)
    local refund=receipt(t); refund.transactionId='80000000-0000-4000-8000-000000000008'; refund.operation='reversal'
    refund.reasonCode='stables.payment_reversal'; refund.referenceType='economy_transaction'; refund.referenceId=receipt(t).transactionId
    refund.fromAccountId,refund.toAccountId=t.sinkAccountId,t.walletAccountId
    assert(m.r.Advance(t.operationId,t.characterId,3,'refunded',{refundReceipt=refund}).ok)
    assert(m.r.Reserve(terms(2)).ok)
    assert(not m.r.Advance(t.operationId,t.characterId,4,'fulfilled',{horseId=t.horseId,ownerCharacterId=t.characterId}).ok)
end)
test('identity columns and corrupt JSON fail closed',function()
    local m=fixture(); assert(m.start().ok); local t=terms(); assert(m.r.Reserve(t).ok)
    m.db.operations[t.operationId].amount=1
    assert(m.r.Get(t.operationId,t.characterId).code=='invalid_operation')
    m.db.operations[t.operationId].record_json='not-json'
    assert(m.r.Get(t.operationId,t.characterId).code=='invalid_operation')
end)
test('foreign character cannot read or advance an operation',function()
    local m=fixture(); assert(m.start().ok); local t=terms(); assert(m.r.Reserve(t).ok)
    local foreign='90000000-0000-4000-8000-000000000009'
    assert(m.r.Get(t.operationId,foreign).code=='operation_not_found')
    assert(m.r.Advance(t.operationId,foreign,0,'payment_pending').code=='operation_not_found')
    assert(m.r.Get('invalid',t.characterId).code=='invalid_input')
end)
test('lost commit response preserves unknown outcome and converges by durable read',function()
    local m=fixture(); assert(m.start().ok); local t=terms(); m.unknownCommit=true
    local lost=m.r.Reserve(t); assert(lost.code=='database_error' and lost.details.outcome=='unknown')
    m.unknownCommit=false
    assert(m.r.Get(t.operationId,t.characterId).value.state=='reserved')
    assert(m.r.Reserve(t).value.replayed)
end)
test('provider loss latches persistence failure until restart',function()
    local m=fixture(); assert(m.start().ok); m.provider='stopped'
    assert(m.r.Reserve(terms()).code=='persistence_unavailable')
    m.provider='started'; assert(m.r.Reserve(terms()).code=='persistence_unavailable')
    m.reload(); assert(m.start().ok)
end)
test('foundation refusal blocks repository writes before opening a transaction',function()
    local m=fixture(); assert(m.start().ok)
    m.env.Stables.Foundation={RequireReady=function() return m.env.Stables.Err('not_ready','Core degraded.') end}
    assert(m.r.Reserve(terms()).code=='not_ready' and next(m.db.operations)==nil and next(m.db.characters)==nil)
end)
print(('%d/%d persistence cases passed; SQL/CFX are modeled, live concurrency pending.'):format(count,count))
