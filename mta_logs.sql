-- phpMyAdmin SQL Dump
-- version 5.0.0-alpha1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Oct 30, 2019 at 05:35 PM
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
-- Database: `mta_logs`
--

-- --------------------------------------------------------

--
-- Table structure for table `aclrequest-logs`
--

CREATE TABLE `aclrequest-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `addaccount-logs`
--

CREATE TABLE `addaccount-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `addatm-logs`
--

CREATE TABLE `addatm-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `addsafe-logs`
--

CREATE TABLE `addsafe-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `addtrash-logs`
--

CREATE TABLE `addtrash-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `addwhitelist-logs`
--

CREATE TABLE `addwhitelist-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `admindutydefend-logs`
--

CREATE TABLE `admindutydefend-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `adminrankdefend-logs`
--

CREATE TABLE `adminrankdefend-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `adminrankdefendwithoutlogin-logs`
--

CREATE TABLE `adminrankdefendwithoutlogin-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `aexec>>success-logs`
--

CREATE TABLE `aexec>>success-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `authserial-logs`
--

CREATE TABLE `authserial-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `axec-logs`
--

CREATE TABLE `axec-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `axec>>success-logs`
--

CREATE TABLE `axec>>success-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ban-logs`
--

CREATE TABLE `ban-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `befizetes-logs`
--

CREATE TABLE `befizetes-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `changeaccpw-logs`
--

CREATE TABLE `changeaccpw-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `changeaccserial-logs`
--

CREATE TABLE `changeaccserial-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `changeblockedserials-off-logs`
--

CREATE TABLE `changeblockedserials-off-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `changeblockedserials-on-logs`
--

CREATE TABLE `changeblockedserials-on-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `changewhitelist-off-logs`
--

CREATE TABLE `changewhitelist-off-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `changewhitelist-on-logs`
--

CREATE TABLE `changewhitelist-on-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `chgpass-logs`
--

CREATE TABLE `chgpass-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `connect-logs`
--

CREATE TABLE `connect-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `createblockedserial-logs`
--

CREATE TABLE `createblockedserial-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `createdevserial-logs`
--

CREATE TABLE `createdevserial-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `crun-logs`
--

CREATE TABLE `crun-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `crun>>success-logs`
--

CREATE TABLE `crun>>success-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `debugscript-logs`
--

CREATE TABLE `debugscript-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `debugscript>>success-logs`
--

CREATE TABLE `debugscript>>success-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `delaccount-logs`
--

CREATE TABLE `delaccount-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `deleteitem-logs`
--

CREATE TABLE `deleteitem-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `delsafe-logs`
--

CREATE TABLE `delsafe-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `delworlditem-logs`
--

CREATE TABLE `delworlditem-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `devconnect-logs`
--

CREATE TABLE `devconnect-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `giveitem-logs`
--

CREATE TABLE `giveitem-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `kifizetes-logs`
--

CREATE TABLE `kifizetes-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `kill-logs`
--

CREATE TABLE `kill-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `login-logs`
--

CREATE TABLE `login-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `login-try-logs`
--

CREATE TABLE `login-try-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `logout-logs`
--

CREATE TABLE `logout-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `logs.tablesave`
--

CREATE TABLE `logs.tablesave` (
  `ID` int(11) NOT NULL,
  `table` varchar(60000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `moneycheat''!-logs`
--

CREATE TABLE `moneycheat''!-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `msg-logs`
--

CREATE TABLE `msg-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `msg>>success-logs`
--

CREATE TABLE `msg>>success-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `nick-logs`
--

CREATE TABLE `nick-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `oban-logs`
--

CREATE TABLE `oban-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `openports-logs`
--

CREATE TABLE `openports-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `refresh-logs`
--

CREATE TABLE `refresh-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `refresh>>success-logs`
--

CREATE TABLE `refresh>>success-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `refreshall-logs`
--

CREATE TABLE `refreshall-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `register-logs`
--

CREATE TABLE `register-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `reloadacl-logs`
--

CREATE TABLE `reloadacl-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `reloadbans-logs`
--

CREATE TABLE `reloadbans-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `removeblockedserial-logs`
--

CREATE TABLE `removeblockedserial-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `removedevserial-logs`
--

CREATE TABLE `removedevserial-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `removewhitelist-logs`
--

CREATE TABLE `removewhitelist-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `restart-logs`
--

CREATE TABLE `restart-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `restart>>success-logs`
--

CREATE TABLE `restart>>success-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `srun-logs`
--

CREATE TABLE `srun-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `srun>>success-logs`
--

CREATE TABLE `srun>>success-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `start-logs`
--

CREATE TABLE `start-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `start>>success-logs`
--

CREATE TABLE `start>>success-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `stop-logs`
--

CREATE TABLE `stop-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `stopall-logs`
--

CREATE TABLE `stopall-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sver-logs`
--

CREATE TABLE `sver-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `transportitem.model-to-player-logs`
--

CREATE TABLE `transportitem.model-to-player-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `transportitem.player-to-object-logs`
--

CREATE TABLE `transportitem.player-to-object-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `transportitem.player-to-player-logs`
--

CREATE TABLE `transportitem.player-to-player-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `unban-logs`
--

CREATE TABLE `unban-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `upgrade-logs`
--

CREATE TABLE `upgrade-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `upgrade>>success-logs`
--

CREATE TABLE `upgrade>>success-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `utalas-logs`
--

CREATE TABLE `utalas-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `worlditems.create-logs`
--

CREATE TABLE `worlditems.create-logs` (
  `id` int(11) NOT NULL,
  `datum` varchar(255) NOT NULL,
  `text` varchar(255) NOT NULL,
  `sourceID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `aclrequest-logs`
--
ALTER TABLE `aclrequest-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `addaccount-logs`
--
ALTER TABLE `addaccount-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `addatm-logs`
--
ALTER TABLE `addatm-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `addsafe-logs`
--
ALTER TABLE `addsafe-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `addtrash-logs`
--
ALTER TABLE `addtrash-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `addwhitelist-logs`
--
ALTER TABLE `addwhitelist-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `admindutydefend-logs`
--
ALTER TABLE `admindutydefend-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `adminrankdefend-logs`
--
ALTER TABLE `adminrankdefend-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `adminrankdefendwithoutlogin-logs`
--
ALTER TABLE `adminrankdefendwithoutlogin-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `aexec>>success-logs`
--
ALTER TABLE `aexec>>success-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `authserial-logs`
--
ALTER TABLE `authserial-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `axec-logs`
--
ALTER TABLE `axec-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `axec>>success-logs`
--
ALTER TABLE `axec>>success-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ban-logs`
--
ALTER TABLE `ban-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `befizetes-logs`
--
ALTER TABLE `befizetes-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `changeaccpw-logs`
--
ALTER TABLE `changeaccpw-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `changeaccserial-logs`
--
ALTER TABLE `changeaccserial-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `changeblockedserials-off-logs`
--
ALTER TABLE `changeblockedserials-off-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `changeblockedserials-on-logs`
--
ALTER TABLE `changeblockedserials-on-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `changewhitelist-off-logs`
--
ALTER TABLE `changewhitelist-off-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `changewhitelist-on-logs`
--
ALTER TABLE `changewhitelist-on-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `chgpass-logs`
--
ALTER TABLE `chgpass-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `connect-logs`
--
ALTER TABLE `connect-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `createblockedserial-logs`
--
ALTER TABLE `createblockedserial-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `createdevserial-logs`
--
ALTER TABLE `createdevserial-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `crun-logs`
--
ALTER TABLE `crun-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `crun>>success-logs`
--
ALTER TABLE `crun>>success-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `debugscript-logs`
--
ALTER TABLE `debugscript-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `debugscript>>success-logs`
--
ALTER TABLE `debugscript>>success-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `delaccount-logs`
--
ALTER TABLE `delaccount-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `deleteitem-logs`
--
ALTER TABLE `deleteitem-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `delsafe-logs`
--
ALTER TABLE `delsafe-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `delworlditem-logs`
--
ALTER TABLE `delworlditem-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `devconnect-logs`
--
ALTER TABLE `devconnect-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `giveitem-logs`
--
ALTER TABLE `giveitem-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `giveitemcmd-logs`
--
ALTER TABLE `giveitemcmd-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `kifizetes-logs`
--
ALTER TABLE `kifizetes-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `kill-logs`
--
ALTER TABLE `kill-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `login-logs`
--
ALTER TABLE `login-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `login-try-logs`
--
ALTER TABLE `login-try-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `logout-logs`
--
ALTER TABLE `logout-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `logs.tablesave`
--
ALTER TABLE `logs.tablesave`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `moneycheat''!-logs`
--
ALTER TABLE `moneycheat''!-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `msg-logs`
--
ALTER TABLE `msg-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `msg>>success-logs`
--
ALTER TABLE `msg>>success-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `nick-logs`
--
ALTER TABLE `nick-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `oban-logs`
--
ALTER TABLE `oban-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `openports-logs`
--
ALTER TABLE `openports-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `refresh-logs`
--
ALTER TABLE `refresh-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `refresh>>success-logs`
--
ALTER TABLE `refresh>>success-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `refreshall-logs`
--
ALTER TABLE `refreshall-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `register-logs`
--
ALTER TABLE `register-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `reloadacl-logs`
--
ALTER TABLE `reloadacl-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `reloadbans-logs`
--
ALTER TABLE `reloadbans-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `removeblockedserial-logs`
--
ALTER TABLE `removeblockedserial-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `removedevserial-logs`
--
ALTER TABLE `removedevserial-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `removewhitelist-logs`
--
ALTER TABLE `removewhitelist-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `restart-logs`
--
ALTER TABLE `restart-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `restart>>success-logs`
--
ALTER TABLE `restart>>success-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sfakelag-logs`
--
ALTER TABLE `sfakelag-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `shutdown-logs`
--
ALTER TABLE `shutdown-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `srun-logs`
--
ALTER TABLE `srun-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `srun>>success-logs`
--
ALTER TABLE `srun>>success-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `start-logs`
--
ALTER TABLE `start-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `start>>success-logs`
--
ALTER TABLE `start>>success-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `stop-logs`
--
ALTER TABLE `stop-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `stop>>success-logs`
--
ALTER TABLE `stop>>success-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `stopall-logs`
--
ALTER TABLE `stopall-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sver-logs`
--
ALTER TABLE `sver-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `transportitem.model-to-player-logs`
--
ALTER TABLE `transportitem.model-to-player-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `transportitem.player-to-object-logs`
--
ALTER TABLE `transportitem.player-to-object-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `transportitem.player-to-player-logs`
--
ALTER TABLE `transportitem.player-to-player-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `unban-logs`
--
ALTER TABLE `unban-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `upgrade-logs`
--
ALTER TABLE `upgrade-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `upgrade>>success-logs`
--
ALTER TABLE `upgrade>>success-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `utalas-logs`
--
ALTER TABLE `utalas-logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `worlditems.create-logs`
--
ALTER TABLE `worlditems.create-logs`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `aclrequest-logs`
--
ALTER TABLE `aclrequest-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `addaccount-logs`
--
ALTER TABLE `addaccount-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `addatm-logs`
--
ALTER TABLE `addatm-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `addsafe-logs`
--
ALTER TABLE `addsafe-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `addtrash-logs`
--
ALTER TABLE `addtrash-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `addwhitelist-logs`
--
ALTER TABLE `addwhitelist-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `admindutydefend-logs`
--
ALTER TABLE `admindutydefend-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `adminrankdefend-logs`
--
ALTER TABLE `adminrankdefend-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `adminrankdefendwithoutlogin-logs`
--
ALTER TABLE `adminrankdefendwithoutlogin-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `aexec>>success-logs`
--
ALTER TABLE `aexec>>success-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `authserial-logs`
--
ALTER TABLE `authserial-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `axec-logs`
--
ALTER TABLE `axec-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `axec>>success-logs`
--
ALTER TABLE `axec>>success-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ban-logs`
--
ALTER TABLE `ban-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `befizetes-logs`
--
ALTER TABLE `befizetes-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `changeaccpw-logs`
--
ALTER TABLE `changeaccpw-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `changeaccserial-logs`
--
ALTER TABLE `changeaccserial-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `changeblockedserials-off-logs`
--
ALTER TABLE `changeblockedserials-off-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `changeblockedserials-on-logs`
--
ALTER TABLE `changeblockedserials-on-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `changewhitelist-off-logs`
--
ALTER TABLE `changewhitelist-off-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `changewhitelist-on-logs`
--
ALTER TABLE `changewhitelist-on-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chgpass-logs`
--
ALTER TABLE `chgpass-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `connect-logs`
--
ALTER TABLE `connect-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=362;

--
-- AUTO_INCREMENT for table `createblockedserial-logs`
--
ALTER TABLE `createblockedserial-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `createdevserial-logs`
--
ALTER TABLE `createdevserial-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `crun-logs`
--
ALTER TABLE `crun-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2155;

--
-- AUTO_INCREMENT for table `crun>>success-logs`
--
ALTER TABLE `crun>>success-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2150;

--
-- AUTO_INCREMENT for table `debugscript-logs`
--
ALTER TABLE `debugscript-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `debugscript>>success-logs`
--
ALTER TABLE `debugscript>>success-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=396;

--
-- AUTO_INCREMENT for table `delaccount-logs`
--
ALTER TABLE `delaccount-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `deleteitem-logs`
--
ALTER TABLE `deleteitem-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `delsafe-logs`
--
ALTER TABLE `delsafe-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delworlditem-logs`
--
ALTER TABLE `delworlditem-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `devconnect-logs`
--
ALTER TABLE `devconnect-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=269;

--
-- AUTO_INCREMENT for table `giveitem-logs`
--
ALTER TABLE `giveitem-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=264;

--
-- AUTO_INCREMENT for table `giveitemcmd-logs`
--
ALTER TABLE `giveitemcmd-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `kifizetes-logs`
--
ALTER TABLE `kifizetes-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kill-logs`
--
ALTER TABLE `kill-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT for table `login-logs`
--
ALTER TABLE `login-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `login-try-logs`
--
ALTER TABLE `login-try-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `logout-logs`
--
ALTER TABLE `logout-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `logs.tablesave`
--
ALTER TABLE `logs.tablesave`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `moneycheat''!-logs`
--
ALTER TABLE `moneycheat''!-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `msg-logs`
--
ALTER TABLE `msg-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `msg>>success-logs`
--
ALTER TABLE `msg>>success-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `nick-logs`
--
ALTER TABLE `nick-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `oban-logs`
--
ALTER TABLE `oban-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `openports-logs`
--
ALTER TABLE `openports-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `refresh-logs`
--
ALTER TABLE `refresh-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `refresh>>success-logs`
--
ALTER TABLE `refresh>>success-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `refreshall-logs`
--
ALTER TABLE `refreshall-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `register-logs`
--
ALTER TABLE `register-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reloadacl-logs`
--
ALTER TABLE `reloadacl-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reloadbans-logs`
--
ALTER TABLE `reloadbans-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `removeblockedserial-logs`
--
ALTER TABLE `removeblockedserial-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `removedevserial-logs`
--
ALTER TABLE `removedevserial-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `removewhitelist-logs`
--
ALTER TABLE `removewhitelist-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `restart-logs`
--
ALTER TABLE `restart-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `restart>>success-logs`
--
ALTER TABLE `restart>>success-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7112;

--
-- AUTO_INCREMENT for table `sfakelag-logs`
--
ALTER TABLE `sfakelag-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `shutdown-logs`
--
ALTER TABLE `shutdown-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `srun-logs`
--
ALTER TABLE `srun-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=241;

--
-- AUTO_INCREMENT for table `srun>>success-logs`
--
ALTER TABLE `srun>>success-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=234;

--
-- AUTO_INCREMENT for table `start-logs`
--
ALTER TABLE `start-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7250;

--
-- AUTO_INCREMENT for table `start>>success-logs`
--
ALTER TABLE `start>>success-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT for table `stop-logs`
--
ALTER TABLE `stop-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7161;

--
-- AUTO_INCREMENT for table `stop>>success-logs`
--
ALTER TABLE `stop>>success-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `stopall-logs`
--
ALTER TABLE `stopall-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sver-logs`
--
ALTER TABLE `sver-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transportitem.model-to-player-logs`
--
ALTER TABLE `transportitem.model-to-player-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transportitem.player-to-object-logs`
--
ALTER TABLE `transportitem.player-to-object-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transportitem.player-to-player-logs`
--
ALTER TABLE `transportitem.player-to-player-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `unban-logs`
--
ALTER TABLE `unban-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `upgrade-logs`
--
ALTER TABLE `upgrade-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `upgrade>>success-logs`
--
ALTER TABLE `upgrade>>success-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `utalas-logs`
--
ALTER TABLE `utalas-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `worlditems.create-logs`
--
ALTER TABLE `worlditems.create-logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

