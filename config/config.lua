Config = {}
-- Set Language
Config.defaultlang = "en_lang"
-- Open Stable Menu
Config.shopKey = 0x760A9C6F --[G]
-- Return Horse at Stable
Config.returnKey = 0xD9D0E1C0 --[spacebar]
-- Max Number of Horses per Player
Config.maxHorses = 5 -- Default: 5
-- Stables
Config.stables = {
    valentine = {
        promptName = "Valentine Stable", -- Text Below the Prompt Button
        blipAllowed = true, -- Turns Blips On / Off
        blipName = "Valentine Stable", -- Name of the Blip on the Map
        blipSprite = "blip_shop_horse",
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32", -- Shop Open - Blip Colors Shown Below
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10", -- Shop Closed - Blip Colors Shown Below
        distanceShop = 3.0, -- Distance from NPC to Get Menu Prompt
        npcAllowed = true, -- Turns NPCs On / Off
        npcModel = "A_M_M_UniBoatCrew_01", -- Sets Model for NPCs
        npcx = -365.08, npcy = 791.21, npcz = 116.18, npch = 179.76, -- Location for NPC
		stablex = -367.73, stabley = 787.72, stablez = 116.26,
        allowedJobs = {}, -- Empty, Everyone Can Use / Insert Job to limit access - ex. "police"
        jobGrade = 0, -- Enter Minimum Rank / Job Grade to Access Shop
        shopHours = false, -- If You Want the Shops to Use Open and Closed Hours
        shopOpen = 7, -- Shop Open Time / 24 Hour Clock
        shopClose = 21, -- Shop Close Time / 24 Hour Clock
        Heading = -30.65,
		SpawnPoint = {
			Pos = vector3(-372.43, 791.79, 116.13),
			CamPos = {x=1, y=-3, z=0},
			Heading = 182.3
        }
    },
    blackwater = {
        promptName = "Blackwater Stable",
        blipAllowed = true,
        blipName = "Blackwater Stable",
        blipSprite = "blip_shop_horse",
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        distanceShop = 3.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = -871.0, npcy = -1369.63, npcz = 43.53, npch = 6.64,
		stablex = -864.84, stabley = -1365.96, stablez = 43.54,
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        Heading = -30.65,
		SpawnPoint = {
			Pos = vector3(-867.74, -1361.69, 43.66),
			CamPos = {x=1, y=-3, z=0},
			Heading = 178.59
        }
    },
    saintdenis = {
        promptName = "Saint Denis Stable",
        blipAllowed = true,
        blipName = "Saint Denis Stable",
        blipSprite = "blip_shop_horse",
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        distanceShop = 3.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = 2512.33, npcy = -1457.1, npcz = 46.31, npch = 99.45,
		stablex = 2503.13, stabley = -1449.08, stablez = 46.3,
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        Heading = -30.65,
		SpawnPoint = {
			Pos = vector3(2508.41, -1446.89, 46.4),
			CamPos = {x=1, y=-3, z=0},
			Heading = 87.88
        }
    },
    annesburg = {
        promptName = "Annesburg Stable",
        blipAllowed = true,
        blipName = "Annesburg Stable",
        blipSprite = "blip_shop_horse",
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        distanceShop = 3.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = 2973.51, npcy = 1427.27, npcz = 44.71, npch = 192.53,
		stablex = 2972.35, stabley = 1425.35, stablez = 44.67,
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        Heading = -30.65,
		SpawnPoint = {
			Pos = vector3(2970.43, 1429.35, 44.7),
			CamPos = {x=1, y=-3, z=0},
			Heading = 223.94
        }
    },
    rhodes = {
        promptName = "Rhodes Stable",
        blipAllowed = true,
        blipName = "Rhodes Stable",
        blipSprite = "blip_shop_horse",
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        distanceShop = 3.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = 1319.5, npcy = -1360.52, npcz = 78.21, npch = 351.46,
		stablex = 1321.46, stabley = -1358.66, stablez = 78.39,
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        Heading = -30.65,
		SpawnPoint = {
			Pos = vector3(1318.74, -1354.64, 78.18),
			CamPos = {x=1, y=-3, z=0},
			Heading = 249.45
        }
    },
    tumbleweed = {
        promptName = "Tumbleweed Stable",
        blipAllowed = true,
        blipName = "Tumbleweed Stable",
        blipSprite = "blip_shop_horse",
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        distanceShop = 3.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = -5515.2, npcy = -3040.17, npcz = -2.39, npch = 180.76,
		stablex = -5519.43, stabley = -3043.45, stablez = -2.39,
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        Heading = 0.0,
		SpawnPoint = {
			Pos = vector3(-5522.14, -3039.16, -2.29),
			CamPos = {x=1, y=-3, z=0},
			Heading = 189.93
        }
    }
}

Config.Horses = { -- Gold to Dollar Ratio Based on 1899 Gold Price / sellPrice is 60% of cashPrice
	{
		name = "Arabian",
		["a_c_horse_arabian_white"] = {version = "White", cashPrice = 1500, goldPrice = 72, sellPrice = 900},
		["a_c_horse_arabian_rosegreybay"] = {version = "Rose Grey Bay", cashPrice = 1350, goldPrice = 65, sellPrice = 810},
		["a_c_horse_arabian_black"] = {version = "Black", cashPrice = 1250, goldPrice = 60, sellPrice = 750},
		["a_c_horse_arabian_grey"] = {version = "Grey", cashPrice = 1150, goldPrice = 55, sellPrice = 690},
		["a_c_horse_arabian_warpedbrindle_pc"] = {version = "Warped Brindle", cashPrice = 650, goldPrice = 31, sellPrice = 390},
		["a_c_horse_arabian_redchestnut"] = {version = "Red Chestnut", cashPrice = 350, goldPrice = 16, sellPrice = 210},
		["a_c_horse_arabian_redchestnut_pc"] = {version = "Red Chestnut II", cashPrice = 350, goldPrice = 16, sellPrice = 210},
	},
	{
		name = "Ardennes",
		["a_c_horse_ardennes_irongreyroan"] = {version = "Iron Grey Roan", cashPrice = 1200, goldPrice = 58, sellPrice = 720},
		["a_c_horse_ardennes_strawberryroan"] = {version = "Strawberry Roan", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_ardennes_bayroan"] = {version = "Bay Roan", cashPrice = 140, goldPrice = 6, sellPrice = 84},
	},
	{
		name = "Missouri Fox Trotter",
		["a_c_horse_missourifoxtrotter_amberchampagne"] = {version = "Amber Champagne", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_missourifoxtrotter_sablechampagne"] = {version = "Sable Champagne", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_missourifoxtrotter_silverdapplepinto"] = {version = "Silver Dapple Pinto", cashPrice = 950, goldPrice = 45, sellPrice = 570},
	},
	{
		name = "Turkoman",
		["a_c_horse_turkoman_gold"] = {version = "Gold", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_turkoman_silver"] = {version = "Silver", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_turkoman_darkbay"] = {version = "Dark Bay", cashPrice = 925, goldPrice = 44, sellPrice = 555},
	},
	{
		name = "Appaloosa",
		["a_c_horse_appaloosa_blacksnowflake"] = {version = "Snow Flake", cashPrice = 900, goldPrice = 43, sellPrice = 540},
		["a_c_horse_appaloosa_brownleopard"] = {version = "Brown Leopard", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_appaloosa_leopard"] = {version = "Leopard", cashPrice = 430, goldPrice = 20, sellPrice = 258},
		["a_c_horse_appaloosa_fewspotted_pc"] = {version = "Few Spotted", cashPrice = 140, goldPrice = 6, sellPrice = 84},
		["a_c_horse_appaloosa_blanket"] = {version = "Blanket", cashPrice = 200, goldPrice = 9, sellPrice = 120},
		["a_c_horse_appaloosa_leopardblanket"] = {version = "Lepard Blanket", cashPrice = 130, goldPrice = 6, sellPrice =78},
	},
	{
		name = "Mustang",
		["a_c_horse_mustang_goldendun"] = {version = "Buckskin", cashPrice = 500, goldPrice = 24, sellPrice = 300},
		["a_c_horse_mustang_tigerstripedbay"] = {version = "Tiger Striped Bay", cashPrice = 350, goldPrice = 16, sellPrice = 210},
		["a_c_horse_mustang_grullodun"] = {version = "Grullo Dun", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_mustang_wildbay"] = {version = "Wild Bay", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		name = "Thoroughbred",
		["a_c_horse_thoroughbred_blackchestnut"] = {version = "Black Chestnut", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_thoroughbred_bloodbay"] = {version = "Blood Bay", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_thoroughbred_brindle"] = {version = "Brindle", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_thoroughbred_reversedappleblack"] = {version = "Dapple Black", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_thoroughbred_dapplegrey"] = {version = "Dapple Grey", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		name = "Andalusian",
		["a_c_horse_andalusian_perlino"] = {version = "Perlino", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_andalusian_rosegray"] = {version = "Rose Gray", cashPrice = 440, goldPrice = 21, sellPrice = 264},
		["a_c_horse_andalusian_darkbay"] = {version = "Dark Bay", cashPrice = 140, goldPrice = 6, sellPrice = 84},
	},
	{
		name = "Dutch Warmblood",
		["a_c_horse_dutchwarmblood_chocolateroan"] = {version = "Chocolate Roan", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_dutchwarmblood_sealbrown"] = {version = "Seal Brown", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_dutchwarmblood_sootybuckskin"] = {version = "Sooty Buckskin", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_buell_warvets"] = {version = "Cremello Gold", cashPrice = 600, goldPrice = 29, sellPrice = 360},
	},
	{
		name = "Nokota",
		["a_c_horse_nokota_reversedappleroan"] = {version = "Reverse Dapple Roan", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["a_c_horse_nokota_blueroan"] = {version = "Blue Roan", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_nokota_whiteroan"] = {version = "White Roan", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		name = "American Paint",
		["a_c_horse_americanpaint_greyovero"] = {version = "Grey Overo", cashPrice = 425, goldPrice = 20, sellPrice = 255},
		["a_c_horse_americanpaint_splashedwhite"] = {version = "Splashed White", cashPrice = 140, goldPrice = 6, sellPrice = 84},
		["a_c_horse_americanpaint_tobiano"] = {version = "Tobiano", cashPrice = 140, goldPrice = 6, sellPrice = 84},
		["a_c_horse_americanpaint_overo"] = {version = "Overo", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		name = "American Standardbred",
		["a_c_horse_americanstandardbred_silvertailbuckskin"] = {version = "Silver Tail Buckskin", cashPrice = 400, goldPrice = 19, sellPrice = 240},
		["a_c_horse_americanstandardbred_palominodapple"] = {version = "Palomino Dapple", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_americanstandardbred_black"] = {version = "Black", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_americanstandardbred_buckskin"] = {version = "Buckskin", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_americanstandardbred_lightbuckskin"] = {version = "Light Buckskin", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		name = "Kentucky Saddler",
		["a_c_horse_kentuckysaddle_buttermilkbuckskin_pc"] = {version = "Buttermilk Buckskin", cashPrice = 240, goldPrice = 11, sellPrice = 144},
		["a_c_horse_kentuckysaddle_black"] = {version = "Black", cashPrice = 50, goldPrice = 2, sellPrice = 30},
		["a_c_horse_kentuckysaddle_chestnutpinto"] = {version = "Chestnut Pinto", cashPrice = 50, goldPrice = 2, sellPrice = 30},
		["a_c_horse_kentuckysaddle_grey"] = {version = "Grey", cashPrice = 50, goldPrice = 2, sellPrice = 30},
		["a_c_horse_kentuckysaddle_silverbay"] = {version = "Silver Bay", cashPrice = 50, goldPrice = 2, sellPrice = 30},
	},
	{
		name = "Hungarian Halfbred",
		["a_c_horse_hungarianhalfbred_darkdapplegrey"] = {version = "Dapple Dark Grey", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_hungarianhalfbred_liverchestnut"] = {version = "Liver Chestnut", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_hungarianhalfbred_flaxenchestnut"] = {version = "Flaxen Chestnut", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_hungarianhalfbred_piebaldtobiano"] = {version = "Piebald Tobiano", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		name = "Suffolk Punch",
		["a_c_horse_suffolkpunch_redchestnut"] = {version = "Red Chestnut", cashPrice = 120, goldPrice = 5, sellPrice = 72},
		["a_c_horse_suffolkpunch_sorrel"] = {version = "Sorrel", cashPrice = 120, goldPrice = 5, sellPrice = 72},
	},
	{
		name = "Tennessee Walker",
		["a_c_horse_tennesseewalker_flaxenroan"] = {version = "Flaxen Roan", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_tennesseewalker_blackrabicano"] = {version = "Black Rabicano", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["a_c_horse_tennesseewalker_chestnut"] = {version = "Chestnut", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["a_c_horse_tennesseewalker_dapplebay"] = {version = "Dapple Bay", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["a_c_horse_tennesseewalker_mahoganybay"] = {version = "Mahogany Bay", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["a_c_horse_tennesseewalker_redroan"] = {version = "Red Roan", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["a_c_horse_tennesseewalker_goldpalomino_pc"] = {version = "Gold Palomino", cashPrice = 60, goldPrice = 3, sellPrice = 36},
	},
	{
		name = "Shire",
		["a_c_horse_shire_lightgrey"] = {version = "Light Grey", cashPrice = 120, goldPrice = 5, sellPrice = 72},
		["a_c_horse_shire_ravenblack"] = {version = "Raven Black", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["a_c_horse_shire_darkbay"] = {version = "Dark Bay", cashPrice = 120, goldPrice = 5, sellPrice = 72},
	},
	{
		name = "Belgian Draft",
		["a_c_horse_belgian_blondchestnut"] = {version = "Blond Chestnut", cashPrice = 120, goldPrice = 5, sellPrice = 72},
		["a_c_horse_belgian_mealychestnut"] = {version = "Mealy Chestnut", cashPrice = 120, goldPrice = 5, sellPrice = 72},
	},
	{
		name = "Morgan",
		["a_c_horse_morgan_palomino"] = {version = "Palomino", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["a_c_horse_morgan_bay"] = {version = "Bay", cashPrice = 55, goldPrice = 2, sellPrice = 33},
		["a_c_horse_morgan_bayroan"] = {version = "Bay Roan", cashPrice = 55, goldPrice = 2, sellPrice = 33},
		["a_c_horse_morgan_flaxenchestnut"] = {version = "Flaxen Chestnut", cashPrice = 55, goldPrice = 2, sellPrice = 33},
		["a_c_horse_morgan_liverchestnut_pc"] = {version = "Liver Chestnut", cashPrice = 55, goldPrice = 2, sellPrice = 33},
	},
	{
		name = "Breton",
		["a_c_horse_breton_grullodun"] = {version = "Grullo Dun", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_breton_mealydapplebay"] = {version = "Meally Dapple", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_breton_redroan"] = {version = "Red Roan", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_breton_sealbrown"] = {version = "Seal Brown", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_breton_sorrel"] = {version = "Sorrel", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_breton_steelgrey"] = {version = "Steel Grey", cashPrice = 950, goldPrice = 45, sellPrice = 570},
	},
	{
		name = "Criollo",
		["a_c_horse_criollo_baybrindle"] = {version = "Bay Brindle", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_criollo_bayframeovero"] = {version = "Bay Frame Overo", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_criollo_blueroanovero"] = {version = "Blue Roan Overo", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_criollo_dun"] = {version = "Dun", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_criollo_marblesabino"] = {version = "Marble Sabino", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_criollo_sorrelovero"] = {version = "Sorrel Overo", cashPrice = 550, goldPrice = 26, sellPrice = 330},
	},
	{
		name = "Kladruber",
		["a_c_horse_kladruber_black"] = {version = "Black", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["a_c_horse_kladruber_cremello"] = {version = "Cremello", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_kladruber_dapplerosegrey"] = {version = "Dapple Rose Grey", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_kladruber_grey"] = {version = "Grey", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["a_c_horse_kladruber_silver"] = {version = "Silver", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["a_c_horse_kladruber_white"] = {version = "White", cashPrice = 150, goldPrice = 7, sellPrice = 90},
	},
	{
		name = "Other",
		["a_c_horse_gang_dutch"] = {version = "Gang Dutch", cashPrice = 3000, goldPrice = 145, sellPrice = 1800},
		["a_c_horsemule_01"] = {version = "Mule", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["a_c_horsemulepainted_01"] = {version = "Zebra", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["a_c_donkey_01"] = {version = "Donkey", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["a_c_horse_mp_mangy_backup"] = {version = "Mangy", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["a_c_horse_eagleflies"] = {version = "Eagle Flies", cashPrice = 15, goldPrice = 1, sellPrice = 9},
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
