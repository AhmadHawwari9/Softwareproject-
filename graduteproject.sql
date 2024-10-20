-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 20 أكتوبر 2024 الساعة 14:10
-- إصدار الخادم: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `graduteproject`
--

-- --------------------------------------------------------

--
-- بنية الجدول `users`
--

CREATE TABLE `users` (
  `User_id` int(11) NOT NULL,
  `First_name` text NOT NULL,
  `Last_name` text NOT NULL,
  `Email` varchar(255) NOT NULL,
  `Age` int(10) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Type_oftheuser` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `users`
--

INSERT INTO `users` (`User_id`, `First_name`, `Last_name`, `Email`, `Age`, `Password`, `Type_oftheuser`) VALUES
(1, 'Ahmad', 'Hawwari', 'ahmadhawwari1092@gmail.com', 21, '$2b$10$/mWiHWin7xztOtvvdL0BK.Co02B9h4z6OkkCrDYNZ1S20s543hIRe', 'Admin'),
(2, 'mohmmad', 'alkhateeb', 'alkhateeb@gmail.com', 21, '$2b$10$JwFCuJIPVYjqYxWoyuPJg.hFFQOG2XOn4J7vJ2FC6k8MpPiswe06q', 'Care giver'),
(3, 'sami', 'jhon', 'jhon@gmail.com', 76, '$2b$10$zBdnq.cpKULZrtavG8S4tOGKVaSspmkATW/vUGUxeJi6cjJcoXRSq', 'Care giver'),
(4, 'Ahmad', 'mahmoud', 'ahmahmoud@gmail.com', 55, '$2b$10$U4D33OGP8sVWcJlFSe8Xde71zj6.CrvZHRdDsc8UigcFLlHZJtetm', 'Care recipient'),
(5, 'fathi', 'ahmad', 'fahm@gmail.com', 66, '$2b$10$XxwjDaiH5p7lkXsL2P7mf.LhNlDIrDhI1W6ulD16PiY0OqNkaNC6C', 'Care recipient'),
(6, 'haww', 'ha', 'haww@gmail.com', 88, '$2b$10$TfY1JNQCE.pT1DHCe8vWue7Qhgd45ik4YFx2QJRgXDN6fKoQD4VNC', 'Care recipient'),
(7, 'haww', 'ha', 'ha313ww@gmail.com', 66, '$2b$10$aXW3Mxqmx6DyaIWbm56G9uiEJzGFqFVm4pkhDu3d.H2knKgA2qqr6', 'Care recipient'),
(8, 'sdsad', 'sadsa', 'sd@gmail.com', 44, '$2b$10$P4T0ZNje7gx9fpSfbtt7e.ggK3CQ01u7PHf6rGKMetFip2LHaX46a', 'Care recipient'),
(9, 'fggg', 'f', 'f@gmail.com', 77, '$2b$10$PC0aV3CSJnQjFsSXe6gU7.V9b5oAjQONTvEUKce3eNLnvZ7qbaCEi', 'Care recipient'),
(10, 'cxvcx', 'Ll', 'L@gmail.com', 54, '$2b$10$s7.SwlbH/uVL5x3bl810n.E/ALEnh0/iYHzZXwSY1evs3spbWnYqC', 'Care recipient');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`User_id`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `User_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
