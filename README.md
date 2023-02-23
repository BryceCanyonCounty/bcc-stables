# Stables

#### Important
This is a "work in progress".

#### Description
Stables script for RedM servers using the [VORP framework](https://github.com/VORPCORE). Using the 7 original stable locations from the game. More stable locations may be added using the `config.lua` file.

#### Features
- Buy and sell horses through the stables
- Cash or gold may be used for payments in the menu
- Shop hours may be set individually for each stable or disabled to allow the stable to remain open
- Stable blips are colored and changeable per stable location
- Blips can change color reflecting if stable is open or closed
- Stable access can be limited by job and jobgrade
- Max player horses is set in the config (default: 5)
- Return horse at stable (when open) or using the flee button in the horse menu

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
        npcx = -365.08, npcy = 791.21, npcz = 116.18, npch = 179.76, -- Location for NPC and Stable
		horseCamx = -368.48, horseCamy = 789.89, horseCamz = 116.16, -- Camera Location to View Horse When In-Menu
		spawnPointx = -371.35, spawnPointy = 786.71, spawnPointz = 116.17, spawnPointh = 269.3, -- Location for Horse Preview When In-Menu
        allowedJobs = {}, -- If Empty, Everyone Can Use / Insert Job to limit access - ex. "police"
        jobGrade = 0, -- Enter Minimum Rank / Job Grade to Access Shop
        shopHours = false, -- If You Want the Shops to Use Open and Closed Hours
        shopOpen = 7, -- Shop Open Time / 24 Hour Clock
        shopClose = 21, -- Shop Close Time / 24 Hour Clock
    },     
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