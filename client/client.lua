local VORPcore = {}
TriggerEvent('getCore', function(core)
    VORPcore = core
end)
local ClientRPC = exports.vorp_core:ClientRpcCall()
-- Shop Prompts
local OpenShops
local OpenCall
local OpenReturn
local ShopGroup = GetRandomIntInRange(0, 0xffffff)
-- Tame Prompts
local KeepTame
local SellTame
local TameGroup = GetRandomIntInRange(0, 0xffffff)
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
local MyModel
local HorseName
local Shop
local HasJob = nil
local MyEntityID
local HorseComponents = {}
local Spawning = false
local Sending = false
local Cam = false
local UsingLantern = false
-- Training data 
local IsTrainer = false
local LastLoc = nil
local MaxBonding = false
local MiniGame = exports['bcc-minigames'].initiate()
local TamingMount = nil
local TameCount = 0
local HorseBreed = nil
local TamedCooldown = false

-- Start Stables
CreateThread(function()
    StartPrompts()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)
        local sleep = true
        local hour = GetClockHours()

        if not InMenu and not IsEntityDead(playerPed) then
            for shop, shopCfg in pairs(Config.shops) do
                if shopCfg.shopHours then
                    -- Using Stable Hours - Stable Closed
                    if hour >= shopCfg.shopClose or hour < shopCfg.shopOpen then
                        if shopCfg.blipOn and Config.blipOnClosed then
                            if not Config.shops[shop].Blip then
                                AddBlip(shop)
                            end
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipClosed])) -- BlipAddModifier
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
                            local shopClosed = CreateVarString(10, 'LITERAL_STRING', shopCfg.shopName .. _U('hours') .. shopCfg.shopOpen .. _U('to') .. shopCfg.shopClose .. _U('hundred'))
                            PromptSetActiveGroupThisFrame(ShopGroup, shopClosed)
                            PromptSetEnabled(OpenShops, 0)
                            if not next(shopCfg.allowedJobs) then
                                if Config.closedCall then
                                    PromptSetEnabled(OpenCall, 1)
                                    if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenCall) then  -- UiPromptHasStandardModeCompleted
                                        GetSelectedHorse()
                                    end
                                else
                                    PromptSetEnabled(OpenCall, 0)
                                end
                                if Config.closedReturn then
                                    PromptSetEnabled(OpenReturn, 1)
                                    if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then  -- UiPromptHasStandardModeCompleted
                                        ReturnHorse()
                                    end
                                else
                                    PromptSetEnabled(OpenReturn, 0)
                                end
                            else
                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenCall) then -- UiPromptHasStandardModeCompleted
                                    CheckPlayerJob(shop)
                                    if HasJob then
                                        GetSelectedHorse()
                                    end
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                    CheckPlayerJob(shop)
                                    if HasJob then
                                        ReturnHorse()
                                    end
                                end
                            end
                        end
                    elseif hour >= shopCfg.shopOpen then
                        -- Using Stable Hours - Stable Open
                        if shopCfg.blipOn and not Config.shops[shop].Blip then
                            AddBlip(shop)
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipOpen])) -- BlipAddModifier
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
                                PromptSetActiveGroupThisFrame(ShopGroup, shopOpen)
                                PromptSetEnabled(OpenShops, 1)
                                PromptSetEnabled(OpenCall, 1)
                                PromptSetEnabled(OpenReturn, 1)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then  -- UiPromptHasStandardModeCompleted
                                    OpenStable(shop)
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenCall) then -- UiPromptHasStandardModeCompleted
                                    GetSelectedHorse()
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                    ReturnHorse()
                                end
                            end
                        else
                            -- Using Stable Hours - Stable Open - Job Locked
                            if Config.shops[shop].Blip then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipJob])) -- BlipAddModifier
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
                                PromptSetActiveGroupThisFrame(ShopGroup, shopOpen)
                                PromptSetEnabled(OpenShops, 1)
                                PromptSetEnabled(OpenCall, 1)
                                PromptSetEnabled(OpenReturn, 1)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                    CheckPlayerJob(shop)
                                    if HasJob then
                                        OpenStable(shop)
                                    end
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenCall) then -- UiPromptHasStandardModeCompleted
                                    CheckPlayerJob(shop)
                                    if HasJob then
                                        GetSelectedHorse()
                                    end
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                    CheckPlayerJob(shop)
                                    if HasJob then
                                        ReturnHorse()
                                    end
                                end
                            end
                        end
                    end
                else
                    -- Not Using Stable Hours - Stable Always Open
                    if shopCfg.blipOn and not Config.shops[shop].Blip then
                        AddBlip(shop)
                        Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipOpen])) -- BlipAddModifier
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
                            PromptSetActiveGroupThisFrame(ShopGroup, shopOpen)
                            PromptSetEnabled(OpenShops, 1)
                            PromptSetEnabled(OpenCall, 1)
                            PromptSetEnabled(OpenReturn, 1)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then      -- UiPromptHasStandardModeCompleted
                                OpenStable(shop)
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenCall) then -- UiPromptHasStandardModeCompleted
                                GetSelectedHorse()
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                ReturnHorse()
                            end
                        end
                    else
                        -- Not Using Stable Hours - Stable Always Open - Job Locked
                        if Config.shops[shop].Blip then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipJob])) -- BlipAddModifier
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
                            PromptSetActiveGroupThisFrame(ShopGroup, shopOpen)
                            PromptSetEnabled(OpenShops, 1)
                            PromptSetEnabled(OpenCall, 1)
                            PromptSetEnabled(OpenReturn, 1)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                CheckPlayerJob(shop)
                                if HasJob then
                                    OpenStable(shop)
                                end
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenCall) then -- UiPromptHasStandardModeCompleted
                                CheckPlayerJob(shop)
                                if HasJob then
                                    GetSelectedHorse()
                                end
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                CheckPlayerJob(shop)
                                if HasJob then
                                    ReturnHorse()
                                end
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
    Citizen.InvokeNative(0x58A850EAEE20FAA3, ShopEntity) -- PlaceObjectOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, ShopEntity, true) -- FreezeEntityPosition
    if not Cam then
        Cam = true
        CameraLighting()
    end
    SetBlockingOfNonTemporaryEvents(ShopEntity, true)
    SetPedConfigFlag(ShopEntity, 113, true) -- DisableShockingEvents
    Wait(300)
    Citizen.InvokeNative(0x6585D955A68452A5, ShopEntity) -- ClearPedEnvDirt
end)

RegisterNUICallback('BuyHorse', function(data, cb)
    cb('ok')
    CheckTrainerJob()
    if IsTrainer then
        data.isTrainer = true
    else
        data.isTrainer = false
    end
    local canBuy = ClientRPC.Callback.TriggerAwait('bcc-stables:BuyHorse', data)
    if canBuy then
        SetHorseName(data, false)
    else
        StableMenu()
    end
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
                    local nameSaved = ClientRPC.Callback.TriggerAwait('bcc-stables:UpdateHorseName', horseInfo)
                    if nameSaved then
                        StableMenu()
                    end
                    return
                else
                    local horseSaved = ClientRPC.Callback.TriggerAwait('bcc-stables:SaveNewHorse', horseInfo)
                    if horseSaved then
                        StableMenu()
                    end
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
    Citizen.InvokeNative(0x283978A15512B2FE, MyEntity, true) -- SetRandomOutfitVariation
    Citizen.InvokeNative(0x58A850EAEE20FAA3, MyEntity) -- PlaceObjectOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, MyEntity, true) -- FreezeEntityPosition
    if data.HorseGender == 'female' then
        Citizen.InvokeNative(0x5653AB26C82938CF, MyEntity, 41611, 1.0) -- SetCharExpression
        Citizen.InvokeNative(0xCC8CA3E88256E58F, MyEntity) -- UpdatePedVariation
    end
    if not Cam then
        Cam = true
        CameraLighting()
    end
    SetBlockingOfNonTemporaryEvents(MyEntity, true)
    SetPedConfigFlag(MyEntity, 113, true) -- PCF_DisableShockingEvents
    Wait(300)
    Citizen.InvokeNative(0x6585D955A68452A5, MyEntity) -- ClearPedEnvDirt

    local componentsHorse = json.decode(data.HorseComp)
    if componentsHorse ~= '[]' then
        for _, hash in pairs(componentsHorse) do
            local compModel = joaat(tonumber(hash))
            if not HasModelLoaded(compModel) then
                Citizen.InvokeNative(0xFA28FE3A6246FC30, compModel) -- RequestModel
            end
            Citizen.InvokeNative(0xD3A7B003ED343FD9, MyEntity, tonumber(hash), true, true, true) -- ApplyShopItemToPed
        end
    end
end)

RegisterNUICallback('selectHorse', function(data, cb)
    cb('ok')
    TriggerServerEvent('bcc-stables:SelectHorse', data)
end)

function GetSelectedHorse()
    local data = ClientRPC.Callback.TriggerAwait('bcc-stables:GetHorseData')
    if data then
        HorseComponents = data.components
        MyHorseId = data.id
        SpawnHorse(data.model, data.name, data.gender, data.xp)
    else
        print('No selected-horse data returned!')
    end
end

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

function SpawnHorse(horseModel, horseName, gender, xp)
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
    MyModel = model

    HorseName = horseName
    local player = PlayerId()
    local playerPed = PlayerPedId()
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -40.0, 0.0))
    local spawnPosition = nil
    for height = 1, 1000 do
        local groundCheck, ground = GetGroundZAndNormalFor_3dCoord(x, y, height + 0.0)
        if groundCheck then
            spawnPosition = vector3(x, y, ground)
            break
        end
    end

    local index = 0
    while index < 25 do
        local nodeCheck, node = GetNthClosestVehicleNode(x, y, z, index)
        if nodeCheck then
            spawnPosition = node
            break
        else
            index = index + 3
        end
    end
    MyHorse = CreatePed(model, spawnPosition, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(model)
    --Citizen.InvokeNative(0xAEB97D84CDF3C00B,MyHorse,0) -- Set horse as wild = false

    LocalPlayer.state.HorseData = {
        MyHorse = NetworkGetNetworkIdFromEntity(MyHorse)
    }

    Citizen.InvokeNative(0x9587913B9E772D29, MyHorse, 0) -- PlaceEntityOnGroundProperly
    Citizen.InvokeNative(0x283978A15512B2FE, MyHorse, true) -- SetRandomOutfitVariation
    if gender == 'female' then
        Citizen.InvokeNative(0x5653AB26C82938CF, MyHorse, 41611, 1.0) -- SetCharExpression
        Citizen.InvokeNative(0xCC8CA3E88256E58F, MyHorse) -- UpdatePedVariation
    end
    Citizen.InvokeNative(0xD2CB0FB0FDCB473D, playerPed, MyHorse) -- SetPedAsSaddleHorseForPlayer
    Citizen.InvokeNative(0x931B241409216C1F, playerPed, MyHorse, false) -- SetPedOwnsAnimal
    Citizen.InvokeNative(0xB8B6430EAD2D2437, MyHorse, joaat('PLAYER_HORSE')) -- SetPedPersonality

    -- ModifyPlayerUiPromptForPed / Horse Target Prompts / (Block = 0, Hide = 1, Grey Out = 2)
    Citizen.InvokeNative(0xA3DB37EDF9A74635, player, MyHorse, 35, 1, true) -- TARGET_INFO
    Citizen.InvokeNative(0xA3DB37EDF9A74635, player, MyHorse, 49, 1, true) -- HORSE_BRUSH
    Citizen.InvokeNative(0xA3DB37EDF9A74635, player, MyHorse, 50, 1, true) -- HORSE_FEED
    if not Config.fleeEnabled then
        Citizen.InvokeNative(0xA3DB37EDF9A74635, player, MyHorse, 33, 1, true) -- HORSE_FLEE
    end

    -- SetPedConfigFlag
    Citizen.InvokeNative(0x1913FE4CBF41C463, MyHorse, 113, true) -- DisableShockingEvents
    Citizen.InvokeNative(0x1913FE4CBF41C463, MyHorse, 297, true) -- ForceInteractionLockonOnTargetPed / Allow to Lead Horse
    Citizen.InvokeNative(0x1913FE4CBF41C463, MyHorse, 312, true) -- DisableHorseGunshotFleeResponse

    local horseBlip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, MyHorse) -- BlipAddForEntity
    Citizen.InvokeNative(0x9CB1A1623062F402, horseBlip, HorseName) -- SetBlipName
    SetPedPromptName(MyHorse, HorseName)

    if HorseComponents ~= nil and HorseComponents ~= '0' then
        for _, componentHash in pairs(json.decode(HorseComponents)) do
            NativeSetPedComponentEnabled(MyHorse, tonumber(componentHash))
        end
    end

    TriggerServerEvent('bcc-stables:RegisterInventory', MyHorseId, horseModel)

    if Config.horseTag then
        TriggerEvent('bcc-stables:HorseTag')
    end

    TriggerEvent('bcc-stables:HorseActions')

    -- Bonding
    Citizen.InvokeNative(0x09A59688C26D88DF, MyHorse, 7, xp) -- SetAttributePoints
    local maxXp = Citizen.InvokeNative(0x223BF310F854871C, MyHorse, 7) -- GetMaxAttributePoints
    MaxBonding = false
    if xp >= maxXp then
        MaxBonding = true
    end
    if Config.trainerOnly then
        CheckTrainerJob()
        if IsTrainer then
            TriggerEvent('bcc-stables:HorseBonding')
        end
    else
        TriggerEvent('bcc-stables:HorseBonding')
    end

    LastLoc = nil
    UsingLantern = false
    Spawning = false
    Sending = true
    SendHorse()
end

-- Set Horse Name Above Horse
AddEventHandler('bcc-stables:HorseTag', function()
    local gamerTagId = Citizen.InvokeNative(0xE961BF23EAB76B12, MyHorse, HorseName) -- CreateMpGamerTagOnEntity
    Citizen.InvokeNative(0x5F57522BC1EB9D9D, gamerTagId, joaat('PLAYER_HORSE')) -- SetMpGamerTagTopIcon
    while MyHorse do
        Wait(1000)
        local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(MyHorse))
        if dist < Config.tagDistance and Citizen.InvokeNative(0xAAB0FE202E9FC9F0, MyHorse, -1) then -- IsMountSeatFree
            Citizen.InvokeNative(0x93171DDDAB274EB8, gamerTagId, 3) -- SetMpGamerTagVisibility
        else
            if Citizen.InvokeNative(0x502E1591A504F843, gamerTagId, MyHorse) then -- IsMpGamerTagActiveOnEntity
                Citizen.InvokeNative(0x93171DDDAB274EB8, gamerTagId, 0) -- SetMpGamerTagVisibility
            end
        end
    end
    Citizen.InvokeNative(0x839BFD7D7E49FE09, Citizen.PointerValueIntInitialized(gamerTagId)) -- RemoveMpGamerTag
end)

AddEventHandler('bcc-stables:HorseActions', function()
    while MyHorse do
        Wait(0)
        -- Open Saddlebags (key: U)
        if Citizen.InvokeNative(0x580417101DDB492F, 2, 0xD8F73058) then -- IsControlJustPressed
            OpenInventory()
        end
        -- Horse Flee (key: F in Horse Menu)
        if Config.fleeEnabled then
            if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x4216AF06) then -- IsDisabledControlJustPressed
                FleeHorse()
            end
        end
    end
end)

-- Whistle Horse
CreateThread(function()
    while true do
        Wait(0)
        local size = GetNumberOfEvents(0) -- GetNumberOfEvents
        if size > 0 then
            for i = 0, size - 1 do
                local event = Citizen.InvokeNative(0xA85E614430EFF816, 0, i) -- GetEventAtIndex
                if event == joaat('EVENT_PED_WHISTLE') then
                    local eventDataSize = 2
                    local eventDataStruct = DataView.ArrayBuffer(128)
                    eventDataStruct:SetInt32(0, 0)
                    eventDataStruct:SetInt32(8, 0)

                    local data = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, 0, i, eventDataStruct:Buffer(), eventDataSize) -- GetEventData
                    if data then
                        if eventDataStruct:GetInt32(0) == PlayerPedId() then
                            if eventDataStruct:GetInt32(8) ~= 869278708 then -- WHISTLEHORSELONG
                                WhistleHorse()
                            else
                                LongWhistleHorse()
                            end
                        end
                    end
                end
            end
        end
    end
end)



function WhistleHorse()
    if MyHorse then
        if Citizen.InvokeNative(0x77F1BEB8863288D5, MyHorse, 0x4924437D, 0) ~= 0 then -- GetScriptTaskStatus
            local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(MyHorse))
            if dist >= 100 then
                DeleteEntity(MyHorse)
                Wait(1000)
                MyHorse = nil
                GetSelectedHorse()
            else
                Sending = true
                SendHorse()
            end
        end
    else
        WhistleSpawn()
    end
end

function LongWhistleHorse()
    local playerPed = PlayerPedId()
    if MyHorse then
        if Citizen.InvokeNative(0x77F1BEB8863288D5, MyHorse, 0x4924437D, 0) ~= 0 then -- GetScriptTaskStatus
            local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyHorse))
            if dist <= 45 then
                if Citizen.InvokeNative(0x77F1BEB8863288D5, MyHorse, 0x3EF867F4, 0) ~= 1 then -- GetScriptTaskStatus
                    Citizen.InvokeNative(0x304AE42E357B8C7E, MyHorse, playerPed, math.random(1.0, 4.0), math.random(5.0, 8.0), 0.0, 0.7, -1, 3.0, 1) -- TaskFollowToOffsetOfEntity
                else
                    ClearPedTasks(MyHorse)
                end
            end
        end
    else
        WhistleSpawn()
    end
end

function WhistleSpawn()
    if Config.whistleSpawn then
        GetSelectedHorse()
    else
        VORPcore.NotifyRightTip(_U('stableSpawn'), 4000)
    end
end

-- Move horse to Player
function SendHorse()
    CreateThread(function()
        local playerPed = PlayerPedId()
        Citizen.InvokeNative(0x6A071245EB0D1882, MyHorse, playerPed, -1, 10.2, 2.0, 0.0, 0) -- TaskGoToEntity
        while Sending == true do
            Wait(0)
            local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyHorse))
            if (dist <= 10.0) then
                ClearPedTasks(MyHorse)
                Sending = false
            end
        end
    end)
end

function OpenInventory()
    local playerPed = PlayerPedId()
    local hasSaddlebags = Citizen.InvokeNative(0xFB4891BD7578CDC1, MyHorse, -2142954459) -- IsMetaPedUsingComponent
    local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyHorse))
    if dist <= 1.5 then
        if Config.useSaddlebags then
            if not hasSaddlebags then
                return VORPcore.NotifyRightTip(_U('noSaddlebags'), 4000)
            end
        end
        if Config.searchSaddlebags and hasSaddlebags then
            if not IsPedOnFoot(playerPed) then
                return VORPcore.NotifyRightTip(_U('standingInv'), 4000)
            else
                Citizen.InvokeNative(0xCD181A959CFDD7F4, playerPed, MyHorse, joaat('Interaction_LootSaddleBags'), 0, 1) -- TaskAnimalInteraction
            end
        end
        TriggerServerEvent('bcc-stables:OpenInventory', MyHorseId)
    end
end

function FleeHorse()
    if MyHorse then
        Citizen.InvokeNative(0x22B0D0E37CCB840D, MyHorse, PlayerPedId(), 150.0, 10000, 6, 3.0) -- TaskSmartFleePed
        Wait(10000)
        TriggerServerEvent('bcc-stables:DeregisterInventory', MyHorseId)
        DeleteEntity(MyHorse)
        MyHorse = nil
    end
end

-- MRP CHANGE: HORSE TRAINER
AddEventHandler('bcc-stables:HorseBonding', function()
    while not MaxBonding do
        Wait(5000)
        local playerPed = PlayerPedId()
        local lastLed = Citizen.InvokeNative(0x693126B5D0457D0D, playerPed) -- GetLastLedMount
        local isMounted = Citizen.InvokeNative(0x460BC76A0E10655E, playerPed) -- IsPedOnMount
        local isLeading = Citizen.InvokeNative(0xEFC4303DDC6E60D3, playerPed) -- IsPedLeadingHorse

        if ((lastLed == MyHorse and isLeading) or (MyHorse == Citizen.InvokeNative(0x4C8B59171957BCF7, playerPed) and isMounted)) then -- GetLastMount
            if LastLoc == nil then
                LastLoc = GetEntityCoords(MyHorse)
            else
                local dist = #(LastLoc - GetEntityCoords(MyHorse))
                if dist >= Config.trainingDistance then
                    LastLoc = GetEntityCoords(MyHorse)
                    SaveXp('travel')
                end
            end
        end
    end
end)

function SaveXp(xpSource)
    local horseXp = nil
    local updateXp = {
        ['travel'] = function()
            horseXp = Config.horseXpPerCheck
        end,
        ['brush'] = function()
            horseXp = Config.horseXpPerBrush
        end,
        ['feed'] = function()
            horseXp = Config.horseXpPerFeed
        end
    }
    if updateXp[xpSource] then
        updateXp[xpSource]()
    else
        return print('No xpSource Data!')
    end
    Citizen.InvokeNative(0x75415EE0CB583760, MyHorse, 7, horseXp) -- AddAttributePoints
    if Config.showXpMessage then
        VORPcore.NotifyRightTip('+ ' .. horseXp .. ' XP', 2000)
    end
    local maxXp = Citizen.InvokeNative(0x223BF310F854871C, MyHorse, 7) -- GetMaxAttributePoints
    local newXp = Citizen.InvokeNative(0x219DA04BAA9CB065, MyHorse, 7, Citizen.ResultAsInteger()) -- GetAttributePoints
    if newXp >= maxXp then
        MaxBonding = true
    end
    if newXp < maxXp then
        TriggerServerEvent('bcc-stables:UpdateHorseXp', newXp, MyHorseId)
    end
end

function HorseStats()
    local currentLevel = Citizen.InvokeNative(0x147149F2E909323C, MyHorse, 7, Citizen.ResultAsInteger()) -- GetAttributeBaseRank
    local currentXp = Citizen.InvokeNative(0x219DA04BAA9CB065, MyHorse, 7, Citizen.ResultAsInteger()) --GetAttributePoints
    local points1 = Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 1) -- GetDefaultAttributePointsNeededForRank / Bonding Level
    local points2 = Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 2)
    local points3 = Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 3)
    local points4 = Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 4)
    print('Horse Name:', HorseName)
    print('Current Bonding Level:', currentLevel)
    print('Current XP:', currentXp)
    print('XP Level 1:', points1, 'Default Settings')
    print('XP Level 2:', points2, 'Trick: Rear-Up / left-ctrl + spacebar')
    print('Xp Level 3:', points3, 'Trick: Skid-Stop / left-ctrl')
    print('XP Level 4:', points4, 'Trick: Dance and Drift / spacebar')
end

RegisterCommand('horseStats', function()
    if MyHorse then
        HorseStats()
    else
        VORPcore.NotifyRightTip(_U('noSelectedHorse'), 4000)
    end
end)

-- Wild Horse Taming
CreateThread(function()
    AddSellPointBlip()
    local maxTamecount = Config.tameDifficulty
    while true do
        local mount = Citizen.InvokeNative(0xE7E11B8DCBED1058, PlayerPedId()) -- GetMount
        Wait(1000)
        if mount and not MyHorse then
            local horseModel = GetEntityModel(mount)
            for _, v in pairs(Config.Horses) do
                for i, r in pairs(v.colors) do
                    local horseHash = GetHashKey(i)
                    if horseHash == horseModel then
                        Entity(mount).state.model = i
                        if not HorseBreed then
                            if Config.displayHorseName then
                                if v.breed == "Other" then
                                    VORPcore.NotifyBottomRight(r.color, 1000)
                                else
                                    VORPcore.NotifyBottomRight(v.breed, 1000)
                                end
                                HorseBreed = true
                            end
                        end
                    end
                end
            end
            local owner = Citizen.InvokeNative(0xF103823FFE72BB49, mount) -- GetActiveAnimalOwner
            local isWild = Citizen.InvokeNative(0x3B005FF0538ED2A9, mount) -- GetAnimalIsWild
            if not isWild and owner ~= false and Entity(mount).state.taming ~= nil then
                if Config.trainerOnly then
                    CheckTrainerJob()
                    if IsTrainer then
                        if TameCount < maxTamecount then
                            TameCount = TameCount + 1
                            if MiniGame ~= nil then
                                HorseCaptureMinigame()
                            end
                            Citizen.InvokeNative(0xAEB97D84CDF3C00B, mount, true) -- SetAnimalIsWild
                            Citizen.InvokeNative(0xBCC76708E5677E1D, mount, true) -- ClearActiveAnimalOwner
                            Citizen.InvokeNative(0x9FF1E042FA597187, mount, 97, false) -- SetAnimalTuningBoolParam
                        else
                            Citizen.InvokeNative(0x9FF1E042FA597187, mount, 97, true) -- SetAnimalTuningBoolParam
                            Entity(mount).state.taming = nil
                            Entity(mount).state.canSell = true
                        end
                    else
                        Citizen.InvokeNative(0xAEB97D84CDF3C00B, mount, true) -- SetAnimalIsWild
                        Citizen.InvokeNative(0xBCC76708E5677E1D, mount, true) -- ClearActiveAnimalOwner
                    end
                else
                    if TameCount < maxTamecount then
                        TameCount = TameCount + 1
                        if MiniGame ~= nil then
                            HorseCaptureMinigame()
                        end
                        Citizen.InvokeNative(0xAEB97D84CDF3C00B, mount, true) -- SetAnimalIsWild
                        Citizen.InvokeNative(0xBCC76708E5677E1D, mount, true) -- ClearActiveAnimalOwner
                        Citizen.InvokeNative(0x9FF1E042FA597187, mount, 97, false) -- SetAnimalTuningBoolParam
                    else
                        Citizen.InvokeNative(0x9FF1E042FA597187, mount, 97, true)
                        Entity(mount).state.taming = nil
                        Entity(mount).state.canSell = true
                    end
                end
            elseif isWild and owner == false and Entity(mount).state.taming == nil then
                if Config.trainerOnly then
                    CheckTrainerJob()
                    TamingMount = mount
                    if IsTrainer then
                        Entity(mount).state.taming = true
                        if MiniGame ~= nil then
                            HorseCaptureMinigame()
                        end
                    else
                        Entity(mount).state.taming = true
                    end
                else
                    TamingMount = mount
                    Entity(mount).state.taming = true
                    if MiniGame ~= nil then
                        HorseCaptureMinigame()
                    end
                end
            end
        else
            if TamingMount then
                Entity(TamingMount).state.taming = nil
                TamingMount = nil
            end
            TameCount = 0
        end
    end
end)

function HorseCaptureMinigame()
    local cfg = {
        focus = true, -- Should minigame take nui focus (required)
        cursor = false, -- Should minigame have cursor
        maxattempts = 3, -- How many fail attempts are allowed before game over
        type = 'bar', -- What should the bar look like. (bar, trailing)
        userandomkey = false, -- Should the minigame generate a random key to press?
        keytopress = 'B', -- userandomkey must be false for this to work. Static key to press
        keycode = 66, -- The JS keycode for the keytopress
        speed = 5, -- How fast the orbiter grows
        strict = true -- if true, letting the timer run out counts as a failed attempt
    }
    MiniGame.Start('skillcheck', cfg, function(result)
        if not result.passed then
            TameCount = TameCount - 1
        end
    end)
end

-- Manage Tamed Horse
CreateThread(function() -- distance and seller
    local markerLoc = nil
    local allowSale = Config.allowSale
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local sleep = true
        local mount = Citizen.InvokeNative(0xE7E11B8DCBED1058, playerPed) -- GetMount
        if Config.trainerOnly then
            if IsTrainer and mount and Entity(mount).state.canSell then
                for _, v in pairs(Config.sellPoints) do
                    local distance = #(GetEntityCoords(playerPed) - v.coords)
                    if distance < 30 then
                        sleep = false
                        if not markerLoc then
                            markerLoc = vector3(v.coords[1], v.coords[2], v.coords[3] -2)
                        end
                        Citizen.InvokeNative(0x2A32FAA57B937173, 0x6EB7D3BB, markerLoc, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 2.0, 255, 255, 255, 175, false, false, 1, false) -- DrawMarker
                        if distance < 5 and not InMenu then
                            local capturePrompts = CreateVarString(10, 'LITERAL_STRING', _U('manageHorse'))
                            PromptSetActiveGroupThisFrame(TameGroup, capturePrompts)
                            if allowSale then
                                if not TamedCooldown then
                                    PromptSetEnabled(SellTame, true)
                                    PromptSetVisible(SellTame, true)
                                else
                                    PromptSetEnabled(SellTame, false)
                                end
                            else
                                PromptSetVisible(SellTame, false)
                            end
                            if Config.allowKeep then
                                PromptSetEnabled(KeepTame, true)
                                PromptSetVisible(KeepTame, true)
                            else
                                PromptSetVisible(KeepTame, false)
                            end

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, SellTame) then  -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-stables:SellTamedHorse', GetEntityModel(mount))
                                TriggerEvent('bcc-stables:SellTamedCooldown')
                                if mount then
                                    Citizen.InvokeNative(0x48E92D3DDE23C23A, playerPed, 0, 0, 0, 0, mount) -- TaskDismountAnimal
                                    while not Citizen.InvokeNative(0x01FEE67DB37F59B2, playerPed) do -- IsPedOnFoot
                                        Wait(10)
                                    end
                                    DeleteEntity(mount)
                                    mount = nil
                                    Wait(200)
                                    HorseBreed = nil
                                end
                            end
                            if Citizen.InvokeNative(0xC92AC953F0A982AE, KeepTame) then  -- UiPromptHasStandardModeCompleted                                
                                local tempData = {}
                                tempData.model = Entity(mount).state.model
                                if IsPedMale(mount) then
                                    tempData.gender = 'male'
                                else
                                    tempData.gender = 'female'
                                end
                                tempData.mount = mount
                                KeepTamedHorse(tempData)
                            end
                        end
                    else
                        markerLoc = nil
                    end
                end
            end
        else
            if mount and Entity(mount).state.canSell then
                for _, v in pairs(Config.sellPoints) do
                    local distance = #(GetEntityCoords(playerPed) - v.coords)
                    if distance < 30 then
                        sleep = false
                        if not markerLoc then
                            markerLoc = vector3(v.coords[1], v.coords[2], v.coords[3] -2)
                        end
                        Citizen.InvokeNative(0x2A32FAA57B937173, 0x6EB7D3BB, markerLoc, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 2.0, 255, 255, 255, 175, false, false, 1, false) -- DrawMarker
                        if distance < 5 and not InMenu then
                            local capturePrompts = CreateVarString(10, 'LITERAL_STRING', _U('manageHorse'))
                            PromptSetActiveGroupThisFrame(TameGroup, capturePrompts)
                            if allowSale then
                                if not TamedCooldown then
                                    PromptSetEnabled(SellTame, true)
                                    PromptSetVisible(SellTame, true)
                                else
                                    PromptSetEnabled(SellTame, false)
                                end
                            else
                                PromptSetVisible(SellTame, false)
                            end
                            if Config.allowKeep then
                                PromptSetEnabled(KeepTame, true)
                                PromptSetVisible(KeepTame, true)
                            else
                                PromptSetVisible(KeepTame, false)
                            end

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, SellTame) then  -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-stables:SellTamedHorse', GetEntityModel(mount))
                                TriggerEvent('bcc-stables:SellTamedCooldown')
                                if mount then
                                    Citizen.InvokeNative(0x48E92D3DDE23C23A, playerPed, 0, 0, 0, 0, mount) -- TaskDismountAnimal
                                    while not Citizen.InvokeNative(0x01FEE67DB37F59B2, playerPed) do -- IsPedOnFoot
                                        Wait(10)
                                    end
                                    DeleteEntity(mount)
                                    mount = nil
                                    Wait(200)
                                    HorseBreed = nil
                                end
                            end
                            if Citizen.InvokeNative(0xC92AC953F0A982AE, KeepTame) then  -- UiPromptHasStandardModeCompleted                                
                                local tempData = {}
                                tempData.model = Entity(mount).state.model
                                if IsPedMale(mount) then
                                    tempData.gender = 'male'
                                else
                                    tempData.gender = 'female'
                                end
                                tempData.mount = mount
                                KeepTamedHorse(tempData)
                            end
                        end
                    else
                        markerLoc = nil
                    end
                end
            end
        end
        if sleep then
            Wait(1000)
        end
    end
end)

AddEventHandler('bcc-stables:SellTamedCooldown', function()
    local cooldown = math.floor(Config.sellCooldown * 60000)
    VORPcore.NotifyRightTip(_U('tamedCooldown') .. Config.sellCooldown .. _U('minutes'), 4000)
    TamedCooldown = true
    Wait(cooldown)
    TamedCooldown = false
end)

function KeepTamedHorse(tempData)
    CheckTrainerJob()
    local data = {}
    if IsTrainer then
        data.isTrainer = true
    else
        data.isTrainer = false
    end
    local canKeep = ClientRPC.Callback.TriggerAwait('bcc-stables:KeepTamedHorse', data)
    if canKeep then
        NameHorse(tempData)
    else
        HorseBreed = nil
    end
end

function NameHorse(tempData)
    InMenu = true
    local playerPed = PlayerPedId()
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
                tempData.name = tostring(horseName)
                Citizen.InvokeNative(0x48E92D3DDE23C23A, playerPed, 0, 0, 0, 0, tempData.mount) -- TaskDismountAnimal
                while not Citizen.InvokeNative(0x01FEE67DB37F59B2, playerPed) do -- IsPedOnFoot
                    Wait(10)
                end
                local horseSaved = ClientRPC.Callback.TriggerAwait('bcc-stables:SaveTamedHorse', tempData)
                if horseSaved then
                    DeleteEntity(tempData.mount)
                    HorseBreed = nil
                end
            else
                NameHorse(tempData)
            end
        end
    end)
    InMenu = false
end

-- Set Horse Wild
RegisterCommand('releaseHorse',function()
    if Config.devMode then
        local mount = Citizen.InvokeNative(0xE7E11B8DCBED1058, PlayerPedId()) -- GetMount
        Citizen.InvokeNative(0xAEB97D84CDF3C00B, mount, true) -- SetAnimalIsWild
        Citizen.InvokeNative(0xBCC76708E5677E1D, mount, true) -- ClearActiveAnimalOwner
        Citizen.InvokeNative(0x9FF1E042FA597187, mount, 97, false) -- SetAnimalTuningBoolParam
    else
        print('Command used in Developer Mode Only!')
    end
end)

RegisterNetEvent('bcc-stables:BrushHorse', function()
    local playerPed = PlayerPedId()
    local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyHorse))
    if dist <= 2.0 then
        if not BrushCooldown then
            Citizen.InvokeNative(0xCD181A959CFDD7F4, playerPed, MyHorse, joaat('Interaction_Brush'), joaat('p_brushHorse02x'), 1) -- TaskAnimalInteraction

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

            Citizen.InvokeNative(0x6585D955A68452A5, MyHorse) -- ClearPedEnvDirt
            Citizen.InvokeNative(0x523C79AEEFCC4A2A, MyHorse, 10, 'ALL') -- ClearPedDamageDecalByZone
            Citizen.InvokeNative(0x8FE22675A5A45817, MyHorse) -- ClearPedBloodDamage
            if (Config.horseXpPerBrush > 0) and (not MaxBonding) then
                if Config.trainerOnly then
                    if IsTrainer then
                        SaveXp('brush')
                    end
                else
                    SaveXp('brush')
                end
            end
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
    local playerPed = PlayerPedId()
    local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyHorse))
    if dist <= 2.0 then
        if not FeedCooldown then
            Citizen.InvokeNative(0xCD181A959CFDD7F4, playerPed, MyHorse, joaat('Interaction_Food'),
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
                Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 1, newStamina) -- SetAttributeCoreValue
            end
            if (Config.horseXpPerFeed > 0) and (not MaxBonding) then
                if Config.trainerOnly then
                    if IsTrainer then
                        SaveXp('feed')
                    end
                else
                    SaveXp('feed')
                end
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
        Citizen.InvokeNative(0xFA28FE3A6246FC30, model) -- RequestModel
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, MyEntity, tonumber(hash), true, true, true) -- ApplyShopItemToPed
end

-- Sell Player Horse
RegisterNUICallback('sellHorse', function(data, cb)
    cb('ok')
    DeleteEntity(MyEntity)
    Cam = false
    local horseSold = ClientRPC.Callback.TriggerAwait('bcc-stables:SellMyHorse', data)
    if horseSold then
        StableMenu()
    end
end)

-- Return Player Horse at Stable
function ReturnHorse()
    local playerPed = PlayerPedId()
    if MyHorse then
        if Citizen.InvokeNative(0x460BC76A0E10655E, playerPed) then -- IsPedOnMount
            Citizen.InvokeNative(0x48E92D3DDE23C23A, playerPed, 0, 0, 0, 0, MyHorse) -- TaskDismountAnimal
            while not Citizen.InvokeNative(0x01FEE67DB37F59B2, playerPed) do -- IsPedOnFoot
                Wait(10)
            end
        end
        TriggerServerEvent('bcc-stables:DeregisterInventory', MyHorseId)
        DeleteEntity(MyHorse)
        MyHorse = nil
        VORPcore.NotifyRightTip(_U('horseReturned'), 4000)
    else
        VORPcore.NotifyRightTip(_U('noHorse'), 4000)
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
            Citizen.InvokeNative(0xD2D9E04C0DF927F4, shopCfg.spawn.x, shopCfg.spawn.y, shopCfg.spawn.z + 3, 130, 130, 85, 4.0, 15.0) -- DrawLightWithRange
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

RegisterCommand('horseRespawn', function()
    Spawning = false
    WhistleSpawn()
end)

function StartPrompts()
    local shopStr = CreateVarString(10, 'LITERAL_STRING', _U('shopPrompt'))
    OpenShops = PromptRegisterBegin()
    PromptSetControlAction(OpenShops, Config.keys.shop)
    PromptSetText(OpenShops, shopStr)
    PromptSetVisible(OpenShops, 1)
    PromptSetStandardMode(OpenShops, 1)
    PromptSetGroup(OpenShops, ShopGroup)
    PromptRegisterEnd(OpenShops)

    local callStr = CreateVarString(10, 'LITERAL_STRING', _U('callPrompt'))
    OpenCall = PromptRegisterBegin()
    PromptSetControlAction(OpenCall, Config.keys.call)
    PromptSetText(OpenCall, callStr)
    PromptSetVisible(OpenCall, 1)
    PromptSetStandardMode(OpenCall, 1)
    PromptSetGroup(OpenCall, ShopGroup)
    PromptRegisterEnd(OpenCall)

    local returnStr = CreateVarString(10, 'LITERAL_STRING', _U('returnPrompt'))
    OpenReturn = PromptRegisterBegin()
    PromptSetControlAction(OpenReturn, Config.keys.ret)
    PromptSetText(OpenReturn, returnStr)
    PromptSetVisible(OpenReturn, 1)
    PromptSetStandardMode(OpenReturn, 1)
    PromptSetGroup(OpenReturn, ShopGroup)
    PromptRegisterEnd(OpenReturn)

    local sellStr = CreateVarString(10, 'LITERAL_STRING', _U('sellPrompt'))
    SellTame = PromptRegisterBegin()
    PromptSetControlAction(SellTame, Config.keys.sell)
    PromptSetText(SellTame, sellStr)
    PromptSetStandardMode(SellTame, 1)
    PromptSetGroup(SellTame, TameGroup)
    PromptRegisterEnd(SellTame)

    local keepStr = CreateVarString(10, 'LITERAL_STRING', _U('keepPrompt') .. tostring(Config.tameCost))
    KeepTame = PromptRegisterBegin()
    PromptSetControlAction(KeepTame, Config.keys.keep)
    PromptSetText(KeepTame, keepStr)
    PromptSetStandardMode(KeepTame, 1)
    PromptSetGroup(KeepTame, TameGroup)
    PromptRegisterEnd(KeepTame)
end

function CheckTrainerJob()
    IsTrainer = false
    local result = ClientRPC.Callback.TriggerAwait('bcc-stables:CheckTrainerJob')
    if result then
        IsTrainer = true
    else
        return
    end
end

function CheckPlayerJob(shop)
    HasJob = nil
    local result = ClientRPC.Callback.TriggerAwait('bcc-stables:CheckPlayerJob', shop)
    if result then
        HasJob = true
    else
        return
    end
end

function AddSellPointBlip()
    for _, v in pairs(Config.sellPoints) do
        local blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, v.coords) -- BlipAddForCoords
        SetBlipSprite(blip, -1103135225, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Trainer') -- SetBlipName
    end
end

function AddBlip(shop)
    local shopCfg = Config.shops[shop]
    shopCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, shopCfg.npc) -- BlipAddForCoords
    SetBlipSprite(shopCfg.Blip, shopCfg.blipSprite, true)
    SetBlipScale(shopCfg.Blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, shopCfg.Blip, shopCfg.blipName) -- SetBlipName
end

function AddNPC(shop)
    local shopCfg = Config.shops[shop]
    local model = joaat(shopCfg.npcModel)
    LoadModel(model)
    shopCfg.NPC = CreatePed(shopCfg.npcModel, shopCfg.npc.x, shopCfg.npc.y, shopCfg.npc.z - 1.0, shopCfg.npcHeading, false, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, shopCfg.NPC, true) -- SetRandomOutfitVariation
    TaskStartScenarioInPlace(shopCfg.NPC, joaat('WORLD_HUMAN_WRITE_NOTEBOOK'), -1, true, false, false, false)
    SetEntityCanBeDamaged(shopCfg.NPC, false)
    SetEntityInvincible(shopCfg.NPC, true)
    Wait(500)
    FreezeEntityPosition(shopCfg.NPC, true)
    SetBlockingOfNonTemporaryEvents(shopCfg.NPC, true)
end

function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

RegisterNetEvent('bcc-stables:UpdateMyHorseEntity', function()
    if MyHorse then
        MyHorse = NetworkGetEntityFromNetworkId(LocalPlayer.state.HorseData.MyHorse) -- Update Global Horse Entity after session change
        local playerPed = PlayerPedId()
        Citizen.InvokeNative(0xD2CB0FB0FDCB473D, playerPed, MyHorse) -- SetPedAsSaddleHorseForPlayer
        Citizen.InvokeNative(0x931B241409216C1F, playerPed, MyHorse, false) -- SetPedOwnsAnimal
        Citizen.InvokeNative(0xB8B6430EAD2D2437, MyHorse, joaat('PLAYER_HORSE')) -- SetPedPersonality

        local horseBlip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, MyHorse) -- BlipAddForEntity
        Citizen.InvokeNative(0x9CB1A1623062F402, horseBlip, HorseName) -- SetBlipName
        SetPedPromptName(MyHorse, HorseName)

        if Config.horseTag then
            TriggerEvent('bcc-stables:HorseTag', HorseName)
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
