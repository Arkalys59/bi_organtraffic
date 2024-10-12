ESX = exports['es_extended']:getSharedObject()

local function sendToDiscordLog(message)
    local content = {
        {
            ["color"] = 16711680, 
            ["title"] = "Vente d'Items",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Log du serveur FiveM"
            }
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers)
        if err ~= 200 then
            print("Erreur lors de l'envoi du log Discord : ", err)
        end
    end, 'POST', json.encode({username = "FiveM Logs", embeds = content}), { ['Content-Type'] = 'application/json' })
end

ESX.RegisterServerCallback('bibiModz:hasScalpel', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local scalpel = xPlayer.getInventoryItem(Config.ScalpelItem)
    cb(scalpel and scalpel.count > 0)
end)


RegisterNetEvent('bibiModz:giveRandomItems')
AddEventHandler('bibiModz:giveRandomItems', function(items)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        for _, item in pairs(items) do
            xPlayer.addInventoryItem(item, 1)
        end
    end
end)

RegisterNetEvent('bibiModz:buyScalpel')
AddEventHandler('bibiModz:buyScalpel', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local scalpelPrice = Config.ScalpelPrice

    if xPlayer.getMoney() >= scalpelPrice then
        xPlayer.removeMoney(scalpelPrice)
        xPlayer.addInventoryItem(Config.ScalpelItem, 1)
        TriggerClientEvent('esx:showNotification', source, 'Vous avez acheté un scalpel pour $' .. scalpelPrice)
    else
        TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez pas assez d\'argent.')
    end
end)

RegisterNetEvent('bibiModz:sellAllItems')
AddEventHandler('bibiModz:sellAllItems', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local totalPrice = 0
    local hasEnoughItems = false
    local itemsSold = {}

    for itemName, itemConfig in pairs(Config.ItemDetails) do
        local item = xPlayer.getInventoryItem(itemName)
        if item.count >= itemConfig.limit then
            totalPrice = totalPrice + (item.count * itemConfig.price)
            hasEnoughItems = true
            xPlayer.removeInventoryItem(itemName, item.count) -- Retirer les items de l'inventaire
            table.insert(itemsSold, itemName .. " (x" .. item.count .. ")")
        end
    end

    if not hasEnoughItems then
        TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez pas assez d\'items pour les vendre.')
        return
    end

    if totalPrice > 0 then
        xPlayer.addMoney(totalPrice)
        TriggerClientEvent('esx:showNotification', source, 'Vous avez vendu vos items pour $' .. totalPrice)


        local itemsSoldString = table.concat(itemsSold, ", ")
        sendToDiscordLog("Le joueur **" .. GetPlayerName(source) .. "** a vendu les items suivants : **" .. itemsSoldString .. "** pour un total de **" .. totalPrice .. "$**.")
    else
        TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez pas d\'items à vendre.')
    end
end)

RegisterNetEvent('bibiModz:sellSpecificItem')
AddEventHandler('bibiModz:sellSpecificItem', function(itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local itemConfig = Config.ItemDetails[itemName]

    if not itemConfig then
        TriggerClientEvent('esx:showNotification', source, 'Cet item ne peut pas être vendu.')
        return
    end

    local item = xPlayer.getInventoryItem(itemName)

    if item.count >= itemConfig.limit then
        local totalPrice = item.count * itemConfig.price
        xPlayer.removeInventoryItem(itemName, item.count)
        xPlayer.addMoney(totalPrice)
        TriggerClientEvent('esx:showNotification', source, 'Vous avez vendu tous les ' .. itemName .. ' pour $' .. totalPrice)

        sendToDiscordLog("Le joueur **" .. GetPlayerName(source) .. "** a vendu **" .. item.count .. " " .. itemName .. "** pour **" .. totalPrice .. "$**.")
    else
        TriggerClientEvent('esx:showNotification', source, 'Vous devez avoir au moins ' .. itemConfig.limit .. ' ' .. itemName .. ' pour les vendre.')
    end
end)
