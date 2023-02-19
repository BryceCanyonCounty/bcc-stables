# Stables

#### Important
This is an open project. If you would like to contribute please submit a PR.

#### Description
Stables script for RedM servers using the [VORP framework](https://github.com/VORPCORE). There are 6 stables configured, more stable locations may be added using the `config.lua` file.

#### Features
- Buy and sell horses through the stables
- Cash or gold may be used for payments in the menu
- Shop hours may be set individually for each stable or disabled to allow the stable to remain open
- Stable blips are colored and changeable per stable location
- Blips can change color reflecting if stable is open or closed
- Stable access can be limited by job and jobgrade
- Max player horses is set in the config (default: 5)
- Return horse at stable or using the flee button in the horse menu

#### Configuration
Settings can be changed in the `config.lua` file. Here is an example of one stable:
```lua
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
    }
```

#### Dependencies
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_utils](https://github.com/VORPCORE/vorp_utils)

#### Installation
- Ensure that the dependancies are added and started
- Add `oss_stables` folder to your resources folder
- Add `ensure oss_stables` to your `resources.cfg`
- Run the included database file `oss_stables.sql`

#### Credits
- lrp_stables

#### GitHub
- https://github.com/JusCampin/oss_stables