local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

RegisterNetEvent('oss_stables:BuyHorse')
AddEventHandler('oss_stables:BuyHorse', function(data, name)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = @identifier AND charid = @charid', {
        ['@identifier'] = identifier,
        ['@charid'] = charid
    }, function(horses)
        if #horses >= 3 then
            VORPcore.NotifyRightTip(_source, "You can have a maximum of 3 horses!", 5000)
            return
        end
        Wait(200)
        if data.IsGold then
            local charGold = Character.gold
            local goldPrice = data.Gold

            if charGold >= goldPrice then
                Character.removeCurrency(1, goldPrice)
            else
                VORPcore.NotifyRightTip(_source, "You don't have enough gold", 5000)
                return
            end
        else
            local charCash = Character.money
            local cashPrice = data.Dollar

            if charCash >= cashPrice then
                Character.removeCurrency(0, cashPrice)
            else
                VORPcore.NotifyRightTip(_source, "You don't have enough money", 5000)
                return
            end
        end

        MySQL.Async.execute('INSERT INTO player_horses (identifier, charid, name, model) VALUES (@identifier, @charid, @name, @model)', {
            ['@identifier'] = identifier,
            ['@charid'] = charid,
            ['@name'] = tostring(name),
            ['@model'] = data.ModelH
        }, function(rowsChanged)
        end)
    end)
end)

RegisterNetEvent('oss_stables:UpdateHorseComponents')
AddEventHandler('oss_stables:UpdateHorseComponents', function(components, idhorse, MyHorse_entity)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local encodedComponents = json.encode(components)
    local id = idhorse

    MySQL.Async.execute('UPDATE player_horses SET components = @encodedComponents WHERE identifier = @identifier AND charid = @charid AND id = @id', {
        ['@identifier'] = identifier,
        ['@charid'] = charid,
        ['@id'] = id,
        ['@encodedComponents'] = encodedComponents
    }, function(done)
        TriggerClientEvent('oss_stables:UpdateHorseComponents', _source, MyHorse_entity, components)
    end)
end)


RegisterNetEvent('oss_stables:GetSelectedHorse')
AddEventHandler('oss_stables:GetSelectedHorse', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = @identifier AND charid = @charid', {
        ['@identifier'] = identifier,
        ['@charid'] = charid
    }, function(horses)
        if #horses ~= 0 then
            for i = 1, #horses do
                if horses[i].selected == 1 then
                    TriggerClientEvent('oss_stables:SetHorseInfo', _source, horses[i].model, horses[i].name, horses[i].components)
                end
            end
        end
    end)
end)

RegisterNetEvent('oss_stables:AskForMyHorses')
AddEventHandler('oss_stables:AskForMyHorses', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local horseId = nil
	local components = nil

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = @identifier AND charid = @charid', {
        ['@identifier'] = identifier,
        ['@charid'] = charid
    }, function(horses)
        if horses[1] then
            horseId = horses[1].id
        else
            horseId = nil
        end

        MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = @identifier AND charid = @charid', {
            ['@identifier'] = identifier,
            ['@charid'] = charid
        }, function(components)
            if components[1] then
                components = components[1].components
            end
        end)
        TriggerClientEvent('oss_stables:ReceiveHorsesData', _source, horses)
    end)
end)

RegisterNetEvent('oss_stables:SelectHorseWithId')
AddEventHandler('oss_stables:SelectHorseWithId', function(id)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = @identifier AND charid = @charid', {
        ['@identifier'] = identifier,
        ['@charid'] = charid
    }, function(horse)
        for i = 1, #horse do
            local horseID = horse[i].id
            MySQL.Async.execute('UPDATE player_horses SET selected = "0" WHERE identifier = @identifier AND charid = @charid AND id = @id', {
                ['@identifier'] = identifier,
                ['@charid'] = charid,
                ['@id'] = horseID
            }, function(done)
            end)

            Wait(300)

            if horse[i].id == id then
                MySQL.Async.execute('UPDATE player_horses SET selected = "1" WHERE identifier = @identifier AND charid = @charid AND id = @id', {
                    ['@identifier'] = identifier,
                    ['@charid'] = charid,
                    ['@id'] = id
                }, function(done)
                    TriggerClientEvent('oss_stables:SetHorseInfo', _source, horse[i].model, horse[i].name, horse[i].components)
                end)
            end
        end
    end)
end)

RegisterNetEvent('oss_stables:SellHorseWithId')
AddEventHandler('oss_stables:SellHorseWithId', function(id)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local modelHorse = nil

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = @identifier AND charid = @charid', {
        ['@identifier'] = identifier,
        ['@charid'] = charid
    }, function(horses)
        for i = 1, #horses do
            if tonumber(horses[i].id) == tonumber(id) then
                modelHorse = horses[i].model
                MySQL.Async.execute('DELETE FROM player_horses WHERE identifier = @identifier AND charid = @charid AND id = @id', {
                    ['@identifier'] = identifier,
                    ['@charid'] = charid,
                    ['@id'] = id
                }, function(result)
                end)
            end
        end

        for k,v in pairs(Config.Horses) do
            for models,values in pairs(v) do
                if models ~= "name" then
                    if models == modelHorse then
                        Character.addCurrency(0, tonumber(values[3]*0.6))
                        VORPcore.NotifyRightTip(_source, "You sold a horse", 5000)
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent('oss_stables:getPlayerJob')
AddEventHandler('oss_stables:getPlayerJob', function()
    local _source = source
    if _source then
        local Character = VORPcore.getUser(_source).getUsedCharacter
        local CharacterJob = Character.job
        local CharacterGrade = Character.jobGrade

        TriggerClientEvent('oss_stables:sendPlayerJob', _source, CharacterJob, CharacterGrade)
    end
end)
