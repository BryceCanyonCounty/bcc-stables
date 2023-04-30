local VORPcore = {}
local VORPInv = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

VORPInv = exports.vorp_inventory:vorp_inventoryApi()

RegisterServerEvent('bcc-stables:GetMyHorses')
AddEventHandler('bcc-stables:GetMyHorses', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid },
        function(horses)
            TriggerClientEvent('bcc-stables:ReceiveHorsesData', _source, horses)
        end)
end)

RegisterServerEvent('bcc-stables:BuyHorse')
AddEventHandler('bcc-stables:BuyHorse', function(data)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local maxHorses = Config.maxHorses

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid },
        function(horses)
            if #horses >= maxHorses then
                VORPcore.NotifyRightTip(_source, _U("horseLimit") .. maxHorses .. _U("horses"), 5000)
                TriggerClientEvent('bcc-stables:StableMenu', _source)
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
                    TriggerClientEvent('bcc-stables:StableMenu', _source)
                    return
                end
            else
                local charGold = Character.gold
                local goldPrice = data.Gold

                if charGold >= goldPrice then
                    Character.removeCurrency(1, goldPrice)
                else
                    VORPcore.NotifyRightTip(_source, _U("shortGold"), 5000)
                    TriggerClientEvent('bcc-stables:StableMenu', _source)
                    return
                end
            end
            local action = "newHorse"
            TriggerClientEvent('bcc-stables:SetHorseName', _source, data, action)
        end)
end)

RegisterServerEvent('bcc-stables:BuyTack')
AddEventHandler('bcc-stables:BuyTack', function(data)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter

    if tonumber(data.cashPrice) > 0 and tonumber(data.goldPrice) > 0 then
        if tonumber(data.currencyType) == 0 then
            local charCash = Character.money
            if charCash >= data.cashPrice then
                Character.removeCurrency(0, data.cashPrice)
            else
                VORPcore.NotifyRightTip(_source, _U("shortCash"), 5000)
                return
            end
        else
            local charGold = Character.gold

            if charGold >= data.goldPrice then
                Character.removeCurrency(1, data.goldPrice)
            else
                VORPcore.NotifyRightTip(_source, _U("shortGold"), 5000)
                return
            end
        end
        VORPcore.NotifyRightTip(_source, _U("purchaseSuccessful"), 5000)
    end

    TriggerClientEvent('bcc-stables:SaveComps', _source)
end)

RegisterServerEvent('bcc-stables:SaveNewHorse')
AddEventHandler('bcc-stables:SaveNewHorse', function(data, name)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.execute('INSERT INTO player_horses (identifier, charid, name, model) VALUES (?, ?, ?, ?)',
        { identifier, charid, tostring(name), data.ModelH },
        function(done)
        end)
end)

RegisterServerEvent('bcc-stables:UpdateHorseName')
AddEventHandler('bcc-stables:UpdateHorseName', function(data, name)
    local horseId = data.horseId

    MySQL.Async.execute('UPDATE player_horses SET name = ? WHERE id = ?', { name, horseId },
        function(done)
        end)
end)

RegisterServerEvent('bcc-stables:SelectHorse')
AddEventHandler('bcc-stables:SelectHorse', function(id)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid },
        function(horse)
            for i = 1, #horse do
                local horseId = horse[i].id
                MySQL.Async.execute(
                    'UPDATE player_horses SET selected = ? WHERE identifier = ? AND charid = ? AND id = ?',
                    { 0, identifier, charid, horseId },
                    function(done)
                    end)

                Wait(300)

                if horse[i].id == id then
                    MySQL.Async.execute(
                        'UPDATE player_horses SET selected = ? WHERE identifier = ? AND charid = ? AND id = ?',
                        { 1, identifier, charid, id },
                        function(done)
                        end)
                end
            end
        end)
end)

RegisterServerEvent('bcc-stables:GetSelectedHorse')
AddEventHandler('bcc-stables:GetSelectedHorse', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid },
        function(horses)
            if #horses ~= 0 then
                for i = 1, #horses do
                    if horses[i].selected == 1 then
                        TriggerClientEvent('bcc-stables:SetHorseInfo', _source, horses[i].model, horses[i].name,
                            horses[i].components, horses[i].id)
                    end
                end
            else
                VORPcore.NotifyRightTip(_source, _U("noHorses"), 5000)
            end
        end)
end)

RegisterServerEvent('bcc-stables:UpdateComponents')
AddEventHandler('bcc-stables:UpdateComponents', function(components, horseId, MyHorse_entity)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local encodedComponents = json.encode(components)
    local id = horseId

    MySQL.Async.execute('UPDATE player_horses SET components = ? WHERE identifier = ? AND charid = ? AND id = ?',
        { encodedComponents, identifier, charid, id },
        function(done)
            TriggerClientEvent('bcc-stables:SetComponents', _source, MyHorse_entity, components)
        end)
end)

RegisterServerEvent('bcc-stables:SellHorse')
AddEventHandler('bcc-stables:SellHorse', function(id)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local modelHorse = nil

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid },
        function(horses)
            for i = 1, #horses do
                if tonumber(horses[i].id) == tonumber(id) then
                    modelHorse = horses[i].model
                    MySQL.Async.execute('DELETE FROM player_horses WHERE identifier = ? AND charid = ? AND id = ?',
                        { identifier, charid, id },
                        function(done)
                        end)
                end
            end

            for _, horseConfig in pairs(Config.Horses) do
                for models, values in pairs(horseConfig.colors) do
                    if models == modelHorse then
                        local sellPrice = values.sellPrice
                        Character.addCurrency(0, sellPrice)
                        VORPcore.NotifyRightTip(_source, _U("soldHorse") .. sellPrice, 5000)
                    end
                end
            end
        end)
end)

RegisterServerEvent('bcc-stables:RegisterInventory')
AddEventHandler('bcc-stables:RegisterInventory', function(id)
    VORPInv.registerInventory("horse_" .. tostring(id), _U("horseInv"), tonumber(Config.invLimit))
end)

RegisterServerEvent('bcc-stables:OpenInventory')
AddEventHandler('bcc-stables:OpenInventory', function(id)
    local _source = source

    VORPInv.OpenInv(_source, "horse_" .. tostring(id))
end)

RegisterServerEvent('bcc-stables:GetPlayerItem')
AddEventHandler('bcc-stables:GetPlayerItem', function(item)
    local _source = source
    if item == "brush" then
        local brush = VORPInv.getItem(_source, "horsebrush")
        if brush then
            TriggerClientEvent('bcc-stables:BrushHorse', _source, brush)
        else
            VORPcore.NotifyRightTip(_source, _U("noBrush"), 5000)
        end
    elseif item == "haycube" then
        local haycube = VORPInv.getItem(_source, "consumable_haycube")
        if haycube then
            TriggerClientEvent('bcc-stables:FeedHorse', _source, haycube)
            VORPInv.subItem(_source, "consumable_haycube", 1)
        else
            VORPcore.NotifyRightTip(_source, _U("noHaycube"), 5000)
        end
    end
end)

RegisterServerEvent('bcc-stables:GetPlayerJob')
AddEventHandler('bcc-stables:GetPlayerJob', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local CharacterJob = Character.job
    local CharacterGrade = Character.jobGrade

    TriggerClientEvent('bcc-stables:SendPlayerJob', _source, CharacterJob, CharacterGrade)
end)
