# bcc-stables

## Description

Embark on an adventure through the untamed wilderness of the Old West with bcc-stables! Here, your trusty steed awaits, ready to be personalized with unique mane styles, tail variations, coat colors, and stylish accessories. Groom, feed, and clean your horse to keep them at peak performance.

## Features

- **Horse Management**: Buy and sell horses through the stables using cash and/or gold.
- **Ownership Limits**: Maximum owned horses can be set separately for players and trainers in the config.
- **Inventory Management**: Individual inventory size for each horse model.
- **Customization**: Choose horse gender at purchase and use oil lanterns from inventory to equip a lantern to your horse.
- **Shop Hours**: Set individually for each stable or disable to keep the stable open.
- **Blips**: Colored and changeable per stable location, reflecting if the stable is open, closed, or job-locked.
- **Access Control**: Stable access can be limited by job and job grade.
- **Horse Return**: Return horse at stable (when open) or using the flee button in the horse menu.
- **Care and Maintenance**: Feed and water your horse to increase health and stamina. Brushing your horse will clean it and give a slight increase in health and stamina.
- **Data Persistence**: Horse Health and Stamina core values are saved in the database.
- **Cooldown**: Configurable cooldown time for selling tamed horses.
- **NPC Spawns**: Distance-based NPC spawns.
- **Training System**: Horse Training System and Horse Trading between players.
- **Config Options**: Only trainers can buy horses from a stable (set per stable).
- **Revival**: Revive your downed horse using the horse reviver item.
- **Looting**: Allow player horse looting.
- **Death Management**: Horse death management set in the main config file.

## Horse Training

### XP System

Gain XP by riding, feeding, watering, and brushing your horse. As XP is gained, bonding levels will increase (0-4) for better horse stats and tricks.

### Bonding Levels

- **Level 1**: Horse can drink from rivers and lakes.
- **Level 2**:
  - Horse can rest. *(Future update will regain stamina)*
  - Shocking events disabled for a calmer horse.
  - Trick: **Rear-Up** by pressing `left-ctrl` + `space`
- **Level 3**:
  - Horse can sleep. *(Future update will regain health and stamina)*
  - Gunshot flee response disabled.
  - Trick: **Skid/Slide** by pressing `left-ctrl`
- **Level 4**:
  - Horse can wallow.
  - Trick: **Dance** by pressing `space`
  - Trick: **Side-Pass** by pressing `space` + `A` or `D`

## Horse Taming

- Tame wild horses and return to a trainer area to sell or register your tamed horse.
  - If you want to keep the tame and have room in your stable, pay a registration fee, and it will be added to your stable.
- Job check if Trainer job is required.
- If the player does not have the Trainer job, the tamed horse can be given to a trainer to sell or register.

## Horse Trading

- While leading your horse, approach another player, and a trade prompt will appear.

## Tips

- **Whistling**: A short whistle will call your horse. A long one will set your horse to follow you. A second whistle or mounting your horse will cancel following.
- **Horse Info**: Press `Q` in the horse prompts to view standard horse info.

## Commands

- `/horseRespawn`: Respawn your horse while bypassing the distance check.
- `/horseInfo`: View more detailed horse info than the standard **Show Info** display.
- `/horseSetWild`: *Dev Mode Only* - Set a tamed horse wild to test taming.
- `/horseWrithe`: *Dev Mode Only* - Set horse to writhe state to test reviving.

## Dependencies

- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)
- [bcc-utils](https://github.com/BryceCanyonCounty/bcc-utils)
- [feather-menu](https://github.com/FeatherFramework/feather-menu/releases)

## Installation

1. Make sure dependencies are installed/updated and ensured before this script.
2. Download the latest release `bcc-stables.zip` at [/releases/latest](https://github.com/BryceCanyonCounty/bcc-stables/releases/latest).
3. Add the `bcc-stables` folder to your resources folder.
4. Add `ensure bcc-stables` to your `server.cfg`.
5. Run the included database file `bcc-stables.sql`.
6. Add images from the `img` folder to: `...\vorp_inventory\html\img\items`.
7. Restart the server.

## Credits

- lrp_stables
- [ByteSizd](https://github.com/AndrewR3K) - Vue Boilerplate for RedM
- [SavSin](https://github.com/DavFount) - UI conversion to VueJS
- Stephenlikewhoa
- [Dokoboe](https://github.com/dokoboe)

## GitHub

- [bcc-stables](https://github.com/BryceCanyonCounty/bcc-stables)
