local ESX = exports['es_extended']:getSharedObject()


local function sendToDiscordLog(message)
    local content = {
        {
            ["color"] = 16711680, -- Rouge vif
            ["title"] = "Dépeçage de PNJ",
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
    local scalpel = xPlayer.getInventoryItem('scalpel')

    if scalpel and scalpel.count > 0 then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('bibiModz:giveRandomItems')
AddEventHandler('bibiModz:giveRandomItems', function(itemsToGive)
    local xPlayer = ESX.GetPlayerFromId(source)
    local receivedItems = {}

    for _, item in ipairs(itemsToGive) do
        xPlayer.addInventoryItem(item.name, item.count)
        table.insert(receivedItems, item.name .. " (x" .. item.count .. ")")
    end

    local itemsString = table.concat(receivedItems, ", ")
    local playerName = GetPlayerName(source)
    local weaponLabel = "Inconnue"
    sendToDiscordLog("Le joueur **" .. playerName .. "** a dépecé un PNJ et a reçu les items suivants : **" .. itemsString .. "**.")
end)

RegisterServerEvent('bibiModz:buyScalpel')
AddEventHandler('bibiModz:buyScalpel', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = Config.ScalpelPrice
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        xPlayer.addInventoryItem('scalpel', 1)
        TriggerClientEvent('esx:showNotification', source, 'Vous avez acheté un scalpel pour $' .. price .. '.')
    else
        TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez pas assez d\'argent.')
    end
end)
