-- phpMyAdmin SQL Dump
-- version 5.0.0-alpha1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Oct 30, 2019 at 05:34 PM
-- Server version: 10.4.6-MariaDB
-- PHP Version: 7.3.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mta`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL DEFAULT 'Ismeretlen',
  `password` varchar(255) NOT NULL,
  `registerdatum` timestamp NULL DEFAULT NULL,
  `serial` varchar(255) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `lastlogin` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `online` int(1) DEFAULT 0,
  `usedSerials` varchar(10000) NOT NULL COMMENT 'Egy olyan JSON tábl mely tartalmazza az adott account összes belépett serialját.',
  `usedIps` varchar(10000) NOT NULL COMMENT 'Egy olyan JSON tábl mely tartalmazza az adott account összes belépett ipjét.',
  `usedEmails` varchar(10000) NOT NULL DEFAULT '[ [ ] ]' COMMENT 'Egy tábla amely tárolja az accountban használt összes emailt',
  `banned` varchar(255) NOT NULL DEFAULT 'false' COMMENT 'Ez arra szolgál ha valaki beakar lépni egy bannolt accountba 1 ne engedje, 2 őt is bannolja a rákba'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `bank_accounts`
--

CREATE TABLE `bank_accounts` (
  `dbid` int(255) NOT NULL,
  `cardnum` varchar(255) COLLATE utf8_bin NOT NULL,
  `pin` varchar(100) COLLATE utf8_bin NOT NULL,
  `money` int(255) NOT NULL,
  `owner` int(255) NOT NULL,
  `main` int(1) NOT NULL DEFAULT 0,
  `createdat` datetime NOT NULL,
  `lastmodified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `bank_atms`
--

CREATE TABLE `bank_atms` (
  `dbid` int(255) NOT NULL,
  `position` varchar(255) COLLATE utf8_bin NOT NULL,
  `name` varchar(255) COLLATE utf8_bin NOT NULL,
  `disabled` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `bank_transactions`
--

CREATE TABLE `bank_transactions` (
  `dbid` int(255) NOT NULL,
  `sender` varchar(255) COLLATE utf8_bin NOT NULL,
  `receiver` varchar(255) COLLATE utf8_bin NOT NULL,
  `amount` varchar(255) COLLATE utf8_bin NOT NULL,
  `date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `bans`
--

CREATE TABLE `bans` (
  `id` int(11) NOT NULL,
  `banIdentity` varchar(30000) NOT NULL COMMENT 'Ez egy olyan tábla mely bannál tartalmazza az account nevet, ipket, serialokat',
  `reason` varchar(2000) NOT NULL DEFAULT 'Ismeretlen',
  `aName` varchar(255) NOT NULL DEFAULT 'Ismeretlen',
  `aId` int(11) NOT NULL,
  `startDate` varchar(255) NOT NULL COMMENT 'Egy tábla mely külön keyekbe tartalmazza az évet, napot, hónapot, percet',
  `endDate` varchar(255) NOT NULL COMMENT 'Egy tábla mely külön keyekbe tartalmazza az évet, napot, hónapot, percet',
  `aLevel` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ban_log`
--

CREATE TABLE `ban_log` (
  `id` int(11) NOT NULL,
  `account_id` int(255) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `admin` varchar(255) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` varchar(255) NOT NULL DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `blockedserials`
--

CREATE TABLE `blockedserials` (
  `id` int(11) NOT NULL,
  `serial` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `characters`
--

CREATE TABLE `characters` (
  `id` int(11) NOT NULL,
  `ownerAccountName` varchar(255) NOT NULL,
  `charname` varchar(255) NOT NULL,
  `position` varchar(2000) NOT NULL DEFAULT '[ [ 1584.9250488281, -2311.2719726563, 13.546875, 0,0, 70 ] ] ' COMMENT 'x, y, z, dim, int, rot',
  `details` varchar(45000) NOT NULL COMMENT 'Health, Armor, SkinID, Money, PlayedTime, Level, premiumPoints, job, food, drink, vehicleLimit, interiorLimit, avatar, isKnow, Bones, isHidden, BankMoney, GroupData',
  `charDetails` varchar(2000) NOT NULL COMMENT 'neme, nationality, age, born, height, weight, fightStyle, walkStyle, description',
  `deathDetails` varchar(2000) NOT NULL DEFAULT '[ [ false, [ "Ismeretlen", "Ismeretlen" ], false, [ ] ] ]' COMMENT 'isDead, reason, headless, bulletsInBody',
  `adminDetails` varchar(10000) NOT NULL DEFAULT '[ [ 0, "Ismeretlen", 0, [ ], [ ] ] ]' COMMENT 'alevel, nick, aTime, usedCmds, ajail',
  `usedNames` varchar(4000) NOT NULL DEFAULT '[ [ ] ]' COMMENT 'Egy tábla mely tárolja a karakter összes használt nevét.'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `devserials`
--

CREATE TABLE `devserials` (
  `id` int(7) NOT NULL,
  `serial` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT 'Ismeretlen'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `groupattach`
--

CREATE TABLE `groupattach` (
  `id` int(11) NOT NULL,
  `playerid` int(11) NOT NULL,
  `leader` int(11) NOT NULL DEFAULT 0,
  `permissions` varchar(25000) NOT NULL DEFAULT '[ [ ] ]',
  `groupID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE `groups` (
  `id` int(11) NOT NULL,
  `name` varchar(250) NOT NULL,
  `players` varchar(25000) NOT NULL DEFAULT '[ [ ] ]',
  `createdBy` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `hifi`
--

CREATE TABLE `hifi` (
  `id` int(11) NOT NULL,
  `x` varchar(255) NOT NULL,
  `y` varchar(255) NOT NULL,
  `z` varchar(255) NOT NULL,
  `rotZ` varchar(255) NOT NULL,
  `creator` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `interiors`
--

CREATE TABLE `interiors` (
  `dbid` int(255) NOT NULL,
  `int_data` varchar(255) COLLATE utf8_bin NOT NULL,
  `entrance` varchar(255) COLLATE utf8_bin NOT NULL,
  `exitp` varchar(255) COLLATE utf8_bin NOT NULL,
  `owner_data` varchar(255) COLLATE utf8_bin NOT NULL,
  `rental_data` varchar(255) COLLATE utf8_bin NOT NULL,
  `lastmodified` datetime NOT NULL,
  `createdat` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `id` int(11) NOT NULL,
  `elementtype` varchar(255) NOT NULL,
  `elementid` varchar(255) NOT NULL,
  `itemtype` varchar(255) NOT NULL,
  `itemid` varchar(255) NOT NULL DEFAULT '1',
  `slot` varchar(255) NOT NULL DEFAULT '1',
  `value` varchar(5000) NOT NULL DEFAULT '1',
  `count` varchar(255) DEFAULT '1',
  `status` varchar(255) NOT NULL DEFAULT '100',
  `dutyitem` varchar(255) NOT NULL DEFAULT '0',
  `premium` varchar(255) NOT NULL DEFAULT '0',
  `nbt` varchar(5000) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `items_givecache`
--

CREATE TABLE `items_givecache` (
  `id` int(11) NOT NULL,
  `data` varchar(2500) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `ownertype` int(11) NOT NULL,
  `ownerid` int(11) NOT NULL,
  `iType` int(11) NOT NULL,
  `time` varchar(2500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- --------------------------------------------------------

--
-- Table structure for table `jail_log`
--

CREATE TABLE `jail_log` (
  `id` int(11) NOT NULL,
  `account_id` int(255) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `admin` varchar(255) NOT NULL,
  `jailTime` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Az idő mikor bejaileztek',
  `time` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `jobdata`
--

CREATE TABLE `jobdata` (
  `id` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `job` int(11) NOT NULL,
  `data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `jobpeds`
--

CREATE TABLE `jobpeds` (
  `id` int(11) NOT NULL,
  `data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `kick_log`
--

CREATE TABLE `kick_log` (
  `id` int(11) NOT NULL,
  `account_id` int(255) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `admin` varchar(255) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` varchar(255) NOT NULL DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `licenseped`
--

CREATE TABLE `licenseped` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` int(11) NOT NULL,
  `model` int(11) NOT NULL,
  `position` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `lumberjack`
--

CREATE TABLE `lumberjack` (
  `id` int(11) NOT NULL,
  `data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `miner`
--

CREATE TABLE `miner` (
  `id` int(11) NOT NULL,
  `data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `miner_processors`
--

CREATE TABLE `miner_processors` (
  `id` int(11) NOT NULL,
  `data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `playertimes`
--

CREATE TABLE `playertimes` (
  `id` int(11) NOT NULL,
  `time` varchar(2500) NOT NULL,
  `sectorDetails` varchar(25000) NOT NULL,
  `playerName` varchar(255) NOT NULL,
  `playerID` varchar(255) NOT NULL,
  `modelid` varchar(255) NOT NULL DEFAULT '503'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `premiumcodes`
--

CREATE TABLE `premiumcodes` (
  `id` int(11) NOT NULL,
  `code` varchar(255) NOT NULL,
  `count` int(11) NOT NULL DEFAULT 0,
  `dontDelete` int(1) NOT NULL DEFAULT 0,
  `userCache` varchar(60000) NOT NULL DEFAULT '[ [ ] ]'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `safe`
--

CREATE TABLE `safe` (
  `id` int(11) NOT NULL,
  `pos` varchar(2550) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `shop`
--

CREATE TABLE `shop` (
  `id` int(11) NOT NULL,
  `data` text NOT NULL,
  `npcs` text NOT NULL,
  `carts` text NOT NULL,
  `objects` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `speedcams`
--

CREATE TABLE `speedcams` (
  `id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL DEFAULT '1',
  `pos` varchar(255) NOT NULL DEFAULT '[[ 0, 0, 0, 0, 0, 90 ]]' COMMENT 'x,y,z,int,dim,rot',
  `colpos` varchar(255) NOT NULL DEFAULT '[[ 0, 0, 0, 0, 0 ]]' COMMENT 'x,y,z,int,dim'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tradepapers`
--

CREATE TABLE `tradepapers` (
  `dbid` int(255) NOT NULL,
  `seller` varchar(255) COLLATE utf8_bin NOT NULL,
  `buyer` varchar(255) COLLATE utf8_bin NOT NULL,
  `price` int(255) NOT NULL,
  `element` varchar(255) COLLATE utf8_bin NOT NULL,
  `createdat` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `trafficboards`
--

CREATE TABLE `trafficboards` (
  `id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL DEFAULT '1',
  `pos` varchar(255) NOT NULL DEFAULT '[[ 0, 0, 0, 0, 0, 90 ]]' COMMENT 'x,y,z,int,dim,rot'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `trash`
--

CREATE TABLE `trash` (
  `id` int(11) NOT NULL,
  `pos` varchar(255) COLLATE utf8_hungarian_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vehicle`
--

CREATE TABLE `vehicle` (
  `id` int(11) NOT NULL,
  `modelid` varchar(255) NOT NULL,
  `pos` varchar(2550) NOT NULL DEFAULT '[[0,0,0,0,0,0,0,0]]' COMMENT 'x,y,z,rx,ry,rz,int,dim',
  `owner` varchar(255) NOT NULL,
  `fuel` varchar(255) NOT NULL DEFAULT '100',
  `engine` varchar(255) NOT NULL DEFAULT 'false',
  `engineBroken` varchar(255) NOT NULL DEFAULT 'false',
  `light` varchar(255) NOT NULL DEFAULT 'false',
  `plate` varchar(255) NOT NULL,
  `odometer` varchar(255) NOT NULL DEFAULT '0',
  `lastOilRecoil` varchar(255) NOT NULL DEFAULT '0',
  `locked` varchar(255) NOT NULL DEFAULT 'false',
  `health` varchar(255) NOT NULL DEFAULT '1000',
  `colors` varchar(255) NOT NULL DEFAULT '[[0, 0, 0, 0, 0, 0 ]]' COMMENT 'R,G,B,R1,G1,B1',
  `windows` varchar(255) NOT NULL DEFAULT '[[ false, false, false, false ]]',
  `panels` varchar(255) NOT NULL DEFAULT '[[ 0, 0, 0, 0, 0, 0, 0 ]]',
  `wheels` varchar(255) NOT NULL DEFAULT '[[ 0, 0, 0, 0 ]]',
  `lights` varchar(255) NOT NULL DEFAULT '[[ 0, 0, 0, 0 ]]',
  `doors` varchar(255) NOT NULL DEFAULT '[[ 0, 0, 0, 0, 0, 0 ]]',
  `handbrake` varchar(255) NOT NULL DEFAULT 'false',
  `damageProof` varchar(255) NOT NULL DEFAULT 'false',
  `variant` varchar(255) NOT NULL DEFAULT '[[ 5, 5 ]]',
  `headlight` varchar(255) NOT NULL DEFAULT '[[ 255, 255, 255 ]]',
  `kmColor` varchar(255) NOT NULL DEFAULT '[[ 255, 255, 255 ]]',
  `parkPos` varchar(255) NOT NULL DEFAULT '[[ 0, 0, 0 ]]',
  `protect` varchar(255) NOT NULL DEFAULT 'false',
  `faction` varchar(255) NOT NULL DEFAULT '0',
  `fueltype` varchar(50) DEFAULT NULL,
  `chassis` varchar(17) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `vehicleshopcount`
--

CREATE TABLE `vehicleshopcount` (
  `id` int(11) NOT NULL,
  `model` int(11) NOT NULL,
  `count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `whitelist`
--

CREATE TABLE `whitelist` (
  `id` int(11) NOT NULL,
  `serial` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `worlditems`
--

CREATE TABLE `worlditems` (
  `id` int(11) NOT NULL,
  `pos` varchar(5000) NOT NULL,
  `data` varchar(5000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `wreckcarrier_cranes`
--

CREATE TABLE `wreckcarrier_cranes` (
  `id` int(11) NOT NULL,
  `data` text NOT NULL,
  `type` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  ADD PRIMARY KEY (`dbid`);

--
-- Indexes for table `bank_atms`
--
ALTER TABLE `bank_atms`
  ADD PRIMARY KEY (`dbid`);

--
-- Indexes for table `bank_transactions`
--
ALTER TABLE `bank_transactions`
  ADD PRIMARY KEY (`dbid`);

--
-- Indexes for table `bans`
--
ALTER TABLE `bans`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ban_log`
--
ALTER TABLE `ban_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `blockedserials`
--
ALTER TABLE `blockedserials`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `characters`
--
ALTER TABLE `characters`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `devserials`
--
ALTER TABLE `devserials`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `groupattach`
--
ALTER TABLE `groupattach`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hifi`
--
ALTER TABLE `hifi`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `interiors`
--
ALTER TABLE `interiors`
  ADD PRIMARY KEY (`dbid`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `items_givecache`
--
ALTER TABLE `items_givecache`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jail_log`
--
ALTER TABLE `jail_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jobdata`
--
ALTER TABLE `jobdata`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jobpeds`
--
ALTER TABLE `jobpeds`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `kick_log`
--
ALTER TABLE `kick_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `licenseped`
--
ALTER TABLE `licenseped`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `lumberjack`
--
ALTER TABLE `lumberjack`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `miner`
--
ALTER TABLE `miner`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `playertimes`
--
ALTER TABLE `playertimes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `premiumcodes`
--
ALTER TABLE `premiumcodes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `safe`
--
ALTER TABLE `safe`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `shop`
--
ALTER TABLE `shop`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `speedcams`
--
ALTER TABLE `speedcams`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tradepapers`
--
ALTER TABLE `tradepapers`
  ADD PRIMARY KEY (`dbid`);

--
-- Indexes for table `trafficboards`
--
ALTER TABLE `trafficboards`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `trash`
--
ALTER TABLE `trash`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `vehicle`
--
ALTER TABLE `vehicle`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `whitelist`
--
ALTER TABLE `whitelist`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `worlditems`
--
ALTER TABLE `worlditems`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `wreckcarrier_cranes`
--
ALTER TABLE `wreckcarrier_cranes`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  MODIFY `dbid` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `bank_atms`
--
ALTER TABLE `bank_atms`
  MODIFY `dbid` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `bank_transactions`
--
ALTER TABLE `bank_transactions`
  MODIFY `dbid` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT for table `bans`
--
ALTER TABLE `bans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `ban_log`
--
ALTER TABLE `ban_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `blockedserials`
--
ALTER TABLE `blockedserials`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `devserials`
--
ALTER TABLE `devserials`
  MODIFY `id` int(7) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `groupattach`
--
ALTER TABLE `groupattach`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `groups`
--
ALTER TABLE `groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `hifi`
--
ALTER TABLE `hifi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `interiors`
--
ALTER TABLE `interiors`
  MODIFY `dbid` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `items`
--
ALTER TABLE `items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1032;

--
-- AUTO_INCREMENT for table `items_givecache`
--
ALTER TABLE `items_givecache`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `jail_log`
--
ALTER TABLE `jail_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `jobdata`
--
ALTER TABLE `jobdata`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobpeds`
--
ALTER TABLE `jobpeds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `kick_log`
--
ALTER TABLE `kick_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `licenseped`
--
ALTER TABLE `licenseped`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lumberjack`
--
ALTER TABLE `lumberjack`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `miner`
--
ALTER TABLE `miner`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `playertimes`
--
ALTER TABLE `playertimes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `premiumcodes`
--
ALTER TABLE `premiumcodes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `safe`
--
ALTER TABLE `safe`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `shop`
--
ALTER TABLE `shop`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `speedcams`
--
ALTER TABLE `speedcams`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `tradepapers`
--
ALTER TABLE `tradepapers`
  MODIFY `dbid` int(255) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trafficboards`
--
ALTER TABLE `trafficboards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=228;

--
-- AUTO_INCREMENT for table `trash`
--
ALTER TABLE `trash`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `vehicle`
--
ALTER TABLE `vehicle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `whitelist`
--
ALTER TABLE `whitelist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `worlditems`
--
ALTER TABLE `worlditems`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `wreckcarrier_cranes`
--
ALTER TABLE `wreckcarrier_cranes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

