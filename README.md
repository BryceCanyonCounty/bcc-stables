# bcc-stables

## Description
Are you ready to embark on a journey through the untamed wilderness of the Old West? Look no further than bcc-stables, where your trusty steed awaits!
Personalize your horse with unique mane styles, tail variations, coat colors, and stylish accessories.
Groom, feed, and clean your horse to keep them at peak performance.

## Features
- Buy and sell horses through the stables.
- Cash and/or gold may be used for payments in the menu.
- Max owned horses set separately for players and trainers in the config.
- Individual inventory size for each horse model.
- Choose horse gender at purchase.
- Use oil lantern from inventory to equip a lantern to your horse.
- Shop hours may be set individually for each stable or disabled to allow the stable to remain open.
- Stable blips are colored and changeable per stable location.
- Blips can change color reflecting if stable is open, closed or job locked.
- Stable access can be limited by job and jobgrade.
- Return horse at stable (when open) or using the flee button in the horse menu.
- Feed and water your horse to increase horse's health and stamina.
- Brushing your horse will clean him and give a slight increase in health and stamina.
- Horse Health and Stamina core values are saved in the database.
- Configurable cooldown time selling tamed horses.
- Distance-based NPC spawns.
- Horse Training System.
- Horse Trading between players.
- Config option: Only trainers can buy horses from a stable (set per stable).
- Revive your downed horse using the horse reviver item.

## Horse Training
### XP System
  - Ride, feed, water and brush your horse to gain XP. As xp is gained, bonding levels will increase (0-4) for better horse stats and tricks.
### Bonding Levels
- Level 1
  - Horse can drink from rivers and lakes.
- Level 2
  - Horse can rest. *(Future update will regain stamina)*
  - Shocking events disabled for a calmer horse.
  - Trick: **Rear-Up** by pressing `left-ctrl` + `space`
- Level 3
  - Horse can sleep. *(Future update will regain health and stamina)*
  - Gunshot flee response disabled.
  - Trick: **Skid/Slide** by pressing `left-ctrl`
- Level 4
  - Horse can wallow.
  - Trick: **Dance** by pressing `space`
  - Trick: **Side-Pass** by pressing `space` + `A` or `D`

## Horse Taming
- Tame wild horses and return to a trainer area to sell or register your tamed horse.
  - If you want to keep the tame, if you have room in your stable, you'll pay a registration fee and it will be added to your stable.
- Job check if Trainer job is required.
- If player does not have Trainer job, the tamed horse can be given to a trainer to sell or register.

## Horse Trading
- While leading your horse, approach another player and a trade prompt will appear.

## Tips
- Whistleing -- A short whistle will call your horse. A long one will set your horse to follow you. A second whistle or mounting your horse will cancel following.
- Horse Info -- Press `Q` in the horse prompts to view standard horse info.

## Commands
- `/horseRespawn` Respawn your horse while bypassing the distance check.
- `/horseInfo` View more detailed horse info than standard **Show Info** display.
- `/horseSetWild` *Dev Mode Only* - Set a tamed horse wild to test taming.
- `/horseWrithe` *Dev Mode Only* - Set horse to writhe state to test reviving.

## Dependencies
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)
- [bcc-utils](https://github.com/BryceCanyonCounty/bcc-utils)
- [feather-menu](https://github.com/FeatherFramework/feather-menu/releases)

## Installation
- Make sure dependencies are installed/updated and ensured before this script
- Download the latest release `bcc-stables.zip` at [/releases/latest](https://github.com/BryceCanyonCounty/bcc-stables/releases/latest)
- Add `bcc-stables` folder to your resources folder
- Add `ensure bcc-stables` to your `resources.cfg`
- Run the included database file `bcc-stables.sql`
- Add images from `img` folder to: `...\vorp_inventory\html\img\items`
- Restart server

## Credits
- lrp_stables
- [ByteSizd](https://github.com/AndrewR3K) - Vue Boilerplate for RedM
- [SavSin](https://github.com/DavFount) - UI conversion to VueJS
- Stephenlikewhoa
- [Dokoboe](https://github.com/dokoboe)

## GitHub
- https://github.com/BryceCanyonCounty/bcc-stables
