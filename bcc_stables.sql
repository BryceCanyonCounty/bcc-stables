CREATE TABLE IF NOT EXISTS `player_horses` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(50) NOT NULL,
  `charid` INT(11) NOT NULL,
  `selected` INT(11) NOT NULL DEFAULT 0,
  `name` VARCHAR(100) NOT NULL,
  `model` VARCHAR(100) NOT NULL,
  `components` VARCHAR(5000) NOT NULL DEFAULT '{}',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS `gender` ENUM('male', 'female') DEFAULT 'male';
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS `xp` INT(11) NOT NULL DEFAULT 0;
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS `captured` INT(11) NOT NULL DEFAULT 0;
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS `born` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS `health` INT(11) NOT NULL DEFAULT 50;
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS `stamina` INT(11) NOT NULL DEFAULT 50;
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS `dead` INT(11) NOT NULL DEFAULT 0;
ALTER TABLE `player_horses` ADD COLUMN IF NOT EXISTS `writhe` INT(11) NOT NULL DEFAULT 0 AFTER `stamina`;

CREATE INDEX IF NOT EXISTS `idx_charid` ON `player_horses` (`charid`);
CREATE INDEX IF NOT EXISTS `idx_identifier` ON `player_horses` (`identifier`);

INSERT INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`)
VALUES
  ('oil_lantern', 'Oil Lantern', 1, 1, 'item_standard', 1, 'A portable light source.'),
  ('consumable_horse_reviver', 'Horse Reviver', 3, 1, 'item_standard', 1, 'Curative compound for injured horse.'),
  ('consumable_haycube', 'Haycube', 10, 1, 'item_standard', 1, 'A compact cube of hay.'),
  ('horsebrush', 'Horse Brush', 5, 1, 'item_standard', 1, 'A brush used for grooming horses.'),
  ('consumable_apple', 'Apple', 10, 1, 'item_standard', 1, 'A juicy and delicious fruit.'),
  ('consumable_carrots', 'Carrots', 10, 1, 'item_standard', 1, 'An orange root vegetable commonly used in cooking.'),
  ('diamond', 'Diamond', 20, 1, 'item_standard', 1, 'A precious gemstone known for its brilliance and value.')
ON DUPLICATE KEY UPDATE
  `label`=VALUES(`label`),
  `limit`=VALUES(`limit`),
  `can_remove`=VALUES(`can_remove`),
  `type`=VALUES(`type`),
  `usable`=VALUES(`usable`),
  `desc`=VALUES(`desc`);
