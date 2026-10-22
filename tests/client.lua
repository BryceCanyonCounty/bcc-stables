-- Exercise the actual F8 command, including Core's nil,error transport return.
local function fixture(response, dropCallback)
    local env = setmetatable({}, { __index = _G })
    local command, output = nil, {}
    env.print = function(message) output[#output + 1] = message end
    env.RegisterCommand = function(name, callback)
        if name == 'BccStablesClientSmokeTest' then command = callback end
    end
    env.CreateThread = function(callback) callback() end
    local now = 0
    env.GetGameTimer = function() return now end
    env.Wait = function(ms) now = now + ms end
    env.exports = { ['feather-core'] = {
        AwaitReady = function() return { ok = true } end,
        CallRPCAsync = function() error('Smoke test must use the callback API') end,
        CallRPC = function(_, name, payload, callback, source, timeout)
            assert(name == 'stables.session.check.v1' and next(payload) == nil)
            assert(source == nil and timeout == 5000)
            if not dropCallback then callback(response()) end
        end,
    } }
    assert(loadfile('client/diagnostics.lua', 't', env))()
    return command, output
end

local cases = {
    { 'active session', function() return { ok = true, value = { sessionCurrent = true, gameplayAvailable = false } } end,
        'session RPC PASS; gameplayAvailable=false' },
    { 'no character gate', function() return nil, { code = 'character_required', message = 'Select a character.' } end,
        'session RPC failed: character_required' },
    { 'expired session gate', function() return nil, { code = 'character_session_expired' } end,
        'session RPC failed: character_session_expired' },
    { 'transport timeout', function() return nil, { code = 'timeout' } end,
        'session RPC failed: timeout' },
    { 'handler rejection envelope', function() return { ok = false, code = 'session_stale' } end,
        'session RPC failed: session_stale' },
    { 'malformed success', function() return { ok = true } end,
        'session RPC failed: invalid_result' },
    { 'missing response', function() return nil end,
        'session RPC failed: invalid_result (diagnostic=2, result=nil, transportError=nil)' },
}

for _, case in ipairs(cases) do
    local command, output = fixture(case[2])
    command()
    assert(output[1] == '[bcc-stables] ' .. case[3], case[1] .. ': ' .. tostring(output[1]))
    -- Each invocation releases the in-flight guard, including rejection paths.
    command()
    assert(#output == 2, case[1] .. ': command remained locked')
    print('PASS client ' .. case[1])
end

local command, output = fixture(nil, true)
command()
assert(output[1] == '[bcc-stables] session RPC failed: timeout')
command()
assert(#output == 2, 'missing callback must release the in-flight gate')
print('PASS client missing callback bounded timeout')
print(('%d/%d client diagnostic cases passed.'):format(#cases + 1, #cases + 1))
