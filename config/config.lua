 Config = {}

-- Language
Config.defaultlang = 'en_lang'
-----------------------------------------------------

Config.devMode = false -- Default: false / Do Not Run on a Live Server
-----------------------------------------------------

-- Set the currency type
-- 0 = Cash Only
-- 1 = Gold Only
-- 2 = Both
Config.currencyType = 2 -- Default: 2
-----------------------------------------------------

Config.keys = {
	shop   = 0x760A9C6F, --[G] Open Stable Menu
    call   = 0x80F28E95, --[L] Call Horse at Stable
	ret    = 0x27D1C284, --[R] Return Horse at Stable
    sell   = 0x80F28E95, --[L] Sell Tamed Horse at Sell Point
    keep   = 0x27D1C284, --[R] Keep Tamed Horse at Sell Point
    trade  = 0x27D1C284, --[R] Trade Horse to Player
    drink  = 0xD8F73058, --[U] Trade Horse to Player
    rest   = 0x620A6C5E, --[V] Trade Horse to Player
    sleep  = 0x43CDA5B0, --[Z] Trade Horse to Player
    wallow = 0x9959A6F0, --[C] Trade Horse to Player
}
-----------------------------------------------------

-- Change / Translate Stables Commands
Config.commands = {
    horseStats   = 'horseStats',   -- Check Horse Bonding Stats in Console
    horseSetWild = 'horseSetWild', -- Dev Mode: Make a Horse Wild
    horseRespawn = 'horseRespawn', -- Respawn Horse if Stuck or Unable to Reach
}
-----------------------------------------------------

-- Sell Price is 60% of cashPrice (shown below)
Config.sellPrice = 0.60 -- Default: 0.60
-----------------------------------------------------

-- Max Number of Horses per Player
Config.maxPlayerHorses  = 5  -- Default: 5
Config.maxTrainerHorses = 10 -- Default: 10
-----------------------------------------------------

-- Can Spawn Horse Anywhere with Whistle 
Config.whistleSpawn = true -- Default:true / Set to false to only Use 'Call Horse' Button at Stable to Spawn Horse
-----------------------------------------------------

-- Can Use Flee Button in Horse Menu
Config.fleeEnabled = true -- Default: true / Set to false to Return Horse at Stable Only
-----------------------------------------------------

-- Can Use when Stable is Closed
Config.closedCall   = true -- Default: true / 'Call Horse' Button at Stable
Config.closedReturn = true -- Default: true / 'Return Horse' Button at Stable
-----------------------------------------------------

-- Horse Inventory
Config.useSaddlebags    = true  -- Default: true / Require Saddlebags for Inventory
Config.searchSaddlebags = true  -- Default: true / Must be on Foot to Access Saddlebags
Config.shareInventory   = false -- Default: false / Share with All Players
Config.allowWeapons     = true  -- Default: true / Allow Weapons
-----------------------------------------------------

-- Health and Stamina Boosts (Set to 0 to Disable Boost - Animations Still Work)
Config.boost = {
	brushHealth  = 10, -- Increase for Brushing Horse
	brushStamina = 10,
	feedHealth   = 20, -- Increase for Feeding Horse
	feedStamina  = 20,
    drinkHealth  = 20, -- Increase for Horse Drinking
	drinkStamina = 20,
}
-----------------------------------------------------

-- Horse Drinking
Config.drinkLength = 15 -- Default: 15 / Time in Seconds for Animation to Run
-----------------------------------------------------

-- Places Horse Name Above Horse When Saddle is Empty
Config.horseTag    = true -- Default: true / Set to false to disable
Config.tagDistance = 15   -- Default: 15 / Distance from Horse the Tag is Visible
-----------------------------------------------------

-- Horse Training
Config.trainerOnly = false -- Default: false / Only Trainers can Tame, Sell and Train Horses
Config.trainerJob = {
	{ name = 'trainer', grade = 0 },
}
Config.trainingDistance = 100  -- Default:100 / Distance Traveled to Increase XP
Config.horseXpPerCheck  = 1    -- Default: 1 / XP Earned per 'trainingDistance' Achieved
Config.horseXpPerBrush  = 1    -- Default: 1 / Set to 0 to Disable / Amount of XP Earned when Brushing Horse
Config.horseXpPerFeed   = 1    -- Default: 1 / Set to 0 to Disable / Amount of XP Earned when Feeding Horse
Config.horseXpPerDrink  = 1    -- Default: 1 / Set to 0 to Disable / Amount of XP Earned When Horse Drinks
Config.showXpMessage    = true -- Default: true / Show XP Increase Message on Screen

Config.displayHorseBreed = true -- Default: true / Display Breed of Horse Player Mounted

Config.tameCost       = 50 -- Default: 50 / Cost of Registering a Tamed Horse
Config.tameDifficulty = 2  -- Default: 2 / How Hard do you Want Taming to Be

Config.allowSale  = true -- Default: true / Allow Player to Sell Tamed Horse
Config.sellCooldown = 15 -- Cooldown for Selling Tamed Horses in Minutes
Config.allowKeep  = true -- Default: true / Allow Player to Keep Tamed Horse
Config.sellPoints = {    -- Sell/Keep locations for Tamed Horses
    valentine = {
        coords = vector3(-357.57, 771.3, 116.45),
        blipOn = true,              -- Turns Blip On / Off
        blipName = 'Trainer',       -- Name of the Blip on the Map
        blipSprite = -1103135225
    }
 }
-----------------------------------------------------

-- Allow Blips on Map when Stable is Closed
Config.blipOnClosed = true -- true = Show Blips / false = Remove Blips
-----------------------------------------------------

-- Stable Locations and Options
Config.shops = {
	valentine = {
		shopName = 'Valentine Stable',                   -- Name Shown on the Stable Menu
		promptName = 'Valentine Stable',                 -- Text Below the Prompt Button
		blipOn = true,                                   -- Turns Blip On / Off
		blipName = 'Valentine Stable',                   -- Name of the Blip on the Map
		blipSprite = 1938782895,                         -- blip_shop_horse
		blipOpen = 'WHITE',                              -- Shop Open - Default: White - Blip Colors Shown Below
		blipClosed = 'RED',                              -- Shop Closed - Default: Red - Blip Colors Shown Below
		blipJob = 'YELLOW_ORANGE',                       -- Shop Job Locked - Default: Yellow - Blip Colors Shown Below
		npcOn = true,                                    -- Turns NPCs On / Off
		npcModel = 'u_m_m_bwmstablehand_01',             -- Sets Model for NPCs
		nDistance = 100.0,                               -- Distance from Shop for NPC to Spawn
		sDistance = 2.0,                                 -- Distance from NPC to Get Menu Prompt
		npc = vector3(-367.87, 784.27, 115.95),          -- Location for NPC and Stable
		npcHeading = 6.27,                               -- NPC Heading
		horseCam = vector3(-369.24, 784.41, 116.16),     -- Camera Location to View Horse When In-Menu
		spawn = vector3(-371.35, 786.71, 116.17),        -- Location for Horse Preview When In-Menu
        spawnHeading = 269.3,                            -- Horse Heading When In-Menu
		allowedJobs = {},                                -- Insert Job to limit access - ex. allowedJobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
		shopHours = false,                               -- If You Want the Shops to Use Open and Closed Hours
		shopOpen = 7,                                    -- Shop Open Time / 24 Hour Clock
		shopClose = 21,                                  -- Shop Close Time / 24 Hour Clock
	},
	strawberry = {
		shopName = 'Strawberry Stable',
		promptName = 'Strawberry Stable',
		blipOn = true,
		blipName = 'Strawberry Stable',
		blipSprite = 1938782895,
		blipOpen = 'WHITE',
		blipClosed = 'RED',
		blipJob = 'YELLOW_ORANGE',
		npcOn = true,
		npcModel = 'u_m_m_bwmstablehand_01',
		nDistance = 100.0,
		sDistance = 2.0,
		npc = vector3(-1817.85, -564.86, 156.06),
		npcHeading = 335.86,
		horseCam = vector3(-1822.55, -563.93, 156.13),
		spawn = vector3(-1823.94, -560.85, 156.06),
        spawnHeading = 257.86,
		allowedJobs = {},
		shopHours = false,
		shopOpen = 7,
		shopClose = 21,
	},
	vanhorn = {
		shopName = 'Van Horn Stable',
		promptName = 'Van Horn Stable',
		blipOn = true,
		blipName = 'Van Horn Stable',
		blipSprite = 1938782895,
		blipOpen = 'WHITE',
		blipClosed = 'RED',
		blipJob = 'YELLOW_ORANGE',
		npcOn = true,
		npcModel = 'u_m_m_bwmstablehand_01',
		nDistance = 100.0,
		sDistance = 2.0,
		npc = vector3(2967.53, 792.71, 51.4),
		npcHeading = 353.62,
		horseCam = vector3(2970.67, 793.65, 51.4),
		spawn = vector3(2971.66, 796.82, 51.4),
        spawnHeading = 96.54,
		allowedJobs = {},
		shopHours = false,
		shopOpen = 7,
		shopClose = 21,
	},
	lemoyne = {
		shopName = 'Lemoyne Stable',
		promptName = 'Lemoyne Stable',
		blipOn = true,
		blipName = 'Lemoyne Stable',
		blipSprite = 1938782895,
		blipOpen = 'WHITE',
		blipClosed = 'RED',
		blipJob = 'YELLOW_ORANGE',
		npcOn = true,
		npcModel = 'u_m_m_bwmstablehand_01',
		nDistance = 100.0,
		sDistance = 2.0,
		npc = vector3(1210.73, -189.78, 101.39),
		npcHeading = 107.52,
		horseCam = vector3(1211.89, -192.76, 101.46),
		spawn = vector3(1210.5, -196.25, 101.38),
        spawnHeading = 15.61,
		allowedJobs = {},
		shopHours = false,
		shopOpen = 7,
		shopClose = 21,
	},
	saintdenis = {
		shopName = 'Saint Denis Stable',
		promptName = 'Saint Denis Stable',
		blipOn = true,
		blipName = 'Saint Denis Stable',
		blipSprite = 1938782895,
		blipOpen = 'WHITE',
		blipClosed = 'RED',
		blipJob = 'YELLOW_ORANGE',
		npcOn = true,
		npcModel = 'u_m_m_bwmstablehand_01',
		nDistance = 100.0,
		sDistance = 2.0,
		npc = vector3(2505.53, -1453.93, 46.32),
		npcHeading = 99.45,
		horseCam = vector3(2505.65, -1441.49, 46.29),
		spawn = vector3(2502.59, -1438.62, 46.32),
        spawnHeading = 182.93,
		allowedJobs = {},
		shopHours = false,
		shopOpen = 7,
		shopClose = 21,
	},
	blackwater = {
		shopName = 'Blackwater Stable',
		promptName = 'Blackwater Stable',
		blipOn = true,
		blipName = 'Blackwater Stable',
		blipSprite = 1938782895,
		blipOpen = 'WHITE',
		blipClosed = 'RED',
		blipJob = 'YELLOW_ORANGE',
		npcOn = true,
		npcModel = 'u_m_m_bwmstablehand_01',
		nDistance = 100.0,
		sDistance = 2.0,
		npc = vector3(-871.0, -1369.63, 43.53),
		npcHeading = 6.64,
		horseCam = vector3(-867.11, -1368.86, 43.54),
		spawn = vector3(-864.7, -1366.19, 43.55),
        spawnHeading = 88.47,
		allowedJobs = {},
		shopHours = false,
		shopOpen = 7,
		shopClose = 21,
	},
    armadillo = {
		shopName = 'Armadillo Stable',
		promptName = 'Armadillo Stable',
		blipOn = true,
		blipName = 'Armadillo Stable',
		blipSprite = 1938782895,
		blipOpen = 'WHITE',
		blipClosed = 'RED',
		blipJob = 'YELLOW_ORANGE',
		npcOn = true,
		npcModel = 'u_m_m_bwmstablehand_01',
		nDistance = 100.0,
		sDistance = 2.0,
		npc = vector3(-3706.91, -2539.68, -13.78),
		npcHeading = 358.23,
		horseCam = vector3(-3704.84, -2537.68, -13.84),
		spawn = vector3(-3702.17, -2534.99, -14.02),
        spawnHeading = 87.22,
		allowedJobs = {},
		jobGrade = 0,
		shopHours = false,
		shopOpen = 7,
		shopClose = 21,
	},
	tumbleweed = {
		shopName = 'Tumbleweed Stable',
		promptName = 'Tumbleweed Stable',
		blipOn = true,
		blipName = 'Tumbleweed Stable',
		blipSprite = 1938782895,
		blipOpen = 'WHITE',
		blipClosed = 'RED',
		blipJob = 'YELLOW_ORANGE',
		npcOn = true,
		npcModel = 'u_m_m_bwmstablehand_01',
		nDistance = 100.0,
		sDistance = 2.0,
		npc = vector3(-5515.2, -3040.17, -2.39),
		npcHeading = 180.76,
		horseCam = vector3(-5521.37, -3041.23, -2.39),
		spawn = vector3(-5524.48, -3044.31, -2.39),
        spawnHeading = 263.98,
		allowedJobs = {},
		shopHours = false,
		shopOpen = 7,
		shopClose = 21,
	},
	guarma = {
		shopName = 'Guarma Stable',
		promptName = 'Guarma Stable',
		blipOn = true,
		blipName = 'Guarma Stable',
		blipSprite = 1938782895,
		blipOpen = 'WHITE',
		blipClosed = 'RED',
		blipJob = 'YELLOW_ORANGE',
		npcOn = true,
		npcModel = 'u_m_m_bwmstablehand_01',
		nDistance = 100.0,
		sDistance = 2.0,
		npc = vector3(1340.28, -6853.88, 47.19),
		npcHeading = 68.92,
		horseCam = vector3(1337.84, -6853.13, 47.23),
		spawn = vector3(1335.06, -6850.62, 47.34),
        spawnHeading = 185.14,
		allowedJobs = {},
		shopHours = false,
		shopOpen = 7,
		shopClose = 21,
	}
}
-----------------------------------------------------

Config.Horses = { -- Gold to Dollar Ratio Based on 1899 Gold Price / sellPrice is 60% of cashPrice / Cash Price is Regular Game Price
	{
		breed = 'American Paint',
		colors = {
			['a_c_horse_americanpaint_greyovero']     = { color = 'Grey Overo',     cashPrice = 425, goldPrice = 20, invLimit = 200 },
			['a_c_horse_americanpaint_splashedwhite'] = { color = 'Splashed White', cashPrice = 140, goldPrice = 6,  invLimit = 200 },
			['a_c_horse_americanpaint_tobiano']       = { color = 'Tobiano',        cashPrice = 140, goldPrice = 6,  invLimit = 200 },
			['a_c_horse_americanpaint_overo']         = { color = 'Overo',          cashPrice = 130, goldPrice = 6,  invLimit = 200 },
		}
	},
	{
		breed = 'American Standardbred',
		colors = {
			['a_c_horse_americanstandardbred_silvertailbuckskin'] = { color = 'Silver Tail Buckskin', cashPrice = 400, goldPrice = 19, invLimit = 200 },
			['a_c_horse_americanstandardbred_palominodapple']     = { color = 'Palomino Dapple',      cashPrice = 150, goldPrice = 7,  invLimit = 200 },
			['a_c_horse_americanstandardbred_black']              = { color = 'Black',                cashPrice = 130, goldPrice = 6,  invLimit = 200 },
			['a_c_horse_americanstandardbred_buckskin']           = { color = 'Buckskin',             cashPrice = 130, goldPrice = 6,  invLimit = 200 },
			['a_c_horse_americanstandardbred_lightbuckskin']      = { color = 'Light Buckskin',       cashPrice = 130, goldPrice = 6,  invLimit = 200 },
		}
	},
	{
		breed = 'Andalusian',
		colors = {
			['a_c_horse_andalusian_perlino']  = { color = 'Perlino',   cashPrice = 450, goldPrice = 21, invLimit = 200 },
			['a_c_horse_andalusian_rosegray'] = { color = 'Rose Gray', cashPrice = 440, goldPrice = 21, invLimit = 200 },
			['a_c_horse_andalusian_darkbay']  = { color = 'Dark Bay',  cashPrice = 140, goldPrice = 6,  invLimit = 200 },
		}
	},
	{
		breed = 'Appaloosa',
		colors = {
			['a_c_horse_appaloosa_blacksnowflake'] = { color = 'Snow Flake',     cashPrice = 900, goldPrice = 43, invLimit = 200 },
			['a_c_horse_appaloosa_brownleopard']   = { color = 'Brown Leopard',  cashPrice = 450, goldPrice = 21, invLimit = 200 },
			['a_c_horse_appaloosa_leopard']        = { color = 'Leopard',        cashPrice = 430, goldPrice = 20, invLimit = 200 },
			['a_c_horse_appaloosa_fewspotted_pc']  = { color = 'Few Spotted',    cashPrice = 140, goldPrice = 6,  invLimit = 200 },
			['a_c_horse_appaloosa_blanket']        = { color = 'Blanket',        cashPrice = 200, goldPrice = 9,  invLimit = 200 },
			['a_c_horse_appaloosa_leopardblanket'] = { color = 'Lepard Blanket', cashPrice = 130, goldPrice = 6,  invLimit = 200 },
		}
	},
	{
		breed = 'Arabian',
		colors = {
			['a_c_horse_arabian_white']            = { color = 'White',           cashPrice = 1500, goldPrice = 72, invLimit = 200 },
			['a_c_horse_arabian_rosegreybay']      = { color = 'Rose Grey Bay',   cashPrice = 1350, goldPrice = 65, invLimit = 200 },
			['a_c_horse_arabian_black']            = { color = 'Black',           cashPrice = 1250, goldPrice = 60, invLimit = 200 },
			['a_c_horse_arabian_grey']             = { color = 'Grey',            cashPrice = 1150, goldPrice = 55, invLimit = 200 },
			['a_c_horse_arabian_warpedbrindle_pc'] = { color = 'Warped Brindle',  cashPrice = 650,  goldPrice = 31, invLimit = 200 },
			['a_c_horse_arabian_redchestnut']      = { color = 'Red Chestnut',    cashPrice = 350,  goldPrice = 16, invLimit = 200 },
			['a_c_horse_arabian_redchestnut_pc']   = { color = 'Red Chestnut II', cashPrice = 350,  goldPrice = 16, invLimit = 200 },
		}
	},
	{
		breed = 'Ardennes',
		colors = {
			['a_c_horse_ardennes_irongreyroan']   = { color = 'Iron Grey Roan',  cashPrice = 1200, goldPrice = 58, invLimit = 200 },
			['a_c_horse_ardennes_strawberryroan'] = { color = 'Strawberry Roan', cashPrice = 450,  goldPrice = 21, invLimit = 200 },
			['a_c_horse_ardennes_bayroan']        = { color = 'Bay Roan',        cashPrice = 140,  goldPrice = 6,  invLimit = 200 },
		}
	},
	{
		breed = 'Belgian Draft',
		colors = {
			['a_c_horse_belgian_blondchestnut'] = { color = 'Blond Chestnut', cashPrice = 120, goldPrice = 5, invLimit = 200 },
			['a_c_horse_belgian_mealychestnut'] = { color = 'Mealy Chestnut', cashPrice = 120, goldPrice = 5, invLimit = 200 },
		}
	},
	{
		breed = 'Breton',
		colors = {
			['a_c_horse_breton_grullodun']      = { color = 'Grullo Dun',    cashPrice = 550, goldPrice = 26, invLimit = 200 },
			['a_c_horse_breton_mealydapplebay'] = { color = 'Meally Dapple', cashPrice = 950, goldPrice = 45, invLimit = 200 },
			['a_c_horse_breton_redroan']        = { color = 'Red Roan',      cashPrice = 150, goldPrice = 7,  invLimit = 200 },
			['a_c_horse_breton_sealbrown']      = { color = 'Seal Brown',    cashPrice = 550, goldPrice = 26, invLimit = 200 },
			['a_c_horse_breton_sorrel']         = { color = 'Sorrel',        cashPrice = 150, goldPrice = 7,  invLimit = 200 },
			['a_c_horse_breton_steelgrey']      = { color = 'Steel Grey',    cashPrice = 950, goldPrice = 45, invLimit = 200 },
		}
	},
	{
		breed = 'Criollo',
		colors = {
			['a_c_horse_criollo_baybrindle']    = { color = 'Bay Brindle',     cashPrice = 550, goldPrice = 26, invLimit = 200 },
			['a_c_horse_criollo_bayframeovero'] = { color = 'Bay Frame Overo', cashPrice = 950, goldPrice = 45, invLimit = 200 },
			['a_c_horse_criollo_blueroanovero'] = { color = 'Blue Roan Overo', cashPrice = 150, goldPrice = 7,  invLimit = 200 },
			['a_c_horse_criollo_dun']           = { color = 'Dun',             cashPrice = 150, goldPrice = 7,  invLimit = 200 },
			['a_c_horse_criollo_marblesabino']  = { color = 'Marble Sabino',   cashPrice = 950, goldPrice = 45, invLimit = 200 },
			['a_c_horse_criollo_sorrelovero']   = { color = 'Sorrel Overo',    cashPrice = 550, goldPrice = 26, invLimit = 200 },
		}
	},
	{
		breed = 'Dutch Warmblood',
		colors = {
			['a_c_horse_dutchwarmblood_chocolateroan'] = { color = 'Chocolate Roan', cashPrice = 450, goldPrice = 21, invLimit = 200 },
			['a_c_horse_dutchwarmblood_sealbrown']     = { color = 'Seal Brown',     cashPrice = 150, goldPrice = 7,  invLimit = 200 },
			['a_c_horse_dutchwarmblood_sootybuckskin'] = { color = 'Sooty Buckskin', cashPrice = 150, goldPrice = 7,  invLimit = 200 },
			['a_c_horse_buell_warvets']                = { color = 'Cremello Gold',  cashPrice = 600, goldPrice = 29, invLimit = 200 },
		}
	},
	{
		breed = 'Gypsy Cob',
		colors = {
			['a_c_horse_gypsycob_palominoblagdon'] = { color = 'Palomino Blagdon', cashPrice = 550, goldPrice = 26, invLimit = 200 },
			['a_c_horse_gypsycob_piebald']         = { color = 'Piebald',          cashPrice = 150, goldPrice = 7,  invLimit = 200 },
			['a_c_horse_gypsycob_skewbald']        = { color = 'Skewbald',         cashPrice = 550, goldPrice = 26, invLimit = 200 },
			['a_c_horse_gypsycob_splashedbay']     = { color = 'Splashed Bay',     cashPrice = 950, goldPrice = 45, invLimit = 200 },
			['a_c_horse_gypsycob_splashedpiebald'] = { color = 'Splashed Piebald', cashPrice = 950, goldPrice = 45, invLimit = 200 },
			['a_c_horse_gypsycob_whiteblagdon']    = { color = 'White Blagdon',    cashPrice = 150, goldPrice = 7,  invLimit = 250 },
		}
	},
	{
		breed = 'Hungarian Halfbred',
		colors = {
			['a_c_horse_hungarianhalfbred_darkdapplegrey'] = { color = 'Dapple Dark Grey', cashPrice = 150, goldPrice = 7, invLimit = 200 },
			['a_c_horse_hungarianhalfbred_liverchestnut']  = { color = 'Liver Chestnut',   cashPrice = 150, goldPrice = 7, invLimit = 200 },
			['a_c_horse_hungarianhalfbred_flaxenchestnut'] = { color = 'Flaxen Chestnut',  cashPrice = 130, goldPrice = 6, invLimit = 200 },
			['a_c_horse_hungarianhalfbred_piebaldtobiano'] = { color = 'Piebald Tobiano',  cashPrice = 130, goldPrice = 6, invLimit = 200 },
		}
	},
	{
		breed = 'Kentucky Saddler',
		colors = {
			['a_c_horse_kentuckysaddle_buttermilkbuckskin_pc'] = { color = 'Buttermilk Buckskin', cashPrice = 240, goldPrice = 11, invLimit = 200 },
			['a_c_horse_kentuckysaddle_black']                 = { color = 'Black',               cashPrice = 50,  goldPrice = 2,  invLimit = 200 },
			['a_c_horse_kentuckysaddle_chestnutpinto']         = { color = 'Chestnut Pinto',      cashPrice = 50,  goldPrice = 2,  invLimit = 200 },
			['a_c_horse_kentuckysaddle_grey']                  = { color = 'Grey',                cashPrice = 50,  goldPrice = 2,  invLimit = 200 },
			['a_c_horse_kentuckysaddle_silverbay']             = { color = 'Silver Bay',          cashPrice = 50,  goldPrice = 2,  invLimit = 200 },
		}
	},
	{
		breed = 'Kladruber',
		colors = {
			['a_c_horse_kladruber_black']          = { color = 'Black',            cashPrice = 150, goldPrice = 7,  invLimit = 200 },
			['a_c_horse_kladruber_cremello']       = { color = 'Cremello',         cashPrice = 550, goldPrice = 26, invLimit = 200 },
			['a_c_horse_kladruber_dapplerosegrey'] = { color = 'Dapple Rose Grey', cashPrice = 950, goldPrice = 45, invLimit = 200 },
			['a_c_horse_kladruber_grey']           = { color = 'Grey',             cashPrice = 550, goldPrice = 26, invLimit = 200 },
			['a_c_horse_kladruber_silver']         = { color = 'Silver',           cashPrice = 950, goldPrice = 45, invLimit = 200 },
			['a_c_horse_kladruber_white']          = { color = 'White',            cashPrice = 150, goldPrice = 7,  invLimit = 200 },
		}
	},
	{
		breed = 'Missouri Fox Trotter',
		colors = {
			['a_c_horse_missourifoxtrotter_amberchampagne']    = { color = 'Amber Champagne',     cashPrice = 950,  goldPrice = 45, invLimit = 200 },
			['a_c_horse_missourifoxtrotter_sablechampagne']    = { color = 'Sable Champagne',     cashPrice = 950,  goldPrice = 45, invLimit = 200 },
			['a_c_horse_missourifoxtrotter_silverdapplepinto'] = { color = 'Silver Dapple Pinto', cashPrice = 950,  goldPrice = 45, invLimit = 200 },
			['a_c_horse_missourifoxtrotter_blacktovero']       = { color = 'Black Tovero',        cashPrice = 1125, goldPrice = 54, invLimit = 200 },
			['a_c_horse_missourifoxtrotter_blueroan']          = { color = 'Blue Roan',           cashPrice = 1125, goldPrice = 54, invLimit = 200 },
			['a_c_horse_missourifoxtrotter_buckskinbrindle']   = { color = 'Buckskin Brindle',    cashPrice = 1125, goldPrice = 54, invLimit = 200 },
			['a_c_horse_missourifoxtrotter_dapplegrey']        = { color = 'Dapple Grey',         cashPrice = 1125, goldPrice = 54, invLimit = 200 },
		}
	},
	{
		breed = 'Morgan',
		colors = {
			['a_c_horse_morgan_palomino']         = { color = 'Palomino',        cashPrice = 15, goldPrice = 1, invLimit = 200 },
			['a_c_horse_morgan_bay']              = { color = 'Bay',             cashPrice = 55, goldPrice = 2, invLimit = 200 },
			['a_c_horse_morgan_bayroan']          = { color = 'Bay Roan',        cashPrice = 55, goldPrice = 2, invLimit = 200 },
			['a_c_horse_morgan_flaxenchestnut']   = { color = 'Flaxen Chestnut', cashPrice = 55, goldPrice = 2, invLimit = 200 },
			['a_c_horse_morgan_liverchestnut_pc'] = { color = 'Liver Chestnut',  cashPrice = 55, goldPrice = 2, invLimit = 200 },
		}
	},
	{
		breed = 'Mustang',
		colors = {
			['a_c_horse_mustang_goldendun']       = { color = 'Golden Dun',        cashPrice = 500, goldPrice = 24, invLimit = 200 },
			['a_c_horse_mustang_tigerstripedbay'] = { color = 'Tiger Striped Bay', cashPrice = 350, goldPrice = 16, invLimit = 200 },
			['a_c_horse_mustang_grullodun']       = { color = 'Grullo Dun',        cashPrice = 130, goldPrice = 6,  invLimit = 200 },
			['a_c_horse_mustang_wildbay']         = { color = 'Wild Bay',          cashPrice = 130, goldPrice = 6,  invLimit = 200 },
			['a_c_horse_mustang_blackovero']      = { color = 'Black Overo',       cashPrice = 500, goldPrice = 24, invLimit = 200 },
			['a_c_horse_mustang_buckskin']        = { color = 'Buckskin',          cashPrice = 500, goldPrice = 24, invLimit = 200 },
			['a_c_horse_mustang_chestnuttovero']  = { color = 'Chestnut Tovero',   cashPrice = 500, goldPrice = 24, invLimit = 200 },
			['a_c_horse_mustang_reddunovero']     = { color = 'Red Dun Overo',     cashPrice = 500, goldPrice = 24, invLimit = 200 },
		}
	},
	{
		breed = 'Nokota',
		colors = {
			['a_c_horse_nokota_reversedappleroan'] = { color = 'Reverse Dapple Roan', cashPrice = 450, goldPrice = 21, invLimit = 200 },
			['a_c_horse_nokota_blueroan']          = { color = 'Blue Roan',           cashPrice = 130, goldPrice = 6,  invLimit = 200 },
			['a_c_horse_nokota_whiteroan']         = { color = 'White Roan',          cashPrice = 130, goldPrice = 6 , invLimit = 200 },
		}
	},
	{
		breed = 'Norfolk Roadster',
		colors = {
			['a_c_horse_norfolkroadster_black']           = { color = 'Black',            cashPrice = 150, goldPrice = 7,  invLimit = 200 },
			['a_c_horse_norfolkroadster_dappledbuckskin'] = { color = 'Dappled Buckskin', cashPrice = 950, goldPrice = 45, invLimit = 200 },
			['a_c_horse_norfolkroadster_piebaldroan']     = { color = 'Piebald Roan',     cashPrice = 550, goldPrice = 26, invLimit = 200 },
			['a_c_horse_norfolkroadster_rosegrey']        = { color = 'Rose Grey',        cashPrice = 550, goldPrice = 26, invLimit = 200 },
			['a_c_horse_norfolkroadster_speckledgrey']    = { color = 'Speckled Grey',    cashPrice = 150, goldPrice = 7,  invLimit = 200 },
			['a_c_horse_norfolkroadster_spottedtricolor'] = { color = 'Spotted Tricolor', cashPrice = 950, goldPrice = 45, invLimit = 200 },
		}
	},
	{
		breed = 'Shire',
		colors = {
			['a_c_horse_shire_lightgrey']  = { color = 'Light Grey',  cashPrice = 120, goldPrice = 5, invLimit = 200 },
			['a_c_horse_shire_ravenblack'] = { color = 'Raven Black', cashPrice = 130, goldPrice = 6, invLimit = 200 },
			['a_c_horse_shire_darkbay']    = { color = 'Dark Bay',    cashPrice = 120, goldPrice = 5, invLimit = 200 },
		}
	},
	{
		breed = 'Suffolk Punch',
		colors = {
			['a_c_horse_suffolkpunch_redchestnut'] = { color = 'Red Chestnut', cashPrice = 120, goldPrice = 5, invLimit = 200 },
			['a_c_horse_suffolkpunch_sorrel']      = { color = 'Sorrel',       cashPrice = 120, goldPrice = 5, invLimit = 200 },
		}
	},
	{
		breed = 'Tennessee Walker',
		colors = {
			['a_c_horse_tennesseewalker_flaxenroan']      = { color = 'Flaxen Roan',    cashPrice = 150, goldPrice = 7, invLimit = 200 },
			['a_c_horse_tennesseewalker_blackrabicano']   = { color = 'Black Rabicano', cashPrice = 60,  goldPrice = 3, invLimit = 200 },
			['a_c_horse_tennesseewalker_chestnut']        = { color = 'Chestnut',       cashPrice = 60,  goldPrice = 3, invLimit = 200 },
			['a_c_horse_tennesseewalker_dapplebay']       = { color = 'Dapple Bay',     cashPrice = 60,  goldPrice = 3, invLimit = 200 },
			['a_c_horse_tennesseewalker_mahoganybay']     = { color = 'Mahogany Bay',   cashPrice = 60,  goldPrice = 3, invLimit = 200 },
			['a_c_horse_tennesseewalker_redroan']         = { color = 'Red Roan',       cashPrice = 60,  goldPrice = 3, invLimit = 200 },
			['a_c_horse_tennesseewalker_goldpalomino_pc'] = { color = 'Gold Palomino',  cashPrice = 60,  goldPrice = 3, invLimit = 200 },
		}
	},
	{
		breed = 'Thoroughbred',
		colors = {
			['a_c_horse_thoroughbred_blackchestnut']      = { color = 'Black Chestnut', cashPrice = 550, goldPrice = 26, invLimit = 200 },
			['a_c_horse_thoroughbred_bloodbay']           = { color = 'Blood Bay',      cashPrice = 130, goldPrice = 6,  invLimit = 200 },
			['a_c_horse_thoroughbred_brindle']            = { color = 'Brindle',        cashPrice = 450, goldPrice = 21, invLimit = 200 },
			['a_c_horse_thoroughbred_reversedappleblack'] = { color = 'Dapple Black',   cashPrice = 550, goldPrice = 26, invLimit = 200 },
			['a_c_horse_thoroughbred_dapplegrey']         = { color = 'Dapple Grey',    cashPrice = 130, goldPrice = 6,  invLimit = 200 },
		}
	},
	{
		breed = 'Turkoman',
		colors = {
			['a_c_horse_turkoman_gold']     = { color = 'Gold',     cashPrice = 950,  goldPrice = 45, invLimit = 200 },
			['a_c_horse_turkoman_silver']   = { color = 'Silver',   cashPrice = 950,  goldPrice = 45, invLimit = 200 },
			['a_c_horse_turkoman_darkbay']  = { color = 'Dark Bay', cashPrice = 925,  goldPrice = 44, invLimit = 200 },
			['a_c_horse_turkoman_black']    = { color = 'Black',    cashPrice = 1000, goldPrice = 48, invLimit = 200 },
			['a_c_horse_turkoman_chestnut'] = { color = 'Chestnut', cashPrice = 1000, goldPrice = 48, invLimit = 200 },
			['a_c_horse_turkoman_grey']     = { color = 'Grey',     cashPrice = 1000, goldPrice = 48, invLimit = 200 },
			['a_c_horse_turkoman_perlino']  = { color = 'Perlino',  cashPrice = 1000, goldPrice = 48, invLimit = 200 },
		}
	},
	{
		breed = 'Special',
		colors = {
			['a_c_horse_eagleflies']                 = { color = 'Eagle Flies Horse', cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_bill']                  = { color = 'Brown Jack',        cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_charles']               = { color = 'Spot',              cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_charles_endlesssummer'] = { color = 'Falmouth',          cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_dutch']                 = { color = 'Arthur',            cashPrice = 2500, goldPrice = 120, invLimit = 200 },
			['a_c_horse_gang_hosea']                 = { color = 'Silver Dollar',     cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_javier']                = { color = 'Boaz',              cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_john']                  = { color = 'Old Boy',           cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_karen']                 = { color = 'Old Belle',         cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_kieran']                = { color = 'Branwen',           cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_lenny']                 = { color = 'Mag',               cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_micah']                 = { color = 'Ghost',             cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_sadie']                 = { color = 'Bob',               cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_sadie_endlesssummer']   = { color = 'Sadie',             cashPrice = 1500, goldPrice = 72,  invLimit = 200 },
			['a_c_horse_gang_sean']                  = { color = 'Ennis',             cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_trelawney']             = { color = 'Gwydion',           cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_uncle']                 = { color = 'Nell II',           cashPrice = 2000, goldPrice = 97,  invLimit = 200 },
			['a_c_horse_gang_uncle_endlesssummer']   = { color = 'Nell IV',           cashPrice = 1500, goldPrice = 72,  invLimit = 200 },
		}
	},
	{
		breed = 'Other',
		colors = {
			['a_c_horsemule_01']          = { color = 'Mule',   cashPrice = 15, goldPrice = 1, invLimit = 200 },
			['a_c_horsemulepainted_01']   = { color = 'Zebra',  cashPrice = 15, goldPrice = 1, invLimit = 200 },
			['a_c_donkey_01']             = { color = 'Donkey', cashPrice = 15, goldPrice = 1, invLimit = 200 },
			['a_c_horse_mp_mangy_backup'] = { color = 'Mangy',  cashPrice = 15, goldPrice = 1, invLimit = 200 },
		}
	}
}

-----------------------------------------------------

Config.BlipColors = {
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
	WHITE         = 'BLIP_MODIFIER_MP_COLOR_32'
}