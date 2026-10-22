Stables.Core = {}

-- Keep the caller as bcc-stables: Core derives registration ownership from CFX.
-- This is a narrow consumer, not a second framework service or API registry.
function Stables.Core.Call(method, ...)
    if GetResourceState('feather-core') ~= 'started' then
        return Stables.Err('dependency_unavailable', 'Feather Core is not started.')
    end
    local args = table.pack(...)
    local ok, result = pcall(function()
        local core = exports['feather-core']
        return core[method](core, table.unpack(args, 1, args.n))
    end)
    if not ok then
        print(('[bcc-stables] Core export failed: %s'):format(method))
        return Stables.Err('dependency_error', 'A Feather Core operation failed.', { operation = method })
    end
    if not Stables.IsResult(result) then
        return Stables.Err('invalid_contract', 'Core returned an invalid result envelope.', { operation = method })
    end
    return result
end

-- Core intentionally returns a boolean here, not a result envelope.
function Stables.Core.IsSessionCurrent(session)
    if type(session) ~= 'table' or GetResourceState('feather-core') ~= 'started' then return false end
    local ok, current = pcall(function()
        return exports['feather-core']:IsSessionCurrent(session.source, session.sessionId, session.characterId)
    end)
    return ok and current == true
end

function Stables.Core.RequireSession(source)
    local result = Stables.Core.Call('RequireSession', source)
    if not result.ok then return result end
    local session = result.value
    if type(session) ~= 'table' or session.source ~= source or session.state ~= 'ready'
        or type(session.sessionId) ~= 'string' or session.sessionId == ''
        or type(session.characterId) ~= 'string' or session.characterId == ''
        or type(session.accountId) ~= 'string' or session.accountId == '' then
        return Stables.Err('invalid_contract', 'Core returned an invalid ready session.')
    end
    if not Stables.Core.IsSessionCurrent(session) then
        return Stables.Err('session_stale', 'The character session is no longer current.')
    end
    return Stables.Ok(Stables.Copy(session))
end
