local F = Stables.Foundation

exports('GetCapabilities', F.Capabilities)
exports('GetHealth', F.Health)
exports('AwaitReady', F.AwaitReady)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then F.Stop()
    elseif resource == 'feather-core' then F.CoreStopped() end
    if resource == 'feather-mysql' then F.DatabaseStopped() end
end)

RegisterCommand('BccStablesStatus', function(source)
    if source ~= 0 then return end
    print('[bcc-stables] ' .. json.encode(F.Health().value))
end, true)

-- Read-only production diagnostics; no fixture horses, accounts or item grants.
RegisterCommand('BccStablesContractSmokeTest', function(source)
    if source ~= 0 then return end
    local ready = F.RequireReady()
    local caps = F.Capabilities().value
    local routes = Stables.Core.Call('GetRpcRoutes')
    local route
    if routes.ok and type(routes.value) == 'table' then
        for _, candidate in ipairs(routes.value) do
            if candidate.route == 'stables.session.check.v1' then route = candidate end
        end
    end
    local tests = {
        { 'foundation ready', ready.ok },
        { 'capabilities', caps.contract == 1 and caps.features.sessionDiagnostics == 1 },
        { 'gameplay not advertised', caps.features.horses == nil and caps.features.commerce == nil },
        { 'owned session route', route and route.owner == GetCurrentResourceName() and route.contract == 1 },
        { 'bounded character route', route and route.requireCharacter == true
            and route.maxPayloadBytes == 64 and route.maxDepth == 2 and route.maxNodes == 4 },
        { 'payload validation', Stables.EmptyPayload({}) and not Stables.EmptyPayload({ characterId = 'spoofed' }) },
    }
    local passed = 0
    for _, test in ipairs(tests) do
        if test[2] then passed = passed + 1 end
        print(('[BccStablesContractSmokeTest] %s %s'):format(test[1], test[2] and 'PASS' or 'FAIL'))
    end
    print(('[BccStablesContractSmokeTest] %d/%d passed'):format(passed, #tests))
end, true)

CreateThread(function()
    local result = F.Start()
    if not result.ok then
        print(('[bcc-stables] startup failed [%s]: %s'):format(result.code, result.message))
        return
    end
    print('[bcc-stables] foundation ready; horse gameplay is not implemented.')
end)
