Stables = Stables or {}

function Stables.Ok(value)
    return { ok = true, value = value }
end

function Stables.Err(code, message, details)
    return { ok = false, code = code, message = message, details = details }
end

function Stables.IsResult(value)
    return type(value) == 'table' and (value.ok == true
        or (value.ok == false and type(value.code) == 'string'
            and type(value.message) == 'string'))
end

function Stables.Copy(value)
    if type(value) ~= 'table' then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = Stables.Copy(child) end
    return copy
end

function Stables.IsCallable(value)
    return type(value) == 'function'
        or (type(value) == 'table'
            and type(rawget(value, '__cfx_functionReference')) == 'string')
end

function Stables.EmptyPayload(payload)
    return type(payload) == 'table' and next(payload) == nil,
        'This route accepts an empty object only.'
end

function Stables.ValidTimeout(value)
    return type(value) == 'number' and value == value and value % 1 == 0
        and value >= 0 and value <= 60000
end

Stables.CoreRequirements = {
    lifecycle = 1, health = 1, sessions = 1, rpc = 1, namedRpcAccess = 1,
    events = 1, localization = 1,
}

function Stables.ValidateCore(result)
    if not Stables.IsResult(result) then
        return Stables.Err('invalid_contract', 'Core returned an invalid capability envelope.')
    end
    if not result.ok then return result end
    local caps = result.value
    if type(caps) ~= 'table' or caps.resource ~= 'feather-core' or caps.contract ~= 1
        or caps.state ~= 'ready' or type(caps.features) ~= 'table' then
        return Stables.Err('unsupported_contract', 'A ready Feather Core Contract 1 is required.')
    end
    for feature, contract in pairs(Stables.CoreRequirements) do
        if caps.features[feature] ~= contract then
            return Stables.Err('unsupported_contract', 'A required Core feature contract is unavailable.', {
                feature = feature, required = contract,
            })
        end
    end
    return Stables.Ok(Stables.Copy(caps))
end
