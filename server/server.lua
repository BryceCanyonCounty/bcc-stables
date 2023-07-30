local VORPcore = {}
local VORPInv = {}
TriggerEvent('getCore', function(core)
    VORPcore = core
end)
VORPInv = exports.vorp_inventory:vorp_inventoryApi()

VORPcore.addRpcCallback('BuyHorse', function(source, cb, data)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local maxHorses = Config.maxHorses

    local horses = MySQL.query.await('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid })
    if #horses >= maxHorses then
        VORPcore.NotifyRightTip(src, _U('horseLimit') .. maxHorses .. _U('horses'), 4000)
        cb(false)
        return
    end
    if data.IsCash then
        if Character.money >= data.Cash then
            cb(true)
        else
            VORPcore.NotifyRightTip(src, _U('shortCash'), 4000)
            cb(false)
            return
        end
    else
        if Character.gold >= data.Gold then
            cb(true)
        else
            VORPcore.NotifyRightTip(src, _U('shortGold'), 4000)
            cb(false)
            return
        end
    end
end)

RegisterNetEvent('bcc-stables:BuyTack', function(data)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter

    if tonumber(data.cashPrice) > 0 and tonumber(data.goldPrice) > 0 then
        if tonumber(data.currencyType) == 0 then
            if Character.money >= data.cashPrice then
                Character.removeCurrency(0, data.cashPrice)
            else
                VORPcore.NotifyRightTip(src, _U('shortCash'), 4000)
                return
            end
        else
            if Character.gold >= data.goldPrice then
                Character.removeCurrency(1, data.goldPrice)
            else
                VORPcore.NotifyRightTip(src, _U('shortGold'), 4000)
                return
            end
        end
        VORPcore.NotifyRightTip(src, _U('purchaseSuccessful'), 4000)
    end
    TriggerClientEvent('bcc-stables:SaveComps', src)
end)

VORPcore.addRpcCallback('SaveNewHorse', function(source, cb, horseInfo)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.query.await('INSERT INTO player_horses (identifier, charid, name, model, gender) VALUES (?, ?, ?, ?, ?)',
    { identifier, charid, tostring(horseInfo.name), horseInfo.horseData.ModelH, horseInfo.horseData.gender })
    if horseInfo.horseData.IsCash then
        Character.removeCurrency(0, horseInfo.horseData.Cash)
    else
        Character.removeCurrency(1, horseInfo.horseData.Gold)
    end
    cb(true)
end)

VORPcore.addRpcCallback('UpdateHorseName', function(source, cb, horseInfo)
    MySQL.query.await('UPDATE player_horses SET name = ? WHERE id = ?', { horseInfo.name, horseInfo.horseData.horseId })
    cb(true)
end)

RegisterNetEvent('bcc-stables:SelectHorse', function(data)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local id = tonumber(data.horseId)

    local horse = MySQL.query.await('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid })
    for i = 1, #horse do
        local horseId = horse[i].id
        MySQL.query.await('UPDATE player_horses SET selected = ? WHERE identifier = ? AND charid = ? AND id = ?', { 0, identifier, charid, horseId })
        if horse[i].id == id then
            MySQL.query.await('UPDATE player_horses SET selected = ? WHERE identifier = ? AND charid = ? AND id = ?', { 1, identifier, charid, id })
        end
    end
end)

--RegisterNetEvent('bcc-stables:GetSelectedHorse', function()
VORPcore.addRpcCallback("GetHorseData", function(source, cb)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    local horses = MySQL.query.await('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid })
    if #horses ~= 0 then
        for i = 1, #horses do
            if horses[i].selected == 1 then
                local data = {model = horses[i].model, name = horses[i].name, components = horses[i].components, id = horses[i].id, gender = horses[i].gender}
                cb(data)
                --TriggerClientEvent('bcc-stables:SetHorseInfo', src, horses[i].model, horses[i].name, horses[i].components, horses[i].id, horses[i].gender)
            end
        end
    else
        VORPcore.NotifyRightTip(src, _U('noHorses'), 4000)
        cb(false)
    end
end)

RegisterNetEvent('bcc-stables:GetMyHorses', function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    local horses = MySQL.query.await('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid })
    TriggerClientEvent('bcc-stables:ReceiveHorsesData', src, horses)
end)

RegisterNetEvent('bcc-stables:UpdateComponents', function(components, horseId, MyHorse_entity)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local encodedComponents = json.encode(components)

    MySQL.query.await('UPDATE player_horses SET components = ? WHERE identifier = ? AND charid = ? AND id = ?',
    { encodedComponents, identifier, charid, horseId })
    TriggerClientEvent('bcc-stables:SetComponents', src, MyHorse_entity, components)
end)

VORPcore.addRpcCallback('SellMyHorse', function(source, cb, data)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local modelHorse = nil
    local id = tonumber(data.horseId)

    local horses = MySQL.query.await('SELECT * FROM player_horses WHERE identifier = ? AND charid = ?', { identifier, charid })
    for i = 1, #horses do
        if tonumber(horses[i].id) == id then
            modelHorse = horses[i].model
            MySQL.query.await('DELETE FROM player_horses WHERE identifier = ? AND charid = ? AND id = ?', { identifier, charid, id })
        end
    end
    for _, horseConfig in pairs(Config.Horses) do
        for models, values in pairs(horseConfig.colors) do
            if models == modelHorse then
                local sellPrice = (Config.sellPrice * values.cashPrice)
                Character.addCurrency(0, sellPrice)
                VORPcore.NotifyRightTip(src, _U('soldHorse') .. sellPrice, 4000)
                cb(true)
            end
        end
    end
end)

-- Inventory
RegisterNetEvent('bcc-stables:RegisterInventory', function(id)
    VORPInv.registerInventory('horse_' .. tostring(id), _U('horseInv'), tonumber(Config.invLimit), true, false, true)
end)

RegisterNetEvent('bcc-stables:OpenInventory', function(id)
    local src = source
    VORPInv.OpenInv(src, 'horse_' .. tostring(id))
end)

-- Horse Care
VORPInv.RegisterUsableItem('consumable_haycube', function(data)
    local src = data.source
    local item = 'consumable_haycube'
    VORPInv.CloseInv(src)
    TriggerClientEvent('bcc-stables:FeedHorse', src, item)
end)

RegisterNetEvent('bcc-stables:RemoveItem', function(item)
    local src = source
    VORPInv.subItem(src, item, 1)
end)

VORPInv.RegisterUsableItem('horsebrush', function(data)
    local src = data.source
    VORPInv.CloseInv(src)
    TriggerClientEvent('bcc-stables:BrushHorse', src, data)
end)

VORPInv.RegisterUsableItem('oil_lantern', function(data)
    local src = data.source
    VORPInv.CloseInv(src)
    TriggerClientEvent('bcc-stables:UseLantern', src, data)
end)

-- Check if Player has Required Job
VORPcore.addRpcCallback('CheckPlayerJob', function(source, cb, shop)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local playerJob = Character.job
    local jobGrade = Character.jobGrade

    if playerJob then
        for _, job in pairs(Config.shops[shop].allowedJobs) do
            if playerJob == job then
                if tonumber(jobGrade) >= tonumber(Config.shops[shop].jobGrade) then
                    cb(true)
                    return
                end
            end
        end
    end
    VORPcore.NotifyRightTip(src, _U('needJob'), 4000)
    cb(false)
end)

--- Check if properly downloaded
function file_exists(name)
    local f = LoadResourceFile(GetCurrentResourceName(), name)
    return f ~= nil
end

if not file_exists('./ui/index.html') then
    print('^1 INCORRECT DOWNLOAD!  ^0')
    print('^4 Please Download: ^2(bcc-stables.zip) ^4from ^3<https://github.com/BryceCanyonCounty/bcc-stables/releases/latest>^0')
end
