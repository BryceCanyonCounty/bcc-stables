# bcc-stables

#### Description
Are you ready to embark on a journey through the untamed wilderness of the Old West? Look no further than bcc-stables, where your trusty steed awaits!
Personalize your horse with unique mane styles, tail variations, coat colors, and stylish accessories.
Groom, feed, and clean your horse to keep them at peak performance.

#### Features
- Buy and sell horses through the stables
- Cash and/or gold may be used for payments in the menu
- Max player horses is set in the config (default: 5)
- Individual inventory for each horse
- Choose horse gender at purchase
- Use oil lantern from inventory to equip a lantern to your horse
- Shop hours may be set individually for each stable or disabled to allow the stable to remain open
- Stable blips are colored and changeable per stable location
- Blips can change color reflecting if stable is open, closed or job locked
- Stable access can be limited by job and jobgrade
- Return horse at stable (when open) or using the flee button in the horse menu
- Feed your horse (haycubes) to increase horse's health and stamina
- Brushing your horse will clean him and give a slight increase in health and stamina
- Configurable cooldown time for feeding and brushing
- Distance-based NPC spawns
- XP System for horse bonding
- Tame wild horses

#### Tips
- Whistleing -- A short whistle will call your horse. A long one will set your horse to follow you. A second whistle or mounting your horse will cancel following.
- XP System -- Ride, feed and brush your horse to gain XP. Gain bonding levels (0-4) for better horse stats
#### Commands
`/horseRespawn` Respawn your horse while bypassing the distance check

#### Dependencies
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)

#### Installation
- Download the latest release `bcc-stables.zip` at [/releases/latest](https://github.com/BryceCanyonCounty/bcc-stables/releases/latest)
- Add `bcc-stables` folder to your resources folder
- Add `ensure bcc-stables` to your `resources.cfg`
- Run the included database file `bcc-stables.sql`
- Add oil_lantern image to: `...\vorp_inventory\html\img`
- Restart server

#### Credits
- lrp_stables
- [ByteSizd](https://github.com/AndrewR3K) - Vue Boilerplate for RedM
- [SavSin](https://github.com/DavFount) - UI conversion to VueJS
- Stephenlikewhoa
- [Dokoboe](https://github.com/dokoboe)

#### GitHub
- https://github.com/BryceCanyonCounty/bcc-stables
