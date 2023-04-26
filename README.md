# Stables

#### Important

This is a "work in progress".

#### Description

Stables script for RedM servers using the [VORP framework](https://github.com/VORPCORE). Using the 7 original stable locations from the game. More stable locations may be added using the `config.lua` file.

#### Features

- Buy and sell horses through the stables
- Cash or gold may be used for payments in the menu
- Individual inventory for each horse
- Shop hours may be set individually for each stable or disabled to allow the stable to remain open
- Stable blips are colored and changeable per stable location
- Blips can change color reflecting if stable is open, closed or job locked
- Stable access can be limited by job and jobgrade
- Max player horses is set in the config (default: 5)
- Return horse at stable (when open) or using the flee button in the horse menu
- Feed your horse (haycubes), using the horse menu, to increase horse's health and stamina
- Brushing your horse, using the horse menu, will clean him and give a slight increase in health
- Configurable cooldown time for feeding and brushing

#### Dependencies

- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)

#### Installation

- Add `oss_stables` folder to your resources folder
- Add `ensure oss_stables` to your `resources.cfg`
- Run the included database file `oss_stables.sql`

#### Credits

- lrp_stables
- SavSin - Everything

#### GitHub

- https://github.com/JusCampin/oss_stables
