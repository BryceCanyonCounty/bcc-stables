local VORPcore = exports.vorp_core:GetCore()
local FeatherMenu =  exports['feather-menu'].initiate()

-- Shop Prompts
local OpenShops, OpenCall, OpenReturn
local ShopGroup = GetRandomIntInRange(0, 0xffffff)

-- Tame Prompts
local KeepTame, SellTame
local TameGroup = GetRandomIntInRange(0, 0xffffff)

-- Trade Prompts
local TradeHorse
local TradeGroup = GetRandomIntInRange(0, 0xffffff)

-- Loot Prompts
local LootHorse
local LootGroup = GetRandomIntInRange(0, 0xffffff)

-- Target Prompts
local HorseDrink, HorseRest, HorseSleep, HorseWallow = nil, nil, nil, nil

-- Horse Tack
local BedrollsUsing, MasksUsing, MustachesUsing, HolstersUsing = nil, nil, nil, nil
local SaddlesUsing, SaddleclothsUsing, StirrupsUsing = nil, nil, nil
local BagsUsing, ManesUsing, TailsUsing, SaddleHornsUsing = nil, nil, nil, nil

-- Horse Training
local LastLoc, TamedModel = nil, nil
local IsTrainer, IsNaming, MaxBonding, HorseBreed = false, false, false, false

-- Misc.
local MyHorse = nil
local HorseComponents = {}
local StableName, ShopEntity, HorseName, Site
local MyEntity, MyEntityID, MyHorseId, MyModel
local InMenu, HasJob, UsingLantern, PromptsStarted = false, false, false, false
local Drinking, Spawning, Sending, Cam, InWrithe = false, false, false, false, false

CreateThread(function()
    StartPrompts()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000
        local hour = GetClockHours()

        if InMenu or IsEntityDead(playerPed) then goto END end

        for site, siteCfg in pairs(Stables) do
            local distance = #(playerCoords - siteCfg.npc.coords)
            -- Stable Closed
            if (siteCfg.shop.hours.active and hour >= siteCfg.shop.hours.close) or (siteCfg.shop.hours.active and hour < siteCfg.shop.hours.open) then
                ManageStableBlip(site, true)
                RemoveStableNPC(site)
                if distance <= siteCfg.shop.distance then
                    sleep = 0
                    PromptSetActiveGroupThisFrame(ShopGroup, CreateVarString(10, 'LITERAL_STRING', siteCfg.shop.name .. _U('hours') ..
                    siteCfg.shop.hours.open .. _U('to') .. siteCfg.shop.hours.close .. _U('hundred')), 2, 0, 0, 0)
                    PromptSetEnabled(OpenShops, false)
                    PromptSetEnabled(OpenCall, Config.closedCall)
                    PromptSetEnabled(OpenReturn, Config.closedReturn)
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenCall) then  -- PromptHasStandardModeCompleted
                        if siteCfg.shop.jobsEnabled then
                            CheckPlayerJob(false, site)
                            if not HasJob then goto END end
                        end
                        GetSelectedHorse()
                    end
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then  -- PromptHasStandardModeCompleted
                        if siteCfg.shop.jobsEnabled then
                            CheckPlayerJob(false, site)
                            if not HasJob then goto END end
                        end
                        ReturnHorse()
                    end
                end
            -- Stable Open
            else
                ManageStableBlip(site, false)
                if distance <= siteCfg.npc.distance then
                    if siteCfg.npc.active then
                        AddStableNPC(site)
                    end
                else
                    RemoveStableNPC(site)
                end
                if distance <= siteCfg.shop.distance then
                    sleep = 0
                    PromptSetActiveGroupThisFrame(ShopGroup, CreateVarString(10, 'LITERAL_STRING', siteCfg.shop.prompt), 2, 0, 0, 0)
                    PromptSetEnabled(OpenShops, true)
                    PromptSetEnabled(OpenCall, true)
                    PromptSetEnabled(OpenReturn, true)

                    if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then  -- PromptHasStandardModeCompleted
                        CheckPlayerJob(false, site)
                        if siteCfg.shop.jobsEnabled then
                            if not HasJob then goto END end
                        end
                        OpenStable(site)

                    elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenCall) then -- PromptHasStandardModeCompleted
                        if siteCfg.shop.jobsEnabled then
                            CheckPlayerJob(false, site)
                            if not HasJob then goto END end
                        end
                        GetSelectedHorse()

                    elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- PromptHasStandardModeCompleted
                        if siteCfg.shop.jobsEnabled then
                            CheckPlayerJob(false, site)
                            if not HasJob then goto END end
                        end
                        ReturnHorse()
                    end
                end
            end
        end
        ::END::
        Wait(sleep)
    end
end)

function OpenStable(site)
    DisplayRadar(false)
    InMenu = true
    Site = site
    StableName = Stables[Site].shop.name
    CreateCamera()

    SendNUIMessage({
        action = 'show',
        shopData = JobMatchedHorses,
        compData = HorseComp,
        location = StableName,
        currencyType = Config.currencyType
    })
    SetNuiFocus(true, true)
    TriggerServerEvent('bcc-stables:GetMyHorses')
end

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

    local siteCfg = Stables[Site]
    ShopEntity = CreatePed(model, siteCfg.horse.coords.x, siteCfg.horse.coords.y, siteCfg.horse.coords.z - 1.0, siteCfg.horse.heading, false, false)
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
    CheckPlayerJob(true)
    if Stables[Site].trainerBuy and not IsTrainer then
        VORPcore.NotifyRightTip(_U('trainerBuyHorse'), 4000)
        StableMenu()
        return
    end
    if IsTrainer then
        data.isTrainer = true
    else
        data.isTrainer = false
    end
    data.origin = 'buyHorse'
    local canBuy = VORPcore.Callback.TriggerAwait('bcc-stables:BuyHorse', data)
    if canBuy then
        SetHorseName(data)
    else
        StableMenu()
    end
end)

function SetHorseName(data)
    IsNaming = true
    if data.origin ~= 'tameHorse' then
        SendNUIMessage({
            action = 'hide'
        })
        SetNuiFocus(false, false)
        Wait(200)
    end

    AddTextEntry('FMMC_MPM_NA', _U('nameHorse'))
    DisplayOnscreenKeyboard(1, 'FMMC_MPM_NA', '', '', '', '', '', 30)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(0)
    end
    if GetOnscreenKeyboardResult() then
        local horseName = GetOnscreenKeyboardResult()
        if string.len(horseName) > 0 then
            data.name = horseName
            if data.origin == 'updateHorse' then
                local nameSaved = VORPcore.Callback.TriggerAwait('bcc-stables:UpdateHorseName', data)
                if nameSaved then
                    StableMenu()
                end
                IsNaming = false
                return
            elseif data.origin == 'buyHorse' then
                data.captured = 0
                local horseSaved = VORPcore.Callback.TriggerAwait('bcc-stables:SaveNewHorse', data)
                if horseSaved then
                    StableMenu()
                end
                IsNaming = false
                return
            elseif data.origin == 'tameHorse' then
                data.captured = 1
                local playerPed = PlayerPedId()
                Citizen.InvokeNative(0x48E92D3DDE23C23A, playerPed, 0, 0, 0, 0, data.mount) -- TaskDismountAnimal
                while not Citizen.InvokeNative(0x01FEE67DB37F59B2, playerPed) do -- IsPedOnFoot
                    Wait(10)
                end
                local horseSaved = VORPcore.Callback.TriggerAwait('bcc-stables:SaveNewHorse', data)
                if horseSaved then
                    DeleteEntity(data.mount)
                    HorseBreed = false
                end
                IsNaming = false
                return
            end
        else
            SetHorseName(data)
            return
        end
    end
    if data.origin ~= 'tameHorse' then
        SendNUIMessage({
            action = 'show',
            shopData = Horses,
            compData = HorseComp,
            location = StableName,
            currencyType = Config.currencyType
        })
        SetNuiFocus(true, true)
        TriggerServerEvent('bcc-stables:GetMyHorses')
    end
    IsNaming = false
end

RegisterNUICallback('RenameHorse', function(data, cb)
    cb('ok')
    data.origin = 'updateHorse'
    SetHorseName(data)
end)

-- View Owned Horse in Stable Menu
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

    local siteCfg = Stables[Site]
    MyEntity = CreatePed(model, siteCfg.horse.coords.x, siteCfg.horse.coords.y, siteCfg.horse.coords.z - 1.0, siteCfg.horse.heading, false, false)
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
    local data = VORPcore.Callback.TriggerAwait('bcc-stables:GetHorseData')
    if data then
        HorseComponents = data.components
        MyHorseId = data.id
        SpawnHorse(data)
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
        MustachesUsing,
        HolstersUsing
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
        shopData = Horses,
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

function SpawnHorse(data)
    if Spawning then
        return
    end
    Spawning = true

    if MyHorse then
        DeleteEntity(MyHorse)
        MyHorse = nil
    end

    local horseModel = data.model
    local xp = data.xp

    MyModel = joaat(horseModel)
    LoadModel(MyModel)

    for _, horseCfg in pairs(Horses) do
        for model, modelCfg in pairs(horseCfg.colors) do
            local horseHash = joaat(model)
            if horseHash == MyModel then
                MyHorseBreed = horseCfg.breed
                MyHorseColor = modelCfg.color
            end
        end
    end

    HorseName = data.name
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
    MyHorse = CreatePed(MyModel, spawnPosition, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(MyModel)

    LocalPlayer.state.HorseData = {
        MyHorse = NetworkGetNetworkIdFromEntity(MyHorse)
    }

    Citizen.InvokeNative(0x9587913B9E772D29, MyHorse, 0) -- PlaceEntityOnGroundProperly
    Citizen.InvokeNative(0x283978A15512B2FE, MyHorse, true) -- SetRandomOutfitVariation
    if data.gender == 'female' then
        Citizen.InvokeNative(0x5653AB26C82938CF, MyHorse, 41611, 1.0) -- SetCharExpression
        Citizen.InvokeNative(0xCC8CA3E88256E58F, MyHorse) -- UpdatePedVariation
    end
    Citizen.InvokeNative(0xD2CB0FB0FDCB473D, playerPed, MyHorse) -- SetPedAsSaddleHorseForPlayer
    Citizen.InvokeNative(0x931B241409216C1F, playerPed, MyHorse, false) -- SetPedOwnsAnimal
    Citizen.InvokeNative(0xB8B6430EAD2D2437, MyHorse, joaat('PLAYER_HORSE')) -- SetPedPersonality
    Citizen.InvokeNative(0xE6D4E435B56D5BD0, player, MyHorse) -- SetPlayerOwnsMount

    -- ModifyPlayerUiPromptForPed / Horse Prompts / (Block = 0, Hide = 1, Grey Out = 2)
    Citizen.InvokeNative(0xA3DB37EDF9A74635, player, MyHorse, 49, 1, true) -- HORSE_BRUSH
    Citizen.InvokeNative(0xA3DB37EDF9A74635, player, MyHorse, 50, 1, true) -- HORSE_FEED
    if not Config.fleeEnabled then
        Citizen.InvokeNative(0xA3DB37EDF9A74635, player, MyHorse, 33, 1, true) -- HORSE_FLEE
    end

    -- Bonding
    Citizen.InvokeNative(0x09A59688C26D88DF, MyHorse, 7, xp) -- SetAttributePoints
    local maxXp = Citizen.InvokeNative(0x223BF310F854871C, MyHorse, 7) -- GetMaxAttributePoints
    MaxBonding = false
    if xp >= maxXp then
        MaxBonding = true
    end
    if Config.trainerOnly then
        CheckPlayerJob(true)
        if IsTrainer then
            TriggerEvent('bcc-stables:HorseBonding')
        end
    else
        TriggerEvent('bcc-stables:HorseBonding')
    end

    local currentLevel = Citizen.InvokeNative(0x147149F2E909323C, MyHorse, 7, Citizen.ResultAsInteger()) -- GetAttributeBaseRank
    -- SetPedConfigFlag
    if currentLevel >= 2 then
        Citizen.InvokeNative(0x1913FE4CBF41C463, MyHorse, 113, true) -- DisableShockingEvents
    end
    if currentLevel >= 3 then
        Citizen.InvokeNative(0x1913FE4CBF41C463, MyHorse, 312, true) -- DisableHorseGunshotFleeResponse
    end
    Citizen.InvokeNative(0x1913FE4CBF41C463, MyHorse, 297, true) -- ForceInteractionLockonOnTargetPed / Allow to Lead Horse

    Citizen.InvokeNative(0xE2487779957FE897, MyHorse, 528) -- SetTransportUsageFlags

    local horseBlip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, MyHorse) -- BlipAddForEntity
    Citizen.InvokeNative(0x9CB1A1623062F402, horseBlip, HorseName) -- SetBlipName
    SetPedPromptName(MyHorse, HorseName)

    if HorseComponents ~= nil and HorseComponents ~= '0' then
        for _, componentHash in pairs(json.decode(HorseComponents)) do
            NativeSetPedComponentEnabled(MyHorse, tonumber(componentHash))
        end
    end

    SetHorseStats(data)

    TriggerServerEvent('bcc-stables:RegisterInventory', MyHorseId, horseModel)

    if Config.shareInventory then
        local myHorseNetId = NetworkGetNetworkIdFromEntity(MyHorse)
        TriggerServerEvent('bcc-stables:SetLootHorseData', myHorseNetId, MyHorseId)
    end

    if Config.horseTag then
        TriggerEvent('bcc-stables:HorseTag')
    end

    TriggerEvent('bcc-stables:TradeHorse')

    PromptsStarted = false
    TriggerEvent('bcc-stables:HorsePrompts')

    InWrithe = false
    LastLoc = nil
    UsingLantern = false
    Spawning = false
    Sending = true
    SendHorse()
end

-- Loot Players Horse Inventory
CreateThread(function()
    if Config.shareInventory then
        while true do
            local pedId, horseId, isLeading, ownerOfMount = nil, nil, nil, nil
            local playerPed = PlayerPedId()
            local sleep = 1000

            pedId = Citizen.InvokeNative(0x0501D52D24EA8934, 1, Citizen.ResultAsInteger()) -- Get HorsePedId in Range

            if (IsEntityDead(playerPed)) or (pedId == 0) or (pedId == MyHorse) then goto END end

            ownerOfMount = Citizen.InvokeNative(0xAD03B03737CE6810, pedId) -- GetPlayerOwnerOfMount
            isLeading = Citizen.InvokeNative(0xEFC4303DDC6E60D3, playerPed) -- IsPedLeadingHorse
            if (ownerOfMount == 255) or isLeading then goto END end

            sleep = 0
            PromptSetActiveGroupThisFrame(LootGroup, CreateVarString(10, 'LITERAL_STRING', _U('lootInventory')), 1, 0, 0, 0)
            if Citizen.InvokeNative(0xC92AC953F0A982AE, LootHorse) then  -- PromptHasStandardModeCompleted
                horseId = Entity(pedId).state.myHorseId
                OpenInventory(pedId, horseId, true)
            end
            ::END::
            Wait(sleep)
        end
    end
end)

-- Set Horse Name and Health Bar Above Horse
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

AddEventHandler('bcc-stables:HorsePrompts', function()
    local player = PlayerId()
    local fleeEnabled = Config.fleeEnabled
    while MyHorse do
        local playerPed = PlayerPedId()
        local sleep = 1000
        local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(MyHorse))

        if (IsPlayerFreeAiming(player)) or (distance > 2.8) or (IsEntityDead(playerPed)) then
            Citizen.InvokeNative(0xA3DB37EDF9A74635, player, MyHorse, 35, 1, true) -- Hide TARGET_INFO
            Citizen.InvokeNative(0xA3DB37EDF9A74635, player, MyHorse, 33, 1, true) -- Hide HORSE_FLEE
            PromptDelete(HorseDrink)
            PromptDelete(HorseRest)
            PromptDelete(HorseSleep)
            PromptDelete(HorseWallow)
            PromptsStarted = false
            goto END
        end

        sleep = 0

        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, `INPUT_OPEN_SATCHEL_HORSE_MENU`) then -- IsDisabledControlJustPressed
            OpenInventory(MyHorse, MyHorseId, false)
        end

        if InWrithe then
            if Citizen.InvokeNative(0x91AEF906BCA88877, 0, `INPUT_REVIVE`) then -- IsDisabledControlJustPressed
                TriggerEvent('bcc-stables:ReviveHorse')
            end
            goto END
        end

        Citizen.InvokeNative(0xA3DB37EDF9A74635, player, MyHorse, 35, 1, false) -- Show TARGET_INFO
        Citizen.InvokeNative(0xA3DB37EDF9A74635, player, MyHorse, 33, 1, false) -- Show HORSE_FLEE
        if Citizen.InvokeNative(0x27F89FDC16688A7A, player, MyHorse, false) then -- IsPlayerTargettingEntity
            sleep = 0
            local menuGroup = Citizen.InvokeNative(0xB796970BD125FCE8, MyHorse) -- PromptGetGroupIdForTargetEntity
            HorseTargetPrompts(menuGroup)

            if Citizen.InvokeNative(0x580417101DDB492F, 0, Config.keys.drink) then -- [U] IsControlJustPressed
                if Drinking then
                    goto END
                end
                HorseDrinking()
            end

            if Citizen.InvokeNative(0x580417101DDB492F, 0, Config.keys.rest) then -- [V] IsControlJustPressed
                if Drinking then
                    goto END
                end
                HorseResting()
            end

            if Citizen.InvokeNative(0x580417101DDB492F, 0, Config.keys.sleep) then -- [Z] IsControlJustPressed
                if Drinking then
                    goto END
                end
                HorseSleeping()
            end

            if Citizen.InvokeNative(0x580417101DDB492F, 0, Config.keys.wallow) then -- [C] IsControlJustPressed
                if Drinking then
                    goto END
                end
                HorseWallowing()
            end

            if fleeEnabled then
                if Citizen.InvokeNative(0x580417101DDB492F, 0, `INPUT_HORSE_COMMAND_FLEE`) then -- IsControlJustPressed
                    FleeHorse()
                end
            end
        end
        ::END::
        Wait(sleep)
    end
end)

function HorseDrinking()
    if not IsEntityInWater(MyHorse) then
        VORPcore.NotifyRightTip(HorseName .. _U('needWater'), 4000)
        return
    end
    Drinking = true
    local drinkTime = Config.drinkLength * 1000
    local dict = 'amb_creature_mammal@world_horse_drink_ground@idle'
    LoadAnim(dict)
    TaskPlayAnim(MyHorse, dict, 'idle_a', 1.0, 1.0, drinkTime, 3, 1.0, false, false, false)
    Wait(drinkTime)
    local health = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    local stamina = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 1, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    if health < 100 or stamina < 100 then
        local healthBoost = Config.boost.drinkHealth
        local staminaBoost = Config.boost.drinkStamina
        if healthBoost > 0 then
            local newHealth = health + healthBoost
            if newHealth > 100 then
                newHealth = 100
            end
            Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 0, newHealth) -- SetAttributeCoreValue
        end
        if staminaBoost > 0 then
            local newStamina = stamina + staminaBoost
            if newStamina > 100 then
                newStamina = 100
            end
            Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 1, newStamina) -- SetAttributeCoreValue
        end
        if Config.horseXpPerDrink > 0 and not MaxBonding then
            if Config.trainerOnly then
                if IsTrainer then
                    SaveXp('drink')
                end
            else
                SaveXp('drink')
            end
        end
        Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Core_Fill_Up', 'Consumption_Sounds', true, 0) -- PlaySoundFrontend
    end
    Drinking = false
end

function HorseResting()
    if not Citizen.InvokeNative(0xAAB0FE202E9FC9F0, MyHorse, -1) then -- IsMountSeatFree
        return
    end
    local dict = 'amb_creature_mammal@world_horse_resting@idle'
    LoadAnim(dict)
    TaskPlayAnim(MyHorse, dict, 'idle_a', 1.0, 1.0, -1, 3, 1.0, false, false, false)
end

function HorseSleeping()
    if not Citizen.InvokeNative(0xAAB0FE202E9FC9F0, MyHorse, -1) then -- IsMountSeatFree
        return
    end
    local dict = 'amb_creature_mammal@world_horse_sleeping@base'
    LoadAnim(dict)
    TaskPlayAnim(MyHorse, dict, 'base', 1.0, 1.0, -1, 3, 1.0, false, false, false)
end

function HorseWallowing()
    if not Citizen.InvokeNative(0xAAB0FE202E9FC9F0, MyHorse, -1) then -- IsMountSeatFree
        return
    end
    local dict = 'amb_creature_mammal@world_horse_wallow_shake@idle'
    LoadAnim(dict)
    TaskPlayAnim(MyHorse, dict, 'idle_a', 1.0, 1.0, -1, 3, 1.0, false, false, false)
end

function LoadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

-- Event Listener
CreateThread(function()
    while true do
        Wait(0)
        local size = GetNumberOfEvents(0)
        if size > 0 then
            for i = 0, size - 1 do
                local event = Citizen.InvokeNative(0xA85E614430EFF816, 0, i) -- GetEventAtIndex
                if event == 1327216456 then -- EVENT_PED_WHISTLE
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
                elseif event == 218595333 then -- EVENT_HORSE_BROKEN
                    local eventDataSize = 3
                    local eventDataStruct = DataView.ArrayBuffer(128)
                    eventDataStruct:SetInt32(0, 0)  -- Rider Ped Id
                    eventDataStruct:SetInt32(8, 0)  -- Horse Ped Id
                    eventDataStruct:SetInt32(16, 0) -- Broken Type Id

                    local data = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, 0, i, eventDataStruct:Buffer(), eventDataSize) -- GetEventData
                    if data then
                        if eventDataStruct:GetInt32(16) == 2 then -- Horse Taming Successful
                            local tamedNetId = NetworkGetNetworkIdFromEntity(eventDataStruct:GetInt32(8))
                            TriggerServerEvent('bcc-stables:SetTamedData', tamedNetId)
                        end
                    end
                elseif event == 1784289253 then -- EVENT_TRIGGERED_ANIMAL_WRITHE 
                    local eventDataSize = 2
                    local eventDataStruct = DataView.ArrayBuffer(128)
                    eventDataStruct:SetInt32(0, 0)  -- Animal Ped Id
                    eventDataStruct:SetInt32(8, 0)  -- Ped Id that Damaged Animal

                    local data = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, 0, i, eventDataStruct:Buffer(), eventDataSize) -- GetEventData
                    if data then
                        if eventDataStruct:GetInt32(0) == MyHorse then
                            TriggerEvent('bcc-stables:HorseDown')
                        end
                    end
                elseif event == 402722103 then -- EVENT_ENTITY_DAMAGED 
                    local eventDataSize = 9
                    local eventDataStruct = DataView.ArrayBuffer(128)
                    eventDataStruct:SetInt32(0, 0)  -- Damaged Entity Id
                    eventDataStruct:SetInt32(8, 0)  -- Object/Ped Id that Damaged Entity
                    eventDataStruct:SetInt32(16, 0) -- Weapon Hash that Damaged Entity
                    eventDataStruct:SetInt32(24, 0) -- Ammo Hash that Damaged Entity
                    eventDataStruct:SetInt32(32, 0) -- (float) Damage Amount
                    eventDataStruct:SetInt32(40, 0) -- Unknown
                    eventDataStruct:SetInt32(48, 0) -- (float) Entity Coord x
                    eventDataStruct:SetInt32(56, 0) -- (float) Entity Coord y
                    eventDataStruct:SetInt32(64, 0) -- (float) Entity Coord z

                    local data = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, 0, i, eventDataStruct:Buffer(), eventDataSize) -- GetEventData
                    if data then
                        if eventDataStruct:GetInt32(0) == MyHorse then
                            TriggerEvent('bcc-stables:HorseDamaged')
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
    local playerPed = PlayerPedId()
    TaskGoToEntity(MyHorse, playerPed, -1, 10.2, 2.0, 0.0, 0)
    while Sending do
        Wait(0)
        local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyHorse))
        if dist <= 10.0 then
            ClearPedTasks(MyHorse)
            Sending = false
        end
    end
end

-- Wild Horse Taming
CreateThread(function()
    local horseModel
    while true do
        local mount = Citizen.InvokeNative(0xE7E11B8DCBED1058, PlayerPedId()) -- GetMount
        if not mount or mount == MyHorse then
            goto END
        end
        horseModel = GetEntityModel(mount)
        for _, horseCfg in pairs(Horses) do
            for model, modelCfg in pairs(horseCfg.colors) do
                local horseHash = joaat(model)
                if horseHash == horseModel then
                    TamedModel = model
                    if Config.displayHorseBreed and not HorseBreed then
                        if horseCfg.breed == 'Other' then
                            VORPcore.NotifyBottomRight(modelCfg.color, 1000)
                        else
                            VORPcore.NotifyBottomRight(horseCfg.breed, 1000)
                        end
                        HorseBreed = true
                    end
                end
            end
        end
        ::END::
        Wait(1000)
    end
end)

CreateThread(function()
    local mount, mountNetId, tamedNetId
    local allowSale = Config.allowSale
    local allowKeep = Config.allowKeep
    while true do
        local playerPed = PlayerPedId()
        local sleep = 1000

        if IsEntityDead(playerPed) then goto END end

        mount = Citizen.InvokeNative(0xE7E11B8DCBED1058, playerPed) -- GetMount
        if mount then
            mountNetId = NetworkGetNetworkIdFromEntity(mount)
            tamedNetId = Entity(mount).state.netId
        end

        for site, siteCfg in pairs(Trainers) do
            local distance = #(GetEntityCoords(playerPed) - siteCfg.npc.coords)

            if siteCfg.blip.show and not siteCfg.TrainerBlip then
                AddTrainerBlip(site)
                Citizen.InvokeNative(0x662D364ABF16DE2F, siteCfg.TrainerBlip, joaat(Config.BlipColors[siteCfg.blip.color])) -- BlipAddModifier
            end

            if siteCfg.npc.active then
                if distance <= siteCfg.npc.distance then
                    if not siteCfg.TrainerNPC then
                        AddTrainerNPC(site)
                    end
                else
                    if siteCfg.TrainerNPC then
                        DeleteEntity(siteCfg.TrainerNPC)
                        siteCfg.TrainerNPC = nil
                    end
                end
            end

            if (distance <= siteCfg.shop.distance) and IsPedOnMount(playerPed) and (mountNetId == tamedNetId) and (not IsNaming) then
                sleep = 0
                PromptSetActiveGroupThisFrame(TameGroup, CreateVarString(10, 'LITERAL_STRING', siteCfg.shop.prompt), 1, 0, 0, 0)

                PromptSetVisible(SellTame, allowSale)
                PromptSetEnabled(SellTame, allowSale)

                PromptSetVisible(KeepTame, allowKeep)
                PromptSetEnabled(KeepTame, allowKeep)

                if Citizen.InvokeNative(0xE0F65F0640EF0617, SellTame) then  -- PromptHasHoldModeCompleted
                    local onCooldown = VORPcore.Callback.TriggerAwait('bcc-stables:CheckPlayerCooldown', 'sellTame')
                    if onCooldown then
                        VORPcore.NotifyRightTip(_U('sellCooldown'), 4000)
                        HorseBreed = false
                        goto END
                    end
                    if Config.trainerOnly then
                        CheckPlayerJob(true)
                        if not IsTrainer then
                            VORPcore.NotifyRightTip(_U('trainerSellHorse'), 4000)
                            HorseBreed = false
                            goto END
                        end
                    end
                    TriggerServerEvent('bcc-stables:SellTamedHorse', GetEntityModel(mount))
                    if mount then
                        Citizen.InvokeNative(0x48E92D3DDE23C23A, playerPed, 0, 0, 0, 0, mount) -- TaskDismountAnimal
                        while not Citizen.InvokeNative(0x01FEE67DB37F59B2, playerPed) do -- IsPedOnFoot
                            Wait(10)
                        end
                        VORPcore.NotifyRightTip(_U('tamedCooldown') .. Config.cooldown.sellTame .. _U('minutes'), 4000)
                        DeleteEntity(mount)
                        mount = nil
                        Wait(200)
                        HorseBreed = false
                    end
                end
                if Citizen.InvokeNative(0xE0F65F0640EF0617, KeepTame) then  -- PromptHasHoldModeCompleted
                    CheckPlayerJob(true)
                    if Config.trainerOnly then
                        if not IsTrainer then
                            VORPcore.NotifyRightTip(_U('trainerRegHorse'), 4000)
                            HorseBreed = false
                            goto END
                        end
                    end
                    local tameData = {}
                    tameData.ModelH = TamedModel
                    tameData.origin = 'tameHorse'
                    tameData.IsCash = true
                    if IsPedMale(mount) then
                        tameData.gender = 'male'
                    else
                        tameData.gender = 'female'
                    end
                    tameData.mount = mount
                    KeepTamedHorse(tameData)
                end
            end
        end
        ::END::
        Wait(sleep)
    end
end)

function KeepTamedHorse(tameData)
    if IsTrainer then
        tameData.isTrainer = true
    else
        tameData.isTrainer = false
    end

    tameData.Cash = Config.regCost

    local canKeep = VORPcore.Callback.TriggerAwait('bcc-stables:BuyHorse', tameData)
    if canKeep then
        SetHorseName(tameData)
    else
        HorseBreed = false
    end
end

AddEventHandler('bcc-stables:HorseDamaged', function()
    if IsEntityDead(MyHorse) then
        SaveHorseStats(true)
        Wait(5000)
        DeleteEntity(MyHorse)
        MyHorse = nil
        return
    end

    local writheHealth = Config.writheHealth
    if writheHealth <= 0 then
        return
    end

    local health = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    if health <= writheHealth then
        Citizen.InvokeNative(0x8C038A39C4A4B6D6, MyHorse, 0, 0) -- TaskAnimalWrithe
    end
end)

AddEventHandler('bcc-stables:HorseDown', function()
    Citizen.InvokeNative(0x925A160133003AC6, MyHorse, true) -- SetPausePedWritheBleedout
    Wait(5000)
    if not IsEntityDead(MyHorse) then
        InWrithe = true
        Citizen.InvokeNative(0xA3DB37EDF9A74635, PlayerId(), MyHorse, 35, 1, true) -- TARGET_INFO
        PromptDelete(HorseDrink)
        PromptDelete(HorseSleep)
        PromptDelete(HorseRest)
        PromptDelete(HorseWallow)
        PromptsStarted = false
    end
end)

AddEventHandler('bcc-stables:ReviveHorse', function()
    local hasItem = VORPcore.Callback.TriggerAwait('bcc-stables:HorseReviveItem')

    if not hasItem then
        VORPcore.NotifyRightTip(_U('noReviver'), 4000)
        return
    end

    if not IsEntityDead(MyHorse) then
        Citizen.InvokeNative(0x356088527D9EBAAD, PlayerPedId(), MyHorse, joaat('s_inv_horsereviver01x')) -- TaskReviveTarget
        InWrithe = false
    end
end)

function OpenInventory(horsePedId, horseId, isLooting)
    local hasBags = Citizen.InvokeNative(0xFB4891BD7578CDC1, horsePedId, -2142954459) -- IsMetaPedUsingComponent

    if not isLooting and Config.useSaddlebags and not hasBags then
        VORPcore.NotifyRightTip(_U('noSaddlebags'), 4000)
        return
    end

    if hasBags then
        Citizen.InvokeNative(0xCD181A959CFDD7F4, PlayerPedId(), MyHorse, joaat('Interaction_LootSaddleBags'), 0, 1) -- TaskAnimalInteraction
    end

    TriggerServerEvent('bcc-stables:OpenInventory', horseId)
end

function FleeHorse()
    Citizen.InvokeNative(0x22B0D0E37CCB840D, MyHorse, PlayerPedId(), 150.0, 10000, 6, 3.0) -- TaskSmartFleePed
    SaveHorseStats(false)
    Wait(10000)
    DeleteEntity(MyHorse)
    MyHorse = nil
end

AddEventHandler('bcc-stables:HorseBonding', function()
    while not MaxBonding do
        Wait(5000)
        local playerPed = PlayerPedId()
        local lastLed = Citizen.InvokeNative(0x693126B5D0457D0D, playerPed)   -- GetLastLedMount
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
        end,
        ['drink'] = function()
            horseXp = Config.horseXpPerDrink
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

    if newXp <= maxXp then
        TriggerServerEvent('bcc-stables:UpdateHorseXp', newXp, MyHorseId)
    end
end

function HorseInfoMenu()
    local horseHealth = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    local horseStamina = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 1, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    local currentLevel = Citizen.InvokeNative(0x147149F2E909323C, MyHorse, 7, Citizen.ResultAsInteger()) -- GetAttributeBaseRank
    local currentXp = Citizen.InvokeNative(0x219DA04BAA9CB065, MyHorse, 7, Citizen.ResultAsInteger()) -- GetAttributePoints
    local level1 = Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 1) -- GetDefaultAttributePointsNeededForRank / Bonding Level
    local level2 = Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 2)
    local level3 = Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 3)
    local level4 = Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 4)

    local infoMenu = FeatherMenu:RegisterMenu('bcc-stables:HorseInfoMenu', {
        top = '3%',
        left = '3%',
        ['720width'] = '400px',
        ['1080width'] = '500px',
        ['2kwidth'] = '600px',
        ['4kwidth'] = '800px',
        style = {},
        contentslot = {
            style = {
                ['height'] = '325px',
                ['min-height'] = '325px'
            }
        },
        draggable = true,
        canclose = true
    })

    local homePage = infoMenu:RegisterPage('home:page')

    homePage:RegisterElement('header', {
        value = HorseName,
        slot = 'header',
        style = {
            ['color'] = '#ddd'
        }
    })

    homePage:RegisterElement('subheader', {
        value = MyHorseBreed,
        slot = 'header',
        style = {
            ['color'] = '#ddd'
        }
    })

    homePage:RegisterElement('textdisplay', {
        value = _U('horseInfoCoat') .. MyHorseColor,
        slot = 'header',
        style = {
            ['color'] = '#C0C0C0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '16px'
        }
    })

    homePage:RegisterElement('textdisplay', {
        value = _U('horseInfoHealth') .. horseHealth .. ' | ' .. _U('horseInfoStamina') .. horseStamina,
        slot = 'header',
        style = {
            ['color'] = '#C0C0C0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '16px'
        }
    })
    homePage:RegisterElement('textdisplay', {
        value = _U('horseInfoLevel') .. currentLevel .. ' | ' .. _U('horseInfoCurXp') .. currentXp,
        slot = 'header',
        style = {
            ['color'] = '#C0C0C0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '16px'
        }
    })

    homePage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    homePage:RegisterElement('subheader', {
        value = _U('horseInfoBondLevels'),
        slot = 'content',
        style = {
            ['color'] = '#ddd'
        }
    })

    homePage:RegisterElement('textdisplay', {
        value = _U('horseInfoLvl_1') .. level1 .. _U('horseInfoXp'),
        slot = 'content',
        style = {
            ['color'] = '#C0C0C0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '16px'
        }
    })

    homePage:RegisterElement('textdisplay', {
        value = _U('horseInfoLvl_2') .. level2 .. _U('horseInfoXp') .. '\n' .. _U('horseInfoTrickLvl_2'),
        slot = 'content',
        style = {
            ['color'] = '#C0C0C0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '16px'
        }
    })

    homePage:RegisterElement('textdisplay', {
        value = _U('horseInfoLvl_3') .. level3 .. _U('horseInfoXp') .. '\n' .. _U('horseInfoTrickLvl_3'),
        slot = 'content',
        style = {
            ['color'] = '#C0C0C0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '16px'
        }
    })

    homePage:RegisterElement('textdisplay', {
        value = _U('horseInfoLvl_4') .. level4 .. _U('horseInfoXp') .. '\n' .. _U('horseInfoTrickLvl_4a') .. '\n' .. _U('horseInfoTrickLvl_4b'),
        slot = 'content',
        style = {
            ['color'] = '#C0C0C0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '16px'
        }
    })

    homePage:RegisterElement('line', {
        slot = 'footer',
        style = {

        }
    })

    infoMenu:Open({
        startupPage = homePage
    })
end

RegisterNetEvent('bcc-stables:BrushHorse', function()
    local playerPed = PlayerPedId()
    local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyHorse))
    if dist > 3.5 then
        VORPcore.NotifyRightTip(_U('tooFar'), 4000)
        return
    end
    ClearPedTasksImmediately(playerPed)
    Citizen.InvokeNative(0xCD181A959CFDD7F4, playerPed, MyHorse, joaat('Interaction_Brush'), joaat('p_brushHorse02x'), 1) -- TaskAnimalInteraction
    Wait(5000)
    Citizen.InvokeNative(0x6585D955A68452A5, MyHorse) -- ClearPedEnvDirt
    Citizen.InvokeNative(0x523C79AEEFCC4A2A, MyHorse, 10, 'ALL') -- ClearPedDamageDecalByZone
    Citizen.InvokeNative(0x8FE22675A5A45817, MyHorse) -- ClearPedBloodDamage
    local health = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    local stamina = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 1, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    if health < 100 or stamina < 100 then
        local healthBoost = Config.boost.brushHealth
        local staminaBoost = Config.boost.brushStamina
        if healthBoost > 0 then
            local newHealth = health + healthBoost
            if newHealth > 100 then
                newHealth = 100
            end
            Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 0, newHealth) -- SetAttributeCoreValue
        end
        if staminaBoost > 0 then
            local newStamina = stamina + staminaBoost
            if newStamina > 100 then
                newStamina = 100
            end
            Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 1, newStamina) -- SetAttributeCoreValue
        end
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
    end
end)

RegisterNetEvent('bcc-stables:FeedHorse', function(item)
    local playerPed = PlayerPedId()
    local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyHorse))
    if dist > 3.5 then
        VORPcore.NotifyRightTip(_U('tooFar'), 4000)
        return
    end
    ClearPedTasksImmediately(playerPed)
    Citizen.InvokeNative(0xCD181A959CFDD7F4, playerPed, MyHorse, joaat('Interaction_Food'), joaat('s_horsnack_haycube01x'), 1) -- TaskAnimalInteraction
    TriggerServerEvent('bcc-stables:RemoveItem', item)
    Wait(5000)
    local health = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    local stamina = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 1, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    if health < 100 or stamina < 100 then
        local healthBoost = Config.boost.feedHealth
        local staminaBoost = Config.boost.feedStamina
        if healthBoost > 0 then
            local newHealth = health + healthBoost
            if newHealth > 100 then
                newHealth = 100
            end
            Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 0, newHealth) -- SetAttributeCoreValue
        end
        if staminaBoost > 0 then
            local newStamina = stamina + staminaBoost
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
    end
end)

RegisterNetEvent('bcc-stables:UseLantern', function()
    local playerPed = PlayerPedId()

    if #(GetEntityCoords(playerPed) - GetEntityCoords(MyHorse)) <= 3.5 then
        ClearPedTasksImmediately(playerPed)
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

AddEventHandler('bcc-stables:TradeHorse', function()
    while MyHorse do
        local playerPed = PlayerPedId()
        local sleep = 1000
        local lastLed = Citizen.InvokeNative(0x693126B5D0457D0D, playerPed) -- GetLastLedMount

        if not IsEntityDead(playerPed) and lastLed == MyHorse and Citizen.InvokeNative(0xEFC4303DDC6E60D3, playerPed) then  -- IsPedLeadingHorse
            local closestPlayer, closestDistance = GetClosestPlayer()
            if closestPlayer and closestDistance <= 2.0 then
                sleep = 0
                PromptSetActiveGroupThisFrame(TradeGroup, CreateVarString(10, 'LITERAL_STRING', HorseName), 1, 0, 0, 0)
                if Citizen.InvokeNative(0xE0F65F0640EF0617, TradeHorse) then  -- PromptHasHoldModeCompleted
                    local serverId = GetPlayerServerId(closestPlayer)
                    TriggerServerEvent('bcc-stables:SaveHorseTrade', serverId, MyHorseId)
                    FleeHorse()
                end
            end
        end
        Wait(sleep)
    end
end)

function GetClosestPlayer()
    local players = GetActivePlayers()
    local player = PlayerId()
    local coords = GetEntityCoords(PlayerPedId())
    local closestDistance = nil
    local closestPlayer = nil
    for i = 1, #players, 1 do
        local target = GetPlayerPed(players[i])
        if players[i] ~= player then
            local distance = #(coords - GetEntityCoords(target))
            if closestDistance == nil or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

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

RegisterNUICallback('Holsters', function(data, cb)
    cb('ok')
    if tonumber(data.id) == -1 then
        HolstersUsing = 0
        local playerHorse = MyEntity
        Citizen.InvokeNative(0x0D7FFA1B2F69ED82, playerHorse, 0xF772CED6, 0, false) -- RemoveShopItemFromPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local hash = data.hash
        SetModel(hash)
        HolstersUsing = hash
    end
end)

function SetModel(hash)
    local model = joaat(tonumber(hash))
    if not HasModelLoaded(model) then
        Citizen.InvokeNative(0xFA28FE3A6246FC30, model) -- RequestModel
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, MyEntity, tonumber(hash), true, true, true) -- ApplyShopItemToPed
end

RegisterNUICallback('sellHorse', function(data, cb)
    cb('ok')
    DeleteEntity(MyEntity)
    Cam = false

    local horseSold = VORPcore.Callback.TriggerAwait('bcc-stables:SellMyHorse', data)
    if horseSold then
        StableMenu()
    end
end)

function ReturnHorse()
    local playerPed = PlayerPedId()

    if not MyHorse then
        VORPcore.NotifyRightTip(_U('noHorse'), 4000)
        return
    end

    if Citizen.InvokeNative(0x460BC76A0E10655E, playerPed) then -- IsPedOnMount
        Citizen.InvokeNative(0x48E92D3DDE23C23A, playerPed, 0, 0, 0, 0, MyHorse) -- TaskDismountAnimal
        while not Citizen.InvokeNative(0x01FEE67DB37F59B2, playerPed) do -- IsPedOnFoot
            Wait(10)
        end
    end

    SaveHorseStats(false)
    DeleteEntity(MyHorse)
    MyHorse = nil
    VORPcore.NotifyRightTip(_U('horseReturned'), 4000)
end

function SaveHorseStats(dead)
    local data = {}
    local healthCore, staminaCore

    if not dead then
        healthCore = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0, Citizen.ResultAsInteger())  -- GetAttributeCoreValue
        staminaCore = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 1, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    else
        healthCore = 20
        staminaCore = 20
    end

    data = {
        health = healthCore,
        stamina = staminaCore,
    }
    TriggerServerEvent('bcc-stables:SaveHorseStats', data, MyHorseId)
end

function SetHorseStats(data)
    Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 0, data.health)  -- SetAttributeCoreValue
    Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 1, data.stamina) -- SetAttributeCoreValue
end

-- View Horses While in Menu
function CreateCamera()
    local siteCfg = Stables[Site]
    local horseCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(horseCam, siteCfg.horse.camera.x, siteCfg.horse.camera.y, siteCfg.horse.camera.z + 1.2)
    SetCamActive(horseCam, true)
    PointCamAtCoord(horseCam, siteCfg.horse.coords.x - 0.5, siteCfg.horse.coords.y, siteCfg.horse.coords.z)
    DoScreenFadeOut(500)
    Wait(500)
    DoScreenFadeIn(500)
    RenderScriptCams(true, false, 0, 0, 0)
    Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Leaderboard_Show', 'MP_Leaderboard_Sounds', true, 0) -- PlaySoundFrontend
end

function CameraLighting()
    CreateThread(function()
        local siteCfg = Stables[Site]
        while Cam do
            Wait(0)
            Citizen.InvokeNative(0xD2D9E04C0DF927F4, siteCfg.horse.coords.x, siteCfg.horse.coords.y, siteCfg.horse.coords.z + 3, 130, 130, 85, 4.0, 15.0) -- DrawLightWithRange
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
    local entity = nil

    if MyEntity then
        entity = MyEntity
    elseif ShopEntity then
        entity = ShopEntity
    end

    SetEntityHeading(entity, (GetEntityHeading(entity) + dir) % 360)
end

RegisterCommand(Config.commands.horseRespawn, function(source, args, rawCommand)
    Spawning = false
    WhistleSpawn()
end)

RegisterCommand(Config.commands.horseSetWild, function(source, args, rawCommand)
    if Config.devMode then
        local mount = Citizen.InvokeNative(0xE7E11B8DCBED1058, PlayerPedId()) -- GetMount
        Citizen.InvokeNative(0xAEB97D84CDF3C00B, mount, true) -- SetAnimalIsWild
        Citizen.InvokeNative(0xBCC76708E5677E1D, mount, true) -- ClearActiveAnimalOwner
        Citizen.InvokeNative(0x9FF1E042FA597187, mount, 97, false) -- SetAnimalTuningBoolParam
    else
        print('Command used in Developer Mode Only!') -- Not for use on live server
    end
end)

RegisterCommand(Config.commands.horseWrithe, function(source, args, rawCommand)
    if Config.devMode then
        Citizen.InvokeNative(0x8C038A39C4A4B6D6, MyHorse, 0, 0) -- TaskAnimalWrithe
    else
        print('Command used in Developer Mode Only!') -- Not for use on live server
    end
end)

RegisterCommand(Config.commands.horseInfo, function(source, args, rawCommand)
    if not MyHorse then
        VORPcore.NotifyRightTip(_U('noHorse'), 4000)
        return
    end

    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(MyHorse)) <= 3.0 then
        HorseInfoMenu()
    else
        VORPcore.NotifyRightTip(_U('tooFar'), 4000)
    end
end)

function StartPrompts()
    OpenShops = PromptRegisterBegin()
    PromptSetControlAction(OpenShops, Config.keys.shop)
    PromptSetText(OpenShops, CreateVarString(10, 'LITERAL_STRING', _U('shopPrompt')))
    PromptSetVisible(OpenShops, true)
    PromptSetStandardMode(OpenShops)
    PromptSetGroup(OpenShops, ShopGroup, 0)
    PromptRegisterEnd(OpenShops)

    OpenCall = PromptRegisterBegin()
    PromptSetControlAction(OpenCall, Config.keys.call)
    PromptSetText(OpenCall, CreateVarString(10, 'LITERAL_STRING', _U('callPrompt')))
    PromptSetVisible(OpenCall, true)
    PromptSetStandardMode(OpenCall)
    PromptSetGroup(OpenCall, ShopGroup, 1)
    PromptRegisterEnd(OpenCall)

    OpenReturn = PromptRegisterBegin()
    PromptSetControlAction(OpenReturn, Config.keys.ret)
    PromptSetText(OpenReturn, CreateVarString(10, 'LITERAL_STRING', _U('returnPrompt')))
    PromptSetVisible(OpenReturn, true)
    PromptSetStandardMode(OpenReturn)
    PromptSetGroup(OpenReturn, ShopGroup, 1)
    PromptRegisterEnd(OpenReturn)

    SellTame = PromptRegisterBegin()
    PromptSetControlAction(SellTame, Config.keys.sell)
    PromptSetText(SellTame, CreateVarString(10, 'LITERAL_STRING', _U('sellPrompt')))
    PromptSetHoldMode(SellTame, 2000)
    PromptSetGroup(SellTame, TameGroup, 0)
    PromptRegisterEnd(SellTame)

    KeepTame = PromptRegisterBegin()
    PromptSetControlAction(KeepTame, Config.keys.keep)
    PromptSetText(KeepTame, CreateVarString(10, 'LITERAL_STRING', _U('keepPrompt') .. tostring(Config.regCost)))
    PromptSetHoldMode(KeepTame, 2000)
    PromptSetGroup(KeepTame, TameGroup, 0)
    PromptRegisterEnd(KeepTame)

    TradeHorse = PromptRegisterBegin()
    PromptSetControlAction(TradeHorse, Config.keys.trade)
    PromptSetText(TradeHorse, CreateVarString(10, 'LITERAL_STRING', _U('tradePrompt')))
    PromptSetVisible(TradeHorse, true)
    PromptSetEnabled(TradeHorse, true)
    PromptSetHoldMode(TradeHorse, 2000)
    PromptSetGroup(TradeHorse, TradeGroup, 0)
    PromptRegisterEnd(TradeHorse)

    LootHorse = PromptRegisterBegin()
    PromptSetControlAction(LootHorse, Config.keys.loot)
    PromptSetText(LootHorse, CreateVarString(10, 'LITERAL_STRING', _U('lootHorsePrompt')))
    PromptSetVisible(LootHorse, true)
    PromptSetEnabled(LootHorse, true)
    PromptSetStandardMode(LootHorse)
    PromptSetGroup(LootHorse, LootGroup, 0)
    PromptRegisterEnd(LootHorse)
end

function HorseTargetPrompts(menuGroup)
    local currentLevel = Citizen.InvokeNative(0x147149F2E909323C, MyHorse, 7, Citizen.ResultAsInteger()) -- GetAttributeBaseRank

    if not PromptsStarted then
        HorseDrink = PromptRegisterBegin()
        PromptSetControlAction(HorseDrink, Config.keys.drink)
        PromptSetText(HorseDrink, CreateVarString(10, 'LITERAL_STRING', _U('drinkPrompt')))
        PromptSetVisible(HorseDrink, true)
        PromptSetStandardMode(HorseDrink, true)
        PromptSetGroup(HorseDrink, menuGroup, 0)
        PromptRegisterEnd(HorseDrink)

        HorseRest = PromptRegisterBegin()
        PromptSetControlAction(HorseRest, Config.keys.rest)
        PromptSetText(HorseRest, CreateVarString(10, 'LITERAL_STRING', _U('restPrompt')))
        PromptSetVisible(HorseRest, true)
        PromptSetStandardMode(HorseRest, true)
        PromptSetGroup(HorseRest, menuGroup, 0)
        PromptRegisterEnd(HorseRest)

        HorseSleep = PromptRegisterBegin()
        PromptSetControlAction(HorseSleep, Config.keys.sleep)
        PromptSetText(HorseSleep, CreateVarString(10, 'LITERAL_STRING', _U('sleepPrompt')))
        PromptSetVisible(HorseSleep, true)
        PromptSetStandardMode(HorseSleep, true)
        PromptSetGroup(HorseSleep, menuGroup, 0)
        PromptRegisterEnd(HorseSleep)

        HorseWallow = PromptRegisterBegin()
        PromptSetControlAction(HorseWallow, Config.keys.wallow)
        PromptSetText(HorseWallow, CreateVarString(10, 'LITERAL_STRING', _U('wallowPrompt')))
        PromptSetVisible(HorseWallow, true)
        PromptSetStandardMode(HorseWallow, true)
        PromptSetGroup(HorseWallow, menuGroup, 0)
        PromptRegisterEnd(HorseWallow)

        PromptsStarted = true
    end

    if currentLevel >= 1 then
        PromptSetEnabled(HorseDrink, true)
    else
        PromptSetEnabled(HorseDrink, false)
    end
    if currentLevel >= 2 then
        PromptSetEnabled(HorseRest, true)
    else
        PromptSetEnabled(HorseRest, false)
    end
    if currentLevel >= 3 then
        PromptSetEnabled(HorseSleep, true)
    else
        PromptSetEnabled(HorseSleep, false)
    end
    if currentLevel >= 4 then
        PromptSetEnabled(HorseWallow, true)
    else
        PromptSetEnabled(HorseWallow, false)
    end
end

function CheckPlayerJob(trainer, site)
    local result = VORPcore.Callback.TriggerAwait('bcc-stables:CheckJob', trainer, site)
    if trainer and result then
        IsTrainer = false
        if result[1] then
            IsTrainer = true
        end
    elseif result then
        HasJob = false
        if result[1] then
            HasJob = true
        elseif Stables[site].shop.jobsEnabled then
            VORPcore.NotifyRightTip(_U('needJob'), 4000)
        end
        JobMatchedHorses = FindHorsesByJob(result[2])
    end
end

function AddTrainerBlip(site)
    local siteCfg = Trainers[site]
    siteCfg.TrainerBlip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, siteCfg.npc.coords) -- BlipAddForCoords
    SetBlipSprite(siteCfg.TrainerBlip, siteCfg.blip.sprite, true)
    Citizen.InvokeNative(0x9CB1A1623062F402, siteCfg.TrainerBlip,  siteCfg.blip.name) -- SetBlipName
end

function ManageStableBlip(site, closed)
    local siteCfg = Stables[site]

    if closed and not siteCfg.blip.showClosed then
        if Stables[site].Blip then
            RemoveBlip(Stables[site].Blip)
            Stables[site].Blip = nil
        end
        return
    end

    if not Stables[site].Blip then
        siteCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, siteCfg.npc.coords) -- BlipAddForCoords
        SetBlipSprite(siteCfg.Blip, siteCfg.blip.sprite, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, siteCfg.Blip, siteCfg.blip.name) -- SetBlipNameFromPlayerString
    end

    local color = siteCfg.blip.color.open
    if siteCfg.shop.jobsEnabled then color = siteCfg.blip.color.job end
    if closed then color = siteCfg.blip.color.closed end
    Citizen.InvokeNative(0x662D364ABF16DE2F, Stables[site].Blip, joaat(Config.BlipColors[color])) -- BlipAddModifier
end

function AddTrainerNPC(site)
    local siteCfg = Trainers[site]
    local model = joaat(siteCfg.npc.model)
    LoadModel(model)
    siteCfg.TrainerNPC = CreatePed(model, siteCfg.npc.coords.x, siteCfg.npc.coords.y, siteCfg.npc.coords.z - 1.0, siteCfg.npc.heading, false, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, siteCfg.TrainerNPC, true) -- SetRandomOutfitVariation
    SetEntityCanBeDamaged(siteCfg.TrainerNPC, false)
    SetEntityInvincible(siteCfg.TrainerNPC, true)
    Wait(500)
    FreezeEntityPosition(siteCfg.TrainerNPC, true)
    SetBlockingOfNonTemporaryEvents(siteCfg.TrainerNPC, true)
end

function AddStableNPC(site)
    local siteCfg = Stables[site]
    if not siteCfg.NPC then
        local modelName = siteCfg.npc.model
        local model = joaat(modelName)
        LoadModel(model, modelName)
        siteCfg.NPC = CreatePed(model, siteCfg.npc.coords.x, siteCfg.npc.coords.y, siteCfg.npc.coords.z - 1.0, siteCfg.npc.heading, false, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, siteCfg.NPC, true) -- SetRandomOutfitVariation
        TaskStartScenarioInPlace(siteCfg.NPC, joaat('WORLD_HUMAN_WRITE_NOTEBOOK'), -1, true, false, false, false)
        SetEntityCanBeDamaged(siteCfg.NPC, false)
        SetEntityInvincible(siteCfg.NPC, true)
        Wait(500)
        FreezeEntityPosition(siteCfg.NPC, true)
        SetBlockingOfNonTemporaryEvents(siteCfg.NPC, true)
    end
end

function RemoveStableNPC(site)
    local siteCfg = Stables[site]
    if siteCfg.NPC then
        DeleteEntity(siteCfg.NPC)
        siteCfg.NPC = nil
    end
end

function LoadModel(model, modelName)
    if not IsModelValid(model) then
        return print('Invalid model:', modelName)
    end
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

-- to count length of maps
local function len(t)
    local counter = 0
    for _, _ in pairs(t) do
        counter += 1
    end
    return counter
end

--let's go fancy with an implementation that orders pairs for you using default table.sort(). Taken from a lua-users post.

local function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1, #(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

local function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

 function FindHorsesByJob(job)
    local matchingHorses = {}
    for _, horseType in ipairs(Horses) do
        local matchingColors = {}

        
        for horseColor, horseColorData in orderedPairs(horseType.colors) do
            -- using maps to break a loop, though technically making another loop, albeit simpler. Preferably you already configure jobs as a map so that you could expand
            -- perhaps when a request comes to have color accesses by job grade or similar
            local horseJobs = {}
            for _, horseJob in pairs(horseColorData.job) do
                horseJobs[horseJob] = horseJob
            end
            -- add matching color directly 
                if horseJobs[job] ~= nil then
                        matchingColors[horseColor] = {
                            color = horseColorData.color,
                            cashPrice = horseColorData.cashPrice,
                            goldPrice = horseColorData.goldPrice,
                            invLimit = horseColorData.invLimit,
                            job = horseColorData.job
                        }
                end
                --handle case where there isn\t a job attached to horse color config
                if len(horseJobs) == 0 then
                    matchingColors[horseColor] = {
                        color = horseColorData.color,
                        cashPrice = horseColorData.cashPrice,
                        goldPrice = horseColorData.goldPrice,
                        invLimit = horseColorData.invLimit,
                        job = nil
                    }
                end
        end

        if len(matchingColors) > 0 then
            matchingHorses[#matchingHorses + 1] = {
                breed = horseType.breed,
                colors = matchingColors
            }
        end
    end
    return matchingHorses
end

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
        SaveHorseStats(false)
        DeleteEntity(MyHorse)
        MyHorse = nil
    end
    for _, siteCfg in pairs(Stables) do
        if siteCfg.Blip then
            RemoveBlip(siteCfg.Blip)
            siteCfg.Blip = nil
        end
        if siteCfg.NPC then
            DeleteEntity(siteCfg.NPC)
            siteCfg.NPC = nil
        end
    end
    for _, siteCfg in pairs(Trainers) do
        if siteCfg.TrainerBlip then
            RemoveBlip(siteCfg.TrainerBlip)
            siteCfg.TrainerBlip = nil
        end
        if siteCfg.TrainerNPC then
            DeleteEntity(siteCfg.TrainerNPC)
            siteCfg.TrainerNPC = nil
        end
    end
    CleanupAnimalInfoHud()
end)