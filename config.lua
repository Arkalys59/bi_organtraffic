Config = {}

-- URL du webhook Discord
Config.DiscordWebhook = "VOTRE WEBHOOK" -- Remplace par ton URL webhook

-- Pnj Mission
Config.MissionNpc = {
    model = 'a_m_m_farmer_01',
    coords = vector3(1174.3648, 2633.0109, 37.8059),
    heading = 180.0
}

-- Pnj Dealer
Config.DealerNpc = {
    model = 'a_m_y_business_01',
    coords = vector3(1580.294, -1722.2945, 88.1362),
    heading = 180.0
}

-- Zones de spawn pour les cibles
Config.SpawnZones = {
    vector3(280.246154, 181.556046,104.4974),
    vector3(280.246154, 181.556046,104.4974),
    vector3(280.246154, 181.556046,104.4974)
}

-- Prix et limites pour chaque item
Config.ItemDetails = {
    rein = { price = 100, limit = 1 }, -- 1 reins requis pour vendre
    crane = { price = 50, limit = 1 },
    pied = { price = 40, limit = 1 },
    yeux = { price = 60, limit = 1 },
    organe = { price = 80, limit = 1 },
    coeur = { price = 120, limit = 1 },
    os = { price = 30, limit = 1 }
}

-- (20 minutes)
Config.MissionCooldown = 0

-- Nom de l'item scalpel
Config.ScalpelItem = 'scalpel'
-- Prix du scalpel
Config.ScalpelPrice = 200


