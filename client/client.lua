local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

local OpenShops
local CloseShops
local ShopPrompt1 = GetRandomIntInRange(0, 0xffffff)
local ShopPrompt2 = GetRandomIntInRange(0, 0xffffff)
local PlayerJob
local JobName
local JobGrade

local Cam = nil
Zoom = 4.0
Offset = 0.2
local fixedCam
local InterP = true
local Adding = true
local ShowroomHorse_entity
local ShowroomHorse_model
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
local SpawnPoint = {}
local StablePoint = {}
local HeadingPoint
local CamPos = {}
local SpawnplayerHorse = 0
local HorseModel
local horseName
local horseComponents = {}
local initializing = false
local alreadySentShopData = false
local SaddlesUsing = nil
local SaddleclothsUsing = nil
local StirrupsUsing = nil
local BagsUsing = nil
local ManesUsing = nil
local HorseTailsUsing = nil
local AcsHornUsing = nil
local AcsLuggageUsing = nil

cameraUsing = {
    {
        name = "Horse",
        x = 0.2,
        y = 0.0,
        z = 1.8
    },
    {
        name = "Olhos",
        x = 0.0,
        y = -0.4,
        z = 0.65
    }
}
-- Start Stables
Citizen.CreateThread(function()
    ShopOpen()
    ShopClosed()

    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local sleep = true
        local dead = IsEntityDead(player)
        local hour = GetClockHours()

        if not dead then
            for shopId, shopConfig in pairs(Config.stables) do
                if shopConfig.shopHours then
                    if hour >= shopConfig.shopClose or hour < shopConfig.shopOpen then
                        if not Config.stables[shopId].BlipHandle and shopConfig.blipAllowed then
                            AddBlip(shopId)
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
                            local shopClosed = CreateVarString(10, 'LITERAL_STRING', _U("closed") .. shopConfig.shopOpen .. _U("am") .. shopConfig.shopClose .. _U("pm"))
                            PromptSetActiveGroupThisFrame(ShopPrompt2, shopClosed)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, CloseShops) then -- UiPromptHasStandardModeCompleted

                                Wait(100)
                                VORPcore.NotifyRightTip(_U("closed") .. shopConfig.shopOpen .. _U("am") .. shopConfig.shopClose .. _U("pm"), 3000)
                            end
                        end
                    elseif hour >= shopConfig.shopOpen then
                        if not Config.stables[shopId].BlipHandle and shopConfig.blipAllowed then
                            AddBlip(shopId)
                        end
                        if Config.stables[shopId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle, GetHashKey(shopConfig.blipColorOpen)) -- BlipAddModifier
                        end
                        if not shopConfig.NPC and shopConfig.npcAllowed then
                            SpawnNPC(shopId)
                        end
                        if not next(shopConfig.allowedJobs) then
                            local coordsDist = vector3(coords.x, coords.y, coords.z)
                            local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                            local distanceShop = #(coordsDist - coordsShop)

                            if (distanceShop <= shopConfig.distanceShop) then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                                PromptSetActiveGroupThisFrame(ShopPrompt1, shopOpen)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                    HeadingPoint = shopConfig.Heading
                                    StablePoint = {shopConfig.npcx, shopConfig.npcy, shopConfig.npcz}
                                    CamPos = {shopConfig.SpawnPoint.CamPos.x, shopConfig.SpawnPoint.CamPos.y}
                                    SpawnPoint = {x = shopConfig.SpawnPoint.Pos.x, y = shopConfig.SpawnPoint.Pos.y, z = shopConfig.SpawnPoint.Pos.z, h = shopConfig.SpawnPoint.Heading}
                                    Wait(300)

                                    OpenStable()
                                end
                            end
                        else
                            local coordsDist = vector3(coords.x, coords.y, coords.z)
                            local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                            local distanceShop = #(coordsDist - coordsShop)

                            if (distanceShop <= shopConfig.distanceShop) then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                                PromptSetActiveGroupThisFrame(ShopPrompt1, shopOpen)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted

                                    TriggerServerEvent("oss_stables:getPlayerJob")
                                    Wait(200)
                                    if PlayerJob then
                                        if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                            if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                                HeadingPoint = shopConfig.Heading
                                                StablePoint = {shopConfig.npcx, shopConfig.npcy, shopConfig.npcz}
                                                CamPos = {shopConfig.SpawnPoint.CamPos.x, shopConfig.SpawnPoint.CamPos.y}
                                                SpawnPoint = {x = shopConfig.SpawnPoint.Pos.x, y = shopConfig.SpawnPoint.Pos.y, z = shopConfig.SpawnPoint.Pos.z, h = shopConfig.SpawnPoint.Heading}
                                                Wait(300)

                                                OpenStable()
                                            else
                                                VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
                                            end
                                        else
                                            VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
                                    end
                                end
                            end
                        end
                    end
                else
                    if not Config.stables[shopId].BlipHandle and shopConfig.blipAllowed then
                        AddBlip(shopId)
                    end
                    if Config.stables[shopId].BlipHandle then
                        Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle, GetHashKey(shopConfig.blipColorOpen)) -- BlipAddModifier
                    end
                    if not shopConfig.NPC and shopConfig.npcAllowed then
                        SpawnNPC(shopId)
                    end
                    if not next(shopConfig.allowedJobs) then
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                        local distanceShop = #(coordsDist - coordsShop)

                        if (distanceShop <= shopConfig.distanceShop) then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                            PromptSetActiveGroupThisFrame(ShopPrompt1, shopOpen)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                HeadingPoint = shopConfig.Heading
                                StablePoint = {shopConfig.npcx, shopConfig.npcy, shopConfig.npcz}
                                CamPos = {shopConfig.SpawnPoint.CamPos.x, shopConfig.SpawnPoint.CamPos.y}
                                SpawnPoint = {x = shopConfig.SpawnPoint.Pos.x, y = shopConfig.SpawnPoint.Pos.y, z = shopConfig.SpawnPoint.Pos.z, h = shopConfig.SpawnPoint.Heading}
                                Wait(300)

                                OpenStable()
                            end
                        end
                    else
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                        local distanceShop = #(coordsDist - coordsShop)

                        if (distanceShop <= shopConfig.distanceShop) then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                            PromptSetActiveGroupThisFrame(ShopPrompt1, shopOpen)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted

                                TriggerServerEvent("oss_stables:getPlayerJob")
                                Wait(200)
                                if PlayerJob then
                                    if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                        if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                            HeadingPoint = shopConfig.Heading
                                            StablePoint = {shopConfig.npcx, shopConfig.npcy, shopConfig.npcz}
                                            CamPos = {shopConfig.SpawnPoint.CamPos.x, shopConfig.SpawnPoint.CamPos.y}
                                            SpawnPoint = {x = shopConfig.SpawnPoint.Pos.x, y = shopConfig.SpawnPoint.Pos.y, z = shopConfig.SpawnPoint.Pos.z, h = shopConfig.SpawnPoint.Heading}
                                            Wait(300)

                                            OpenStable()
                                        else
                                            VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
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

function OpenStable()
    local playerHorse = MyHorse_entity
    local player = PlayerPedId()

    SetEntityHeading(playerHorse, 334)
    SetNuiFocus(true, true)
    InterP = true

    createCamera(player)

    if not alreadySentShopData then
        SendNUIMessage(
            {
                action = "show",
                shopData = getShopData()
            }
        )
    else
        SendNUIMessage(
            {
                action = "show"
            }
        )
    end
    TriggerServerEvent('oss_stables:AskForMyHorses')
end

function createCamera(entity)
    local groundCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
    SetCamCoord(groundCam, StablePoint[1] + 0.5, StablePoint[2] - 3.6, StablePoint[3] )
    SetCamRot(groundCam, -20.0, 0.0, HeadingPoint + 20)
    SetCamActive(groundCam, true)
    RenderScriptCams(true, false, 1, true, true)
    --Wait(3000)
    -- last camera, create interpolate
    fixedCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
    SetCamCoord(fixedCam, StablePoint[1] + 0.5, StablePoint[2] - 3.6, StablePoint[3] +1.8)
    SetCamRot(fixedCam, -20.0, 0, HeadingPoint + 50.0)
    SetCamActive(fixedCam, true)
    SetCamActiveWithInterp(fixedCam, groundCam, 3900, true, true)
    Wait(3900)
    DestroyCam(groundCam)
end

function createCam(creatorType)
    for k, v in pairs(cams) do
        if cams[k].type == creatorType then
            Cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cams[k].x, cams[k].y, cams[k].z, cams[k].rx, cams[k].ry, cams[k].rz, cams[k].fov, false, 0) -- CAMERA COORDS
            SetCamActive(Cam, true)
            RenderScriptCams(true, false, 3000, true, false)
            createPeds()
        end
    end
end

local function interpCamera(cameraName, entity)
    for k, v in pairs(cameraUsing) do
        if cameraUsing[k].name == cameraName then
            tempCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
            AttachCamToEntity(tempCam, entity, cameraUsing[k].x + CamPos[1], cameraUsing[k].y + CamPos[2], cameraUsing[k].z)
            SetCamActive(tempCam, true)
            SetCamRot(tempCam, -30.0, 0, HeadingPoint + 50.0)
            if InterP then
                SetCamActiveWithInterp(tempCam, fixedCam, 1200, true, true)
                InterP = false
            end
        end
    end
end

function getShopData()
    alreadySentShopData = true
    local ret = Config.Horses
    return ret
end

local function rotation(dir)
    local playerHorse = MyHorse_entity
    local pedRot = GetEntityHeading(playerHorse) + dir
    SetEntityHeading(playerHorse, pedRot % 360)
end

local function NativeSetPedComponentEnabled(ped, component)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, component, true, true, true)
end

local function setcloth(hash)
    local model2 = GetHashKey(tonumber(hash))
    if not HasModelLoaded(model2) then
        Citizen.InvokeNative(0xFA28FE3A6246FC30, model2)
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, MyHorse_entity, tonumber(hash), true, true, true)
end

local function SetHorseName(data)
    SetNuiFocus(false, false)
    SendNUIMessage(
        {
            action = "hide"
        }
    )
    Wait(200)
    local HorseName = ""

	Citizen.CreateThread(function()
		AddTextEntry('FMMC_MPM_NA', "Name your horse:")
		DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
		while (UpdateOnscreenKeyboard() == 0) do
			DisableAllControlActions(0)
			Citizen.Wait(0)
		end
		if (GetOnscreenKeyboardResult()) then
            HorseName = GetOnscreenKeyboardResult()
            TriggerServerEvent('oss_stables:BuyHorse', data, HorseName)

            SetNuiFocus(true, true)
            SendNUIMessage(
            {
                action = "show",
                shopData = getShopData()
            }
        )

        Wait(1000)
        TriggerServerEvent('oss_stables:AskForMyHorses')
		end
    end)
end

local function CloseStable()
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
        TriggerServerEvent('oss_stables:UpdateHorseComponents', compData, IdMyHorse, MyHorse_entity)
    end
end

local function InitiateHorse(atCoords)
    if initializing then
        return
    end

    initializing = true

    if SpawnplayerHorse ~= 0 then
        DeleteEntity(SpawnplayerHorse)
        SpawnplayerHorse = 0
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
        local bool, nodePosition = GetClosestVehicleNode(x, y, z, 1, 3.0, 0.0)
        local index = 0
        while index <= 25 do
            local _bool, _nodePosition = GetNthClosestVehicleNode(x, y, z, index, 1, 3.0, 2.5)
            if _bool == true or _bool == 1 then
                bool = _bool
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
        initializing = false
        return
    end

    local entity = CreatePed(modelHash, spawnPosition, GetEntityHeading(player), true, true)
    SetModelAsNoLongerNeeded(modelHash)

    Citizen.InvokeNative(0x9587913B9E772D29, entity, 0)
    Citizen.InvokeNative(0x4DB9D03AC4E1FA84, entity, -1, -1, 0)
    Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, entity)
    Citizen.InvokeNative(0xBCC76708E5677E1D9, entity, 0)
    Citizen.InvokeNative(0xB8B6430EAD2D2437, entity, GetHashKey("PLAYER_HORSE"))
    Citizen.InvokeNative(0xFD6943B6DF77E449, entity, false)

    SetPedConfigFlag(entity, 324, true)
    SetPedConfigFlag(entity, 211, true)
    SetPedConfigFlag(entity, 208, true)
    SetPedConfigFlag(entity, 209, true)
    SetPedConfigFlag(entity, 400, true)
    SetPedConfigFlag(entity, 297, true)
    SetPedConfigFlag(entity, 136, false)
    SetPedConfigFlag(entity, 312, false)
    SetPedConfigFlag(entity, 113, false)
    SetPedConfigFlag(entity, 301, false)
    SetPedConfigFlag(entity, 277, true)
    SetPedConfigFlag(entity, 319, true)
    SetPedConfigFlag(entity, 6, true)

    SetAnimalTuningBoolParam(entity, 25, false)
    SetAnimalTuningBoolParam(entity, 24, false)

    TaskAnimalUnalerted(entity, -1, false, 0, 0)
    Citizen.InvokeNative(0x283978A15512B2FE, entity, true)

    SpawnplayerHorse = entity

    Citizen.InvokeNative(0x283978A15512B2FE, entity, true)
    -- SetVehicleHasBeenOwnedByPlayer(playerHorse, true)
    SetPedNameDebug(entity, horseName)
    SetPedPromptName(entity, horseName)
    --CreatePrompts(PromptGetGroupIdForTargetEntity(entity))
    if horseComponents ~= nil and horseComponents ~= "0" then
        for _, componentHash in pairs(json.decode(horseComponents)) do
            NativeSetPedComponentEnabled(entity, tonumber(componentHash))
        end
    end

    if HorseModel == "A_C_Horse_MP_Mangy_Backup" then
        NativeSetPedComponentEnabled(entity, 0x106961A8) --sela
        NativeSetPedComponentEnabled(entity, 0x508B80B9) --blanket
    end

    TaskGoToEntity(entity, player, -1, 7.2, 2.0, 0, 0)
    SetPedConfigFlag(entity, 297, true) -- Enable_Horse_Leadin
    initializing = false
end

local function WhistleHorse()
    local player = PlayerPedId()
    if SpawnplayerHorse ~= 0 then
        if GetScriptTaskStatus(SpawnplayerHorse, 0x4924437D, 0) ~= 0 then
            local pcoords = GetEntityCoords(player)
            local hcoords = GetEntityCoords(SpawnplayerHorse)
            local caldist = #(pcoords - hcoords)
            if caldist >= 100 then
                DeleteEntity(SpawnplayerHorse)
                Wait(1000)
                SpawnplayerHorse = 0
            else
                TaskGoToEntity(SpawnplayerHorse, player, -1, 4, 2.0, 0, 0)
            end
        end
    else
        TriggerServerEvent('oss_stables:GetSelectedHorse')
        Wait(100)
        InitiateHorse()
    end
end

local function fleeHorse(playerHorse)
    local player = PlayerPedId()
    TaskAnimalFlee(SpawnplayerHorse, player, -1)
    Wait(5000)
    DeleteEntity(SpawnplayerHorse)
    Wait(1000)
    SpawnplayerHorse = 0
end

RegisterNUICallback("rotate", function(data, cb)
    if (data["key"] == "left") then
        rotation(20)
    else
        rotation(-20)
    end
    cb("ok")
end)

RegisterNUICallback("Saddles", function(data)
    Zoom = 4.0
    Offset = 0.2
    if tonumber(data.id) == 0 then
        num = 0
        SaddlesUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xBAA7E618, 0) -- HAT REMOVE
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Saddles[num])
        setcloth(hash)
        SaddlesUsing = ("0x" .. Saddles[num])
    end
end)

RegisterNUICallback("Saddlecloths", function(data)
    Zoom = 4.0
    Offset = 0.2
    if tonumber(data.id) == 0 then
        num = 0
        SaddleclothsUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x17CEB41A, 0) -- HAT REMOVE
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Saddlecloths[num])
        setcloth(hash)
        SaddleclothsUsing = ("0x" .. Saddlecloths[num])
    end
end)

RegisterNUICallback("Stirrups", function(data)
    Zoom = 4.0
    Offset = 0.2
    if tonumber(data.id) == 0 then
        num = 0
        StirrupsUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xDA6DADCA, 0) -- HAT REMOVE
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Stirrups[num])
        setcloth(hash)
        StirrupsUsing = ("0x" .. Stirrups[num])
    end
end)

RegisterNUICallback("Bags", function(data)
    Zoom = 4.0
    Offset = 0.2
    if tonumber(data.id) == 0 then
        num = 0
        BagsUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x80451C25, 0) -- HAT REMOVE
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Bags[num])
        setcloth(hash)
        BagsUsing = ("0x" .. Bags[num])
    end
end)

RegisterNUICallback("Manes", function(data)
    Zoom = 4.0
    Offset = 0.2
    if tonumber(data.id) == 0 then
        num = 0
        ManesUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xAA0217AB, 0) -- HAT REMOVE
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Manes[num])
        setcloth(hash)
        ManesUsing = ("0x" .. Manes[num])
    end
end)

RegisterNUICallback("HorseTails", function(data)
    Zoom = 4.0
    Offset = 0.2
    if tonumber(data.id) == 0 then
        num = 0
        HorseTailsUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x17CEB41A, 0) -- HAT REMOVE
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Horsetails[num])
        setcloth(hash)
        HorseTailsUsing = ("0x" .. Horsetails[num])
    end
end)

RegisterNUICallback("AcsHorn", function(data)
    Zoom = 4.0
    Offset = 0.2
    if tonumber(data.id) == 0 then
        num = 0
        AcsHornUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x5447332, 0) -- HAT REMOVE
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Acshorn[num])
        setcloth(hash)
        AcsHornUsing = ("0x" .. Acshorn[num])
    end
end)

RegisterNUICallback("AcsLuggage", function(data)
    Zoom = 4.0
    Offset = 0.2
    if tonumber(data.id) == 0 then
        num = 0
        AcsLuggageUsing = num
        local playerHorse = MyHorse_entity
        Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xEFB31921, 0) -- HAT REMOVE
        Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
    else
        local num = tonumber(data.id)
        hash = ("0x" .. Acsluggage[num])
        setcloth(hash)
        AcsLuggageUsing = ("0x" .. Acsluggage[num])
    end
end)

RegisterNUICallback("selectHorse", function(data)
    TriggerServerEvent('oss_stables:SelectHorseWithId', tonumber(data.horseID))
end)

RegisterNUICallback("sellHorse", function(data)
    DeleteEntity(ShowroomHorse_entity)
    TriggerServerEvent('oss_stables:SellHorseWithId', tonumber(data.horseID))
    TriggerServerEvent('oss_stables:AskForMyHorses')
    alreadySentShopData = false
    Wait(300)

    SendNUIMessage(
        {
            action = "show",
            shopData = getShopData()
        }
    )
    TriggerServerEvent('oss_stables:AskForMyHorses')
end)

RegisterNUICallback("loadHorse", function(data)
    local horseModel = data.horseModel

    if ShowroomHorse_model == horseModel then
        return
    end

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

    ShowroomHorse_model = horseModel
    ShowroomHorse_entity = CreatePed(modelHash, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z - 0.98, SpawnPoint.h, false, 0)
    Citizen.InvokeNative(0x283978A15512B2FE, ShowroomHorse_entity, true) -- _SET_RANDOM_OUTFIT_VARIATION
    Citizen.InvokeNative(0x58A850EAEE20FAA3, ShowroomHorse_entity) -- PLACE_OBJECT_ON_GROUND_PROPERLY
    NetworkSetEntityInvisibleToNetwork(ShowroomHorse_entity, true)
    SetVehicleHasBeenOwnedByPlayer(ShowroomHorse_entity, true)
    -- SetModelAsNoLongerNeeded(modelHash)
    interpCamera("Horse", ShowroomHorse_entity)
end)

RegisterNUICallback("loadMyHorse", function(data)
    local horseModel = data.horseModel
    IdMyHorse = data.IdHorse

    if ShowroomHorse_model == horseModel then
        return
    end

    if ShowroomHorse_entity ~= nil then
        DeleteEntity(ShowroomHorse_entity)
        ShowroomHorse_entity = nil
    end

    if MyHorse_entity ~= nil then
        DeleteEntity(MyHorse_entity)
        MyHorse_entity = nil
    end

    ShowroomHorse_model = horseModel

    local modelHash = GetHashKey(ShowroomHorse_model)

    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(10)
        end
    end

    MyHorse_entity = CreatePed(modelHash, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z - 0.98, SpawnPoint.h, false, 0)
    Citizen.InvokeNative(0x283978A15512B2FE, MyHorse_entity, true)
    Citizen.InvokeNative(0x58A850EAEE20FAA3, MyHorse_entity)
    NetworkSetEntityInvisibleToNetwork(MyHorse_entity, true)
    SetVehicleHasBeenOwnedByPlayer(MyHorse_entity, true)
    local componentsHorse = json.decode(data.HorseComp)

    if componentsHorse ~= '[]' then
        for _, Key in pairs(componentsHorse) do
            local model2 = GetHashKey(tonumber(Key))
            if not HasModelLoaded(model2) then
                Citizen.InvokeNative(0xFA28FE3A6246FC30, model2)
            end
            Citizen.InvokeNative(0xD3A7B003ED343FD9, MyHorse_entity, tonumber(Key), true, true, true)
        end
    end
        -- SetModelAsNoLongerNeeded(modelHash)
    interpCamera("Horse", MyHorse_entity)
end)

RegisterNUICallback("BuyHorse", function(data)
    SetHorseName(data)
end)

RegisterNUICallback("CloseStable", function()
    local player = PlayerPedId()
    SetNuiFocus(false, false)
    SendNUIMessage(
        {
            action = "hide"
        }
    )
    SetEntityVisible(player, true)

    ShowroomHorse_model = nil

    if ShowroomHorse_entity ~= nil then
        DeleteEntity(ShowroomHorse_entity)
    end

    if MyHorse_entity ~= nil then
        DeleteEntity(MyHorse_entity)
    end

    DestroyAllCams(true)
    ShowroomHorse_entity = nil
    CloseStable()
end)

RegisterNetEvent('oss_stables:ReceiveHorsesData')
AddEventHandler('oss_stables:ReceiveHorsesData', function(dataHorses)
    SendNUIMessage(
        {
            myHorsesData = dataHorses
        }
    )
end)

RegisterNetEvent('oss_stables:UpdateHorseComponents')
AddEventHandler('oss_stables:UpdateHorseComponents', function(horseEntity, components)
    for _, value in pairs(components) do
        NativeSetPedComponentEnabled(horseEntity, value)
    end
end)

RegisterNetEvent('oss_stables:SetHorseInfo')
AddEventHandler('oss_stables:SetHorseInfo', function(horse_model, horse_name, horse_components)
    horseModel = horse_model
    horseName = horse_name
    horseComponents = horse_components
end)

--[[Citizen.CreateThread(function()
    while true do
        Wait(1)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        for _, prompt in pairs(prompts) do
            if PromptIsJustPressed(prompt) then
                for k, v in pairs(Config.Stables) do
                    if #(coords - vector3(v.Pos.x, v.Pos.y, v.Pos.z)) < 7 then
                        HeadingPoint = v.Heading
                        StablePoint = {v.Pos.x, v.Pos.y, v.Pos.z}
                        CamPos = {v.SpawnPoint.CamPos.x, v.SpawnPoint.CamPos.y}
                        SpawnPoint = {x = v.SpawnPoint.Pos.x, y = v.SpawnPoint.Pos.y, z = v.SpawnPoint.Pos.z, h = v.SpawnPoint.Heading}
                        Wait(300)
                    end
                end
                OpenStable()
            end
        end
    end
end)]]

--[[Citizen.CreateThread(function()
    for _, v in pairs(Config.Stables) do
        blip = N_0x554d9d53f696d002(1664425300, v.Pos.x, v.Pos.y, v.Pos.z)
        SetBlipSprite(blip, 4221798391, 1)
        SetBlipScale(blip, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Stable")
        local prompt = PromptRegisterBegin()
        PromptSetActiveGroupThisFrame(promptGroup, varStringCasa)
        PromptSetControlAction(prompt, 0x760A9C6F)
        PromptSetText(prompt, CreateVarString(10, "LITERAL_STRING", "Open Stable"))
        PromptSetStandardMode(prompt, true)
        PromptSetEnabled(prompt, 1)
        PromptSetVisible(prompt, 1)
        PromptSetHoldMode(prompt, 1)
        PromptSetPosition(prompt, v.Pos.x, v.Pos.y, v.Pos.z)
        N_0x0c718001b77ca468(prompt, 3.0)
        PromptSetGroup(prompt, promptGroup)
        PromptRegisterEnd(prompt)
        prompts[#prompts+1] = prompt
    end
end)]]

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(100)
        if MyHorse_entity ~= nil then
            SendNUIMessage(
                {
                    EnableCustom = "true"
                }
            )
        else
            SendNUIMessage(
                {
                    EnableCustom = "false"
                }
            )
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		local getHorseMood = Citizen.InvokeNative(0x42688E94E96FD9B4, SpawnplayerHorse, 3, 0, Citizen.ResultAsFloat())
		if getHorseMood >= 0.60 then
		    Citizen.InvokeNative(0x06D26A96CA1BCA75, SpawnplayerHorse, 3, PlayerPedId())
		    Citizen.InvokeNative(0xA1EB5D029E0191D3, SpawnplayerHorse, 3, 0.99)
		end
		Citizen.Wait(30000)
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x24978A28) then -- Control =  H
			WhistleHorse()
			Citizen.Wait(10000) --Flood Protection? i think yes zoot
        end
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x4216AF06) then -- Control = Horse Flee            
         --   local horseCheck = Citizen.InvokeNative(0x7912F7FC4F6264B6, PlayerPedId(), myHorse[4])            
			if SpawnplayerHorse ~= 0 then
				fleeHorse(SpawnplayerHorse)
			end
		end
    end
end)

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
    PromptSetGroup(OpenShops, ShopPrompt1)
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
    PromptSetGroup(CloseShops, ShopPrompt2)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, CloseShops, true) -- UiPromptSetUrgentPulsingEnabled
    PromptRegisterEnd(CloseShops)
end

-- Blips
function AddBlip(shopId)
    local shopConfig = Config.stables[shopId]
    if shopConfig.blipAllowed then
        shopConfig.BlipHandle = N_0x554d9d53f696d002(1664425300, shopConfig.npcx, shopConfig.npcy, shopConfig.npcz) -- BlipAddForCoords
        SetBlipSprite(shopConfig.BlipHandle, shopConfig.blipSprite, 1)
        SetBlipScale(shopConfig.BlipHandle, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, shopConfig.BlipHandle, shopConfig.blipName) -- SetBlipName
    end
end

-- NPCs
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
    if shopConfig.npcAllowed then
        local npc = CreatePed(shopConfig.npcModel, shopConfig.npcx, shopConfig.npcy, shopConfig.npcz, shopConfig.npch, false, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
        SetEntityCanBeDamaged(npc, false)
        SetEntityInvincible(npc, true)
        Wait(500)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        Config.stables[shopId].NPC = npc
    end
end

-- Check if Player has Job
function CheckJob(allowedJob, playerJob)
    for _, jobAllowed in pairs(allowedJob) do
        JobName = jobAllowed
        if JobName == playerJob then
            return true
        end
    end
    return false
end

RegisterNetEvent("oss_stables:sendPlayerJob")
AddEventHandler("oss_stables:sendPlayerJob", function(Job, grade)
    PlayerJob = Job
    JobGrade = grade
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    ClearPedTasksImmediately(PlayerPedId())
    PromptDelete(OpenShops)
    PromptDelete(CloseShops)

    if SpawnplayerHorse then
        DeleteEntity(SpawnplayerHorse)
        SpawnplayerHorse = 0
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
    SetNuiFocus(false, false)
    SendNUIMessage({action = "hide"})
end)
