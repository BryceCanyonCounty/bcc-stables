# Stables

#### Description
This is a basic stables script for RedM servers using the [VORP framework](https://github.com/VORPCORE). There are 6 stables configured, more stable locations may be added using the `config.lua` file.

#### Features
- Buy and sell horses through the stables
- Cash or gold may be used for payments
- Shop hours may be set individually for each stable or disabled to allow the stable to remain open
- Stable blips are colored and changeable per stable location
- Blips can change color reflecting if stable is open or closed
- Stable access can be limited by job and jobgrade

#### Configuration
Settings can be changed in the `config.lua` file. Here is an example of one stable:
```lua
     valentine = {
        Name = "Valentine Stable", -- Name of Shop on Menu
        promptName = "Valentine Stable", -- Text Below the Prompt Button
        blipAllowed = true, -- Turns Blips On / Off
        blipName = "Valentine Stable", -- Name of the Blip on the Map
        blipSprite = -145868367,
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
```

#### Dependencies
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)

#### Installation
- Ensure that the dependancies are added and started
- Add `oss_stables` folder to your resources folder
- Add `ensure oss_stables` to your `resources.cfg`
- Run the included database file `oss_stables.sql`

#### Credits
- lrp_stables

#### GitHub
- https://github.com/JusCampin/oss_stables