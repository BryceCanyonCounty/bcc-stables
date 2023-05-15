local VORPcore = {}
-- Prompts
local OpenShops
local CloseShops
local OpenReturn
local OpenGroup = GetRandomIntInRange(0, 0xffffff)
local ClosedGroup = GetRandomIntInRange(0, 0xffffff)
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
-- Job Check
local PlayerJob
local JobName
local JobGrade
-- Misc.
local InMenu = false
local StableName
local BrushCooldown = false
local FeedCooldown = false
local ShopEntity
local MyEntity
local MyHorse = nil
local MyHorseId
local SpawnPoint = {}
local MyEntityID
local HorseModel
local HorseName
local HorseGender
local HorseComponents = {}
local Spawning = false
local Spawned = false

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- Start Stables
CreateThread(function()
    ShopOpen()
    ShopClosed()
    ReturnOpen()

    while true do
        Wait(0)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local sleep = true
        local dead = IsEntityDead(player)
        local hour = GetClockHours()

        if InMenu == false and not dead then
            for shopId, shopConfig in pairs(Config.stables) do
                if shopConfig.shopHours then
                    -- Using Stable Hours - Stable Closed
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
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle,
                                joaat(shopConfig.blipColorClosed)) -- BlipAddModifier
                        end
                        if shopConfig.NPC then
                            DeleteEntity(shopConfig.NPC)
                            DeletePed(shopConfig.NPC)
                            SetEntityAsNoLongerNeeded(shopConfig.NPC)
                            shopConfig.NPC = nil
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsShop = vector3(shopConfig.npc.x, shopConfig.npc.y, shopConfig.npc.z)
                        local distanceShop = #(coordsDist - coordsShop)

                        if (distanceShop <= shopConfig.distanceShop) then
                            sleep = false
                            local shopClosed = CreateVarString(10, 'LITERAL_STRING', shopConfig.shopName .. _U("closed"))
                            PromptSetActiveGroupThisFrame(ClosedGroup, shopClosed)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, CloseShops) then -- UiPromptHasStandardModeCompleted
                                Wait(100)
                                VORPcore.NotifyRightTip(
                                    shopConfig.shopName ..
                                    _U("hours") ..
                                    shopConfig.shopOpen .. _U("to") .. shopConfig.shopClose .. _U("hundred"),
                                    4000)
                            end
                        end
                    elseif hour >= shopConfig.shopOpen then
                        -- Using Stable Hours - Stable Open
                        if not Config.stables[shopId].BlipHandle and shopConfig.blipAllowed then
                            AddBlip(shopId)
                        end
                        if not shopConfig.NPC and shopConfig.npcAllowed then
                            SpawnNPC(shopId)
                        end
                        if not next(shopConfig.allowedJobs) then
                            if Config.stables[shopId].BlipHandle then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle,
                                    joaat(shopConfig.blipColorOpen)) -- BlipAddModifier
                            end
                            local coordsDist = vector3(coords.x, coords.y, coords.z)
                            local coordsShop = vector3(shopConfig.npc.x, shopConfig.npc.y, shopConfig.npc.z)
                            local distanceShop = #(coordsDist - coordsShop)

                            if (distanceShop <= shopConfig.distanceShop) then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                                PromptSetActiveGroupThisFrame(OpenGroup, shopOpen)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                    DisplayRadar(false)
                                    OpenStable(shopId)
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                    ReturnHorse(shopId)
                                end
                            end
                        else
                            -- Using Stable Hours - Stable Open - Job Locked
                            if Config.stables[shopId].BlipHandle then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle,
                                    joaat(shopConfig.blipColorJob)) -- BlipAddModifier
                            end
                            local coordsDist = vector3(coords.x, coords.y, coords.z)
                            local coordsShop = vector3(shopConfig.npc.x, shopConfig.npc.y, shopConfig.npc.z)
                            local distanceShop = #(coordsDist - coordsShop)

                            if (distanceShop <= shopConfig.distanceShop) then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                                PromptSetActiveGroupThisFrame(OpenGroup, shopOpen)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                    TriggerServerEvent("bcc-stables:GetPlayerJob")
                                    Wait(200)
                                    if PlayerJob then
                                        if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                            if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                                DisplayRadar(false)
                                                OpenStable(shopId)
                                            else
                                                VORPcore.NotifyRightTip(
                                                    _U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                            end
                                        else
                                            VORPcore.NotifyRightTip(
                                                _U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,
                                            5000)
                                    end
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                    TriggerServerEvent("bcc-stables:GetPlayerJob")
                                    Wait(200)
                                    if PlayerJob then
                                        if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                            if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                                ReturnHorse(shopId)
                                            else
                                                VORPcore.NotifyRightTip(
                                                    _U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                            end
                                        else
                                            VORPcore.NotifyRightTip(
                                                _U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,
                                            5000)
                                    end
                                end
                            end
                        end
                    end
                else
                    -- Not Using Stable Hours - Stable Always Open
                    if not Config.stables[shopId].BlipHandle and shopConfig.blipAllowed then
                        AddBlip(shopId)
                    end
                    if not shopConfig.NPC and shopConfig.npcAllowed then
                        SpawnNPC(shopId)
                    end
                    if not next(shopConfig.allowedJobs) then
                        if Config.stables[shopId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle,
                                joaat(shopConfig.blipColorOpen)) -- BlipAddModifier
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsShop = vector3(shopConfig.npc.x, shopConfig.npc.y, shopConfig.npc.z)
                        local distanceShop = #(coordsDist - coordsShop)

                        if (distanceShop <= shopConfig.distanceShop) then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                            PromptSetActiveGroupThisFrame(OpenGroup, shopOpen)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                DisplayRadar(false)
                                OpenStable(shopId)
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                ReturnHorse(shopId)
                            end
                        end
                    else
                        -- Not Using Stable Hours - Stable Always Open - Job Locked
                        if Config.stables[shopId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.stables[shopId].BlipHandle,
                                joaat(shopConfig.blipColorJob)) -- BlipAddModifier
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsShop = vector3(shopConfig.npc.x, shopConfig.npc.y, shopConfig.npc.z)
                        local distanceShop = #(coordsDist - coordsShop)

                        if (distanceShop <= shopConfig.distanceShop) then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                            PromptSetActiveGroupThisFrame(OpenGroup, shopOpen)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent("bcc-stables:GetPlayerJob")
                                Wait(200)
                                if PlayerJob then
                                    if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                        if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                            DisplayRadar(false)
                                            OpenStable(shopId)
                                        else
                                            VORPcore.NotifyRightTip(
                                                _U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,
                                            5000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                end
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent("bcc-stables:GetPlayerJob")
                                Wait(200)
                                if PlayerJob then
                                    if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                        if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                            ReturnHorse(shopId)
                                        else
                                            VORPcore.NotifyRightTip(
                                                _U("needJob") .. JobName .. " " .. shopConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,
                                            5000)
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
            Wait(1000)
        end
    end
end)

-- Open Main Menu
function OpenStable(shopId)
    InMenu = true

    local shopConfig = Config.stables[shopId]
    StableName = shopConfig.shopName
    SpawnPoint = {
        x = shopConfig.spawnPoint.x,
        y = shopConfig.spawnPoint.y,
        z = shopConfig.spawnPoint.z,
        h = shopConfig.spawnPoint.h
    }

    CreateCamera(shopId)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "show",
        shopData = Config.Horses,
        compData = HorseComp,
        location = StableName
    })
    TriggerServerEvent('bcc-stables:GetMyHorses')
end

-- Get Horse Data for Players Horses
RegisterNetEvent('bcc-stables:ReceiveHorsesData')
AddEventHandler('bcc-stables:ReceiveHorsesData', function(dataHorses)
    SendNUIMessage({
        action = "updateMyHorses",
        myHorsesData = dataHorses
    })
end)

-- View Horses for Purchase
RegisterNUICallback("loadHorse", function(data, cb)
    cb('ok')

    if MyEntity ~= nil then
        DeleteEntity(MyEntity)
        MyEntity = nil
    end

    local model = joaat(data.horseModel)
    LoadModel(model)

    if ShopEntity ~= nil then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
    end

    ShopEntity = CreatePed(model, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z - 0.98, SpawnPoint.h, false, 0)
    Citizen.InvokeNative(0x283978A15512B2FE, ShopEntity, true) -- SetRandomOutfitVariation
    Citizen.InvokeNative(0x58A850EAEE20FAA3, ShopEntity)       -- PlaceObjectOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, ShopEntity, true) -- FreezeEntityPosition
    SetBlockingOfNonTemporaryEvents(ShopEntity, true)
    SetPedConfigFlag(ShopEntity, 113, true)                    -- DisableShockingEvents
    Wait(300)
    Citizen.InvokeNative(0x6585D955A68452A5, ShopEntity)       -- ClearPedEnvDirt
end)

-- Buy and Name New Horse
RegisterNUICallback("BuyHorse", function(data, cb)
    cb('ok')
    SendNUIMessage({
        action = "hide"
    })
    TriggerServerEvent('bcc-stables:BuyHorse', data)
end)

RegisterNetEvent('bcc-stables:SetHorseName')
AddEventHandler('bcc-stables:SetHorseName', function(data, rename)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "hide"
    })

    Wait(200)
    local horseName = ""
    CreateThread(function()
        AddTextEntry('FMMC_MPM_NA', "Name your horse:")
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0)
            Wait(0)
        end
        if (GetOnscreenKeyboardResult()) then
            horseName = GetOnscreenKeyboardResult()

            if (horseName == "") then
                TriggerEvent('bcc-stables:SetHorseName', data, rename)
                return
            end

            if not rename then
                TriggerServerEvent('bcc-stables:SaveNewHorse', data, horseName)
            else
                TriggerServerEvent('bcc-stables:UpdateHorseName', data, horseName)
            end

            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "show",
                shopData = Config.Horses,
                compData = HorseComp,
                location = StableName
            })

            Wait(1000)
            TriggerServerEvent('bcc-stables:GetMyHorses')
        end
    end)
end)

-- Rename Owned Horse
RegisterNUICallback("RenameHorse", function(data, cb)
    cb('ok')
    SendNUIMessage({
        action = "hide"
    })
    local rename = true
    TriggerEvent('bcc-stables:SetHorseName', data, rename)
end)

-- View Player Owned Horses
RegisterNUICallback("loadMyHorse", function(data, cb)
    cb('ok')

    MyEntityID = data.HorseId

    if ShopEntity ~= nil then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
    end

    if MyEntity ~= nil then
        DeleteEntity(MyEntity)
        MyEntity = nil
    end

    local model = joaat(data.HorseModel)
    LoadModel(model)

    MyEntity = CreatePed(model, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z - 0.98, SpawnPoint.h, false, 0)
    Citizen.InvokeNative(0x283978A15512B2FE, MyEntity, true)           -- SetRandomOutfitVariation
    Citizen.InvokeNative(0x58A850EAEE20FAA3, MyEntity)                 -- PlaceObjectOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, MyEntity, true)           -- FreezeEntityPosition
    if data.HorseGender == 'female' then
        Citizen.InvokeNative(0x5653AB26C82938CF, MyEntity, 41611, 1.0) -- SetCharExpression
        Citizen.InvokeNative(0xCC8CA3E88256E58F, MyEntity)             -- UpdatePedVariation
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
                Citizen.InvokeNative(0xFA28FE3A6246FC30, compModel)                                        -- RequestModel
            end
            Citizen.InvokeNative(0xD3A7B003ED343FD9, MyEntity, tonumber(hash), true, true, true) -- ApplyShopItemToPed
        end
    end
end)

-- Select Active Horse
RegisterNUICallback("selectHorse", function(data, cb)
    cb('ok')
    TriggerServerEvent('bcc-stables:SelectHorse', tonumber(data.horseId))
end)

RegisterNetEvent('bcc-stables:SetHorseInfo')
AddEventHandler('bcc-stables:SetHorseInfo', function(model, name, components, id, gender)
    HorseModel = model
    HorseName = name
    HorseComponents = components
    MyHorseId = id
    HorseGender = gender
    SpawnHorse()
end)

-- Close Stable Menu
RegisterNUICallback("CloseStable", function(data, cb)
    cb('ok')
    local player = PlayerPedId()

    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "hide"
    })

    SetEntityVisible(player, true)

    if ShopEntity ~= nil then
        DeleteEntity(ShopEntity)
    end

    if MyEntity ~= nil then
        DeleteEntity(MyEntity)
    end

    DestroyAllCams(true)
    ShopEntity = nil
    DisplayRadar(true)
    InMenu = false

    local menuAction = data.MenuAction
    if menuAction == "save" then
        TriggerServerEvent('bcc-stables:BuyTack', data)
    else
        return
    end
end)

-- Save Horse Tack to Database
RegisterNetEvent('bcc-stables:SaveComps')
AddEventHandler('bcc-stables:SaveComps', function()
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
    if compDataEncoded ~= "[]" then
        TriggerServerEvent('bcc-stables:UpdateComponents', compData, MyEntityID, MyEntity)
    end
end)


-- Reopen Menu After Sell or Failed Purchase
RegisterNetEvent('bcc-stables:StableMenu')
AddEventHandler('bcc-stables:StableMenu', function()
    if ShopEntity ~= nil then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
    end

    SendNUIMessage({
        action = "show",
        shopData = Config.Horses,
        compData = HorseComp,
        location = StableName
    })
    TriggerServerEvent('bcc-stables:GetMyHorses')
end)

RegisterNetEvent('bcc-stables:SetComponents')
AddEventHandler('bcc-stables:SetComponents', function(horseEntity, components)
    for _, value in pairs(components) do
        NativeSetPedComponentEnabled(horseEntity, value)
    end
end)

function NativeSetPedComponentEnabled(ped, component)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, component, true, true, true) -- ApplyShopItemToPed
end

-- Spawn Player Horse
function SpawnHorse()
    if Spawning then
        return
    end
    Spawning = true

    if MyHorse ~= nil then
        DeleteEntity(MyHorse)
        MyHorse = nil
    end

    local model = joaat(HorseModel)
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
        MyHorse = CreatePed(model, spawnPosition, GetEntityHeading(player), true, true)
    else
        MyHorse = CreatePed(model, x, y, groundZ + 2, GetEntityHeading(player), true, true)
    end
    SetModelAsNoLongerNeeded(model)

    Citizen.InvokeNative(0x9587913B9E772D29, MyHorse, 0)                             -- PlaceEntityOnGroundProperly
    Citizen.InvokeNative(0xE6D4E435B56D5BD0, player, MyHorse)                        -- SetPlayerOwnsMount
    Citizen.InvokeNative(0x283978A15512B2FE, MyHorse, true)                          -- SetRandomOutfitVariation
    if HorseGender == 'female' then
        Citizen.InvokeNative(0x5653AB26C82938CF, MyHorse, 41611, 1.0)                -- SetCharExpression
        Citizen.InvokeNative(0xCC8CA3E88256E58F, MyHorse)                            -- UpdatePedVariation
    end
    SetPedConfigFlag(MyHorse, 113, true)                                             -- DisableShockingEvents
    SetPedConfigFlag(MyHorse, 297, true)                                             -- EnableHorseLeading
    SetPedConfigFlag(MyHorse, 546, true)                                             -- IgnoreOwnershipForHorseFeedAndBrush

    local horseBlip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, MyHorse) -- BlipAddForEntity
    Citizen.InvokeNative(0x9CB1A1623062F402, horseBlip, HorseName)                   -- SetBlipName

    SetPedPromptName(MyHorse, HorseName)

    if HorseComponents ~= nil and HorseComponents ~= "0" then
        for _, componentHash in pairs(json.decode(HorseComponents)) do
            NativeSetPedComponentEnabled(MyHorse, tonumber(componentHash))
        end
    end

    TriggerServerEvent('bcc-stables:RegisterInventory', MyHorseId)

    Spawned = true
    SendHorse()
    Spawning = false
end

-- Horse Actions
CreateThread(function()
    while true do
        Wait(1)
        -- Whistle for Horse (key: H)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x24978A28) then -- IsDisabledControlJustPressed
            CallHorse()
        end
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

function CallHorse()
    local player = PlayerPedId()
    if MyHorse ~= nil then
        if GetScriptTaskStatus(MyHorse, 0x4924437D, 0) ~= 0 then
            local pcoords = GetEntityCoords(player)
            local hcoords = GetEntityCoords(MyHorse)
            local callDist = #(pcoords - hcoords)
            if callDist >= 100 then
                DeleteEntity(MyHorse)
                Wait(1000)
                MyHorse = nil
                TriggerServerEvent('bcc-stables:GetSelectedHorse')
            else
                Spawned = true
                SendHorse()
            end
        end
    else
        TriggerServerEvent('bcc-stables:GetSelectedHorse')
    end
end

-- Move horse to Player
function SendHorse()
    CreateThread(function()
        local player = PlayerPedId()
        Citizen.InvokeNative(0x6A071245EB0D1882, MyHorse, player, -1, 10.2, 2.0, 0.0, 0) -- TaskGoToEntity
        while Spawned == true do
            local coords = GetEntityCoords(player)
            local hCoords = GetEntityCoords(MyHorse)
            local distance = #(coords - hCoords)
            if (distance < 10.0) then
                ClearPedTasks(MyHorse, true, true)
                Spawned = false
            end
            Wait(1000)
        end
    end)
end

-- Open Horse Inventory
function OpenInventory()
    local pcoords = GetEntityCoords(PlayerPedId())
    local hcoords = GetEntityCoords(MyHorse)
    local invDist = #(pcoords - hcoords)
    if invDist <= 1.0 then
        local hasSaddlebags = Citizen.InvokeNative(0xFB4891BD7578CDC1, MyHorse, -2142954459)
        if not hasSaddlebags then
            VORPcore.NotifyRightTip(_U("noSaddlebags"), 5000)
        else
            TriggerServerEvent('bcc-stables:OpenInventory', MyHorseId)
        end
    end
end

-- Send Horse Away
function FleeHorse()
    if MyHorse ~= nil then
        TaskAnimalFlee(MyHorse, PlayerPedId(), -1)
        Wait(10000)
        DeleteEntity(MyHorse)
        Wait(1000)
        MyHorse = 0
    end
end

-- Brush and Feed Player Horse
CreateThread(function()
    while true do
        Wait(1)
        -- Brush Horse (Key: B in Horse Menu)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x63A38F2C) then -- IsDisabledControlJustPressed
            if not BrushCooldown then
                TriggerServerEvent('bcc-stables:GetPlayerItem', 'brush')
            else
                VORPcore.NotifyRightTip(_U("notDirty"), 5000)
            end
        end
        -- Feed Horse (Key: R in Horse Menu)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x0D55A0F0) then -- IsDisabledControlJustPressed
            if not FeedCooldown then
                TriggerServerEvent('bcc-stables:GetPlayerItem', 'haycube')
            else
                VORPcore.NotifyRightTip(_U("notHungry"), 5000)
            end
        end
    end
end)

RegisterNetEvent('bcc-stables:BrushHorse')
AddEventHandler('bcc-stables:BrushHorse', function(data)
    local horsebrush = data.name
    if horsebrush == "horsebrush" then
        Citizen.InvokeNative(0xCD181A959CFDD7F4, PlayerPedId(), MyHorse, joaat("Interaction_Brush"),
            joaat("p_brushHorse02x"), 1)                                    -- TaskAnimalInteraction
        local health = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0) -- GetAttributeCoreValue

        Wait(5000)

        Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 0, health + Config.brushHealthBoost) -- SetAttributeCoreValue
        Citizen.InvokeNative(0x6585D955A68452A5, MyHorse)                                      -- ClearPedEnvDirt
        Citizen.InvokeNative(0x523C79AEEFCC4A2A, MyHorse, 10, "ALL")                           -- ClearPedDamageDecalByZone
        Citizen.InvokeNative(0x8FE22675A5A45817, MyHorse)                                      -- ClearPedBloodDamage

        local bCooldown = math.ceil(Config.brushCooldown / 60000)
        VORPcore.NotifyRightTip(_U("brushCooldown") .. bCooldown .. _U("minutes"), 5000)
        BrushCooldown = true

        Wait(Config.brushCooldown)

        BrushCooldown = false
    end
end)

RegisterNetEvent('bcc-stables:FeedHorse')
AddEventHandler('bcc-stables:FeedHorse', function(data)
    local haycube = data.name
    if haycube == "consumable_haycube" then
        Citizen.InvokeNative(0xCD181A959CFDD7F4, PlayerPedId(), MyHorse, joaat("Interaction_Food"),
            joaat("s_horsnack_haycube01x"), 1)                               -- TaskAnimalInteraction
        local health = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0)  -- GetAttributeCoreValue
        local stamina = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 1) -- GetAttributeCoreValue

        Wait(3000)

        Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 0, health + Config.feedHealthBoost)   -- SetAttributeCoreValue
        Citizen.InvokeNative(0xC6258F41D86676E0, MyHorse, 1, stamina + Config.feedStaminaBoost) -- SetAttributeCoreValue

        local fCooldown = math.ceil(Config.feedCooldown / 60000)
        VORPcore.NotifyRightTip(_U("feedCooldown") .. fCooldown .. _U("minutes"), 5000)
        FeedCooldown = true

        Wait(Config.feedCooldown)

        FeedCooldown = false
    end
end)

-- Select Horse Tack from Menu
RegisterNUICallback("Saddles", function(data, cb)
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

RegisterNUICallback("Saddlecloths", function(data, cb)
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

RegisterNUICallback("Stirrups", function(data, cb)
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

RegisterNUICallback("SaddleBags", function(data, cb)
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

RegisterNUICallback("Manes", function(data, cb)
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

RegisterNUICallback("Tails", function(data, cb)
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

RegisterNUICallback("SaddleHorns", function(data, cb)
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

RegisterNUICallback("Bedrolls", function(data, cb)
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

RegisterNUICallback("Masks", function(data, cb)
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

RegisterNUICallback("Mustaches", function(data, cb)
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
        Citizen.InvokeNative(0xFA28FE3A6246FC30, model)                                        -- RequestModel
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, MyEntity, tonumber(hash), true, true, true) -- ApplyShopItemToPed
end

-- Sell Player Horse
RegisterNUICallback("sellHorse", function(data)
    SendNUIMessage({
        action = "hide"
    })
    DeleteEntity(MyEntity)
    TriggerServerEvent('bcc-stables:SellHorse', tonumber(data.horseId))
    Wait(300)

    SendNUIMessage({
        action = "show",
        shopData = Config.Horses,
        compData = HorseComp,
        location = StableName
    })
    TriggerServerEvent('bcc-stables:GetMyHorses')
end)

-- Return Player Horse at Stable
function ReturnHorse(shopId)
    if MyHorse == nil then
        VORPcore.NotifyRightTip(_U("noHorse"), 5000)
    elseif MyHorse ~= nil then
        DeleteEntity(MyHorse)
        MyHorse = nil
        VORPcore.NotifyRightTip(_U("horseReturned"), 5000)
    end
end

-- View Horses While in Menu
function CreateCamera(shopId)
    local shopConfig = Config.stables[shopId]
    local horseCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(horseCam, shopConfig.horseCam.x, shopConfig.horseCam.y, shopConfig.horseCam.z + 1.2)
    SetCamActive(horseCam, true)
    PointCamAtCoord(horseCam, SpawnPoint.x - 0.5, SpawnPoint.y, SpawnPoint.z)
    DoScreenFadeOut(500)
    Wait(500)
    DoScreenFadeIn(500)
    RenderScriptCams(true, false, 0, 0, 0)
end

-- -- Rotate Horses while Viewing
RegisterNUICallback("rotate", function(data, cb)
    cb('ok')
    local direction = data.RotateHorse

    if direction == "left" then
        Rotation(20)
    elseif direction == "right" then
        Rotation(-20)
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
    TriggerServerEvent('bcc-stables:GetSelectedHorse')
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
    shopConfig.BlipHandle = N_0x554d9d53f696d002(1664425300, shopConfig.npc.x, shopConfig.npc.y, shopConfig.npc.z) -- BlipAddForCoords
    SetBlipSprite(shopConfig.BlipHandle, shopConfig.blipSprite, 1)
    SetBlipScale(shopConfig.BlipHandle, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, shopConfig.BlipHandle, shopConfig.blipName) -- SetBlipName
end

-- NPSs
function SpawnNPC(shopId)
    local shopConfig = Config.stables[shopId]
    local model = joaat(shopConfig.npcModel)
    LoadModel(model)
    local npc = CreatePed(shopConfig.npcModel, shopConfig.npc.x, shopConfig.npc.y, shopConfig.npc.z - 1, shopConfig.npc
        .h, false, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    Wait(500)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    Config.stables[shopId].NPC = npc
end

function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(100)
    end
end

-- Check for Jobs
function CheckJob(allowedJob, playerJob)
    for _, jobAllowed in pairs(allowedJob) do
        JobName = jobAllowed
        if JobName == playerJob then
            return true
        end
    end
    return false
end

RegisterNetEvent("bcc-stables:SendPlayerJob")
AddEventHandler("bcc-stables:SendPlayerJob", function(Job, grade)
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
    DestroyAllCams(true)
    DisplayRadar(true)

    if MyHorse ~= nil then
        DeleteEntity(MyHorse)
        MyHorse = nil
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
