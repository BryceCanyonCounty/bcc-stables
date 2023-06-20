local VORPcore = {}
local VORPInv = {}
TriggerEvent('getCore', function(core)
    VORPcore = core
end)

VORPInv = exports.vorp_inventory:vorp_inventoryApi()

RegisterNetEvent('bcc-stables:GetMyHorses', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid },
    function(horses)
        TriggerClientEvent('bcc-stables:ReceiveHorsesData', _source, horses)
    end)
end)

RegisterNetEvent('bcc-stables:BuyHorse', function(data)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local maxHorses = Config.maxHorses

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid },
    function(horses)
        if #horses >= maxHorses then
            VORPcore.NotifyRightTip(_source, _U('horseLimit') .. maxHorses .. _U('horses'), 5000)
            TriggerClientEvent('bcc-stables:StableMenu', _source)
            return
        end
        Wait(200)

        if data.IsCash then
            local cashPrice = data.Cash
            if Character.money >= cashPrice then
                Character.removeCurrency(0, cashPrice)
            else
                VORPcore.NotifyRightTip(_source, _U('shortCash'), 5000)
                TriggerClientEvent('bcc-stables:StableMenu', _source)
                return
            end
        else
            local goldPrice = data.Gold
            if Character.gold >= goldPrice then
                Character.removeCurrency(1, goldPrice)
            else
                VORPcore.NotifyRightTip(_source, _U('shortGold'), 5000)
                TriggerClientEvent('bcc-stables:StableMenu', _source)
                return
            end
        end
        TriggerClientEvent('bcc-stables:SetHorseName', _source, data, false)
    end)
end)

RegisterNetEvent('bcc-stables:BuyTack', function(data)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter

    if tonumber(data.cashPrice) > 0 and tonumber(data.goldPrice) > 0 then
        if tonumber(data.currencyType) == 0 then
            if Character.money >= data.cashPrice then
                Character.removeCurrency(0, data.cashPrice)
            else
                VORPcore.NotifyRightTip(_source, _U('shortCash'), 5000)
                return
            end
        else
            if Character.gold >= data.goldPrice then
                Character.removeCurrency(1, data.goldPrice)
            else
                VORPcore.NotifyRightTip(_source, _U('shortGold'), 5000)
                return
            end
        end
        VORPcore.NotifyRightTip(_source, _U('purchaseSuccessful'), 5000)
    end
    TriggerClientEvent('bcc-stables:SaveComps', _source)
end)

RegisterNetEvent('bcc-stables:SaveNewHorse', function(data, name)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.execute('INSERT INTO player_horses (identifier, charid, name, model, gender) VALUES (?, ?, ?, ?, ?)', { identifier, charid, tostring(name), data.ModelH, data.gender },
    function(done)
    end)
end)

RegisterNetEvent('bcc-stables:UpdateHorseName', function(data, name)
    local horseId = data.horseId

    MySQL.Async.execute('UPDATE player_horses SET name = ? WHERE id = ?', { name, horseId },
    function(done)
    end)
end)

RegisterNetEvent('bcc-stables:SelectHorse', function(id)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid },
    function(horse)
        for i = 1, #horse do
            local horseId = horse[i].id
            MySQL.Async.execute('UPDATE player_horses SET selected = ? WHERE identifier = ? AND charid = ? AND id = ?', { 0, identifier, charid, horseId },
            function(done)
                if horse[i].id == id then
                    MySQL.Async.execute('UPDATE player_horses SET selected = ? WHERE identifier = ? AND charid = ? AND id = ?', { 1, identifier, charid, id },
                    function(done)
                    end)
                end
            end)
        end
    end)
end)

RegisterNetEvent('bcc-stables:GetSelectedHorse', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid },
    function(horses)
        if #horses ~= 0 then
            for i = 1, #horses do
                if horses[i].selected == 1 then
                    TriggerClientEvent('bcc-stables:SetHorseInfo', _source, horses[i].model, horses[i].name, horses[i].components, horses[i].id, horses[i].gender)
                end
            end
        else
            VORPcore.NotifyRightTip(_source, _U('noHorses'), 5000)
        end
    end)
end)

RegisterNetEvent('bcc-stables:UpdateComponents', function(components, horseId, MyHorse_entity)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local encodedComponents = json.encode(components)

    MySQL.Async.execute('UPDATE player_horses SET components = ? WHERE identifier = ? AND charid = ? AND id = ?', { encodedComponents, identifier, charid, horseId },
    function(done)
        TriggerClientEvent('bcc-stables:SetComponents', _source, MyHorse_entity, components)
    end)
end)

RegisterNetEvent('bcc-stables:SellHorse', function(id)
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
                MySQL.Async.execute('DELETE FROM player_horses WHERE identifier = ? AND charid = ? AND id = ?', { identifier, charid, id },
                function(done)
                    for _, horseConfig in pairs(Config.Horses) do
                        for models, values in pairs(horseConfig.colors) do
                            if models == modelHorse then
                                local sellPrice = (Config.sellPrice * values.cashPrice)
                                Character.addCurrency(0, sellPrice)
                                VORPcore.NotifyRightTip(_source, _U('soldHorse') .. sellPrice, 5000)
                            end
                        end
                    end
                end)
            end
        end
    end)
end)

-- Inventory
RegisterNetEvent('bcc-stables:RegisterInventory', function(id)
    VORPInv.registerInventory('horse_' .. tostring(id), _U('horseInv'), tonumber(Config.invLimit), true, false, true)
end)

RegisterNetEvent('bcc-stables:OpenInventory', function(id)
    local _source = source
    VORPInv.OpenInv(_source, 'horse_' .. tostring(id))
end)

-- Horse Care
VORPInv.RegisterUsableItem('consumable_haycube', function(data)
    local _source = data.source
    local item = 'consumable_haycube'
    VORPInv.CloseInv(_source)
    TriggerClientEvent('bcc-stables:FeedHorse', _source, item)
end)

RegisterNetEvent('bcc-stables:RemoveItem', function(item)
    local _source = source
    VORPInv.subItem(_source, item, 1)
end)

VORPInv.RegisterUsableItem('horsebrush', function(data)
    local _source = data.source
    VORPInv.CloseInv(_source)
    TriggerClientEvent('bcc-stables:BrushHorse', _source, data)
end)

-- Job Check
RegisterNetEvent('bcc-stables:GetPlayerJob', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local CharacterJob = Character.job
    local CharacterGrade = Character.jobGrade

    TriggerClientEvent('bcc-stables:SendPlayerJob', _source, CharacterJob, CharacterGrade)
end)
