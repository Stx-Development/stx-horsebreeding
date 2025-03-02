CREATE TABLE IF NOT EXISTS `stx_horsebreeding` (
  `citizenid` varchar(50) DEFAULT NULL,
  `customid` varchar(50) DEFAULT NULL,
  `malemodel` varchar(50) DEFAULT NULL,
  `maleid` varchar(50) DEFAULT NULL,
  `femalemodel` varchar(50) DEFAULT NULL,
  `femaleid` varchar(50) DEFAULT NULL,
  `timer` varchar(50) DEFAULT NULL,
  `breeding` varchar(50) DEFAULT NULL,
  `gendergen` varchar(50) DEFAULT NULL,
  `modelgen` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


ALTER TABLE `player_horses`
ADD COLUMN `breedable` VARCHAR(50) DEFAULT NULL,
ADD COLUMN `inBreed` VARCHAR(50) DEFAULT NULL;


