local VORPcore = exports.vorp_core:GetCore()

local CooldownData = {}

VORPcore.Callback.Register('bcc-stables:BuyHorse', function(source, cb, data)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local charid = Character.charIdentifier
    local maxHorses = tonumber(Config.maxPlayerHorses)
    if data.isTrainer then
        maxHorses = tonumber(Config.maxTrainerHorses)
    end
    local horses = MySQL.query.await('SELECT * FROM `player_horses` WHERE `charid` = ? AND `dead` = ?', { charid, 0 })
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
        end
    else
        if Character.gold >= data.Gold then
            cb(true)
        else
            VORPcore.NotifyRightTip(src, _U('shortGold'), 4000)
            cb(false)
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

VORPcore.Callback.Register('bcc-stables:SaveNewHorse', function(source, cb, data)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.query.await('INSERT INTO `player_horses` (identifier, charid, name, model, gender, captured) VALUES (?, ?, ?, ?, ?, ?)',
        { identifier, charid, tostring(data.name), data.ModelH, data.gender,  data.captured })

    if data.IsCash then
        Character.removeCurrency(0, data.Cash)
    else
        Character.removeCurrency(1, data.Gold)
    end
    cb(true)
end)

VORPcore.Callback.Register('bcc-stables:UpdateHorseName', function(source, cb, data)
    MySQL.query.await('UPDATE `player_horses` SET `name` = ? WHERE `id` = ?', { data.name, data.horseId })
    cb(true)
end)

RegisterServerEvent('bcc-stables:UpdateHorseXp', function(Xp, horseId)
    MySQL.query.await('UPDATE `player_horses` SET `xp` = ? WHERE `id` = ?', { Xp, horseId })
end)

RegisterServerEvent('bcc-stables:SaveHorseStats', function(data, horseId)
    MySQL.query.await('UPDATE `player_horses` SET `health` = ?, `stamina` = ? WHERE id = ?', { data.health, data.stamina, horseId })
end)

RegisterServerEvent('bcc-stables:SelectHorse', function(data)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local charid = Character.charIdentifier
    local id = tonumber(data.horseId)

    local horse = MySQL.query.await('SELECT * FROM `player_horses` WHERE `charid` = ? AND `dead` = ?', { charid, 0 })
    for i = 1, #horse do
        local horseId = horse[i].id
        MySQL.query.await('UPDATE `player_horses` SET `selected` = ? WHERE `charid` = ? AND `id` = ?', { 0, charid, horseId })
        if horse[i].id == id then
            MySQL.query.await('UPDATE `player_horses` SET `selected` = ? WHERE `charid` = ? AND `id` = ?', { 1, charid, id })
        end
    end
end)

VORPcore.Callback.Register('bcc-stables:DeselectHorse', function(source, cb, horseId)

    MySQL.query.await('UPDATE `player_horses` SET `selected` = ? WHERE `id` = ?', { 0, horseId })
    cb(true)
end)

VORPcore.Callback.Register('bcc-stables:SetHorseDead', function(source, cb, horseId)

    MySQL.query.await('UPDATE `player_horses` SET `selected` = ?, `dead` = ? WHERE `id` = ?', { 0, 1, horseId })
    cb(true)
end)

VORPcore.Callback.Register('bcc-stables:GetHorseData', function(source, cb)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local charid = Character.charIdentifier
    local data = nil

    local horses = MySQL.query.await('SELECT * FROM `player_horses` WHERE `charid` = ? AND `dead` = ?', { charid, 0 })
    if #horses ~= 0 then
        for i = 1, #horses do
            if horses[i].selected == 1 then
                data = {
                    model = horses[i].model,
                    name = horses[i].name,
                    components = horses[i].components,
                    id = horses[i].id,
                    gender = horses[i].gender,
                    xp = horses[i].xp,
                    captured = horses[i].captured,
                    health = horses[i].health,
                    stamina = horses[i].stamina
                }
                cb(data)
            end
        end
        if data == nil then
            VORPcore.NotifyRightTip(src, _U('noSelectedHorse'), 4000)
            cb(false)
        end
    else
        VORPcore.NotifyRightTip(src, _U('noHorses'), 4000)
        cb(false)
    end
end)

RegisterNetEvent('bcc-stables:GetMyHorses', function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local charid = Character.charIdentifier

    local horses = MySQL.query.await('SELECT * FROM `player_horses` WHERE `charid` = ? AND `dead` = ?', { charid, 0 })
    TriggerClientEvent('bcc-stables:ReceiveHorsesData', src, horses)
end)

RegisterNetEvent('bcc-stables:UpdateComponents', function(components, horseId, MyHorse_entity)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local charid = Character.charIdentifier
    local encodedComponents = json.encode(components)

    MySQL.query.await('UPDATE `player_horses` SET `components` = ? WHERE `charid` = ? AND `id` = ?', { encodedComponents, charid, horseId })
    TriggerClientEvent('bcc-stables:SetComponents', src, MyHorse_entity, components)
end)

VORPcore.Callback.Register('bcc-stables:SellMyHorse', function(source, cb, data)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local charid = Character.charIdentifier
    local modelHorse = nil
    local id = tonumber(data.horseId)
    local captured = data.captured
    local horses = MySQL.query.await('SELECT * FROM `player_horses` WHERE `charid` = ? AND `dead` = ?', { charid, 0 })
    for i = 1, #horses do
        if tonumber(horses[i].id) == id then
            modelHorse = horses[i].model
            MySQL.query.await('DELETE FROM `player_horses` WHERE `charid` = ? AND `id` = ?', { charid, id })
        end
    end
    for _, horseCfg in pairs(Horses) do
        for models, values in pairs(horseCfg.colors) do
            if models == modelHorse then
                if captured then
                    local sellPrice = (Config.sellPrice * (values.cashPrice/2))
                    Character.addCurrency(0, math.floor(sellPrice))
                    VORPcore.NotifyRightTip(src, _U('soldHorse') .. sellPrice, 4000)
                    cb(true)
                else
                    local sellPrice = (Config.sellPrice * values.cashPrice)
                    Character.addCurrency(0, sellPrice)
                    VORPcore.NotifyRightTip(src, _U('soldHorse') .. sellPrice, 4000)
                    cb(true)
                end
            end
        end
    end
end)

RegisterServerEvent('bcc-stables:SellTamedHorse', function(horseModel)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local charid = Character.charIdentifier
    for _, horseCfg in pairs(Horses) do
        for model, modelCfg in pairs(horseCfg.colors) do
            local horseHash = joaat(model)
            if horseHash == horseModel then
                local sellPrice = (Config.tamedSellPrice * modelCfg.cashPrice)
                Character.addCurrency(0, math.floor(sellPrice))
                VORPcore.NotifyRightTip(src, _U('soldHorse') .. sellPrice, 4000)
                SetPlayerCooldown('sellTame', charid)
            end
        end
    end
end)

function SetPlayerCooldown(type, charid)
    CooldownData[type .. tostring(charid)] = os.time()
end

VORPcore.Callback.Register('bcc-stables:CheckPlayerCooldown', function(source, cb, type)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local cooldown = Config.cooldown[type]
    local onList = false
    local typeId = type .. tostring(Character.charIdentifier)
    for id, time in pairs(CooldownData) do
        if id == typeId then
            onList = true
            if os.difftime(os.time(), time) >= cooldown * 60 then
                cb(false) -- Not on Cooldown
                break
            else
                cb(true)
                break
            end
        end
    end
    if not onList then
        cb(false)
    end
end)

RegisterServerEvent('bcc-stables:SaveHorseTrade', function(serverId, horseId)
    -- Current Owner
    local src = source
    local curOwner = VORPcore.getUser(src).getUsedCharacter
    local curOwnerName = curOwner.firstname .. " " .. curOwner.lastname
    -- New Owner
    local newOwner = VORPcore.getUser(serverId).getUsedCharacter
    local newOwnerId = newOwner.identifier
    local newOwnerCharId = newOwner.charIdentifier
    local newOwnerName = newOwner.firstname .. " " .. newOwner.lastname
    MySQL.query.await('UPDATE `player_horses` SET `identifier` = ?, `charid` = ?, `selected` = ? WHERE `id` = ?', { newOwnerId, newOwnerCharId, 0, horseId })

    VORPcore.NotifyRightTip(src, _U('youGave') .. newOwnerName .. _U('aHorse'), 4000)
    VORPcore.NotifyRightTip(serverId, curOwnerName .._U('gaveHorse'), 4000)
end)

RegisterServerEvent('bcc-stables:RegisterInventory', function(id, horseModel)
    local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered('horse_' .. tostring(id))

    if isRegistered then return end

    for _, horseCfg in pairs(Horses) do
        for model, value in pairs(horseCfg.colors) do
            if model == horseModel then
                local data = {
                    id = 'horse_' .. tostring(id),
                    name = _U('horseInv'),
                    limit = tonumber(value.invLimit),
                    acceptWeapons = Config.allowWeapons,
                    shared = Config.shareInventory,
                    ignoreItemStackLimit = true,
                    whitelistItems = false,
                    UsePermissions = false,
                    UseBlackList = false,
                    whitelistWeapons = false
                }
                exports.vorp_inventory:registerInventory(data)
                break
            end
        end
    end
end)

RegisterServerEvent('bcc-stables:OpenInventory', function(id)
    local src = source
    exports.vorp_inventory:openInventory(src, 'horse_' .. tostring(id))
end)

-- Iterate over each item in the Config.horseFood array to register them as usable items
for _, item in ipairs(Config.horseFood) do
    exports.vorp_inventory:registerUsableItem(item, function(data)
        local src = data.source
        -- Close the inventory when the item is used
        exports.vorp_inventory:closeInventory(src)
        -- Trigger an event on the client side to handle the feeding action, passing the specific item used
        TriggerClientEvent('bcc-stables:FeedHorse', src, item)
    end)
end

RegisterServerEvent('bcc-stables:RemoveItem', function(item)
    local src = source
    exports.vorp_inventory:subItem(src, item, 1)
end)

exports.vorp_inventory:registerUsableItem(Config.horsebrush, function(data)
    local src = data.source
    local item = exports.vorp_inventory:getItem(src, Config.horsebrush)
    exports.vorp_inventory:closeInventory(src)
    TriggerClientEvent('bcc-stables:BrushHorse', src)
    if not Config.horsebrushDurability then return end

    if not next(item.metadata) then
        local newData = {
            description = _U('horsebrushDesc') .. '</br>' .. _U('durability') .. 100 - 1 .. '%',
            durability = 100 - 1,
            id = item.id
        }
        exports.vorp_inventory:setItemMetadata(src, item.id, newData, 1)
    else
        if item.metadata.durability < 1 then
            exports.vorp_inventory:subItemID(src, item.id)
        else
            local newData = {
                description = _U('horsebrushDesc') .. '</br>' .. _U('durability') .. item.metadata.durability - 1 .. '%',
                durability = item.metadata.durability - 1,
                id = item.id
            }
            exports.vorp_inventory:setItemMetadata(src, item.id, newData, 1)
        end
    end
end)

exports.vorp_inventory:registerUsableItem(Config.lantern, function(data)
    local src = data.source
    local item = exports.vorp_inventory:getItem(src, Config.lantern)
    exports.vorp_inventory:closeInventory(src)
    TriggerClientEvent('bcc-stables:UseLantern', src)
    if not Config.lanternDurability then return end

    if not next(item.metadata) then
        local newData = {
            description = _U('durability') .. 100 - 1 .. '%',
            durability = 100 - 1,
            id = item.id
        }
        exports.vorp_inventory:setItemMetadata(src, item.id, newData, 1)
    else
        if item.metadata.durability < 1 then
            exports.vorp_inventory:subItemID(src, item.id)
        else
            local newData = {
                description = _U('durability') .. item.metadata.durability - 1 .. '%',
                durability = item.metadata.durability - 1,
                id = item.id
            }
            exports.vorp_inventory:setItemMetadata(src, item.id, newData, 1)
        end
    end
end)

VORPcore.Callback.Register('bcc-stables:HorseReviveItem', function(source, cb)
    local src = source
    local reviveItem = Config.reviver
    local item = exports.vorp_inventory:getItem(src, reviveItem)
    if not item then
        cb(false)
        return
    end
    exports.vorp_inventory:subItem(src, reviveItem, 1)
    cb(true)
end)

VORPcore.Callback.Register('bcc-stables:CheckJob', function(source, cb, trainer, site)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local charJob = Character.job
    local jobGrade = Character.jobGrade
    if not charJob then
        cb(false)
        return
    end
    local jobConfig
    if trainer then
        jobConfig = Config.trainerJob
    else
        jobConfig = Stables[site].shop.jobs
    end
    local hasJob = false
    hasJob = CheckPlayerJob(charJob, jobGrade, jobConfig)
    if hasJob then
        cb({true, charJob})
    else
        cb({false, charJob})
    end
end)

function CheckPlayerJob(charJob, jobGrade, jobConfig)
    for _, job in pairs(jobConfig) do
        if (charJob == job.name) and (tonumber(jobGrade) >= tonumber(job.grade)) then
            return true
        end
    end
end

RegisterNetEvent('vorp_core:instanceplayers', function(setRoom)
    local src = source
    if setRoom == 0 then
        Wait(3000)
        TriggerClientEvent('bcc-stables:UpdateMyHorseEntity', src)
    end
end)

--- Check if properly downloaded
function file_exists(name)
    local f = LoadResourceFile(GetCurrentResourceName(), name)
    return f ~= nil
end

if not file_exists('./ui/index.html') then
    print('^1 INCORRECT DOWNLOAD!  ^0')
    print(
        '^4 Please Download: ^2(bcc-stables.zip) ^4from ^3<https://github.com/BryceCanyonCounty/bcc-stables/releases/latest>^0')
end
