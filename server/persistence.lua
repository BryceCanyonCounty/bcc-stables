Stables.Persistence = {}
local P = Stables.Persistence
local health = { state = 'starting', schemaVersion = 0 }

function P.Checksum(migration)
    local hash = 2166136261
    for _, definition in ipairs(migration.tables) do
        local text = definition.name .. '\n' .. definition.sql .. '\n'
        for index = 1, #text do hash = ((hash ~ text:byte(index)) * 16777619) & 0xffffffff end
    end
    return ('fnv1a32:%08x'):format(hash) -- Drift detection, not a security signature.
end

function P.Health() return Stables.Copy(health) end
function P.Stop() health.state = 'stopped' end
function P.RequireReady()
    if health.state ~= 'ready' or GetResourceState('feather-mysql') ~= 'started' then
        health.state = 'failed'
        return Stables.Err('persistence_unavailable', 'Stables persistence is unavailable; restart in dependency order.')
    end
    return Stables.Ok(P.Health())
end

function P.DatabaseError(failure)
    return Stables.Err('database_error', 'Stables database operation failed; reconcile before retrying a value-bearing operation.', {
        code = type(failure) == 'table' and failure.code or 'LUA_ERROR',
        outcome = type(failure) == 'table' and failure.outcome or 'unknown',
    })
end

local function Exists(name)
    return (tonumber(DB.value([[SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?]], name)) or 0) == 1
end

function P.Start()
    local limit = StablesConfig.ownedHorseLimit
    if type(limit) ~= 'number' or limit % 1 ~= 0 or limit < 1 or limit > 100 then
        return Stables.Err('config_error', 'ownedHorseLimit must be an integer from 1 to 100.')
    end
    local ok, result = pcall(function()
        if not DB.awaitReady(StablesConfig.startupTimeoutMs) then return Stables.Err('database_timeout', 'Database readiness timed out.') end
        if health.state == 'stopped' then return Stables.Err('startup_cancelled', 'Persistence startup was cancelled.') end
        DB.exec([[CREATE TABLE IF NOT EXISTS `fs_schema_migrations` (
            `id` VARCHAR(100) NOT NULL, `checksum` VARCHAR(64) NOT NULL,
            `state` VARCHAR(16) NOT NULL, `applied_at` TIMESTAMP NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin]])
        local known, tables, ledger = {}, {}, {}
        for _, migration in ipairs(Stables.Migrations) do
            if type(migration.id) ~= 'string' or known[migration.id] or #migration.tables == 0 then
                return Stables.Err('invalid_migration', 'Migration definition is invalid.')
            end
            known[migration.id] = P.Checksum(migration)
            for _, definition in ipairs(migration.tables) do
                if not definition.name:match('^fs_[a-z_]+$') or tables[definition.name]
                    or not definition.sql:match('^CREATE TABLE IF NOT EXISTS `' .. definition.name .. '`')
                    or definition.sql:find(';', 1, true) then
                    return Stables.Err('invalid_migration', 'Only owned idempotent CREATE TABLE statements are supported.')
                end
                tables[definition.name] = true
            end
        end
        for _, row in ipairs(DB.query('SELECT id,checksum,state FROM fs_schema_migrations') or {}) do
            if not known[row.id] then return Stables.Err('schema_newer_than_resource', 'Unknown Stables migration; deploy a matching resource version.') end
            if row.checksum ~= known[row.id] then return Stables.Err('migration_checksum_mismatch', 'Restore the original migration and add a new migration for changes.') end
            if row.state ~= 'pending' and row.state ~= 'applied' then return Stables.Err('invalid_migration_ledger', 'Migration ledger state is invalid.') end
            ledger[row.id] = row
        end
        local applied, resumed = 0, 0
        for _, migration in ipairs(Stables.Migrations) do
            local row = ledger[migration.id]
            if not row then
                for _, definition in ipairs(migration.tables) do
                    if Exists(definition.name) then return Stables.Err('untracked_schema', 'Untracked Stables table exists; inspect before adopting or modifying it.') end
                end
                DB.exec("INSERT IGNORE INTO fs_schema_migrations (id,checksum,state) VALUES (?,?,'pending')", migration.id, known[migration.id])
                row = DB.one('SELECT id,checksum,state FROM fs_schema_migrations WHERE id=?', migration.id)
                if not row or row.checksum ~= known[migration.id] then return Stables.Err('migration_checksum_mismatch', 'Migration intent changed.') end
            elseif row.state == 'pending' then resumed = resumed + 1 end
            if row.state ~= 'applied' then
                for _, definition in ipairs(migration.tables) do DB.exec(definition.sql) end
                DB.exec("UPDATE fs_schema_migrations SET state='applied',applied_at=CURRENT_TIMESTAMP WHERE id=? AND checksum=?", migration.id, known[migration.id])
                applied = applied + 1
            end
            local verified = DB.one('SELECT id,checksum,state FROM fs_schema_migrations WHERE id=?', migration.id)
            if not verified or verified.state ~= 'applied' or verified.checksum ~= known[migration.id] then
                return Stables.Err('invalid_migration_ledger', 'Migration completion was not recorded.')
            end
        end
        for name in pairs(tables) do
            if not Exists(name) then return Stables.Err('schema_incomplete', 'An applied Stables table is missing; restore it rather than silently recreating player data.') end
        end
        if health.state == 'stopped' then return Stables.Err('startup_cancelled', 'Persistence startup was cancelled.') end
        return Stables.Ok({ schemaVersion = #Stables.Migrations, applied = applied, resumed = resumed })
    end)
    if not ok then result = P.DatabaseError(result) end
    if not result.ok then health.state, health.failure = 'failed', Stables.Copy(result); return result end
    health = result.value; health.state = 'ready'
    return Stables.Ok(P.Health())
end

-- Read-only schema smoke; no synthetic character, operation, money or horse rows.
RegisterCommand('BccStablesPersistenceSmokeTest', function(source)
    if source ~= 0 then return end
    CreateThread(function()
        local ready = P.RequireReady()
        if not ready.ok then print('[BccStablesPersistenceSmokeTest] FAIL ' .. ready.code); return end
        local ok, result = pcall(function()
            local tests = { { 'persistence ready', P.Health().state == 'ready' } }
            for _, migration in ipairs(Stables.Migrations) do
                local row = DB.one('SELECT id,checksum,state FROM fs_schema_migrations WHERE id=?', migration.id)
                tests[#tests + 1] = { 'migration checksum ' .. migration.id,
                    row and row.state == 'applied' and row.checksum == P.Checksum(migration) }
                for _, definition in ipairs(migration.tables) do tests[#tests + 1] = { definition.name .. ' exists', Exists(definition.name) } end
            end
            local passed = 0
            for _, test in ipairs(tests) do
                if test[2] then passed = passed + 1 end
                print(('[BccStablesPersistenceSmokeTest] %s %s'):format(test[1], test[2] and 'PASS' or 'FAIL'))
            end
            print(('[BccStablesPersistenceSmokeTest] %d/%d; schema reads only'):format(passed, #tests))
        end)
        if not ok then print('[BccStablesPersistenceSmokeTest] FAIL database_error') end
    end)
end, true)
