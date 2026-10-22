local fixture = assert(loadfile('tests/fixtures/persistence.lua'))()
local count = 0
local function test(name,fn) fn(); count=count+1; print('PASS repository proof '..name) end
local function setup(enabled)
    local m=fixture(); assert(m.start().ok)
    local env=m.env
    local commands,queue,clock={}, {},0
    env.StablesConfig.repositoryProof=enabled~=false
    env.Stables.Foundation={RequireReady=function() return m.p.RequireReady() end}
    env.RegisterCommand=function(name,callback) commands[name]=callback end
    env.CreateThread=function(fn) queue[#queue+1]=coroutine.create(fn) end
    env.Wait=function(ms) clock=clock+math.max(ms,1); coroutine.yield() end
    env.GetGameTimer=function() return clock end
    local transaction=env.DB.transaction
    env.DB.transaction=function(body) env.Wait(1); return transaction(body) end
    assert(loadfile('server/repository_proof.lua','t',env))()
    m.h=env.Stables.RepositoryProof
    m.run=function(action,source)
        commands.BccStablesRepositoryProof(source or 0,{action})
        local steps=0
        while #queue>0 do
            steps=steps+1; assert(steps<10000,'scheduler stalled')
            local current=table.remove(queue,1)
            local ok,err=coroutine.resume(current); assert(ok,err)
            if coroutine.status(current)~='dead' then queue[#queue+1]=current end
        end
    end
    m.logs=function()
        local values={}
        for _,line in ipairs(m.outputs) do
            local payload=line:match('^%[bcc%-stables:repository%-proof%] (.+)$')
            if payload then values[#values+1]=env.json.decode(payload) end
        end
        return values
    end
    m.last=function() local values=m.logs(); return values[#values] end
    return m
end
test('console opt-in and source guards prevent unintended writes',function()
    local m=setup(false); m.run('run')
    assert(m.last().code=='disabled' and next(m.db.operations)==nil)
    m=setup(); m.run('run',2)
    assert(#m.outputs==0 and next(m.db.operations)==nil)
end)
test('run races final slot retains pending intent and cleanup removes only exact fixture',function()
    local m=setup(); m.run('run')
    assert(m.last().ok and m.last().rows==3 and m.last().paymentPending==1)
    local completed
    for _,log in ipairs(m.logs()) do if log.event=='run_complete' then completed=log end end
    assert(completed and completed.overlappingRequests==2 and completed.admitted==1 and completed.capacityRefused==1)
    assert(completed.sqlRollback and completed.changedTermsRefused and completed.staleRevisionRefused)
    assert(next(m.db.horses)==nil and next(m.db.history)==nil and next(m.db.outbox)==nil)
    m.run('clear'); assert(m.last().ok and m.last().state=='empty')
    assert(next(m.db.operations)==nil and next(m.db.characters)==nil)
end)
test('single-slot capacity works without filler reservations',function()
    local m=setup(); m.env.StablesConfig.ownedHorseLimit=1
    m.run('run'); assert(m.last().ok and m.last().rows==1 and m.last().paymentPending==1)
end)
test('a second run cannot reuse retained fixture',function()
    local m=setup(); m.run('run'); m.run('run')
    assert(m.last().code=='proof_failed')
end)
test('inspect derives retained state from persisted records after proof reload',function()
    local m=setup(); m.run('run'); assert(m.last().ok)
    -- Reinstall console handlers/module without restoring any local proof state.
    local callback
    m.env.RegisterCommand=function(_,fn) callback=fn end
    assert(loadfile('server/repository_proof.lua','t',m.env))()
    callback(0,{'inspect'})
    m.run('inspect') -- scheduler drains both queued inspectors
    assert(m.last().ok and m.last().paymentPending==1)
end)
test('unexpected terms or receipt-bearing records block cleanup',function()
    for _,field in ipairs({'amount','payment_transaction_id','state'}) do
        local m=setup(); m.run('run')
        local row=next(m.db.operations); row=m.db.operations[row]
        row[field]=field=='amount' and 999 or field=='state' and 'paid' or 'foreign-receipt'
        m.run('clear'); assert(m.last().code=='proof_failed' and next(m.db.operations)~=nil)
    end
end)
test('unexpected selected horse or foreign operation blocks cleanup',function()
    local m=setup(); m.run('run')
    local char=m.h.Terms(1).characterId
    m.db.characters[char].selected_horse_id='unrelated'
    m.run('clear'); assert(m.last().code=='proof_failed')
    m.db.characters[char].selected_horse_id=nil
    m.db.operations.foreign={operation_id='unknown',character_id=char}
    m.run('clear'); assert(m.last().code=='proof_failed')
end)
test('horse history and outbox artifacts are never deleted or reported empty',function()
    for _,kind in ipairs({'horses','history','outbox'}) do
        local m=setup(); local t=m.h.Terms(1)
        if kind=='horses' then m.db.horses[t.horseId]={horse_id=t.horseId,origin_operation_id=t.operationId}
        elseif kind=='history' then m.db.history.artifact={'id','horse',t.operationId}
        else m.db.outbox.artifact={'event',t.operationId} end
        m.run('clear'); assert(m.last().code=='proof_failed' and next(m.db[kind])~=nil)
    end
end)
test('failed exact deletion rolls back cleanup transaction',function()
    local m=setup(); m.run('run'); m.failClearDelete=true
    m.run('clear'); assert(m.last().code=='proof_failed')
    m.failClearDelete=false; m.run('inspect'); assert(m.last().ok and m.last().rows==3)
end)
test('proof refuses large fixture capacity and unavailable foundation',function()
    local m=setup(); m.env.StablesConfig.ownedHorseLimit=11; m.run('run')
    assert(m.last().code=='proof_failed' and next(m.db.operations)==nil)
    m=setup(); m.env.Stables.Foundation.RequireReady=function() return m.env.Stables.Err('not_ready','Stopped.') end
    m.run('run'); assert(m.last().code=='proof_failed' and next(m.db.operations)==nil)
end)
print(('%d/%d repository proof cases passed; concurrent SQL still requires live testing.'):format(count,count))
