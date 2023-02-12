Config = {}
-- Set Language
Config.defaultlang = "en_lang"
-- Open Stable Menu
Config.shopKey = 0x760A9C6F --[G]
-- Stables
Config.stables = {
    valentine = {
        Name = "Valentine Stable", -- Name of Shop on Menu
        promptName = "Valentine Stable", -- Text Below the Prompt Button
        blipAllowed = true, -- Turns Blips On / Off
        blipName = "Valentine Stable", -- Name of the Blip on the Map
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32", -- Shop Open - Blip Colors Shown Below
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10", -- Shop Closed - Blip Colors Shown Below
        distanceShop = 2.0, -- Distance from NPC to Get Menu Prompt
        npcAllowed = true, -- Turns NPCs On / Off
        npcModel = "A_M_M_UniBoatCrew_01", -- Sets Model for NPCs
        npcx = -367.73, npcy = 787.72, npcz = 116.26,
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
        Name = "Blackwater Stable",
        promptName = "Blackwater Stable",
        blipAllowed = true,
        blipName = "Blackwater Stable",
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        distanceShop = 2.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = -864.84, npcy = -1365.96, npcz = 43.54,
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
        Name = "Saint Denis Stable",
        promptName = "Saint Denis Stable",
        blipAllowed = true,
        blipName = "Saint Denis Stable",
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        distanceShop = 2.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = 2503.13, npcy = -1449.08, npcz = 46.3,
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
        Name = "Annesburg Stable",
        promptName = "Annesburg Stable",
        blipAllowed = true,
        blipName = "Annesburg Stable",
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        distanceShop = 2.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = 2972.35, npcy = 1425.35, npcz = 44.67,
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
        Name = "Rhodes Stable",
        promptName = "Rhodes Stable",
        blipAllowed = true,
        blipName = "Rhodes Stable",
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        distanceShop = 2.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = 1321.46, npcy = -1358.66, npcz = 78.39,
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
        Name = "Tumbleweed Stable",
        promptName = "Tumbleweed Stable",
        blipAllowed = true,
        blipName = "Tumbleweed Stable",
        blipSprite = 1938782895,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        distanceShop = 2.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        npcx = -5519.43, npcy = -3043.45, npcz = -2.39,
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

Config.Horses = {
	{
		name = "Arabian",
		["A_C_Horse_Arabian_White"] = {"White", 72, 1500},
		["A_C_Horse_Arabian_RoseGreyBay"] = {"Rose Grey Bay", 65, 1350},
		["A_C_Horse_Arabian_Black"] = {"Black", 60, 1250},
		["A_C_Horse_Arabian_Grey"] = {"Grey", 55, 1150},
		["A_C_Horse_Arabian_WarpedBrindle_PC"] = {"Warped Brindle", 31, 650},
		["A_C_Horse_Arabian_RedChestnut"] = {"Red Chestnut", 16, 350},
	},
	{
		name = "Ardennes",
		["A_C_Horse_Ardennes_IronGreyRoan"] = {"Iron Grey Roan", 58, 1200},
		["A_C_Horse_Ardennes_StrawberryRoan"] = {"Strawberry Roan", 21, 450},
		["A_C_Horse_Ardennes_BayRoan"] = {"Bay Roan", 6, 140},
	},
	{
		name = "Missouri Fox Trotter",
		["A_C_Horse_MissouriFoxTrotter_AmberChampagne"] = {"Amber Champagne", 45, 950},
		["A_C_Horse_MissouriFoxTrotter_SableChampagne"] = {"Sable Champagne", 45, 950},
		["A_C_Horse_MissouriFoxTrotter_SilverDapplePinto"] = {"Silver Dapple Pinto", 45, 950},
	},
	{
		name = "Turkoman",
		["A_C_Horse_Turkoman_Gold"] = {"Gold", 45, 950},
		["A_C_Horse_Turkoman_Silver"] = {"Silver", 45, 950},
		["A_C_Horse_Turkoman_DarkBay"] = {"Dark Bay", 44, 925},
	},
	{
		name = "Appaloosa",
		["A_C_Horse_Appaloosa_BlackSnowflake"] = {"Snow Flake", 43, 900},
		["A_C_Horse_Appaloosa_BrownLeopard"] = {"Brown Leopard", 21, 450},
		["A_C_Horse_Appaloosa_Leopard"] = {"Leopard", 20, 430},
		["A_C_Horse_Appaloosa_FewSpotted_PC"] = {"Few Spotted", 6, 140},
		["A_C_Horse_Appaloosa_Blanket"] = {"Blanket", 9, 200},
		["A_C_Horse_Appaloosa_LeopardBlanket"] = {"Lepard Blanket", 6, 130},
	},
	{
		name = "Mustang",
		["A_C_Horse_Mustang_GoldenDun"] = {"Golden Dun", 45, 950},
		["A_C_Horse_Mustang_TigerStripedBay"] = {"Tiger Striped Bay", 16, 350},
		["A_C_Horse_Mustang_GrulloDun"] = {"Grullo Dun", 6, 130},
		["A_C_Horse_Mustang_WildBay"] = {"Wild Bay", 6, 130},
	},
	{
		name = "Thoroughbred",
		["A_C_Horse_Thoroughbred_BlackChestnut"] = {"Black Chestnut", 26, 550},
		["A_C_Horse_Thoroughbred_BloodBay"] = {"Blood Bay", 26, 550},
		["A_C_Horse_Thoroughbred_Brindle"] = {"Brindle", 26, 550},
		["A_C_Horse_Thoroughbred_ReverseDappleBlack"] = {"Reverse Dapple Black", 26, 550},
		["A_C_Horse_Thoroughbred_DappleGrey"] = {"Dapple Grey", 6, 130},
	},
	{
		name = "Andalusian",
		["A_C_Horse_Andalusian_Perlino"] = {"Perlino", 21, 450},
		["A_C_Horse_Andalusian_RoseGray"] = {"Rose Gray", 21, 440},
		["A_C_Horse_Andalusian_DarkBay"] = {"Dark Bay", 6, 140},
	},
	{
		name = "Dutch Warmblood",
		["A_C_Horse_DutchWarmblood_ChocolateRoan"] = {"Chocolate Roan", 21, 450},
		["A_C_Horse_DutchWarmblood_SealBrown"] = {"Seal Brown", 7, 150},
		["A_C_Horse_DutchWarmblood_SootyBuckskin"] = {"Sooty Buckskin", 7, 150},
	},
	{
		name = "Nokota",
		["A_C_Horse_Nokota_ReverseDappleRoan"] = {"Reverse Dapple Roan", 21, 450},
		["A_C_Horse_Nokota_BlueRoan"] = {"Blue Roan", 6, 130},
		["A_C_Horse_Nokota_WhiteRoan"] = {"White Roan", 6, 130},
	},
	{
		name = "American Paint",
		["A_C_Horse_AmericanPaint_Greyovero"] = {"Grey Overo", 20, 425},
		["A_C_Horse_AmericanPaint_SplashedWhite"] = {"Splashed White", 6, 140},
		["A_C_Horse_AmericanPaint_Tobiano"] = {"Tobiano", 6, 140},
		["A_C_Horse_AmericanPaint_Overo"] = {"Overo", 6, 130},
	},
	{
		name = "American Standardbred",
		["A_C_Horse_AmericanStandardbred_SilverTailBuckskin"] = {"Silver Tail Buckskin", 19, 400},
		["A_C_Horse_AmericanStandardbred_PalominoDapple"] = {"Palomino Dapple", 7, 150},
		["A_C_Horse_AmericanStandardbred_Black"] = {"Black", 6, 130},
		["A_C_Horse_AmericanStandardbred_Buckskin"] = {"Buckskin", 6, 130},
	},
	{
		name = "Kentucky Saddle",
		["A_C_Horse_KentuckySaddle_ButterMilkBuckskin_PC"] = {"Butter Milk Buckskin", 11, 240},
		["A_C_Horse_KentuckySaddle_Black"] = {"Black", 2, 50},
		["A_C_Horse_KentuckySaddle_ChestnutPinto"] = {"Chestnut Pinto", 2, 50},
		["A_C_Horse_KentuckySaddle_Grey"] = {"Grey", 2, 50},
		["A_C_Horse_KentuckySaddle_SilverBay"] = {"Silver Bay", 2, 50},
	},
	{
		name = "Hungarian Halfbred",
		["A_C_Horse_HungarianHalfbred_DarkDappleGrey"] = {"Dark Dapple Grey", 7, 150},
		["A_C_Horse_HungarianHalfbred_LiverChestnut"] = {"Liver Chestnut", 7, 150},
		["A_C_Horse_HungarianHalfbred_FlaxenChestnut"] = {"Flaxen Chestnut", 6, 130},
		["A_C_Horse_HungarianHalfbred_PiebaldTobiano"] = {"Piebald Tobiano", 6, 130},
	},
	{
		name = "Suffolk Punch",
		["A_C_Horse_SuffolkPunch_RedChestnut"] = {"Red Chestnut", 7, 150},
		["A_C_Horse_SuffolkPunch_Sorrel"] = {"Sorrel", 5, 120},
	},
	{
		name = "Tennessee Walker",
		["A_C_Horse_TennesseeWalker_FlaxenRoan"] = {"Flaxen Roan", 7, 150},
		["A_C_Horse_TennesseeWalker_BlackRabicano"] = {"Black Rabicano", 3, 60},
		["A_C_Horse_TennesseeWalker_Chestnut"] = {"Chestnut", 3, 60},
		["A_C_Horse_TennesseeWalker_DappleBay"] = {"Dapple Bay", 3, 60},
		["A_C_Horse_TennesseeWalker_MahoganyBay"] = {"Mahogany Bay", 3, 60},
		["A_C_Horse_TennesseeWalker_RedRoan"] = {"Red Roan", 3, 60},
		["A_C_Horse_TennesseeWalker_GoldPalomino_PC"] = {"Gold Palomino", 3, 60},
	},
	{
		name = "Shire",
		["A_C_Horse_Shire_LightGrey"] = {"Light Grey", 6, 130},
		["A_C_Horse_Shire_RavenBlack"] = {"Raven Black", 6, 130},
		["A_C_Horse_Shire_DarkBay"] = {"Dark Bay", 5, 120},
	},
	{
		name = "Belgian Draft",
		["A_C_Horse_Belgian_BlondChestnut"] = {"Blond Chestnut", 5, 120},
		["A_C_Horse_Belgian_MealyChestnut"] = {"Mealy Chestnut", 5, 120},
	},
	{
		name = "Morgan",
		["A_C_Horse_Morgan_Palomino"] = {"Palomino", 3, 60},
		["A_C_Horse_Morgan_Bay"] = {"Bay", 2, 55},
		["A_C_Horse_Morgan_BayRoan"] = {"Bay Roan", 2, 55},
		["A_C_Horse_Morgan_FlaxenChestnut"] = {"Flaxen Chestnut", 2, 55},
		["A_C_Horse_Morgan_LiverChestnut_PC"] = {"Liver Chestnut", 2, 55},
	},
	{
		name = "Other",
		["A_C_Horse_Gang_Dutch"] = {"Gang Duch", 145, 3000},
		["A_C_HorseMule_01"] = {"Mule", 1, 18},
		["A_C_HorseMulePainted_01"] = {"Zebra", 1, 15},
		["A_C_Donkey_01"] = {"Donkey", 1, 15},
		["A_C_Horse_MP_Mangy_Backup"] = {"Mangy Backup", 1, 15},
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
