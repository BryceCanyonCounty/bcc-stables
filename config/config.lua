Config = {}

Config.defaultlang = "en_lang"

-- Open Stable Menu
Config.shopKey = 0x760A9C6F --[G]

-- Return Horse at Stable
Config.returnKey = 0xD9D0E1C0 --[spacebar]

-- Max Number of Horses per Player
Config.maxHorses = 5 -- Default: 5

-- Number of Items Allowed in Horse Inventory
Config.invLimit = 200 -- Default: 200

-- Cooldown for Brushing Horse
Config.brushCooldown = 300000 -- Default: 300000 = 5 Minutes

-- Cooldown for Feeding Horse
Config.feedCooldown = 300000 -- Default: 300000 = 5 Minutes

-- Health Increase for Brushing Horse
Config.brushHealthBoost = 5 -- Default: 5

-- Health Increase for Feeding Horse
Config.feedHealthBoost = 15 -- Default: 15

-- Stamina Increase for Feeding Horse
Config.feedStaminaBoost = 15 -- Default: 15

-- Allow Blips on Map when Stable is Closed
Config.blipAllowedClosed = true -- true = Show Blips / false = Remove Blips

-- Stable Locations and Options
Config.stables = { -- Original 7 Stable Locations
    valentine = {
		shopName = "Valentine Stable", -- Name Shown on the Stable Menu
        promptName = "Valentine Stable", -- Text Below the Prompt Button
        blipAllowed = true, -- Turns Blip On / Off
        blipName = "Valentine Stable", -- Name of the Blip on the Map
        blipSprite = 1938782895, -- blip_shop_horse
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32", -- Stable Open - Default: White - Blip Colors Shown Below
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10", -- Stable Closed - Default: Red - Blip Colors Shown Below
		blipColorJob = "BLIP_MODIFIER_MP_COLOR_23", -- Stable Job Locked - Default: Yellow - Blip Colors Shown Below
        distanceShop = 3.0, -- Distance from NPC to Get Menu Prompt
        npcAllowed = true, -- Turns NPCs On / Off
        npcModel = "A_M_M_UniBoatCrew_01", -- Sets Model for NPCs
        npcx = -365.08, npcy = 791.21, npcz = 116.18, npch = 179.76, -- Location for NPC and Stable
		horseCamx = -368.48, horseCamy = 789.89, horseCamz = 116.16, -- Camera Location to View Horse When In-Menu
		spawnPointx = -371.35, spawnPointy = 786.71, spawnPointz = 116.17, spawnPointh = 269.3, -- Location for Horse Preview When In-Menu
        allowedJobs = {}, -- If Empty, Everyone Can Use / Insert Job to limit access - ex. "police"
        jobGrade = 0, -- Enter Minimum Rank / Job Grade to Access Shop
        shopHours = false, -- If You Want the Shops to Use Open and Closed Hours
        shopOpen = 7, -- Shop Open Time / 24 Hour Clock
        shopClose = 21, -- Shop Close Time / 24 Hour Clock
    },
	strawberry = {
		shopName = "Strawberry Stable",
        promptName = "Strawberry Stable",
        blipAllowed = true,
        blipName = "Strawberry Stable",
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
		blipColorJob = "BLIP_MODIFIER_MP_COLOR_23",
        distanceShop = 3.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = -1817.85, npcy = -564.86, npcz = 156.06, npch = 335.86,
		horseCamx = -1822.55, horseCamy = -563.93, horseCamz = 156.13,
		spawnPointx = -1823.94, spawnPointy = -560.85, spawnPointz = 156.06, spawnPointh = 257.86,
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
    },
	vanhorn = {
		shopName = "Van Horn Stable",
        promptName = "Van Horn Stable",
        blipAllowed = true,
        blipName = "Van Horn Stable",
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
		blipColorJob = "BLIP_MODIFIER_MP_COLOR_23",
        distanceShop = 3.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = 2967.53, npcy = 792.71, npcz = 51.4, npch = 353.62,
		horseCamx = 2970.67, horseCamy = 793.65, horseCamz = 51.4,
		spawnPointx = 2971.66, spawnPointy = 796.82, spawnPointz = 51.4, spawnPointh = 96.54,
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
    },
	lemoyne = {
		shopName = "Lemoyne Stable",
        promptName = "Lemoyne Stable",
        blipAllowed = true,
        blipName = "Lemoyne Stable",
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
		blipColorJob = "BLIP_MODIFIER_MP_COLOR_23",
        distanceShop = 3.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = 1210.73, npcy = -189.78, npcz = 101.39, npch = 107.52,
		horseCamx = 1211.89, horseCamy = -192.76, horseCamz = 101.46,
		spawnPointx = 1210.5, spawnPointy = -196.25, spawnPointz = 101.38, spawnPointh = 15.61,
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
    },
	saintdenis = {
		shopName = "Saint Denis Stable",
        promptName = "Saint Denis Stable",
        blipAllowed = true,
        blipName = "Saint Denis Stable",
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
		blipColorJob = "BLIP_MODIFIER_MP_COLOR_23",
        distanceShop = 3.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = 2505.53, npcy = -1453.93, npcz = 46.32, npch = 99.45,
		horseCamx = 2505.65, horseCamy = -1441.49, horseCamz = 46.29,
		spawnPointx = 2502.59, spawnPointy = -1438.62, spawnPointz = 46.32, spawnPointh = 182.93,
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
    },
    blackwater = {
		shopName = "Blackwater Stable",
        promptName = "Blackwater Stable",
        blipAllowed = true,
        blipName = "Blackwater Stable",
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
		blipColorJob = "BLIP_MODIFIER_MP_COLOR_23",
        distanceShop = 3.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = -871.0, npcy = -1369.63, npcz = 43.53, npch = 6.64,
		horseCamx = -867.11, horseCamy = -1368.86, horseCamz = 43.54,
		spawnPointx = -864.7, spawnPointy = -1366.19, spawnPointz = 43.55, spawnPointh = 88.47,
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
    },
    tumbleweed = {
		shopName = "Tumbleweed Stable",
        promptName = "Tumbleweed Stable",
        blipAllowed = true,
        blipName = "Tumbleweed Stable",
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
		blipColorJob = "BLIP_MODIFIER_MP_COLOR_23",
        distanceShop = 3.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = -5515.2, npcy = -3040.17, npcz = -2.39, npch = 180.76,
		horseCamx = -5521.37, horseCamy = -3041.23, horseCamz = -2.39,
		spawnPointx = -5524.48, spawnPointy = -3044.31, spawnPointz = -2.39, spawnPointh = 263.98,
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
    }
}

Config.Horses = { -- Gold to Dollar Ratio Based on 1899 Gold Price / sellPrice is 60% of cashPrice / Cash Price is Regular Game Price
	{
		breed = "American Paint",
		["a_c_horse_americanpaint_greyovero"] = {color = "Grey Overo", cashPrice = 425, goldPrice = 20, sellPrice = 255},
		["a_c_horse_americanpaint_splashedwhite"] = {color = "Splashed White", cashPrice = 140, goldPrice = 6, sellPrice = 84},
		["a_c_horse_americanpaint_tobiano"] = {color = "Tobiano", cashPrice = 140, goldPrice = 6, sellPrice = 84},
		["a_c_horse_americanpaint_overo"] = {color = "Overo", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		breed = "American Standardbred",
		["a_c_horse_americanstandardbred_silvertailbuckskin"] = {color = "Silver Tail Buckskin", cashPrice = 400, goldPrice = 19, sellPrice = 240},
		["a_c_horse_americanstandardbred_palominodapple"] = {color = "Palomino Dapple", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_americanstandardbred_black"] = {color = "Black", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_americanstandardbred_buckskin"] = {color = "Buckskin", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_americanstandardbred_lightbuckskin"] = {color = "Light Buckskin", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		breed = "Andalusian",
		["a_c_horse_andalusian_perlino"] = {color = "Perlino", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_andalusian_rosegray"] = {color = "Rose Gray", cashPrice = 440, goldPrice = 21, sellPrice = 264},
		["a_c_horse_andalusian_darkbay"] = {color = "Dark Bay", cashPrice = 140, goldPrice = 6, sellPrice = 84},
	},
	{
		breed = "Appaloosa",
		["a_c_horse_appaloosa_blacksnowflake"] = {color = "Snow Flake", cashPrice = 900, goldPrice = 43, sellPrice = 540},
		["a_c_horse_appaloosa_brownleopard"] = {color = "Brown Leopard", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_appaloosa_leopard"] = {color = "Leopard", cashPrice = 430, goldPrice = 20, sellPrice = 258},
		["a_c_horse_appaloosa_fewspotted_pc"] = {color = "Few Spotted", cashPrice = 140, goldPrice = 6, sellPrice = 84},
		["a_c_horse_appaloosa_blanket"] = {color = "Blanket", cashPrice = 200, goldPrice = 9, sellPrice = 120},
		["a_c_horse_appaloosa_leopardblanket"] = {color = "Lepard Blanket", cashPrice = 130, goldPrice = 6, sellPrice =78},
	},
	{
		breed = "Arabian",
		["a_c_horse_arabian_white"] = {color = "White", cashPrice = 1500, goldPrice = 72, sellPrice = 900},
		["a_c_horse_arabian_rosegreybay"] = {color = "Rose Grey Bay", cashPrice = 1350, goldPrice = 65, sellPrice = 810},
		["a_c_horse_arabian_black"] = {color = "Black", cashPrice = 1250, goldPrice = 60, sellPrice = 750},
		["a_c_horse_arabian_grey"] = {color = "Grey", cashPrice = 1150, goldPrice = 55, sellPrice = 690},
		["a_c_horse_arabian_warpedbrindle_pc"] = {color = "Warped Brindle", cashPrice = 650, goldPrice = 31, sellPrice = 390},
		["a_c_horse_arabian_redchestnut"] = {color = "Red Chestnut", cashPrice = 350, goldPrice = 16, sellPrice = 210},
		["a_c_horse_arabian_redchestnut_pc"] = {color = "Red Chestnut II", cashPrice = 350, goldPrice = 16, sellPrice = 210},
	},
	{
		breed = "Ardennes",
		["a_c_horse_ardennes_irongreyroan"] = {color = "Iron Grey Roan", cashPrice = 1200, goldPrice = 58, sellPrice = 720},
		["a_c_horse_ardennes_strawberryroan"] = {color = "Strawberry Roan", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_ardennes_bayroan"] = {color = "Bay Roan", cashPrice = 140, goldPrice = 6, sellPrice = 84},
	},
	{
		breed = "Belgian Draft",
		["a_c_horse_belgian_blondchestnut"] = {color = "Blond Chestnut", cashPrice = 120, goldPrice = 5, sellPrice = 72},
		["a_c_horse_belgian_mealychestnut"] = {color = "Mealy Chestnut", cashPrice = 120, goldPrice = 5, sellPrice = 72},
	},
	{
		breed = "Breton",
		["a_c_horse_breton_grullodun"] = {color = "Grullo Dun", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_breton_mealydapplebay"] = {color = "Meally Dapple", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_breton_redroan"] = {color = "Red Roan", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_breton_sealbrown"] = {color = "Seal Brown", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_breton_sorrel"] = {color = "Sorrel", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_breton_steelgrey"] = {color = "Steel Grey", cashPrice = 950, goldPrice = 45, sellPrice = 570},
	},
	{
		breed = "Criollo",
		["a_c_horse_criollo_baybrindle"] = {color = "Bay Brindle", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_criollo_bayframeovero"] = {color = "Bay Frame Overo", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_criollo_blueroanovero"] = {color = "Blue Roan Overo", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_criollo_dun"] = {color = "Dun", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_criollo_marblesabino"] = {color = "Marble Sabino", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_criollo_sorrelovero"] = {color = "Sorrel Overo", cashPrice = 550, goldPrice = 26, sellPrice = 330},
	},
	{
		breed = "Dutch Warmblood",
		["a_c_horse_dutchwarmblood_chocolateroan"] = {color = "Chocolate Roan", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_dutchwarmblood_sealbrown"] = {color = "Seal Brown", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_dutchwarmblood_sootybuckskin"] = {color = "Sooty Buckskin", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_buell_warvets"] = {color = "Cremello Gold", cashPrice = 600, goldPrice = 29, sellPrice = 360},
	},
	{
		breed = "Gypsy Cob",
		["a_c_horse_gypsycob_palominoblagdon"] = {color = "Palomino Blagdon", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_gypsycob_piebald"] = {color = "Piebald", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_gypsycob_skewbald"] = {color = "Skewbald", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_gypsycob_splashedbay"] = {color = "Splashed Bay", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_gypsycob_splashedpiebald"] = {color = "Splashed Piebald", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_gypsycob_whiteblagdon"] = {color = "White Blagdon", cashPrice = 150, goldPrice = 7, sellPrice = 90},
	},
	{
		breed = "Hungarian Halfbred",
		["a_c_horse_hungarianhalfbred_darkdapplegrey"] = {color = "Dapple Dark Grey", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_hungarianhalfbred_liverchestnut"] = {color = "Liver Chestnut", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_hungarianhalfbred_flaxenchestnut"] = {color = "Flaxen Chestnut", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_hungarianhalfbred_piebaldtobiano"] = {color = "Piebald Tobiano", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		breed = "Kentucky Saddler",
		["a_c_horse_kentuckysaddle_buttermilkbuckskin_pc"] = {color = "Buttermilk Buckskin", cashPrice = 240, goldPrice = 11, sellPrice = 144},
		["a_c_horse_kentuckysaddle_black"] = {color = "Black", cashPrice = 50, goldPrice = 2, sellPrice = 30},
		["a_c_horse_kentuckysaddle_chestnutpinto"] = {color = "Chestnut Pinto", cashPrice = 50, goldPrice = 2, sellPrice = 30},
		["a_c_horse_kentuckysaddle_grey"] = {color = "Grey", cashPrice = 50, goldPrice = 2, sellPrice = 30},
		["a_c_horse_kentuckysaddle_silverbay"] = {color = "Silver Bay", cashPrice = 50, goldPrice = 2, sellPrice = 30},
	},
	{
		breed = "Kladruber",
		["a_c_horse_kladruber_black"] = {color = "Black", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_kladruber_cremello"] = {color = "Cremello", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_kladruber_dapplerosegrey"] = {color = "Dapple Rose Grey", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_kladruber_grey"] = {color = "Grey", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_kladruber_silver"] = {color = "Silver", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_kladruber_white"] = {color = "White", cashPrice = 150, goldPrice = 7, sellPrice = 90},
	},
	{
		breed = "Missouri Fox Trotter",
		["a_c_horse_missourifoxtrotter_amberchampagne"] = {color = "Amber Champagne", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_missourifoxtrotter_sablechampagne"] = {color = "Sable Champagne", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_missourifoxtrotter_silverdapplepinto"] = {color = "Silver Dapple Pinto", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_missourifoxtrotter_blacktovero"] = {color = "Black Tovero", cashPrice = 1125, goldPrice = 54, sellPrice = 675},
		["a_c_horse_missourifoxtrotter_blueroan"] = {color = "Blue Roan", cashPrice = 1125, goldPrice = 54, sellPrice = 675},
		["a_c_horse_missourifoxtrotter_buckskinbrindle"] = {color = "Buckskin Brindle", cashPrice = 1125, goldPrice = 54, sellPrice = 675},
		["a_c_horse_missourifoxtrotter_dapplegrey"] = {color = "Dapple Grey", cashPrice = 1125, goldPrice = 54, sellPrice = 675},
	},
	{
		breed = "Morgan",
		["a_c_horse_morgan_palomino"] = {color = "Palomino", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["a_c_horse_morgan_bay"] = {color = "Bay", cashPrice = 55, goldPrice = 2, sellPrice = 33},
		["a_c_horse_morgan_bayroan"] = {color = "Bay Roan", cashPrice = 55, goldPrice = 2, sellPrice = 33},
		["a_c_horse_morgan_flaxenchestnut"] = {color = "Flaxen Chestnut", cashPrice = 55, goldPrice = 2, sellPrice = 33},
		["a_c_horse_morgan_liverchestnut_pc"] = {color = "Liver Chestnut", cashPrice = 55, goldPrice = 2, sellPrice = 33},
	},
	{
		breed = "Mustang",
		["a_c_horse_mustang_goldendun"] = {color = "Golden Dun", cashPrice = 500, goldPrice = 24, sellPrice = 300},
		["a_c_horse_mustang_tigerstripedbay"] = {color = "Tiger Striped Bay", cashPrice = 350, goldPrice = 16, sellPrice = 210},
		["a_c_horse_mustang_grullodun"] = {color = "Grullo Dun", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_mustang_wildbay"] = {color = "Wild Bay", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_mustang_blackovero"] = {color = "Black Overo", cashPrice = 500, goldPrice = 24, sellPrice = 300},
		["a_c_horse_mustang_buckskin"] = {color = "Buckskin", cashPrice = 500, goldPrice = 24, sellPrice = 300},
		["a_c_horse_mustang_chestnuttovero"] = {color = "Chestnut Tovero", cashPrice = 500, goldPrice = 24, sellPrice = 300},
		["a_c_horse_mustang_reddunovero"] = {color = "Red Dun Overo", cashPrice = 500, goldPrice = 24, sellPrice = 300},
	},
	{
		breed = "Nokota",
		["a_c_horse_nokota_reversedappleroan"] = {color = "Reverse Dapple Roan", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_nokota_blueroan"] = {color = "Blue Roan", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_nokota_whiteroan"] = {color = "White Roan", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		breed = "Norfolk Roadster",
		["a_c_horse_norfolkroadster_black"] = {color = "Black", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_norfolkroadster_dappledbuckskin"] = {color = "Dappled Buckskin", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_norfolkroadster_piebaldroan"] = {color = "Piebald Roan", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_norfolkroadster_rosegrey"] = {color = "Rose Grey", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_norfolkroadster_speckledgrey"] = {color = "Speckled Grey", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_norfolkroadster_spottedtricolor"] = {color = "Spotted Tricolor", cashPrice = 950, goldPrice = 45, sellPrice = 570},
	},
	{
		breed = "Shire",
		["a_c_horse_shire_lightgrey"] = {color = "Light Grey", cashPrice = 120, goldPrice = 5, sellPrice = 72},
		["a_c_horse_shire_ravenblack"] = {color = "Raven Black", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_shire_darkbay"] = {color = "Dark Bay", cashPrice = 120, goldPrice = 5, sellPrice = 72},
	},
	{
		breed = "Suffolk Punch",
		["a_c_horse_suffolkpunch_redchestnut"] = {color = "Red Chestnut", cashPrice = 120, goldPrice = 5, sellPrice = 72},
		["a_c_horse_suffolkpunch_sorrel"] = {color = "Sorrel", cashPrice = 120, goldPrice = 5, sellPrice = 72},
	},
	{
		breed = "Tennessee Walker",
		["a_c_horse_tennesseewalker_flaxenroan"] = {color = "Flaxen Roan", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_tennesseewalker_blackrabicano"] = {color = "Black Rabicano", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["a_c_horse_tennesseewalker_chestnut"] = {color = "Chestnut", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["a_c_horse_tennesseewalker_dapplebay"] = {color = "Dapple Bay", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["a_c_horse_tennesseewalker_mahoganybay"] = {color = "Mahogany Bay", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["a_c_horse_tennesseewalker_redroan"] = {color = "Red Roan", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["a_c_horse_tennesseewalker_goldpalomino_pc"] = {color = "Gold Palomino", cashPrice = 60, goldPrice = 3, sellPrice = 36},
	},
	{
		breed = "Thoroughbred",
		["a_c_horse_thoroughbred_blackchestnut"] = {color = "Black Chestnut", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_thoroughbred_bloodbay"] = {color = "Blood Bay", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_thoroughbred_brindle"] = {color = "Brindle", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_thoroughbred_reversedappleblack"] = {color = "Dapple Black", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_thoroughbred_dapplegrey"] = {color = "Dapple Grey", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		breed = "Turkoman",
		["a_c_horse_turkoman_gold"] = {color = "Gold", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_turkoman_silver"] = {color = "Silver", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_turkoman_darkbay"] = {color = "Dark Bay", cashPrice = 925, goldPrice = 44, sellPrice = 555},
		["a_c_horse_turkoman_black"] = {color = "Black", cashPrice = 1000, goldPrice = 48, sellPrice = 600},
		["a_c_horse_turkoman_chestnut"] = {color = "Chestnut", cashPrice = 1000, goldPrice = 48, sellPrice = 600},
		["a_c_horse_turkoman_grey"] = {color = "Grey", cashPrice = 1000, goldPrice = 48, sellPrice = 600},
		["a_c_horse_turkoman_perlino"] = {color = "Perlino", cashPrice = 1000, goldPrice = 48, sellPrice = 600},
	},
	{
		breed = "Other",
		["a_c_horsemule_01"] = {color = "Mule", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["a_c_horsemulepainted_01"] = {color = "Zebra", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["a_c_donkey_01"] = {color = "Donkey", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["a_c_horse_mp_mangy_backup"] = {color = "Mangy", cashPrice = 15, goldPrice = 1, sellPrice = 9},
	}
}

--[[--------BLIP_COLORS----------
LIGHT_BLUE    = 'BLIP_MODIFIER_MP_COLOR_1',
DARK_RED      = 'BLIP_MODIFIER_MP_COLOR_2',
PURPLE        = 'BLIP_MODIFIER_MP_COLOR_3',
ORANGE        = 'BLIP_MODIFIER_MP_COLOR_4',
TEAL          = 'BLIP_MODIFIER_MP_COLOR_5',
LIGHT_YELLOW  = 'BLIP_MODIFIER_MP_COLOR_6',
PINK          = 'BLIP_MODIFIER_MP_COLOR_7',
GREEN         = 'BLIP_MODIFIER_MP_COLOR_8',
DARK_TEAL     = 'BLIP_MODIFIER_MP_COLOR_9',
RED           = 'BLIP_MODIFIER_MP_COLOR_10',
LIGHT_GREEN   = 'BLIP_MODIFIER_MP_COLOR_11',
TEAL2         = 'BLIP_MODIFIER_MP_COLOR_12',
BLUE          = 'BLIP_MODIFIER_MP_COLOR_13',
DARK_PUPLE    = 'BLIP_MODIFIER_MP_COLOR_14',
DARK_PINK     = 'BLIP_MODIFIER_MP_COLOR_15',
DARK_DARK_RED = 'BLIP_MODIFIER_MP_COLOR_16',
GRAY          = 'BLIP_MODIFIER_MP_COLOR_17',
PINKISH       = 'BLIP_MODIFIER_MP_COLOR_18',
YELLOW_GREEN  = 'BLIP_MODIFIER_MP_COLOR_19',
DARK_GREEN    = 'BLIP_MODIFIER_MP_COLOR_20',
BRIGHT_BLUE   = 'BLIP_MODIFIER_MP_COLOR_21',
BRIGHT_PURPLE = 'BLIP_MODIFIER_MP_COLOR_22',
YELLOW_ORANGE = 'BLIP_MODIFIER_MP_COLOR_23',
BLUE2         = 'BLIP_MODIFIER_MP_COLOR_24',
TEAL3         = 'BLIP_MODIFIER_MP_COLOR_25',
TAN           = 'BLIP_MODIFIER_MP_COLOR_26',
OFF_WHITE     = 'BLIP_MODIFIER_MP_COLOR_27',
LIGHT_YELLOW2 = 'BLIP_MODIFIER_MP_COLOR_28',
LIGHT_PINK    = 'BLIP_MODIFIER_MP_COLOR_29',
LIGHT_RED     = 'BLIP_MODIFIER_MP_COLOR_30',
LIGHT_YELLOW3 = 'BLIP_MODIFIER_MP_COLOR_31',
WHITE         = 'BLIP_MODIFIER_MP_COLOR_32']]
