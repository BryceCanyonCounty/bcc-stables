local running = false

local function CallSessionCallback()
    local response, completed = nil, false
    exports['feather-core']:CallRPC('stables.session.check.v1', {}, function(...)
        if completed then return end
        response, completed = table.pack(...), true
    end, nil, 5000)
    local started = GetGameTimer()
    while not completed and GetGameTimer() - started < 6000 do Wait(25) end
    completed = true -- Ignore responses after the diagnostic deadline.
    return response
end

RegisterCommand('BccStablesClientSmokeTest', function()
    if running then return end
    running = true
    CreateThread(function()
        local ok, failure = pcall(function()
            local ready = exports['feather-core']:AwaitReady(5000)
            if type(ready) ~= 'table' or ready.ok ~= true then
                print('[bcc-stables] Core client readiness failed: ' .. tostring(type(ready) == 'table' and ready.code or 'invalid_result'))
                return
            end
            -- The callback path preserves Core's nil,error rejection. Capture
            -- it locally instead of returning that tuple through the async export.
            local response = CallSessionCallback()
            if not response then
                print('[bcc-stables] session RPC failed: timeout')
                return
            end
            local result, transportError = response[1], response[2]
            if result == nil and type(transportError) == 'table' and type(transportError.code) == 'string' then
                print('[bcc-stables] session RPC failed: ' .. transportError.code)
                return
            end
            if type(result) ~= 'table' or result.ok ~= true then
                local code = type(result) == 'table' and result.code or nil
                if type(code) == 'string' then
                    print('[bcc-stables] session RPC failed: ' .. code)
                else
                    print(('[bcc-stables] session RPC failed: invalid_result (diagnostic=2, result=%s, transportError=%s)')
                        :format(type(result), type(transportError)))
                end
                return
            end
            if type(result.value) ~= 'table' or result.value.sessionCurrent ~= true
                or result.value.gameplayAvailable ~= false then
                print('[bcc-stables] session RPC failed: invalid_result')
                return
            end
            print('[bcc-stables] session RPC PASS; gameplayAvailable=' .. tostring(result.value.gameplayAvailable))
        end)
        running = false
        if not ok then print('[bcc-stables] client diagnostic failed: ' .. tostring(failure)) end
    end)
end, false)

local function DescribeResponse(path, values)
    local first, second = values[1], values[2]
    local code = type(first) == 'table' and first.code or nil
    if type(code) ~= 'string' then code = type(second) == 'table' and second.code or nil end
    local outcome = type(first) == 'table' and first.ok == true and 'ok'
        or (type(code) == 'string' and code or 'missing_or_invalid')
    print(('[bcc-stables] compare %s: returns=%d first=%s second=%s outcome=%s')
        :format(path, values.n, type(first), type(second), outcome))
end

-- Compare the two existing Core exports without changing Core or the route's
-- character requirement. Output contains shapes/codes only, never session data.
RegisterCommand('BccStablesRpcCompare', function()
    if running then return end
    running = true
    CreateThread(function()
        local ok, failure = pcall(function()
            local ready = exports['feather-core']:AwaitReady(5000)
            if type(ready) ~= 'table' or ready.ok ~= true then
                print('[bcc-stables] compare aborted: Core client is not ready.')
                return
            end
            print('[bcc-stables] compare diagnostic=3; stay on the same character selection/play state until done.')
            -- Space both requests beyond the route's two-second rate window.
            Wait(2100)
            local callbackResult = CallSessionCallback()
            if callbackResult then DescribeResponse('callback', callbackResult)
            else print('[bcc-stables] compare callback: no callback within 6000ms') end
            Wait(2100)
            local asyncResult = table.pack(exports['feather-core']:CallRPCAsync(
                'stables.session.check.v1', {}, nil, 5000))
            DescribeResponse('async', asyncResult)
            print('[bcc-stables] compare done; no gameplay or authorization state was changed.')
        end)
        running = false
        if not ok then print('[bcc-stables] compare failed: ' .. tostring(failure)) end
    end)
end, false)
