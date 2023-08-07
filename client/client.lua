local VORPcore = {}
local VORPutils = {}
-- Prompts
local OpenShops
local OpenReturn
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
-- Horse Tack
local SaddlesUsing = nil
local SaddleclothsUsing = nil
local StirrupsUsing = nil
local BagsUsing = nil
local ManesUsing = nil
local TailsUsing = nil
local SaddleHornsUsing = nil
local BedrollsUsing = nil
local MasksUsing = nil
local MustachesUsing = nil
-- Misc.
local InMenu = false
local StableName
local BrushCooldown = false
local FeedCooldown = false
local ShopEntity
local MyEntity
local MyHorse = nil
local MyHorseId
local Shop
local MyEntityID
local HorseComponents = {}
local Spawning = false
local Spawned = false
local Cam = false
local UsingLantern = false

TriggerEvent('getCore', function(core)
    VORPcore = core
end)
TriggerEvent('getUtils', function(utils)
    VORPutils = utils
end)

-- Start Stables
CreateThread(function()
    StartPrompts()
    while true do
        Wait(0)
        local player = PlayerPedId()
        local pCoords = GetEntityCoords(player)
        local sleep = true
        local hour = GetClockHours()

        if not InMenu and not IsEntityDead(player) then
            for shop, shopCfg in pairs(Config.shops) do
                if shopCfg.shopHours then
                    -- Using Stable Hours - Stable Closed
                    if hour >= shopCfg.shopClose or hour < shopCfg.shopOpen then
                        if shopCfg.blipOn and Config.blipOnClosed then
                            if not Config.shops[shop].Blip then
                                AddBlip(shop)
                            end
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip,
                                joaat(Config.BlipColors[shopCfg.blipClosed])) -- BlipAddModifier
                        else
                            if Config.shops[shop].Blip then
                                RemoveBlip(Config.shops[shop].Blip)
                                Config.shops[shop].Blip = nil
                            end
                        end
                        if shopCfg.NPC then
                            DeleteEntity(shopCfg.NPC)
                            shopCfg.NPC = nil
                        end
                        local sDist = #(pCoords - shopCfg.npc)
                        if sDist <= shopCfg.sDistance then
                            sleep = false
                            local shopClosed = CreateVarString(10, 'LITERAL_STRING',
                                shopCfg.shopName ..
                                _U('hours') .. shopCfg.shopOpen .. _U('to') .. shopCfg.shopClose .. _U('hundred'))
                            PromptSetActiveGroupThisFrame(PromptGroup, shopClosed)
                            PromptSetEnabled(OpenShops, 0)
                            PromptSetEnabled(OpenReturn, 0)
                        end
                    elseif hour >= shopCfg.shopOpen then
                        -- Using Stable Hours - Stable Open
                        if shopCfg.blipOn and not Config.shops[shop].Blip then
                            AddBlip(shop)
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip,
                                joaat(Config.BlipColors[shopCfg.blipOpen])) -- BlipAddModifier
                        end
                        if not next(shopCfg.allowedJobs) then
                            local sDist = #(pCoords - shopCfg.npc)
                            if shopCfg.npcOn then
                                if sDist <= shopCfg.nDistance then
                                    if not shopCfg.NPC then
                                        AddNPC(shop)
                                    end
                                end
                            else
                                if shopCfg.NPC then
                                    DeleteEntity(shopCfg.NPC)
                                    shopCfg.NPC = nil
                                end
                            end
                            if sDist <= shopCfg.sDistance then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopCfg.promptName)
                                PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                                PromptSetEnabled(OpenShops, 1)
                                PromptSetEnabled(OpenReturn, 1)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then      -- UiPromptHasStandardModeCompleted
                                    OpenStable(shop)
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                    ReturnHorse()
                                end
                            end
                        else
                            -- Using Stable Hours - Stable Open - Job Locked
                            if Config.shops[shop].Blip then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip,
                                    joaat(Config.BlipColors[shopCfg.blipJob])) -- BlipAddModifier
                            end
                            local sDist = #(pCoords - shopCfg.npc)
                            if shopCfg.npcOn then
                                if sDist <= shopCfg.nDistance then
                                    if not shopCfg.NPC then
                                        AddNPC(shop)
                                    end
                                end
                            else
                                if shopCfg.NPC then
                                    DeleteEntity(shopCfg.NPC)
                                    shopCfg.NPC = nil
                                end
                            end
                            if sDist <= shopCfg.sDistance then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopCfg.promptName)
                                PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                                PromptSetEnabled(OpenShops, 1)
                                PromptSetEnabled(OpenReturn, 1)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                    VORPcore.RpcCall('CheckPlayerJob', function(result)
                                        if result then
                                            OpenStable(shop)
                                        else
                                            return
                                        end
                                    end, shop)
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                    VORPcore.RpcCall('CheckPlayerJob', function(result)
                                        if result then
                                            ReturnHorse()
                                        else
                                            return
                                        end
                                    end, shop)
                                end
                            end
                        end
                    end
                else
                    -- Not Using Stable Hours - Stable Always Open
                    if shopCfg.blipOn and not Config.shops[shop].Blip then
                        AddBlip(shop)
                        Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip,
                            joaat(Config.BlipColors[shopCfg.blipOpen])) -- BlipAddModifier
                    end
                    if not next(shopCfg.allowedJobs) then
                        local sDist = #(pCoords - shopCfg.npc)
                        if shopCfg.npcOn then
                            if sDist <= shopCfg.nDistance then
                                if not shopCfg.NPC then
                                    AddNPC(shop)
                                end
                            end
                        else
                            if shopCfg.NPC then
                                DeleteEntity(shopCfg.NPC)
                                shopCfg.NPC = nil
                            end
                        end
                        if sDist <= shopCfg.sDistance then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopCfg.promptName)
                            PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                            PromptSetEnabled(OpenShops, 1)
                            PromptSetEnabled(OpenReturn, 1)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then      -- UiPromptHasStandardModeCompleted
                                OpenStable(shop)
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                ReturnHorse()
                            end
                        end
                    else
                        -- Not Using Stable Hours - Stable Always Open - Job Locked
                        if Config.shops[shop].Blip then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip,
                                joaat(Config.BlipColors[shopCfg.blipJob])) -- BlipAddModifier
                        end
                        local sDist = #(pCoords - shopCfg.npc)
                        if shopCfg.npcOn then
                            if sDist <= shopCfg.nDistance then
                                if not shopCfg.NPC then
                                    AddNPC(shop)
                                end
                            end
                        else
                            if shopCfg.NPC then
                                DeleteEntity(shopCfg.NPC)
                                shopCfg.NPC = nil
                            end
                        end
                        if sDist <= shopCfg.sDistance then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopCfg.promptName)
                            PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                            PromptSetEnabled(OpenShops, 1)
                            PromptSetEnabled(OpenReturn, 1)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                VORPcore.RpcCall('CheckPlayerJob', function(result)
                                    if result then
                                        OpenStable(shop)
                                    else
                                        return
                                    end
                                end, shop)
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                VORPcore.RpcCall('CheckPlayerJob', function(result)
                                    if result then
                                        ReturnHorse()
                                    else
                                        return
                                    end
                                end, shop)
                            end
                        end
                    end
                end
            end
        end
        if sleep then
            Wait(1000)
        end
    end
end)

-- Open Main Menu
function OpenStable(shop)
    DisplayRadar(false)
    InMenu = true
    Shop = shop
    StableName = Config.shops[Shop].shopName
    CreateCamera()

    SendNUIMessage({
        action = 'show',
        shopData = Config.Horses,
        compData = HorseComp,
        location = StableName,
        currencyType = Config.currencyType
    })
    SetNuiFocus(true, true)
    TriggerServerEvent('bcc-stables:GetMyHorses')
end

-- Get Horse Data for Players Horses
RegisterNetEvent('bcc-stables:ReceiveHorsesData', function(dataHorses)
    SendNUIMessage({
        action = 'updateMyHorses',
        myHorsesData = dataHorses
    })
end)

-- View Horses for Purchase
RegisterNUICallback('loadHorse', function(data, cb)
    cb('ok')
    if MyEntity then
        DeleteEntity(MyEntity)
        MyEntity = nil
    end

    local model = joaat(data.horseModel)
    LoadModel(model)

    if ShopEntity then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
    end

    local shopCfg = Config.shops[Shop]
    ShopEntity = CreatePed(model, shopCfg.spawn.x, shopCfg.spawn.y, shopCfg.spawn.z - 1.0, shopCfg.spawn.w, false, false)
    Citizen.InvokeNative(0x283978A15512B2FE, ShopEntity, true) -- SetRandomOutfitVariation
    Citizen.InvokeNative(0x58A850EAEE20FAA3, ShopEntity)       -- PlaceObjectOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, ShopEntity, true) -- FreezeEntityPosition
    if not Cam then
        Cam = true
        CameraLighting()
    end
    SetBlockingOfNonTemporaryEvents(ShopEntity, true)
    SetPedConfigFlag(ShopEntity, 113, true)              -- DisableShockingEvents
    Wait(300)
    Citizen.InvokeNative(0x6585D955A68452A5, ShopEntity) -- ClearPedEnvDirt
end)

-- Buy and Name New Horse
RegisterNUICallback('BuyHorse', function(data, cb)
    cb('ok')
    VORPcore.RpcCall('BuyHorse', function(canBuy)
        if canBuy then
            SetHorseName(data, false)
        else
            StableMenu()
        end
    end, data)
end)

function SetHorseName(data, rename)
    SendNUIMessage({
        action = 'hide'
    })
    SetNuiFocus(false, false)
    Wait(200)

    CreateThread(function()
        AddTextEntry('FMMC_MPM_NA', _U('nameHorse'))
        DisplayOnscreenKeyboard(1, 'FMMC_MPM_NA', '', '', '', '', '', 30)
        while UpdateOnscreenKeyboard() == 0 do
            DisableAllControlActions(0)
            Wait(0)
        end
        if GetOnscreenKeyboardResult() then
            local horseName = GetOnscreenKeyboardResult()
            if string.len(horseName) > 0 then
                local horseInfo = { horseData = data, name = horseName }
                if rename then
                    VORPcore.RpcCall('UpdateHorseName', function(horseSaved)
                        if horseSaved then
                            StableMenu()
                        end
                    end, horseInfo)
                    return
                else
                    VORPcore.RpcCall('SaveNewHorse', function(horseSaved)
                        if horseSaved then
                            StableMenu()
                        end
                    end, horseInfo)
                    return
                end
            else
                SetHorseName(data, rename)
                return
            end
        end
        SendNUIMessage({
            action = 'show',
            shopData = Config.Horses,
            compData = HorseComp,
            location = StableName,
            currencyType = Config.currencyType
        })
        SetNuiFocus(true, true)
        TriggerServerEvent('bcc-stables:GetMyHorses')
    end)
end

-- Rename Owned Horse
RegisterNUICallback('RenameHorse', function(data, cb)
    cb('ok')
    SetHorseName(data, true)
end)

-- View Player Owned Horses
RegisterNUICallback('loadMyHorse', function(data, cb)
    cb('ok')
    MyEntityID = data.HorseId

    if ShopEntity then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
    end

    if MyEntity then
        DeleteEntity(MyEntity)
        MyEntity = nil
    end

    local model = joaat(data.HorseModel)
    LoadModel(model)

    local shopCfg = Config.shops[Shop]
    MyEntity = CreatePed(model, shopCfg.spawn.x, shopCfg.spawn.y, shopCfg.spawn.z - 1.0, shopCfg.spawn.w, false, false)
    Citizen.InvokeNative(0x283978A15512B2FE, MyEntity, true)           -- SetRandomOutfitVariation
    Citizen.InvokeNative(0x58A850EAEE20FAA3, MyEntity)                 -- PlaceObjectOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, MyEntity, true)           -- FreezeEntityPosition
    if data.HorseGender == 'female' then
        Citizen.InvokeNative(0x5653AB26C82938CF, MyEntity, 41611, 1.0) -- SetCharExpression
        Citizen.InvokeNative(0xCC8CA3E88256E58F, MyEntity)             -- UpdatePedVariation
    end
    if not Cam then
        Cam = true
        CameraLighting()
    end
    SetBlockingOfNonTemporaryEvents(MyEntity, true)
    SetPedConfigFlag(MyEntity, 113, true)              -- PCF_DisableShockingEvents
    Wait(300)
    Citizen.InvokeNative(0x6585D955A68452A5, MyEntity) -- ClearPedEnvDirt

    local componentsHorse = json.decode(data.HorseComp)
    if componentsHorse ~= '[]' then
        for _, hash in pairs(componentsHorse) do
            local compModel = joaat(tonumber(hash))
            if not HasModelLoaded(compModel) then
                Citizen.InvokeNative(0xFA28FE3A6246FC30, compModel)                              -- RequestModel
            end
            Citizen.InvokeNative(0xD3A7B003ED343FD9, MyEntity, tonumber(hash), true, true, true) -- ApplyShopItemToPed
        end
    end
end)

-- Select Active Horse
RegisterNUICallback('selectHorse', function(data, cb)
    cb('ok')
    TriggerServerEvent('bcc-stables:SelectHorse', data)
end)

function GetSelectedHorse()
    VORPcore.RpcCall("GetHorseData", function(data)
        if data then
            HorseComponents = data.components
            MyHorseId = data.id
            SpawnHorse(data.model, data.name, data.gender)
        else
            print('No selected-horse data returned!')
        end
    end)
end

-- Close Stable Menu
RegisterNUICallback('CloseStable', function(data, cb)
    cb('ok')
    SendNUIMessage({
        action = 'hide'
    })
    SetNuiFocus(false, false)

    Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Leaderboard_Hide', 'MP_Leaderboard_Sounds', true, 0) -- PlaySoundFrontend
    if ShopEntity then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
    end
    if MyEntity then
        DeleteEntity(MyEntity)
        MyEntity = nil
    end

    Cam = false
    DestroyAllCams(true)
    DisplayRadar(true)
    InMenu = false
    ClearPedTasksImmediately(PlayerPedId())

    if data.MenuAction == 'save' then
        TriggerServerEvent('bcc-stables:BuyTack', data)
    else
        return
    end
end)

-- Save Horse Tack to Database
RegisterNetEvent('bcc-stables:SaveComps', function()
    local compData = {
        SaddlesUsing,
        SaddleclothsUsing,
        StirrupsUsing,
        BagsUsing,
        ManesUsing,
        TailsUsing,
        SaddleHornsUsing,
        BedrollsUsing,
        MasksUsing,
        MustachesUsing
    }
    local compDataEncoded = json.encode(compData)
    if compDataEncoded ~= '[]' then
        TriggerServerEvent('bcc-stables:UpdateComponents', compData, MyEntityID, MyEntity)
    end
end)


-- Reopen Menu After Sell or Failed Purchase
function StableMenu()
    if ShopEntity then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
    end

    SendNUIMessage({
        action = 'show',
        shopData = Config.Horses,
        compData = HorseComp,
        location = StableName,
        currencyType = Config.currencyType
    })
    SetNuiFocus(true, true)
    TriggerServerEvent('bcc-stables:GetMyHorses')
end

RegisterNetEvent('bcc-stables:SetComponents', function(horseEntity, components)
    for _, value in pairs(components) do
        NativeSetPedComponentEnabled(horseEntity, value)
    end
end)

function NativeSetPedComponentEnabled(ped, component)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, component, true, true, true) -- ApplyShopItemToPed
end

-- Spawn Player Horse
function SpawnHorse(horseModel, horseName, gender)
    if Spawning then
        return
    end
    Spawning = true

    if MyHorse then
        DeleteEntity(MyHorse)
        MyHorse = nil
    end

    local model = joaat(horseModel)
    LoadModel(model)

    local player = PlayerPedId()
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(player, 0.0, -40.0, 0.0))
    local gChk, groundZ = nil, nil
    for height = 1, 1000 do
        gChk, groundZ = GetGroundZAndNormalFor_3dCoord(x, y, height + 0.0)
        if gChk then
            break
        end
    end

    local spawnPosition = nil
    local index = 0
    while index <= 25 do
        local _bool, _nodePosition = GetNthClosestVehicleNode(x, y, z, index, 1, 3.0, 2.5)
        if _bool then
            spawnPosition = _nodePosition
            index = index + 3
        else
            break
        end
    end

    if spawnPosition then
        MyHorse = CreatePed(model, spawnPosition, GetEntityHeading(player), true, false)
    else
        MyHorse = CreatePed(model, x, y, groundZ + 2, GetEntityHeading(player), true, false)
    end
    SetModelAsNoLongerNeeded(model)

    LocalPlayer.state.HorseData = {
        HorseName = horseName,
        MyHorse = NetworkGetNetworkIdFromEntity(MyHorse),
    }

    Citizen.InvokeNative(0x9587913B9E772D29, MyHorse, 0)              -- PlaceEntityOnGroundProperly
    Citizen.InvokeNative(0x283978A15512B2FE, MyHorse, true)           -- SetRandomOutfitVariation
    if gender == 'female' then
        Citizen.InvokeNative(0x5653AB26C82938CF, MyHorse, 41611, 1.0) -- SetCharExpression
        Citizen.InvokeNative(0xCC8CA3E88256E58F, MyHorse)             -- UpdatePedVariation
    end
    Citizen.InvokeNative(0xE6D4E435B56D5BD0, player, MyHorse)         -- SetPlayerOwnsMount

    -- SetPedConfigFlag
    Citizen.InvokeNative(0x1913FE4CBF41C463, MyHorse, 113, true)                     -- DisableShockingEvents
    Citizen.InvokeNative(0x1913FE4CBF41C463, MyHorse, 297, true)                     -- ForceInteractionLockonOnTargetPed / Allow to Lead Horse
    Citizen.InvokeNative(0x1913FE4CBF41C463, MyHorse, 312, true)                     -- DisableHorseGunshotFleeResponse

    local horseBlip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, MyHorse) -- BlipAddForEntity
    Citizen.InvokeNative(0x9CB1A1623062F402, horseBlip, horseName)                   -- SetBlipName
    SetPedPromptName(MyHorse, horseName)

    if HorseComponents ~= nil and HorseComponents ~= '0' then
        for _, componentHash in pairs(json.decode(HorseComponents)) do
            NativeSetPedComponentEnabled(MyHorse, tonumber(componentHash))
        end
    end

    TriggerServerEvent('bcc-stables:RegisterInventory', MyHorseId)

    if Config.horseTag then
        local horseTag = Citizen.InvokeNative(0xE961BF23EAB76B12, MyHorse, horseName) -- CreateMpGamerTagOnEntity
        Citizen.InvokeNative(0x5F57522BC1EB9D9D, horseTag, joaat('PLAYER_HORSE'))     -- SetMpGamerTagTopIcon
        Citizen.InvokeNative(0xA0D7CE5F83259663, horseTag)                            -- SetMpGamerTagBigText
        TriggerEvent('bcc-stables:HorseTag', horseTag)
    end

    TriggerEvent('bcc-stables:HorseActions')

    UsingLantern = false
    Spawned = true
    SendHorse()
    Spawning = false
end

-- Set Horse Name Above Horse
AddEventHandler('bcc-stables:HorseTag', function(horseTag)
    while MyHorse do
        Wait(1000)
        local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(MyHorse))
        if dist < 15 and Citizen.InvokeNative(0xAAB0FE202E9FC9F0, MyHorse, -1) then -- IsMountSeatFree
            Citizen.InvokeNative(0x93171DDDAB274EB8, horseTag, 2)                   -- SetMpGamerTagVisibility
        else
            if Citizen.InvokeNative(0x502E1591A504F843, horseTag, MyHorse) then     -- IsMpGamerTagActiveOnEntity
                Citizen.InvokeNative(0x93171DDDAB274EB8, horseTag, 0)               -- SetMpGamerTagVisibility
            end
        end
    end
end)

-- Horse Actions
AddEventHandler('bcc-stables:HorseActions', function()
    while MyHorse do
        Wait(0)
        -- Open Saddlebags (key: U)
        if Citizen.InvokeNative(0x580417101DDB492F, 2, 0xD8F73058) then -- IsControlJustPressed
            OpenInventory()
        end
        -- Horse Flee (key: F in Horse Menu)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x4216AF06) then -- IsDisabledControlJustPressed
            FleeHorse()
        end
    end
end)

CreateThread(function()
    VORPutils.Events:RegisterEventListener('EVENT_PED_WHISTLE', function(args)
        WhistleHorse(args[1], args[2])
    end)
end)

function WhistleHorse(whistler, whistleType)
    local player = PlayerPedId()
    if whistler == player then
        if MyHorse then
            local longWhistle = false
            if whistleType == joaat('WHISTLEHORSELONG') then
                longWhistle = true
            end
            if not longWhistle then
                if Citizen.InvokeNative(0x77F1BEB8863288D5, MyHorse, 0x4924437D, 0) ~= 0 then -- GetScriptTaskStatus
                    local dist = #(GetEntityCoords(player) - GetEntityCoords(MyHorse))
                    if dist >= 100 then
                        DeleteEntity(MyHorse)
                        Wait(1000)
                        MyHorse = nil
                        GetSelectedHorse()
                    else
                        Spawned = true
                        SendHorse()
                    end
                end
            else
                if Citizen.InvokeNative(0x77F1BEB8863288D5, MyHorse, 0x3EF867F4, 0) ~= 1 then -- GetScriptTaskStatus
                    Citizen.InvokeNative(0x304AE42E357B8C7E, MyHorse, player, math.random(1.0, 4.0),
                        math.random(5.0, 8.0), 0.0, 0.7, -1, 3.0, 1)                          -- TaskFollowToOffsetOfEntity
                else
                    ClearPedTasks(MyHorse)
                end
            end
        else
            GetSelectedHorse()
        end
    end
end

-- Move horse to Player
function SendHorse()
    CreateThread(function()
        local player = PlayerPedId()
        Citizen.InvokeNative(0x6A071245EB0D1882, MyHorse, player, -1, 10.2, 2.0, 0.0, 0) -- TaskGoToEntity
        while Spawned == true do
            Wait(0)
            local dist = #(GetEntityCoords(player) - GetEntityCoords(MyHorse))
            if (dist <= 10.0) then
                ClearPedTasks(MyHorse)
                Spawned = false
            end
        end
    end)
end

-- Open Horse Inventory
function OpenInventory()
    local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(MyHorse))
    if dist <= 1.5 then
        if Config.useSaddlebags then
            local hasSaddlebags = Citizen.InvokeNative(0xFB4891BD7578CDC1, MyHorse, -2142954459)
            if hasSaddlebags then
                TriggerServerEvent('bcc-stables:OpenInventory', MyHorseId)
            else
                VORPcore.NotifyRightTip(_U('noSaddlebags'), 4000)
                return
            end
        else
            TriggerServerEvent('bcc-stables:OpenInventory', MyHorseId)
        end
    end
end

-- Send Horse Away
function FleeHorse()
    if MyHorse then
        Citizen.InvokeNative(0x22B0D0E37CCB840D, MyHorse, PlayerPedId(), 150.0, 10000, 6, 3.0) -- TaskSmartFleePed
        Wait(10000)
        DeleteEntity(MyHorse)
        MyHorse = nil
    end
end

RegisterNetEvent('bcc-stables:BrushHorse', function()
    local player = PlayerPedId()
    local dist = #(GetEntityCoords(player) - GetEntityCoords(MyHorse))
    if dist <= 2.0 then
        if not BrushCooldown then
            Citizen.InvokeNative(0xCD181A959CFDD7F4, player, MyHorse, joaat('Interaction_Brush'),
                joaat('p_brushHorse02x'), 1) -- TaskAnimalInteraction

            if Config.boost.brushHealth > 0 then
                local health = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0) -- GetAttributeCoreValue
                Wait(2000)
                local newHealth = health + Config.boost.brushHealth
                if newHealth > 100 then
                    newHealth = 100
                end
                Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 0, newHealth) -- SetAttributeCoreValue
            end

            if Config.boost.brushStamina > 0 then
                local stamina = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 1) -- GetAttributeCoreValue
                Wait(2000)
                local newStamina = stamina + Config.boost.brushStamina
                if newStamina > 100 then
                    newStamina = 100
                end
                Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 1, newStamina) -- SetAttributeCoreValue
            end

            Citizen.InvokeNative(0x6585D955A68452A5, MyHorse)                                       -- ClearPedEnvDirt
            Citizen.InvokeNative(0x523C79AEEFCC4A2A, MyHorse, 10, 'ALL')                            -- ClearPedDamageDecalByZone
            Citizen.InvokeNative(0x8FE22675A5A45817, MyHorse)                                       -- ClearPedBloodDamage
            Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Core_Fill_Up', 'Consumption_Sounds', true, 0) -- PlaySoundFrontend

            local bCooldown = math.floor(Config.timer.brush * 60000)
            VORPcore.NotifyRightTip(_U('brushCooldown') .. Config.timer.brush .. _U('minutes'), 4000)
            BrushCooldown = true
            Wait(bCooldown)
            BrushCooldown = false
        else
            VORPcore.NotifyRightTip(_U('notDirty'), 4000)
        end
    else
        VORPcore.NotifyRightTip(_U('tooFar'), 4000)
    end
end)

RegisterNetEvent('bcc-stables:FeedHorse', function(item)
    local player = PlayerPedId()
    local dist = #(GetEntityCoords(player) - GetEntityCoords(MyHorse))
    if dist <= 2.0 then
        if not FeedCooldown then
            Citizen.InvokeNative(0xCD181A959CFDD7F4, player, MyHorse, joaat('Interaction_Food'),
                joaat('s_horsnack_haycube01x'), 1) -- TaskAnimalInteraction

            if Config.boost.feedHealth > 0 then
                local health = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0) -- GetAttributeCoreValue
                Wait(2000)
                local newHealth = health + Config.boost.feedHealth
                if newHealth > 100 then
                    newHealth = 100
                end
                Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 0, newHealth) -- SetAttributeCoreValue
            end

            if Config.boost.feedStamina > 0 then
                local stamina = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 1) -- GetAttributeCoreValue
                Wait(2000)
                local newStamina = stamina + Config.boost.feedStamina
                if newStamina > 100 then
                    newStamina = 100
                end
                Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 1, newStamina)                    -- SetAttributeCoreValue
            end
            Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Core_Fill_Up', 'Consumption_Sounds', true, 0) -- PlaySoundFrontend
            TriggerServerEvent('bcc-stables:RemoveItem', item)

            local fCooldown = math.ceil(Config.timer.feed * 60000)
            VORPcore.NotifyRightTip(_U('feedCooldown') .. Config.timer.feed .. _U('minutes'), 4000)
            FeedCooldown = true
            Wait(fCooldown)
            FeedCooldown = false
        else
            VORPcore.NotifyRightTip(_U('notHungry'), 4000)
        end
    else
        VORPcore.NotifyRightTip(_U('tooFar'), 4000)
    end
end)

-- Equip Horse Lantern
RegisterNetEvent('bcc-stables:UseLantern', function()
    local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(MyHorse))
    if dist <= 2.0 then
        if not UsingLantern then
            Citizen.InvokeNative(0xD3A7B003ED343FD9, MyHorse, 0x635E387C, 1, 1, 1) -- ApplyShopItemToPed
            UsingLantern = true
        else
            Citizen.InvokeNative(0x0D7FFA1B2F69ED82, MyHorse, 0x635E387C, 0, 0) -- RemoveShopItemFromPed
            Citizen.InvokeNative(0xCC8CA3E88256E58F, MyHorse, 0, 1, 1, 1, 0)    -- UpdatePedVariation
            UsingLantern = false
        end
    end
end)

-- Select Horse Tack from Menu
RegisterNUICallback('Saddles', function(data, cb)
    cb('ok')
    if tonumber(data.id) == -1 then
        SaddlesUsing = 0
        local playerHorse = MyEntity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xBAA7E618, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local hash = data.hash
        SetModel(hash)
        SaddlesUsing = hash
    end
end)

RegisterNUICallback('Saddlecloths', function(data, cb)
    cb('ok')
    if tonumber(data.id) == -1 then
        SaddleclothsUsing = 0
        local playerHorse = MyEntity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x17CEB41A, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local hash = data.hash
        SetModel(hash)
        SaddleclothsUsing = hash
    end
end)

RegisterNUICallback('Stirrups', function(data, cb)
    cb('ok')
    if tonumber(data.id) == -1 then
        StirrupsUsing = 0
        local playerHorse = MyEntity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xDA6DADCA, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local hash = data.hash
        SetModel(hash)
        StirrupsUsing = hash
    end
end)

RegisterNUICallback('SaddleBags', function(data, cb)
    cb('ok')
    if tonumber(data.id) == -1 then
        BagsUsing = 0
        local playerHorse = MyEntity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x80451C25, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local hash = data.hash
        SetModel(hash)
        BagsUsing = hash
    end
end)

RegisterNUICallback('Manes', function(data, cb)
    cb('ok')
    if tonumber(data.id) == -1 then
        ManesUsing = 0
        local playerHorse = MyEntity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xAA0217AB, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local hash = data.hash
        SetModel(hash)
        ManesUsing = hash
    end
end)

RegisterNUICallback('Tails', function(data, cb)
    cb('ok')
    if tonumber(data.id) == -1 then
        TailsUsing = 0
        local playerHorse = MyEntity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x17CEB41A, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local hash = data.hash
        SetModel(hash)
        TailsUsing = hash
    end
end)

RegisterNUICallback('SaddleHorns', function(data, cb)
    cb('ok')
    if tonumber(data.id) == -1 then
        SaddleHornsUsing = 0
        local playerHorse = MyEntity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x5447332, 0)  -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local hash = data.hash
        SetModel(hash)
        SaddleHornsUsing = hash
    end
end)

RegisterNUICallback('Bedrolls', function(data, cb)
    cb('ok')
    if tonumber(data.id) == -1 then
        BedrollsUsing = 0
        local playerHorse = MyEntity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xEFB31921, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local hash = data.hash
        SetModel(hash)
        BedrollsUsing = hash
    end
end)

RegisterNUICallback('Masks', function(data, cb)
    cb('ok')
    if tonumber(data.id) == -1 then
        MasksUsing = 0
        local playerHorse = MyEntity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xD3500E5D, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local hash = data.hash
        SetModel(hash)
        MasksUsing = hash
    end
end)

RegisterNUICallback('Mustaches', function(data, cb)
    cb('ok')
    if tonumber(data.id) == -1 then
        MustachesUsing = 0
        local playerHorse = MyEntity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x30DEFDDF, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local hash = data.hash
        SetModel(hash)
        MustachesUsing = hash
    end
end)

function SetModel(hash)
    local model = joaat(tonumber(hash))
    if not HasModelLoaded(model) then
        Citizen.InvokeNative(0xFA28FE3A6246FC30, model)                                  -- RequestModel
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, MyEntity, tonumber(hash), true, true, true) -- ApplyShopItemToPed
end

-- Sell Player Horse
RegisterNUICallback('sellHorse', function(data, cb)
    cb('ok')
    DeleteEntity(MyEntity)
    Cam = false
    VORPcore.RpcCall('SellMyHorse', function(horseSold)
        if horseSold then
            StableMenu()
        end
    end, data)
end)

-- Return Player Horse at Stable
function ReturnHorse()
    if MyHorse == nil then
        VORPcore.NotifyRightTip(_U('noHorse'), 4000)
    elseif MyHorse then
        DeleteEntity(MyHorse)
        MyHorse = nil
        VORPcore.NotifyRightTip(_U('horseReturned'), 4000)
    end
end

-- View Horses While in Menu
function CreateCamera()
    local shopCfg = Config.shops[Shop]
    local horseCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(horseCam, shopCfg.horseCam.x, shopCfg.horseCam.y, shopCfg.horseCam.z + 1.2)
    SetCamActive(horseCam, true)
    PointCamAtCoord(horseCam, shopCfg.spawn.x - 0.5, shopCfg.spawn.y, shopCfg.spawn.z)
    DoScreenFadeOut(500)
    Wait(500)
    DoScreenFadeIn(500)
    RenderScriptCams(true, false, 0, 0, 0)
    Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Leaderboard_Show', 'MP_Leaderboard_Sounds', true, 0) -- PlaySoundFrontend
end

function CameraLighting()
    CreateThread(function()
        local shopCfg = Config.shops[Shop]
        while Cam do
            Wait(0)
            Citizen.InvokeNative(0xD2D9E04C0DF927F4, shopCfg.spawn.x, shopCfg.spawn.y, shopCfg.spawn.z + 3, 130, 130, 85,
                4.0, 15.0) -- DrawLightWithRange
        end
    end)
end

-- -- Rotate Horses while Viewing
RegisterNUICallback('rotate', function(data, cb)
    cb('ok')
    local direction = data.RotateHorse

    if direction == 'left' then
        Rotation(1)
    elseif direction == 'right' then
        Rotation(-1)
    end
end)

function Rotation(dir)
    local ownedHorse = MyEntity
    local shopHorse = ShopEntity

    if ownedHorse then
        local ownedRot = GetEntityHeading(ownedHorse) + dir
        SetEntityHeading(ownedHorse, ownedRot % 360)
    elseif shopHorse then
        local shopRot = GetEntityHeading(shopHorse) + dir
        SetEntityHeading(shopHorse, shopRot % 360)
    end
end

RegisterCommand('horseRespawn', function(source, args, rawCommand)
    Spawning = false
    GetSelectedHorse()
end)

-- Menu Prompts
function StartPrompts()
    local shopStr = CreateVarString(10, 'LITERAL_STRING', _U('shopPrompt'))
    OpenShops = PromptRegisterBegin()
    PromptSetControlAction(OpenShops, Config.keys.shop)
    PromptSetText(OpenShops, shopStr)
    PromptSetVisible(OpenShops, 1)
    PromptSetStandardMode(OpenShops, 1)
    PromptSetGroup(OpenShops, PromptGroup)
    PromptRegisterEnd(OpenShops)

    local returnStr = CreateVarString(10, 'LITERAL_STRING', _U('returnPrompt'))
    OpenReturn = PromptRegisterBegin()
    PromptSetControlAction(OpenReturn, Config.keys.ret)
    PromptSetText(OpenReturn, returnStr)
    PromptSetVisible(OpenReturn, 1)
    PromptSetStandardMode(OpenReturn, 1)
    PromptSetGroup(OpenReturn, PromptGroup)
    PromptRegisterEnd(OpenReturn)
end

-- Blips
function AddBlip(shop)
    local shopCfg = Config.shops[shop]
    shopCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, shopCfg.npc) -- BlipAddForCoords
    SetBlipSprite(shopCfg.Blip, shopCfg.blipSprite, 1)
    SetBlipScale(shopCfg.Blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, shopCfg.Blip, shopCfg.blipName) -- SetBlipName
end

-- NPSs
function AddNPC(shop)
    local shopCfg = Config.shops[shop]
    local model = joaat(shopCfg.npcModel)
    LoadModel(model)
    local npc = CreatePed(shopCfg.npcModel, shopCfg.npc.x, shopCfg.npc.y, shopCfg.npc.z - 1.0, shopCfg.npcHeading, false,
        true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    Wait(500)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    Config.shops[shop].NPC = npc
end

function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

RegisterNetEvent('bcc-stables:UpdateMyHorseEntity', function()
    if MyHorse then
        MyHorse = NetworkGetEntityFromNetworkId(LocalPlayer.state.HorseData.MyHorse)               -- Update Global Horse Entity after session change

        Citizen.InvokeNative(0xE6D4E435B56D5BD0, PlayerPedId(), MyHorse)                           -- SetPlayerOwnsMount
        local horseBlip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, MyHorse)           -- BlipAddForEntity
        Citizen.InvokeNative(0x9CB1A1623062F402, horseBlip, LocalPlayer.state.HorseData.HorseName) -- SetBlipName
        SetPedPromptName(MyHorse, LocalPlayer.state.HorseData.HorseName)

        if Config.horseTag then
            local horseTag = Citizen.InvokeNative(0xE961BF23EAB76B12, MyHorse, LocalPlayer.state.HorseData.HorseName) -- CreateMpGamerTagOnEntity
            Citizen.InvokeNative(0x5F57522BC1EB9D9D, horseTag, joaat('PLAYER_HORSE'))                                 -- SetMpGamerTagTopIcon
            Citizen.InvokeNative(0xA0D7CE5F83259663, horseTag)                                                        -- SetMpGamerTagBigText
            TriggerEvent('bcc-stables:HorseTag', horseTag)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if InMenu then
        SendNUIMessage({
            action = 'hide'
        })
        SetNuiFocus(false, false)
    end
    ClearPedTasksImmediately(PlayerPedId())
    DestroyAllCams(true)
    DisplayRadar(true)

    if MyHorse then
        DeleteEntity(MyHorse)
        MyHorse = nil
    end
    for _, shopCfg in pairs(Config.shops) do
        if shopCfg.Blip then
            RemoveBlip(shopCfg.Blip)
            shopCfg.Blip = nil
        end
        if shopCfg.NPC then
            DeleteEntity(shopCfg.NPC)
            shopCfg.NPC = nil
        end
    end
end)
