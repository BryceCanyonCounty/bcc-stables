local function fixture(callbackReply, asyncReply, dropCallback)
    local env = setmetatable({}, { __index = _G })
    local commands, output, now, calls = {}, {}, 0, 0
    env.print = function(message) output[#output + 1] = message end
    env.RegisterCommand = function(name, callback) commands[name] = callback end
    env.CreateThread = function(callback) callback() end
    env.Wait = function(ms) now = now + ms end
    env.GetGameTimer = function() return now end
    env.exports = { ['feather-core'] = {
        AwaitReady = function() return { ok = true } end,
        CallRPC = function(_, name, payload, callback, source, timeout)
            assert(name == 'stables.session.check.v1' and next(payload) == nil)
            assert(source == nil and timeout == 5000 and now >= 2100)
            calls = calls + 1
            if not dropCallback then callback(table.unpack(callbackReply, 1, callbackReply.n)) end
        end,
        CallRPCAsync = function(_, name, payload, source, timeout)
            assert(name == 'stables.session.check.v1' and next(payload) == nil)
            assert(source == nil and timeout == 5000 and now >= 4200)
            calls = calls + 1
            return table.unpack(asyncReply, 1, asyncReply.n)
        end,
    } }
    assert(loadfile('client/diagnostics.lua', 't', env))()
    return commands.BccStablesRpcCompare, output, function() return now, calls end
end

local cases = {
    { 'callback preserves rejection but async loses returns',
        table.pack(nil, { code = 'character_required' }), table.pack(),
        'returns=2 first=nil second=table outcome=character_required',
        'returns=0 first=nil second=nil outcome=missing_or_invalid' },
    { 'both paths preserve rejection',
        table.pack(nil, { code = 'character_required' }), table.pack(nil, { code = 'character_required' }),
        'returns=2 first=nil second=table outcome=character_required',
        'returns=2 first=nil second=table outcome=character_required' },
    { 'both paths return success',
        table.pack({ ok = true, value = { private = 'never print' } }), table.pack({ ok = true }),
        'returns=1 first=table second=nil outcome=ok', 'returns=1 first=table second=nil outcome=ok' },
}
for _, case in ipairs(cases) do
    local command, output, state = fixture(case[2], case[3])
    command()
    assert(output[2] == '[bcc-stables] compare callback: ' .. case[4], case[1])
    assert(output[3] == '[bcc-stables] compare async: ' .. case[5], case[1])
    assert(not table.concat(output):find('never print', 1, true))
    local time, calls = state()
    assert(time == 4200 and calls == 2)
    command() -- The command remains usable after a complete comparison.
    assert(#output == 8)
    print('PASS comparison ' .. case[1])
end
local command, output, state = fixture(nil, table.pack(nil), true)
command()
assert(output[2] == '[bcc-stables] compare callback: no callback within 6000ms')
assert(state() == 10200)
assert(output[3] == '[bcc-stables] compare async: returns=1 first=nil second=nil outcome=missing_or_invalid')
print('PASS comparison callback deadline')
print('4/4 RPC comparison cases passed.')
