local VORPcore = {}
local OpenShops
local CloseShops
local OpenReturn
local OpenGroup = GetRandomIntInRange(0, 0xffffff)
local ClosedGroup = GetRandomIntInRange(0, 0xffffff)
local PlayerJob
local JobName
local JobGrade
local InMenu = false
local StableName
local BrushCooldown = false
local FeedCooldown = false
local Adding = true
local ShowroomHorse_entity
local SpawnPoint = {}
local MyHorse_entity
local IdMyHorse
local Saddlecloths = {}
local Acshorn = {}
local Bags = {}
local Horsetails = {}
local Manes = {}
local Saddles = {}
local Stirrups = {}
local Acsluggage = {}
local MyHorse = 0
local HorseModel
local HorseName
local HorseComponents = {}
local Initializing = false
local SaddlesUsing = nil
local SaddleclothsUsing = nil
local StirrupsUsing = nil
local BagsUsing = nil
local ManesUsing = nil
local HorseTailsUsing = nil
local AcsHornUsing = nil
local AcsLuggageUsing = nil

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- Start Stables
Citizen.CreateThread(function()
    ShopOpen()
    ShopClosed()
    ReturnOpen()

    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local sleep = true
        local dead = IsEntityDead(player)
        local hour = GetClockHours()

        if InMenu == false and not dead then
            for shopId, shopConfig in pairs(Config.stables) do
                if shopConfig.shopHours then
                    if hour >= shopConfig.shopClose or hour < shopConfig.shopOpen then
                        if Config.blipAllowedClosed then
                            if not Config.stables[shopId].BlipHandle and shopConfig.blipAllowed then
                                AddBlip(shopId)
                            end
                        else
                            if Config.stables[shopId].BlipHandle then
                                RemoveBlip(Config.stables[shopId].BlipHandle)
                                Config.stables[shopId].BlipHandle = nil
                            end
                        end
                        if Config.stables[shopId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle, GetHashKey(shopConfig.blipColorClosed)) -- BlipAddModifier
                        end
                        if shopConfig.NPC then
                            DeleteEntity(shopConfig.NPC)
                            DeletePed(shopConfig.NPC)
                            SetEntityAsNoLongerNeeded(shopConfig.NPC)
                            shopConfig.NPC = nil
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                        local distanceShop = #(coordsDist - coordsShop)

                        if (distanceShop <= shopConfig.distanceShop) then
                            sleep = false
                            local shopClosed = CreateVarString(10, 'LITERAL_STRING', shopConfig.shopName .. _U("closed"))
                            PromptSetActiveGroupThisFrame(ClosedGroup, shopClosed)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, CloseShops) then -- UiPromptHasStandardModeCompleted

                                Wait(100)
                                VORPcore.NotifyRightTip(shopConfig.shopName .. _U("hours") .. shopConfig.shopOpen .. _U("to") .. shopConfig.shopClose .. _U("hundred"), 4000)
                            end
                        end
                    elseif hour >= shopConfig.shopOpen then
                        if not Config.stables[shopId].BlipHandle and shopConfig.blipAllowed then
                            AddBlip(shopId)
                        end
                        if not shopConfig.NPC and shopConfig.npcAllowed then
                            SpawnNPC(shopId)
                        end
                        if not next(shopConfig.allowedJobs) then
                            if Config.stables[shopId].BlipHandle then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle, GetHashKey(shopConfig.blipColorOpen)) -- BlipAddModifier
                            end
                            local coordsDist = vector3(coords.x, coords.y, coords.z)
                            local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                            local distanceShop = #(coordsDist - coordsShop)

                            if (distanceShop <= shopConfig.distanceShop) then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                                PromptSetActiveGroupThisFrame(OpenGroup, shopOpen)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                    DisplayRadar(false)
                                    OpenStable(shopId)

                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                    returnHorse(shopId)
                                end
                            end
                        else
                            if Config.stables[shopId].BlipHandle then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle, GetHashKey(shopConfig.blipColorJob)) -- BlipAddModifier
                            end
                            local coordsDist = vector3(coords.x, coords.y, coords.z)
                            local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                            local distanceShop = #(coordsDist - coordsShop)

                            if (distanceShop <= shopConfig.distanceShop) then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                                PromptSetActiveGroupThisFrame(OpenGroup, shopOpen)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted

                                    TriggerServerEvent("oss_stables:GetPlayerJob")
                                    Wait(200)
                                    if PlayerJob then
                                        if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                            if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                                DisplayRadar(false)
                                                OpenStable(shopId)
                                            else
                                                VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                            end
                                        else
                                            VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                    end
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted

                                    TriggerServerEvent("oss_stables:GetPlayerJob")
                                    Wait(200)
                                    if PlayerJob then
                                        if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                            if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                                returnHorse(shopId)
                                            else
                                                VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                            end
                                        else
                                            VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                    end
                                end
                            end
                        end
                    end
                else
                    if not Config.stables[shopId].BlipHandle and shopConfig.blipAllowed then
                        AddBlip(shopId)
                    end
                    if not shopConfig.NPC and shopConfig.npcAllowed then
                        SpawnNPC(shopId)
                    end
                    if not next(shopConfig.allowedJobs) then
                        if Config.stables[shopId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle, GetHashKey(shopConfig.blipColorOpen)) -- BlipAddModifier
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                        local distanceShop = #(coordsDist - coordsShop)

                        if (distanceShop <= shopConfig.distanceShop) then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                            PromptSetActiveGroupThisFrame(OpenGroup, shopOpen)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                DisplayRadar(false)
                                OpenStable(shopId)

                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                returnHorse(shopId)
                            end
                        end
                    else
                        if Config.stables[shopId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle, GetHashKey(shopConfig.blipColorJob)) -- BlipAddModifier
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                        local distanceShop = #(coordsDist - coordsShop)

                        if (distanceShop <= shopConfig.distanceShop) then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                            PromptSetActiveGroupThisFrame(OpenGroup, shopOpen)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted

                                TriggerServerEvent("oss_stables:GetPlayerJob")
                                Wait(200)
                                if PlayerJob then
                                    if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                        if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                            DisplayRadar(false)
                                            OpenStable(shopId)
                                        else
                                            VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                end
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted

                                TriggerServerEvent("oss_stables:GetPlayerJob")
                                Wait(200)
                                if PlayerJob then
                                    if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                        if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                            returnHorse(shopId)
                                        else
                                            VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                end
                            end
                        end
                    end
                end
            end
        end
        if sleep then
            Citizen.Wait(1000)
        end
    end
end)

function OpenStable(shopId)
    InMenu = true

    local shopConfig = Config.stables[shopId]
    StableName = shopConfig.shopName
    SpawnPoint = {x = shopConfig.spawnPointx, y = shopConfig.spawnPointy, z = shopConfig.spawnPointz, h = shopConfig.spawnPointh}

    createCamera(shopId)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "show",
        shopData = getShopData(),
        customize = false,
        location = StableName
    })
    TriggerServerEvent('oss_stables:GetMyHorses')
end

function getShopData()
    local ret = Config.Horses
    return ret
end

RegisterNetEvent('oss_stables:ReceiveHorsesData')
AddEventHandler('oss_stables:ReceiveHorsesData', function(dataHorses)
    SendNUIMessage({
        myHorsesData = dataHorses
    })
end)

RegisterNUICallback("loadHorse", function(data)
    local horseModel = data.horseModel

    if MyHorse_entity ~= nil then
        DeleteEntity(MyHorse_entity)
        MyHorse_entity = nil
    end

    local modelHash = GetHashKey(horseModel)
    if IsModelValid(modelHash) then
        if not HasModelLoaded(modelHash) then
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Citizen.Wait(10)
            end
        end
    end

    if ShowroomHorse_entity ~= nil then
        DeleteEntity(ShowroomHorse_entity)
        ShowroomHorse_entity = nil
    end

    ShowroomHorse_entity = CreatePed(modelHash, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z - 0.98, SpawnPoint.h, false, 0)
    Citizen.InvokeNative(0x283978A15512B2FE, ShowroomHorse_entity, true) -- SetRandomOutfitVariation
    Citizen.InvokeNative(0x58A850EAEE20FAA3, ShowroomHorse_entity) -- PlaceObjectOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, ShowroomHorse_entity, true) -- FreezeEntityPosition
    SetPedConfigFlag(ShowroomHorse_entity, 113, true) -- DisableShockingEvents
    Wait(300)
    Citizen.InvokeNative(0x6585D955A68452A5, ShowroomHorse_entity) -- ClearPedEnvDirt

    SendNUIMessage({
        customize = false
    })
end)

RegisterNUICallback("rotate", function(data)
    local direction = data.RotateHorse

    if direction == "left" then
        Rotation(20)
    elseif direction == "right" then
        Rotation(-20)
    end
end)

function Rotation(dir)
    local ownedHorse = MyHorse_entity
    local shopHorse = ShowroomHorse_entity

    if ownedHorse then
        local ownedRot = GetEntityHeading(ownedHorse) + dir
        SetEntityHeading(ownedHorse, ownedRot % 360)

    elseif shopHorse then
        local shopRot = GetEntityHeading(shopHorse) + dir
        SetEntityHeading(shopHorse, shopRot % 360)
    end
end

RegisterNUICallback("BuyHorse", function(data)
    TriggerServerEvent('oss_stables:BuyHorse', data)
end)

RegisterNetEvent('oss_stables:SetHorseName')
AddEventHandler('oss_stables:SetHorseName', function(data)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "hide"
    })

    Wait(200)
    local horseName = ""
	Citizen.CreateThread(function()
		AddTextEntry('FMMC_MPM_NA', "Name your horse:")
		DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
		while (UpdateOnscreenKeyboard() == 0) do
			DisableAllControlActions(0)
			Citizen.Wait(0)
		end
		if (GetOnscreenKeyboardResult()) then
            horseName = GetOnscreenKeyboardResult()
            TriggerServerEvent('oss_stables:SaveNewHorse', data, horseName)

            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "show",
                shopData = getShopData(),
                location = StableName
            })

        Wait(1000)
        TriggerServerEvent('oss_stables:GetMyHorses')
		end
    end)
end)

RegisterNetEvent('oss_stables:StableMenu')
AddEventHandler('oss_stables:StableMenu', function()
    if ShowroomHorse_entity ~= nil then
        DeleteEntity(ShowroomHorse_entity)
        ShowroomHorse_entity = nil
    end

    SendNUIMessage({
        action = "show",
        shopData = getShopData(),
        location = StableName
    })

    TriggerServerEvent('oss_stables:GetMyHorses')
end)

RegisterNUICallback("loadMyHorse", function(data)
    local horseModel = data.HorseModel
    IdMyHorse = data.IdHorse

    if ShowroomHorse_entity ~= nil then
        DeleteEntity(ShowroomHorse_entity)
        ShowroomHorse_entity = nil
    end

    if MyHorse_entity ~= nil then
        DeleteEntity(MyHorse_entity)
        MyHorse_entity = nil
    end

    local modelHash = GetHashKey(horseModel)

    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(10)
        end
    end

    MyHorse_entity = CreatePed(modelHash, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z - 0.98, SpawnPoint.h, false, 0)
    Citizen.InvokeNative(0x283978A15512B2FE, MyHorse_entity, true) -- SetRandomOutfitVariation
    Citizen.InvokeNative(0x58A850EAEE20FAA3, MyHorse_entity) -- PlaceObjectOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, MyHorse_entity, true) -- FreezeEntityPosition
    SetPedConfigFlag(MyHorse_entity, 113, true) -- PCF_DisableShockingEvents
    Wait(300)
    Citizen.InvokeNative(0x6585D955A68452A5, MyHorse_entity) -- ClearPedEnvDirt
    --NetworkSetEntityInvisibleToNetwork(MyHorse_entity, true)

    SendNUIMessage({
        customize = true
    })

    local componentsHorse = json.decode(data.HorseComp)
    if componentsHorse ~= '[]' then
        for _, Key in pairs(componentsHorse) do
            local model2 = GetHashKey(tonumber(Key))
            if not HasModelLoaded(model2) then
                Citizen.InvokeNative(0xFA28FE3A6246FC30, model2) -- RequestModel
            end
            Citizen.InvokeNative(0xD3A7B003ED343FD9, MyHorse_entity, tonumber(Key), true, true, true) -- ApplyShopItemToPed
        end
    end
end)

RegisterNUICallback("selectHorse", function(data)
    TriggerServerEvent('oss_stables:SelectHorse', tonumber(data.horseID))
end)

RegisterNetEvent('oss_stables:SetHorseInfo')
AddEventHandler('oss_stables:SetHorseInfo', function(horse_model, horse_name, horse_components)
    HorseModel = horse_model
    HorseName = horse_name
    HorseComponents = horse_components
end)

RegisterNUICallback("CloseStable", function(data)
    local player = PlayerPedId()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "hide",
        customize = false
    })

    SetEntityVisible(player, true)

    if ShowroomHorse_entity ~= nil then
        DeleteEntity(ShowroomHorse_entity)
    end

    if MyHorse_entity ~= nil then
        DeleteEntity(MyHorse_entity)
    end

    DestroyAllCams(true)
    ShowroomHorse_entity = nil
    DisplayRadar(true)
    InMenu = false

    local menuAction = data.MenuAction
    if menuAction == "save" then
        StableClose()
    else
        return
    end
end)

function StableClose()
    local compData = {
        SaddlesUsing,
        SaddleclothsUsing,
        StirrupsUsing,
        BagsUsing,
        ManesUsing,
        HorseTailsUsing,
        AcsHornUsing,
        AcsLuggageUsing
    }
    local compDataEncoded = json.encode(compData)
    if compDataEncoded ~= "[]" then
        TriggerServerEvent('oss_stables:UpdateComponents', compData, IdMyHorse, MyHorse_entity)
    end
end

RegisterNetEvent('oss_stables:SetComponents')
AddEventHandler('oss_stables:SetComponents', function(horseEntity, components)
    for _, value in pairs(components) do
        NativeSetPedComponentEnabled(horseEntity, value)
    end
end)

function NativeSetPedComponentEnabled(ped, component)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, component, true, true, true) -- ApplyShopItemToPed
end

function InitiateHorse(atCoords)
    if Initializing then
        return
    end

    Initializing = true

    if MyHorse ~= 0 then
        DeleteEntity(MyHorse)
        MyHorse = 0
    end

    local player = PlayerPedId()
    local pCoords = GetEntityCoords(player)
    local modelHash = GetHashKey(HorseModel)
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(10)
        end
    end

    local spawnPosition
    if atCoords == nil then
        local x, y, z = table.unpack(pCoords)
        local nodePosition = GetClosestVehicleNode(x, y, z, 1, 3.0, 0.0)
        local index = 0
        while index <= 25 do
            local _bool, _nodePosition = GetNthClosestVehicleNode(x, y, z, index, 1, 3.0, 2.5)
            if _bool == true or _bool == 1 then
                nodePosition = _nodePosition
                index = index + 3
            else
                break
            end
        end
        spawnPosition = nodePosition
    else
        spawnPosition = atCoords
    end

    if spawnPosition == nil then
        Initializing = false
        return
    end

    MyHorse = CreatePed(modelHash, spawnPosition, GetEntityHeading(player), true, true)
    SetModelAsNoLongerNeeded(modelHash)

    Citizen.InvokeNative(0x9587913B9E772D29, MyHorse, 0) -- PlaceEntityOnGroundProperly
    Citizen.InvokeNative(0x4DB9D03AC4E1FA84, MyHorse, -1, -1, 0) -- SetPedWrithingDuration
    Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, MyHorse) -- BlipAddForEntity
    Citizen.InvokeNative(0xB8B6430EAD2D2437, MyHorse, GetHashKey("PLAYER_HORSE"))
    Citizen.InvokeNative(0xFD6943B6DF77E449, MyHorse, false) -- SetPedCanBeLassoed
    Citizen.InvokeNative(0xC80A74AC829DDD92, MyHorse, GetPedRelationshipGroupHash(MyHorse)) -- SetPedRelationshipGroupHash
    Citizen.InvokeNative(0xBF25EB89375A37AD, 1, GetPedRelationshipGroupHash(MyHorse), "PLAYER") -- SetRelationshipBetweenGroups
    Citizen.InvokeNative(0x931B241409216C1F, player, MyHorse, 1) -- SetPedOwnsAnimal
    Citizen.InvokeNative(0xD2CB0FB0FDCB473D, player, MyHorse) -- SetPedAsSaddleHorseForPlayer

    SetPedConfigFlag(MyHorse, 324, true)
    SetPedConfigFlag(MyHorse, 211, true) -- GiveAmbientDefaultTaskIfMissionPed
    SetPedConfigFlag(MyHorse, 208, true)
    SetPedConfigFlag(MyHorse, 209, true)
    SetPedConfigFlag(MyHorse, 400, true)
    SetPedConfigFlag(MyHorse, 297, true) -- EnableHorseLeading
    SetPedConfigFlag(MyHorse, 136, false) -- DisableHorseMount
    SetPedConfigFlag(MyHorse, 312, false) -- DisableHorseGunshotFleeResponse
    SetPedConfigFlag(MyHorse, 113, false) -- DisableShockingEvents
    SetPedConfigFlag(MyHorse, 301, false) -- DisablePedCanBeTargeted
    SetPedConfigFlag(MyHorse, 277, true)
    SetPedConfigFlag(MyHorse, 319, true) -- EnableAsVehicleTransitionDestination
    SetPedConfigFlag(MyHorse, 6, true) -- DontInfluenceWantedLevel

    SetAnimalTuningBoolParam(MyHorse, 25, false)
    SetAnimalTuningBoolParam(MyHorse, 24, false)

    TaskAnimalUnalerted(MyHorse, -1, false, 0, 0)
    Citizen.InvokeNative(0x283978A15512B2FE, MyHorse, true) -- SetRandomOutfitVariation

    SetPedPromptName(MyHorse, HorseName)

    if HorseComponents ~= nil and HorseComponents ~= "0" then
        for _, componentHash in pairs(json.decode(HorseComponents)) do
            NativeSetPedComponentEnabled(MyHorse, tonumber(componentHash))
        end
    end

    TaskGoToEntity(MyHorse, player, -1, 7.2, 2.0, 0, 0)
    Initializing = false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        -- Whistle for Horse (key: H)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x24978A28) then -- IsDisabledControlJustPressed
			local player = PlayerPedId()
            if MyHorse ~= 0 then
                if GetScriptTaskStatus(MyHorse, 0x4924437D, 0) ~= 0 then
                    local pcoords = GetEntityCoords(player)
                    local hcoords = GetEntityCoords(MyHorse)
                    local caldist = #(pcoords - hcoords)
                    if caldist >= 100 then
                        DeleteEntity(MyHorse)
                        Wait(1000)
                        MyHorse = 0
                    else
                        TaskGoToEntity(MyHorse, player, -1, 4, 2.0, 0, 0)
                    end
                end
            else
                TriggerServerEvent('oss_stables:GetSelectedHorse')
                Wait(100)
                InitiateHorse()
            end
        end
        -- Horse Flee (key: F in Horse Menu)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x4216AF06) then -- IsDisabledControlJustPressed
			if MyHorse ~= 0 then
                local player = PlayerPedId()
                TaskAnimalFlee(MyHorse, player, -1)
                Wait(10000)
                DeleteEntity(MyHorse)
                Wait(1000)
                MyHorse = 0
			end
		end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        -- Brush Horse (Key: B in Horse Menu)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x63A38F2C) then -- IsDisabledControlJustPressed
            if not BrushCooldown then
                TriggerServerEvent('oss_stables:GetPlayerItem', 'brush')
            else
                VORPcore.NotifyRightTip(_U("notDirty"), 5000)
			end
        end
        -- Feed Horse (Key: R in Horse Menu)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x0D55A0F0) then -- IsDisabledControlJustPressed
            if not FeedCooldown then
                TriggerServerEvent('oss_stables:GetPlayerItem', 'haycube')
            else
                VORPcore.NotifyRightTip(_U("notHungry"), 5000)
            end
        end
    end
end)

RegisterNetEvent('oss_stables:BrushHorse')
AddEventHandler('oss_stables:BrushHorse', function(data)
    local horsebrush = data.name
    if horsebrush == "horsebrush" then
        Citizen.InvokeNative(0xCD181A959CFDD7F4, PlayerPedId(), MyHorse, GetHashKey("Interaction_Brush"), GetHashKey("p_brushHorse02x"), 1) -- TaskAnimalInteraction
        local health = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0) -- GetAttributeCoreValue
        Wait(4000)
        Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 0, health + Config.brushHealthBoost) -- SetAttributeCoreValue
        Citizen.InvokeNative(0x6585D955A68452A5, MyHorse) -- ClearPedEnvDirt
        Citizen.InvokeNative(0xB5485E4907B53019, MyHorse) -- SetPedWetnessEnabledThisFrame
        local bCooldown = math.ceil(Config.brushCooldown / 60000)
        VORPcore.NotifyRightTip(_U("brushCooldown") .. bCooldown .. _U("minutes"), 5000)
        BrushCooldown = true
        Wait(Config.brushCooldown)
        BrushCooldown = false
    end
end)

RegisterNetEvent('oss_stables:FeedHorse')
AddEventHandler('oss_stables:FeedHorse', function(data)
    local haycube = data.name
    if haycube == "consumable_haycube" then
        Citizen.InvokeNative(0xCD181A959CFDD7F4, PlayerPedId(), MyHorse, GetHashKey("Interaction_Food"), 0, 1) -- TaskAnimalInteraction
        local health = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0) -- GetAttributeCoreValue
        local stamina = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 1) -- GetAttributeCoreValue
        Wait(3000)
        Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 0, health + Config.feedHealthBoost) -- SetAttributeCoreValue
        Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 1, stamina + Config.feedStaminaBoost) -- SetAttributeCoreValue
        local fCooldown = math.ceil(Config.feedCooldown / 60000)
        VORPcore.NotifyRightTip(_U("feedCooldown") .. fCooldown .. _U("minutes"), 5000)
        FeedCooldown = true
        Wait(Config.feedCooldown)
        FeedCooldown = false
    end
end)

RegisterNUICallback("Saddles", function(data)
    if tonumber(data.id) == 0 then
        num = 0
        SaddlesUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xBAA7E618, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Saddles[num])
        setcloth(hash)
        SaddlesUsing = ("0x" .. Saddles[num])
    end
end)

RegisterNUICallback("Saddlecloths", function(data)
    if tonumber(data.id) == 0 then
        num = 0
        SaddleclothsUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x17CEB41A, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Saddlecloths[num])
        setcloth(hash)
        SaddleclothsUsing = ("0x" .. Saddlecloths[num])
    end
end)

RegisterNUICallback("Stirrups", function(data)
    if tonumber(data.id) == 0 then
        num = 0
        StirrupsUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xDA6DADCA, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Stirrups[num])
        setcloth(hash)
        StirrupsUsing = ("0x" .. Stirrups[num])
    end
end)

RegisterNUICallback("Bags", function(data)
    if tonumber(data.id) == 0 then
        num = 0
        BagsUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x80451C25, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Bags[num])
        setcloth(hash)
        BagsUsing = ("0x" .. Bags[num])
    end
end)

RegisterNUICallback("Manes", function(data)
    if tonumber(data.id) == 0 then
        num = 0
        ManesUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xAA0217AB, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Manes[num])
        setcloth(hash)
        ManesUsing = ("0x" .. Manes[num])
    end
end)

RegisterNUICallback("HorseTails", function(data)
    if tonumber(data.id) == 0 then
        num = 0
        HorseTailsUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x17CEB41A, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Horsetails[num])
        setcloth(hash)
        HorseTailsUsing = ("0x" .. Horsetails[num])
    end
end)

RegisterNUICallback("AcsHorn", function(data)
    if tonumber(data.id) == 0 then
        num = 0
        AcsHornUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x5447332, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Acshorn[num])
        setcloth(hash)
        AcsHornUsing = ("0x" .. Acshorn[num])
    end
end)

RegisterNUICallback("AcsLuggage", function(data)
    if tonumber(data.id) == 0 then
        num = 0
        AcsLuggageUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xEFB31921, 0) -- RemoveTagFromMetaPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Acsluggage[num])
        setcloth(hash)
        AcsLuggageUsing = ("0x" .. Acsluggage[num])
    end
end)

function setcloth(hash)
    local model2 = GetHashKey(tonumber(hash))
    if not HasModelLoaded(model2) then
        Citizen.InvokeNative(0xFA28FE3A6246FC30, model2) -- RequestModel
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, MyHorse_entity, tonumber(hash), true, true, true) -- ApplyShopItemToPed
end

RegisterNUICallback("sellHorse", function(data)
    DeleteEntity(MyHorse_entity)
    TriggerServerEvent('oss_stables:SellHorse', tonumber(data.horseID))
    TriggerServerEvent('oss_stables:GetMyHorses')
    Wait(300)

    SendNUIMessage({
        action = "show",
        shopData = getShopData(),
        location = StableName
    })
    TriggerServerEvent('oss_stables:GetMyHorses')
end)

function returnHorse(shopId)
    if MyHorse == 0 then
        VORPcore.NotifyRightTip(_U("noHorse"), 5000)

    elseif MyHorse ~=0 then
        DeleteEntity(MyHorse)
        MyHorse = 0
        VORPcore.NotifyRightTip(_U("horseReturned"), 5000)
    end
end

Citizen.CreateThread(function()
	while Adding do
		Wait(0)
		for _, v in ipairs(HorseComp) do
			if v.category == "Saddlecloths" then
				Saddlecloths[#Saddlecloths+1] = v.Hash
			elseif v.category == "AcsHorn" then
				Acshorn[#Acshorn+1] = v.Hash
			elseif v.category == "Bags" then
				Bags[#Bags+1] = v.Hash
			elseif v.category == "HorseTails" then
				Horsetails[#Horsetails+1] = v.Hash
			elseif v.category == "Manes" then
				Manes[#Manes+1] = v.Hash
			elseif v.category == "Saddles" then
				Saddles[#Saddles+1] = v.Hash
			elseif v.category == "Stirrups" then
				Stirrups[#Stirrups+1] = v.Hash
			elseif v.category == "AcsLuggage" then
				Acsluggage[#Acsluggage+1] = v.Hash
			end
		end
		Adding = false
	end
end)

function createCamera(shopId)
    local shopConfig = Config.stables[shopId]
    local horseCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(horseCam, shopConfig.horseCamx, shopConfig.horseCamy, shopConfig.horseCamz + 1.2 )
    SetCamActive(horseCam, true)
    PointCamAtCoord(horseCam, SpawnPoint.x - 0.5, SpawnPoint.y, SpawnPoint.z)
    DoScreenFadeOut(500)
    Wait(500)
    DoScreenFadeIn(500)
    RenderScriptCams(true, false, 0, 0, 0)
end

-- Menu Prompts
function ShopOpen()
    local str = _U("shopPrompt")
    OpenShops = PromptRegisterBegin()
    PromptSetControlAction(OpenShops, Config.shopKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(OpenShops, str)
    PromptSetEnabled(OpenShops, 1)
    PromptSetVisible(OpenShops, 1)
    PromptSetStandardMode(OpenShops, 1)
    PromptSetGroup(OpenShops, OpenGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, OpenShops, true) -- UiPromptSetUrgentPulsingEnabled
    PromptRegisterEnd(OpenShops)
end

function ShopClosed()
    local str = _U("shopPrompt")
    CloseShops = PromptRegisterBegin()
    PromptSetControlAction(CloseShops, Config.shopKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(CloseShops, str)
    PromptSetEnabled(CloseShops, 1)
    PromptSetVisible(CloseShops, 1)
    PromptSetStandardMode(CloseShops, 1)
    PromptSetGroup(CloseShops, ClosedGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, CloseShops, true) -- UiPromptSetUrgentPulsingEnabled
    PromptRegisterEnd(CloseShops)
end

function ReturnOpen()
    local str = _U("returnPrompt")
    OpenReturn = PromptRegisterBegin()
    PromptSetControlAction(OpenReturn, Config.returnKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(OpenReturn, str)
    PromptSetEnabled(OpenReturn, 1)
    PromptSetVisible(OpenReturn, 1)
    PromptSetStandardMode(OpenReturn, 1)
    PromptSetGroup(OpenReturn, OpenGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, OpenReturn, true) -- UiPromptSetUrgentPulsingEnabled
    PromptRegisterEnd(OpenReturn)
end

-- Blips
function AddBlip(shopId)
    local shopConfig = Config.stables[shopId]
    shopConfig.BlipHandle = N_0x554d9d53f696d002(1664425300, shopConfig.npcx, shopConfig.npcy, shopConfig.npcz) -- BlipAddForCoords
    SetBlipSprite(shopConfig.BlipHandle, shopConfig.blipSprite, 1)
    SetBlipScale(shopConfig.BlipHandle, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, shopConfig.BlipHandle, shopConfig.blipName) -- SetBlipName
end

function LoadModel(npcModel)
    local model = GetHashKey(npcModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(100)
    end
end

function SpawnNPC(shopId)
    local shopConfig = Config.stables[shopId]
    LoadModel(shopConfig.npcModel)
    local npc = CreatePed(shopConfig.npcModel, shopConfig.npcx, shopConfig.npcy, shopConfig.npcz -1, shopConfig.npch, false, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    Wait(500)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    Config.stables[shopId].NPC = npc
end

function CheckJob(allowedJob, playerJob)
    for _, jobAllowed in pairs(allowedJob) do
        JobName = jobAllowed
        if JobName == playerJob then
            return true
        end
    end
    return false
end

RegisterNetEvent("oss_stables:SendPlayerJob")
AddEventHandler("oss_stables:SendPlayerJob", function(Job, grade)
    PlayerJob = Job
    JobGrade = grade
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if InMenu == true then
        SetNuiFocus(false, false)
        SendNUIMessage({
                action = "hide"
            })
    end

    ClearPedTasksImmediately(PlayerPedId())
        PromptDelete(OpenShops)
        PromptDelete(CloseShops)
        PromptDelete(OpenReturn)

    if MyHorse then
        DeleteEntity(MyHorse)
        MyHorse = 0
    end

    for _, shopConfig in pairs(Config.stables) do
        if shopConfig.BlipHandle then
            RemoveBlip(shopConfig.BlipHandle)
        end
        if shopConfig.NPC then
            DeleteEntity(shopConfig.NPC)
            DeletePed(shopConfig.NPC)
            SetEntityAsNoLongerNeeded(shopConfig.NPC)
        end
    end
end)
