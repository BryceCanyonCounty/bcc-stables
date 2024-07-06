CREATE TABLE IF NOT EXISTS `player_horses` (
  `id` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `identifier` VARCHAR(50) NOT NULL,
  `charid` INT(11) NOT NULL,
  `selected` INT(11) NOT NULL DEFAULT 0,
  `name` VARCHAR(100) NOT NULL,
  `model` VARCHAR(100) NOT NULL,
  `gender` ENUM('male', 'female') DEFAULT 'male',
  `components`  VARCHAR(5000) NOT NULL DEFAULT '{}',
  `xp` INT(11) NOT NULL DEFAULT 0,
  `health` INT(11) NOT NULL DEFAULT 50,
  `stamina` INT(11) NOT NULL DEFAULT 50,
  `captured` INT(11) NOT NULL DEFAULT 0,
  `born` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `dead` INT(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS (`gender` ENUM('male', 'female') DEFAULT 'male');
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS (`xp` INT(11) NOT NULL DEFAULT 0);
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS (`captured` INT(11) NOT NULL DEFAULT 0);
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS (`born` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP());
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS (`health` INT(11) NOT NULL DEFAULT 50);
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS (`stamina` INT(11) NOT NULL DEFAULT 50);
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS (`dead` INT(11) NOT NULL DEFAULT 0);

INSERT INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`) VALUES ('oil_lantern', 'Oil Lantern', 1, 1, 'item_standard', 1, 'A portable light source.')
  ON DUPLICATE KEY UPDATE `item`='oil_lantern', `label`='Oil Lantern', `limit`=1, `can_remove`=1, `type`='item_standard', `usable`=1, `desc`='A portable light source.';
  
INSERT INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`) VALUES ('consumable_horse_reviver', 'Horse Reviver', 3, 1, 'item_standard', 1, 'Curative compound for injured horse.')
  ON DUPLICATE KEY UPDATE `item`='consumable_horse_reviver', `label`='Horse Reviver', `limit`=3, `can_remove`=1, `type`='item_standard', `usable`=1, `desc`='Curative compound for injured horse.';

INSERT INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`) VALUES ('consumable_haycube', 'Haycube', 10, 1, 'item_standard', 1, 'A compact cube of hay.')
  ON DUPLICATE KEY UPDATE `item`='consumable_haycube', `label`='Haycube', `limit`=10, `can_remove`=1, `type`='item_standard', `usable`=1, `desc`='A compact cube of hay.';

INSERT INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`) VALUES ('consumable_apple', 'Apple', 10, 1, 'item_standard', 1, 'A juicy and deliciuos fruit.')
  ON DUPLICATE KEY UPDATE `item`='consumable_apple', `label`='Apple', `limit`=10, `can_remove`=1, `type`='item_standard', `usable`=1, `desc`='A juicy and deliciuos fruit.';

INSERT INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`) VALUES ('consumable_carrots', 'Carrots', 10, 1, 'item_standard', 1, 'An orange root vegetable commonly used in cooking.')
ON DUPLICATE KEY UPDATE `item`='consumable_carrots', `label`='Carrots', `limit`=10, `can_remove`=1, `type`='item_standard', `usable`=1, `desc`='An orange root vegetable commonly used in cooking.';
