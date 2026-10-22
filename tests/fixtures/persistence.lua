local function copy(v) if type(v) ~= 'table' then return v end; local out = {}; for k,x in pairs(v) do out[k] = copy(x) end; return out end
local function fixture()
    local m = { db = { tables = {}, ledger = {}, characters = {}, operations = {}, horses = {}, history = {}, outbox = {} },
        ready = true, provider = 'started', ddl = 0, clock = 0, outputs = {} }
    local env = setmetatable({}, { __index = _G })
    env.GetResourceState = function() return m.provider end
    env.RegisterCommand = function() end
    env.CreateThread = function(fn) fn() end
    env.print = function(value) m.outputs[#m.outputs + 1] = value end
    local docs, serial = {}, 0
    env.json = { encode = function(value) serial = serial + 1; docs[tostring(serial)] = copy(value); return tostring(serial) end,
        decode = function(value) assert(docs[value], 'invalid JSON'); return copy(docs[value]) end }
    for _, path in ipairs({ 'config.lua', 'shared/contracts.lua', 'server/operations.lua', 'server/migrations.lua' }) do
        assert(loadfile(path, 't', env))()
    end
    local function execute(method, sql, ...)
        local p, db = { ... }, m.db
        if sql:find('CREATE TABLE', 1, true) then
            local name = assert(sql:match('CREATE TABLE IF NOT EXISTS `([a-z_]+)`'))
            if m.failCreate == name then error({code='DDL_FAILED',outcome='not_executed'}) end
            if not db.tables[name] then m.ddl = m.ddl + 1 end
            db.tables[name] = true; return 0
        elseif sql:find('information_schema.TABLES', 1, true) then return db.tables[p[1]] and 1 or 0
        elseif sql == 'SELECT id,checksum,state FROM fs_schema_migrations' then
            local rows = {}; for _,row in pairs(db.ledger) do rows[#rows+1] = copy(row) end; return rows
        elseif sql:find('INSERT IGNORE INTO fs_schema_migrations', 1, true) then
            if db.ledger[p[1]] then return 0 end
            db.ledger[p[1]] = {id=p[1],checksum=p[2],state='pending'}; return 1
        elseif sql:find('SELECT id,checksum,state FROM fs_schema_migrations WHERE', 1, true) then return copy(db.ledger[p[1]])
        elseif sql:find('UPDATE fs_schema_migrations', 1, true) then
            if m.failLedger then return 0 end
            db.ledger[p[1]].state = 'applied'; return 1
        elseif sql:find('INSERT IGNORE INTO fs_character_stables', 1, true) then
            db.characters[p[1]] = db.characters[p[1]] or {character_id=p[1],revision=0}; return 1
        elseif sql:find('SELECT character_id,revision FROM fs_character_stables', 1, true)
            or sql:find('SELECT character_id,selected_horse_id,revision FROM fs_character_stables',1,true)
            or sql:find('SELECT character_id FROM fs_character_stables',1,true) then
            m.locked = p[1]; return copy(db.characters[p[1]])
        elseif sql:find('SELECT * FROM fs_operations WHERE character_id=',1,true) then
            local rows={}
            for _,row in pairs(db.operations) do if row.character_id==p[1] then rows[#rows+1]=copy(row) end end
            table.sort(rows,function(a,b) return a.operation_id<b.operation_id end)
            return rows
        elseif sql:find('SELECT * FROM fs_operations', 1, true) then
            local row = db.operations[p[1]]
            return row and (p[2] == nil or row.character_id == p[2]) and copy(row) or nil
        elseif sql:find('SELECT COUNT(*) FROM fs_horses',1,true) and sql:find(' OR ',1,true) then
            local n=0
            for _,horse in pairs(db.horses) do
                local match=horse.owner_character_id==p[1]
                for index=2,12 do match=match or horse.horse_id==p[index] end
                for index=13,23 do match=match or horse.origin_operation_id==p[index] end
                if match then n=n+1 end
            end
            return n
        elseif sql:find('SELECT COUNT(*) FROM fs_horse_history',1,true) or sql:find('SELECT COUNT(*) FROM fs_outbox',1,true) then
            local history=sql:find('fs_horse_history',1,true)
            local n=0
            for _,row in pairs(history and db.history or db.outbox) do
                for _,id in ipairs(p) do if row[history and 3 or 2]==id then n=n+1; break end end
            end
            return n
        elseif sql:find('SELECT COUNT(*) FROM fs_horses', 1, true) then
            assert(m.inTx and m.locked == p[1], 'capacity read must follow the character lock')
            local n = 0; for _,horse in pairs(db.horses) do if horse.owner_character_id == p[1] then n=n+1 end end; return n
        elseif sql:find('SELECT COUNT(*) FROM fs_operations', 1, true) then
            if sql:find('state NOT IN',1,true) then assert(m.inTx and m.locked == p[1]) end
            local n = 0
            for _,row in pairs(db.operations) do
                if row.character_id==p[1] and (not sql:find('state NOT IN',1,true)
                    or row.state~='fulfilled' and row.state~='cancelled' and row.state~='refunded') then n=n+1 end
            end
            return n
        elseif sql:find('SELECT revision FROM fs_character_stables',1,true) then return db.characters[p[1]] and db.characters[p[1]].revision
        elseif sql:find('UPDATE fs_character_stables SET revision=revision+1',1,true) then
            assert(m.locked==p[1]); db.characters[p[1]].revision=db.characters[p[1]].revision+1; return 1
        elseif sql:find('DELETE FROM fs_operations',1,true) then
            local row=db.operations[p[1]]
            if m.failClearDelete or not row or row.character_id~=p[2] or row.fingerprint~=p[3] or row.state~=p[4]
                or row.revision~=p[5] or row.payment_transaction_id or row.refund_transaction_id then return 0 end
            assert(m.locked==p[2]); db.operations[p[1]]=nil; return 1
        elseif sql:find('DELETE FROM fs_character_stables',1,true) then
            local row=db.characters[p[1]]
            if not row or row.selected_horse_id~=nil or row.revision~=0 then return 0 end
            db.characters[p[1]]=nil; return 1
        elseif sql:find('INSERT INTO fs_operations', 1, true) then
            assert(m.locked == p[2])
            for _,row in pairs(db.operations) do assert(row.horse_id ~= p[3] and row.payment_key ~= p[11], 'unique constraint') end
            assert(not db.operations[p[1]])
            db.operations[p[1]] = {operation_id=p[1],kind='horse_purchase',character_id=p[2],horse_id=p[3],quote_id=p[4],catalog_id=p[5],
                catalog_revision=p[6],currency=p[7],amount=p[8],wallet_account_id=p[9],sink_account_id=p[10],payment_key=p[11],
                fingerprint=p[12],state=p[13],revision=p[14],record_json=p[15]}; return 1
        elseif sql:find('SELECT horse_id FROM fs_horses', 1, true) then
            for _,horse in pairs(db.horses) do if horse.origin_operation_id == p[1] then return {horse_id=horse.horse_id} end end
        elseif sql:find('INSERT INTO fs_horses', 1, true) then
            assert(m.locked == p[2] and not db.horses[p[1]])
            db.horses[p[1]] = {horse_id=p[1],owner_character_id=p[2],origin_operation_id=p[3],catalog_id=p[4],catalog_revision=p[5],availability='stored'}; return 1
        elseif sql:find('INSERT INTO fs_horse_history', 1, true) then
            if m.failHistory then error({code='WRITE_FAILED',outcome='rolled_back'}) end
            db.history[p[1]] = copy(p); return 1
        elseif sql:find('INSERT INTO fs_outbox', 1, true) then db.outbox[p[1]] = copy(p); return 1
        elseif sql:find('UPDATE fs_operations', 1, true) then
            local row = db.operations[p[6]]
            if m.failCas or row.character_id ~= p[7] or row.revision ~= p[8] or row.state ~= p[9] then return 0 end
            row.state,row.revision,row.payment_transaction_id,row.refund_transaction_id,row.record_json = p[1],p[2],p[3],p[4],p[5]; return 1
        else error('Unhandled SQL ' .. sql) end
    end
    env.DB = {awaitReady=function() return m.ready end}
    for _, method in ipairs({'exec','query','one','value'}) do
        env.DB[method] = function(sql,...)
            assert(not m.inTx, 'root DB call inside transaction')
            return execute(method,sql,...)
        end
    end
    env.DB.transaction = function(body)
        local snapshot, tx = copy(m.db), {}
        m.inTx,m.locked = true,nil
        for _,method in ipairs({'exec','query','one','value'}) do tx[method] = function(sql,...) return execute(method,sql,...) end end
        local ok, committed = pcall(body,tx)
        m.inTx,m.locked = false,nil
        if not ok or committed ~= true then m.db = snapshot end
        if not ok then error(committed) end
        if m.unknownCommit and committed then error({code='COMMIT_REPLY_LOST',outcome='unknown'}) end
        return committed == true
    end
    m.env = env
    m.reload = function()
        assert(loadfile('server/persistence.lua','t',env))()
        assert(loadfile('server/repository.lua','t',env))()
        m.p, m.r = env.Stables.Persistence, env.Stables.Repository
    end
    m.reload()
    m.start = function() return m.p.Start() end
    return m
end

return fixture
