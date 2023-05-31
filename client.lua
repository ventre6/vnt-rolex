local QBCore = exports['qb-core']:GetCoreObject()

function loadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(1)
        end
    end
end

local RolexSell = false
local SellControl = false

function CreateRolexPed()
    local hashKey = Config.SellNPC
    local pedType = 5
    RequestModel(hashKey)
    while not HasModelLoaded(hashKey) do
        RequestModel(hashKey)
        Citizen.Wait(100)
    end
    deliveryPed = CreatePed(pedType, hashKey, Config.DeliveryPedLocation[rnd]["x"], Config.DeliveryPedLocation[rnd]["y"],
        Config.DeliveryPedLocation[rnd]["z"], Config.DeliveryPedLocation[rnd]["h"], 0, 0)
    ClearPedTasks(deliveryPed)
    ClearPedSecondaryTask(deliveryPed)
    TaskSetBlockingOfNonTemporaryEvents(deliveryPed, true)
    SetPedFleeAttributes(deliveryPed, 0, 0)
    SetPedCombatAttributes(deliveryPed, 17, 1)

    SetPedSeeingRange(deliveryPed, 0.0)
    SetPedHearingRange(deliveryPed, 0.0)
    SetPedAlertness(deliveryPed, 0)
    SetPedKeepTask(deliveryPed, true)
    exports[Config.TargetName]:AddTargetEntity(deliveryPed, {
        options = {
            {
                type = "client",
                event = "vnt-rolexsell:satis",
                label = Config.TargetSellLabel,
                icon = 'fa-solid fa-box',
            }
        },
        distance = 2.0
    })
    SetNewWaypoint(Config.DeliveryPedLocation[rnd]["x"], Config.DeliveryPedLocation[rnd]["y"])
end

function DeleteCreatedPed()
    if DoesEntityExist(deliveryPed) then
        Citizen.Wait(5000)
        SetPedKeepTask(deliveryPed, false)
        TaskSetBlockingOfNonTemporaryEvents(deliveryPed, false)
        ClearPedTasks(deliveryPed)
        TaskWanderStandard(deliveryPed, 10.0, 10)
        SetPedAsNoLongerNeeded(deliveryPed)

        Citizen.Wait(20000)
        DeletePed(deliveryPed)
    end
end

function DeleteBlip()
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end

function CreateBlip()
    DeleteBlip()
    if RolexSell then
        blip = AddBlipForCoord(Config.DeliveryPedLocation[rnd]["x"], Config.DeliveryPedLocation[rnd]["y"],
            Config.DeliveryPedLocation[rnd]["z"])
    end
    SetBlipSprite(blip, 514)
    SetBlipScale(blip, 0.7)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipName)
    EndTextCommandSetBlipName(blip)
end

function playerAnim()
    loadAnimDict("mp_safehouselost@")
    TaskPlayAnim(PlayerPedId(), "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
end

function giveAnim()
    if (DoesEntityExist(deliveryPed) and not IsEntityDead(deliveryPed)) then
        loadAnimDict("mp_safehouselost@")
        if (IsEntityPlayingAnim(deliveryPed, "mp_safehouselost@", "package_dropoff", 3)) then
            TaskPlayAnim(deliveryPed, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
        else
            TaskPlayAnim(deliveryPed, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
        end
    end
end

local sayac = 0

RegisterNetEvent('vnt-rolexsell:satis', function()
    if (DoesEntityExist(deliveryPed) and not IsEntityDead(deliveryPed)) then
        if SellControl then return end
        if RolexSell == true then
            if not IsPedInAnyVehicle(PlayerPedId()) then
                SellControl = true
                exports[Config.TargetName]:RemoveTargetEntity(deliveryPed)
                if QBCore.Functions.HasItem(Config.RolexItem) then
                    playerAnim()
                    giveAnim()
                    TriggerServerEvent("vnt-rolexsell:rolexsil")
                    QBCore.Functions.Notify("The business is successful. Wait for him to give new job.")
                    if RolexSell then
                        TriggerServerEvent('vnt-rolexsell:givemoney')
                    end
                    DeleteBlip()
                    DeleteCreatedPed()
                    SellControl = false
                    if QBCore.Functions.HasItem(Config.RolexItem) and RolexSell then
                        Citizen.Wait(3000)
                        RolexSell = true
                        CreateBlip()
                        CreateRolexPed()
                        QBCore.Functions.Notify("Go to the specified location.")
                    end
                else
                    QBCore.Functions.Notify("You don't have any rolex", "error")
                    RolexSell = false
                    DeleteBlip()
                    DeleteCreatedPed()
                end
            end
        end
    else
        QBCore.Functions.Notify("Customer is dead!", "error", 5000)
        SellControl = false
        RolexSell = false
        DeleteBlip()
        DeleteCreatedPed()
        sayac = 0
    end
end)

function RolexSatBasla()
    if RolexSell then QBCore.Functions.Notify("You already sell rolex", "error") return end
    if QBCore.Functions.HasItem(Config.RolexItem) then
        sayac = 0
        rnd = math.random(1, #Config.DeliveryPedLocation)
        RolexSell = true
        CreateBlip()
        CreateRolexPed()
        QBCore.Functions.Notify("Go to the specified location")
    else
        QBCore.Functions.Notify("You don't have any rolex", "error")
    end
end

Citizen.CreateThread(function()
    RequestModel(GetHashKey(Config.StartNPC))
    while not HasModelLoaded(GetHashKey(Config.StartNPC)) do
        Wait(1)
    end
    npc = CreatePed(1, GetHashKey(Config.StartNPC), Config.NPCLocation, false, true)
    SetPedCombatAttributes(npc, 46, true)
    SetPedFleeAttributes(npc, 0, 0)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    exports[Config.TargetName]:AddTargetEntity(npc, {
        options = {
            {
                label = Config.TargetStartLabel,
                icon = 'fa-solid fa-box',
                action = function()
                    RolexSatBasla()
                end,
            }
        },
        distance = 2.0
    })
end)

RegisterCommand('cancelrolex', function()
    if RolexSell then
        QBCore.Functions.Notify("Job canceled", "error")
        RolexSell = false
        DeleteBlip()
        DeleteCreatedPed()
        sayac = 0
    else
        QBCore.Functions.Notify("You don't sell Rolex", "error")
    end
end)
