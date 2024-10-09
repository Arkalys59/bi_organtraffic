-- BibiModz

local ESX = exports['es_extended']:getSharedObject()
local hasMission = false
local lastMissionTime = 0
local harvestedPeds = {} 
local targetWeaponUsed = nil


local function playAnimation(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, duration, 1, 0, false, false, false)
end


local function addBloodEffect(coords)
    local bloodType = 1010 
    local scale = 1.0 
    AddDecal(bloodType, coords.x, coords.y, coords.z, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, scale, scale, 0.0, 255, 0, 0, 255, 0, 1, 0)
end


local function giveMission()
    local currentTime = GetGameTimer()
    if currentTime - lastMissionTime < Config.MissionCooldown then
        local remainingTime = Config.MissionCooldown - (currentTime - lastMissionTime)
        ESX.ShowNotification('Vous devez attendre ' .. math.ceil(remainingTime / 60000) .. ' minutes avant de reprendre une mission.')
        return
    end

    if hasMission then
        ESX.ShowNotification('Vous avez déjà une mission active.')
        return
    end

    local targetZone = Config.SpawnZones[math.random(1, #Config.SpawnZones)]
    local targetPedModel = 'a_m_m_business_01'

    RequestModel(targetPedModel)
    while not HasModelLoaded(targetPedModel) do
        Wait(0)
    end

    local targetPed = CreatePed(4, GetHashKey(targetPedModel), targetZone, 0.0, true, true)
    local targetPedId = NetworkGetNetworkIdFromEntity(targetPed)

    local targetBlip = AddBlipForEntity(targetPed)
    SetBlipSprite(targetBlip, 273)
    SetBlipColour(targetBlip, 1)
    SetBlipRoute(targetBlip, true)

    Citizen.CreateThread(function()
        while DoesEntityExist(targetPed) do
            Wait(0)
            if IsEntityDead(targetPed) then
                targetWeaponUsed = GetPedCauseOfDeath(targetPed)

                RemoveBlip(targetBlip)
                Wait(2000)


                exports.ox_target:addLocalEntity(targetPed, {
                    {
                        name = 'harvestRein',
                        label = 'Récolter les organes',
                        icon = 'fa-solid fa-scalpel',
                        onSelect = function()
                            if harvestedPeds[targetPedId] then
                                ESX.ShowNotification('Vous avez déjà récolté les organes de ce corps.')
                                return
                            end

                            ESX.TriggerServerCallback('bibiModz:hasScalpel', function(hasScalpel)
                                if hasScalpel then
                                    playAnimation('amb@medic@standing@kneel@base', 'base', 10000)
                                    Citizen.Wait(10000)
                                    local pedCoords = GetEntityCoords(targetPed)
                                    addBloodEffect(pedCoords)

                                    local itemsToGive = {}
                                    for itemName, itemConfig in pairs(Config.ItemDetails) do
                                        local quantity = math.random(1, 3)
                                        if math.random() <= (itemConfig.chance or 1) then
                                            table.insert(itemsToGive, {name = itemName, count = quantity})
                                        end
                                    end
                                    TriggerServerEvent('bibiModz:giveRandomItems', itemsToGive)
                                    harvestedPeds[targetPedId] = true
                                    local playerName = GetPlayerName(PlayerId())
                                    TriggerServerEvent('bibiModz:sendDiscordLog', playerName, itemsToGive, targetWeaponUsed)

                                    hasMission = false
                                    lastMissionTime = GetGameTimer()
                                    ESX.ShowNotification('Vous avez récolté des organes.')
                                else
                                    ESX.ShowNotification('Vous avez besoin d\'un scalpel pour récolter les organes.')
                                end
                            end)
                        end
                    }
                })
                
                break 
            end
        end
    end)

    hasMission = true
end


local function spawnMissionNpc()
    RequestModel(Config.MissionNpc.model)
    while not HasModelLoaded(Config.MissionNpc.model) do
        Wait(0)
    end

    local npc = CreatePed(4, GetHashKey(Config.MissionNpc.model), Config.MissionNpc.coords, Config.MissionNpc.heading, false, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'giveMission',
            label = 'Prendre une mission',
            icon = 'fa-solid fa-handshake',
            onSelect = function()
                giveMission()
            end
        },
        {
            name = 'buyScalpel',
            label = 'Acheter un scalpel ($' .. Config.ScalpelPrice .. ')',
            icon = 'fa-solid fa-dollar-sign',
            onSelect = function()
                TriggerServerEvent('bibiModz:buyScalpel')
            end
        }
    })
end

local function spawnDealerNpc()
    RequestModel(Config.DealerNpc.model)
    while not HasModelLoaded(Config.DealerNpc.model) do
        Wait(0)
    end

    local npc = CreatePed(4, GetHashKey(Config.DealerNpc.model), Config.DealerNpc.coords, Config.DealerNpc.heading, false, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    local sellOptions = {}


    table.insert(sellOptions, {
        name = 'sellAllItems',
        label = 'Vendre tous les organes',
        icon = 'fa-solid fa-money-bill-wave',
        onSelect = function()
            TriggerServerEvent('bibiModz:sellAllItems')
        end
    })

    for itemName, itemConfig in pairs(Config.ItemDetails) do
        table.insert(sellOptions, {
            name = 'sell' .. itemName,
            label = 'Vendre tous les ' .. itemName,
            icon = 'fa-solid fa-money-bill-wave',
            onSelect = function()
                TriggerServerEvent('bibiModz:sellSpecificItem', itemName)
            end
        })
    end

    exports.ox_target:addLocalEntity(npc, sellOptions)
end
Citizen.CreateThread(function()
    spawnMissionNpc()
    spawnDealerNpc()
end)
