local VORPcore = {}
local VORPInv = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

VORPInv = exports.vorp_inventory:vorp_inventoryApi()

RegisterServerEvent('oss_stables:GetMyHorses')
AddEventHandler('oss_stables:GetMyHorses', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', {identifier, charid},
    function(horses)
        TriggerClientEvent('oss_stables:ReceiveHorsesData', _source, horses)
    end)
end)

RegisterServerEvent('oss_stables:BuyHorse')
AddEventHandler('oss_stables:BuyHorse', function(data)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local maxHorses = Config.maxHorses

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', {identifier, charid},
    function(horses)
        if #horses >= maxHorses then
            VORPcore.NotifyRightTip(_source, _U("horseLimit") .. maxHorses .. _U("horses"), 5000)
            TriggerClientEvent('oss_stables:StableMenu', _source)
            return
        end

        Wait(200)

        if data.IsCash then
            local charCash = Character.money
            local cashPrice = data.Cash

            if charCash >= cashPrice then
                Character.removeCurrency(0, cashPrice)
            else
                VORPcore.NotifyRightTip(_source, _U("shortCash"), 5000)
                TriggerClientEvent('oss_stables:StableMenu', _source)
                return
            end

        else
            local charGold = Character.gold
            local goldPrice = data.Gold

            if charGold >= goldPrice then
                Character.removeCurrency(1, goldPrice)
            else
                VORPcore.NotifyRightTip(_source, _U("shortGold"), 5000)
                TriggerClientEvent('oss_stables:StableMenu', _source)
                return
            end
        end

        TriggerClientEvent('oss_stables:SetHorseName', _source, data)
    end)
end)

RegisterServerEvent('oss_stables:SaveNewHorse')
AddEventHandler('oss_stables:SaveNewHorse', function(data, name)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.execute('INSERT INTO player_horses (identifier, charid, name, model) VALUES (?, ?, ?, ?)', {identifier, charid, tostring(name), data.ModelH},
        function(done)
    end)
end)

RegisterServerEvent('oss_stables:SelectHorse')
AddEventHandler('oss_stables:SelectHorse', function(id)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', {identifier, charid},
    function(horse)
        for i = 1, #horse do
            local horseID = horse[i].id
            MySQL.Async.execute('UPDATE player_horses SET selected = ? WHERE identifier = ? AND charid = ? AND id = ?', {0, identifier, charid, horseID},
            function(done)
            end)

            Wait(300)

            if horse[i].id == id then
                MySQL.Async.execute('UPDATE player_horses SET selected = ? WHERE identifier = ? AND charid = ? AND id = ?', {1, identifier, charid, id},
                function(done)
                    TriggerClientEvent('oss_stables:SetHorseInfo', _source, horse[i].model, horse[i].name, horse[i].components)
                end)
            end
        end
    end)
end)

RegisterServerEvent('oss_stables:GetSelectedHorse')
AddEventHandler('oss_stables:GetSelectedHorse', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', {identifier, charid},
    function(horses)
        if #horses ~= 0 then
            for i = 1, #horses do
                if horses[i].selected == 1 then
                    TriggerClientEvent('oss_stables:SetHorseInfo', _source, horses[i].id, horses[i].model, horses[i].name, horses[i].components)
                end
            end
        end
    end)
end)

RegisterServerEvent('oss_stables:UpdateComponents')
AddEventHandler('oss_stables:UpdateComponents', function(components, horseId, MyHorse_entity)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local encodedComponents = json.encode(components)
    local id = horseId

    MySQL.Async.execute('UPDATE player_horses SET components = ? WHERE identifier = ? AND charid = ? AND id = ?', {encodedComponents, identifier, charid, id},
    function(done)
        TriggerClientEvent('oss_stables:SetComponents', _source, MyHorse_entity, components)
    end)
end)

RegisterServerEvent('oss_stables:SellHorse')
AddEventHandler('oss_stables:SellHorse', function(id)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local modelHorse = nil

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', {identifier, charid},
    function(horses)
        for i = 1, #horses do
            if tonumber(horses[i].id) == tonumber(id) then
                modelHorse = horses[i].model
                MySQL.Async.execute('DELETE FROM player_horses WHERE identifier = ? AND charid = ? AND id = ?', {identifier, charid, id},
                function(done)
                end)
            end
        end

        for _,horseConfig in pairs(Config.Horses) do
            for models,values in pairs(horseConfig) do
                if models ~= "breed" then
                    if models == modelHorse then
                        local sellPrice = values.sellPrice
                        Character.addCurrency(0, sellPrice)
                        VORPcore.NotifyRightTip(_source, _U("soldHorse") .. sellPrice, 5000)
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent('oss_stables:RegisterInventory')
AddEventHandler('oss_stables:RegisterInventory', function(id)

    VORPInv.registerInventory("horse_" .. tostring(id), _U("horseInv"), tonumber(Config.invLimit))
end)

RegisterServerEvent('oss_stables:OpenInventory')
AddEventHandler('oss_stables:OpenInventory', function(id)
    local _source = source

    VORPInv.OpenInv(_source, "horse_" .. tostring(id))
end)

RegisterServerEvent('oss_stables:GetPlayerItem')
AddEventHandler('oss_stables:GetPlayerItem', function(item)
    local _source = source
    if item == "brush" then
        local brush = VORPInv.getItem(_source, "horsebrush")
        if brush then
            TriggerClientEvent('oss_stables:BrushHorse', _source, brush)
        else
            VORPcore.NotifyRightTip(_source, _U("noBrush"), 5000)
        end

    elseif item == "haycube" then
        local haycube = VORPInv.getItem(_source, "consumable_haycube")
        if haycube then
            TriggerClientEvent('oss_stables:FeedHorse',_source, haycube)
            VORPInv.subItem(_source, "consumable_haycube", 1)
        else
            VORPcore.NotifyRightTip(_source, _U("noHaycube"), 5000)
        end
    end
end)

RegisterServerEvent('oss_stables:GetPlayerJob')
AddEventHandler('oss_stables:GetPlayerJob', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local CharacterJob = Character.job
    local CharacterGrade = Character.jobGrade

    TriggerClientEvent('oss_stables:SendPlayerJob', _source, CharacterJob, CharacterGrade)
end)
