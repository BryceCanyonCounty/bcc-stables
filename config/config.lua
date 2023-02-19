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
		["A_C_Horse_Arabian_White"] = {version = "White", cashPrice = 1500, goldPrice = 72, sellPrice = 900},
		["A_C_Horse_Arabian_RoseGreyBay"] = {version = "Rose Grey Bay", cashPrice = 1350, goldPrice = 65, sellPrice = 810},
		["A_C_Horse_Arabian_Black"] = {version = "Black", cashPrice = 1250, goldPrice = 60, sellPrice = 750},
		["A_C_Horse_Arabian_Grey"] = {version = "Grey", cashPrice = 1150, goldPrice = 55, sellPrice = 690},
		["A_C_Horse_Arabian_WarpedBrindle_PC"] = {version = "Warped Brindle", cashPrice = 650, goldPrice = 31, sellPrice = 390},
		["A_C_Horse_Arabian_RedChestnut"] = {version = "Red Chestnut", cashPrice = 350, goldPrice = 16, sellPrice = 210},
	},
	{
		name = "Ardennes",
		["A_C_Horse_Ardennes_IronGreyRoan"] = {version = "Iron Grey Roan", cashPrice = 1200, goldPrice = 58, sellPrice = 720},
		["A_C_Horse_Ardennes_StrawberryRoan"] = {version = "Strawberry Roan", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["A_C_Horse_Ardennes_BayRoan"] = {version = "Bay Roan", cashPrice = 140, goldPrice = 6, sellPrice = 84},
	},
	{
		name = "Missouri Fox Trotter",
		["A_C_Horse_MissouriFoxTrotter_AmberChampagne"] = {version = "Amber Champagne", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["A_C_Horse_MissouriFoxTrotter_SableChampagne"] = {version = "Sable Champagne", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["A_C_Horse_MissouriFoxTrotter_SilverDapplePinto"] = {version = "Silver Dapple Pinto", cashPrice = 950, goldPrice = 45, sellPrice = 570},
	},
	{
		name = "Turkoman",
		["A_C_Horse_Turkoman_Gold"] = {version = "Gold", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["A_C_Horse_Turkoman_Silver"] = {version = "Silver", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["A_C_Horse_Turkoman_DarkBay"] = {version = "Dark Bay", cashPrice = 925, goldPrice = 44, sellPrice = 555},
	},
	{
		name = "Appaloosa",
		["A_C_Horse_Appaloosa_BlackSnowflake"] = {version = "Snow Flake", cashPrice = 900, goldPrice = 43, sellPrice = 540},
		["A_C_Horse_Appaloosa_BrownLeopard"] = {version = "Brown Leopard", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["A_C_Horse_Appaloosa_Leopard"] = {version = "Leopard", cashPrice = 430, goldPrice = 20, sellPrice = 258},
		["A_C_Horse_Appaloosa_FewSpotted_PC"] = {version = "Few Spotted", cashPrice = 140, goldPrice = 6, sellPrice = 84},
		["A_C_Horse_Appaloosa_Blanket"] = {version = "Blanket", cashPrice = 200, goldPrice = 9, sellPrice = 120},
		["A_C_Horse_Appaloosa_LeopardBlanket"] = {version = "Lepard Blanket", cashPrice = 130, goldPrice = 6, sellPrice =78},
	},
	{
		name = "Mustang",
		["A_C_Horse_Mustang_GoldenDun"] = {version = "Golden Dun", cashPrice = 950, goldPrice = 45, sellPrice = 570},
		["A_C_Horse_Mustang_TigerStripedBay"] = {version = "Tiger Striped Bay", cashPrice = 350, goldPrice = 16, sellPrice = 210},
		["A_C_Horse_Mustang_GrulloDun"] = {version = "Grullo Dun", cashPrice = 130, 6, sellPrice = 78},
		["A_C_Horse_Mustang_WildBay"] = {version = "Wild Bay", cashPrice = 130, 6, sellPrice = 78},
	},
	{
		name = "Thoroughbred",
		["A_C_Horse_Thoroughbred_BlackChestnut"] = {version = "Black Chestnut", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["A_C_Horse_Thoroughbred_BloodBay"] = {version = "Blood Bay", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["A_C_Horse_Thoroughbred_Brindle"] = {version = "Brindle", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["A_C_Horse_Thoroughbred_ReverseDappleBlack"] = {version = "Reverse Dapple Black", cashPrice = 550, goldPrice = 26, sellPrice = 330},
		["A_C_Horse_Thoroughbred_DappleGrey"] = {version = "Dapple Grey", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		name = "Andalusian",
		["A_C_Horse_Andalusian_Perlino"] = {version = "Perlino", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["A_C_Horse_Andalusian_RoseGray"] = {version = "Rose Gray", cashPrice = 440, goldPrice = 21, sellPrice = 264},
		["A_C_Horse_Andalusian_DarkBay"] = {version = "Dark Bay", cashPrice = 140, goldPrice = 6, sellPrice = 84},
	},
	{
		name = "Dutch Warmblood",
		["A_C_Horse_DutchWarmblood_ChocolateRoan"] = {version = "Chocolate Roan", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["A_C_Horse_DutchWarmblood_SealBrown"] = {version = "Seal Brown", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["A_C_Horse_DutchWarmblood_SootyBuckskin"] = {version = "Sooty Buckskin", cashPrice = 150, goldPrice = 7, sellPrice = 90},
	},
	{
		name = "Nokota",
		["A_C_Horse_Nokota_ReverseDappleRoan"] = {version = "Reverse Dapple Roan", cashPrice = 450, goldPrice = 21, sellPrice = 270},
		["A_C_Horse_Nokota_BlueRoan"] = {version = "Blue Roan", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["A_C_Horse_Nokota_WhiteRoan"] = {version = "White Roan", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		name = "American Paint",
		["A_C_Horse_AmericanPaint_Greyovero"] = {version = "Grey Overo", cashPrice = 425, goldPrice = 20, sellPrice = 255},
		["A_C_Horse_AmericanPaint_SplashedWhite"] = {version = "Splashed White", cashPrice = 140, goldPrice = 6, sellPrice = 84},
		["A_C_Horse_AmericanPaint_Tobiano"] = {version = "Tobiano", cashPrice = 140, goldPrice = 6, sellPrice = 84},
		["A_C_Horse_AmericanPaint_Overo"] = {version = "Overo", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		name = "American Standardbred",
		["A_C_Horse_AmericanStandardbred_SilverTailBuckskin"] = {version = "Silver Tail Buckskin", cashPrice = 400, goldPrice = 19, sellPrice = 240},
		["A_C_Horse_AmericanStandardbred_PalominoDapple"] = {version = "Palomino Dapple", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["A_C_Horse_AmericanStandardbred_Black"] = {version = "Black", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["A_C_Horse_AmericanStandardbred_Buckskin"] = {version = "Buckskin", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		name = "Kentucky Saddle",
		["A_C_Horse_KentuckySaddle_ButterMilkBuckskin_PC"] = {version = "Butter Milk Buckskin", cashPrice = 240, goldPrice = 11, sellPrice = 144},
		["A_C_Horse_KentuckySaddle_Black"] = {version = "Black", cashPrice = 50, goldPrice = 2, sellPrice = 30},
		["A_C_Horse_KentuckySaddle_ChestnutPinto"] = {version = "Chestnut Pinto", cashPrice = 50, goldPrice = 2, sellPrice = 30},
		["A_C_Horse_KentuckySaddle_Grey"] = {version = "Grey", cashPrice = 50, goldPrice = 2, sellPrice = 30},
		["A_C_Horse_KentuckySaddle_SilverBay"] = {version = "Silver Bay", cashPrice = 50, goldPrice = 2, sellPrice = 30},
	},
	{
		name = "Hungarian Halfbred",
		["A_C_Horse_HungarianHalfbred_DarkDappleGrey"] = {version = "Dark Dapple Grey", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["A_C_Horse_HungarianHalfbred_LiverChestnut"] = {version = "Liver Chestnut", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["A_C_Horse_HungarianHalfbred_FlaxenChestnut"] = {version = "Flaxen Chestnut", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["A_C_Horse_HungarianHalfbred_PiebaldTobiano"] = {version = "Piebald Tobiano", cashPrice = 130, goldPrice = 6, sellPrice = 78},
	},
	{
		name = "Suffolk Punch",
		["A_C_Horse_SuffolkPunch_RedChestnut"] = {version = "Red Chestnut", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["A_C_Horse_SuffolkPunch_Sorrel"] = {version = "Sorrel", cashPrice = 120, goldPrice = 5, sellPrice = 72},
	},
	{
		name = "Tennessee Walker",
		["A_C_Horse_TennesseeWalker_FlaxenRoan"] = {version = "Flaxen Roan", cashPrice = 150, goldPrice = 7, sellPrice = 90},
		["A_C_Horse_TennesseeWalker_BlackRabicano"] = {version = "Black Rabicano", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["A_C_Horse_TennesseeWalker_Chestnut"] = {version = "Chestnut", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["A_C_Horse_TennesseeWalker_DappleBay"] = {version = "Dapple Bay", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["A_C_Horse_TennesseeWalker_MahoganyBay"] = {version = "Mahogany Bay", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["A_C_Horse_TennesseeWalker_RedRoan"] = {version = "Red Roan", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["A_C_Horse_TennesseeWalker_GoldPalomino_PC"] = {version = "Gold Palomino", cashPrice = 60, goldPrice = 3, sellPrice = 36},
	},
	{
		name = "Shire",
		["A_C_Horse_Shire_LightGrey"] = {version = "Light Grey", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["A_C_Horse_Shire_RavenBlack"] = {version = "Raven Black", cashPrice = 130, goldPrice = 6, sellPrice = 78},
		["A_C_Horse_Shire_DarkBay"] = {version = "Dark Bay", cashPrice = 120, goldPrice = 5, sellPrice = 72},
	},
	{
		name = "Belgian Draft",
		["A_C_Horse_Belgian_BlondChestnut"] = {version = "Blond Chestnut", cashPrice = 120, goldPrice = 5, sellPrice = 72},
		["A_C_Horse_Belgian_MealyChestnut"] = {version = "Mealy Chestnut", cashPrice = 120, goldPrice = 5, sellPrice = 72},
	},
	{
		name = "Morgan",
		["A_C_Horse_Morgan_Palomino"] = {version = "Palomino", cashPrice = 60, goldPrice = 3, sellPrice = 36},
		["A_C_Horse_Morgan_Bay"] = {version = "Bay", cashPrice = 55, goldPrice = 2, sellPrice = 33},
		["A_C_Horse_Morgan_BayRoan"] = {version = "Bay Roan", cashPrice = 55, goldPrice = 2, sellPrice = 33},
		["A_C_Horse_Morgan_FlaxenChestnut"] = {version = "Flaxen Chestnut", cashPrice = 55, goldPrice = 2, sellPrice = 33},
		["A_C_Horse_Morgan_LiverChestnut_PC"] = {version = "Liver Chestnut", cashPrice = 55, goldPrice = 2, sellPrice = 33},
	},
	{
		name = "Other",
		["A_C_Horse_Gang_Dutch"] = {version = "Gang Duch", cashPrice = 3000, goldPrice = 145, sellPrice = 1800},
		["A_C_HorseMule_01"] = {version = "Mule", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["A_C_HorseMulePainted_01"] = {version = "Zebra", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["A_C_Donkey_01"] = {version = "Donkey", cashPrice = 15, goldPrice = 1, sellPrice = 9},
		["A_C_Horse_MP_Mangy_Backup"] = {version = "Mangy Backup", cashPrice = 15, goldPrice = 1, sellPrice = 9},
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
