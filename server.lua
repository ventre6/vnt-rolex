local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('vnt-rolexsell:givemoney')
AddEventHandler('vnt-rolexsell:givemoney', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney("cash", Config.Money)
end)

RegisterServerEvent('vnt-rolexsell:rolexsil')
AddEventHandler('vnt-rolexsell:rolexsil', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(Config.RolexItem, "1")
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RolexItem], "remove")
end)