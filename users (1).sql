-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 15 أكتوبر 2024 الساعة 09:33
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
(1, 'Ahmad', 'Hawwari', 'ahmadhawwari1092@gmail.com', 21, '$2b$10$BT6btqsXX9Gxs.88EaRAEe0mYclle1FquhbbuXt9HHZCplEO/Qj5y', 'Admin'),
(2, 'mohmmad', 'alkhateeb', 'alkhateeb@gmail.com', 21, '$2b$10$JwFCuJIPVYjqYxWoyuPJg.hFFQOG2XOn4J7vJ2FC6k8MpPiswe06q', 'Care giver'),
(3, 'sami', 'jhon', 'jhon@gmail.com', 76, '$2b$10$zBdnq.cpKULZrtavG8S4tOGKVaSspmkATW/vUGUxeJi6cjJcoXRSq', 'Care giver'),
(4, 'Ahmad', 'mahmoud', 'ahmahmoud@gmail.com', 55, '$2b$10$U4D33OGP8sVWcJlFSe8Xde71zj6.CrvZHRdDsc8UigcFLlHZJtetm', 'Care recipient'),
(5, 'fathi', 'ahmad', 'fahm@gmail.com', 66, '$2b$10$XxwjDaiH5p7lkXsL2P7mf.LhNlDIrDhI1W6ulD16PiY0OqNkaNC6C', 'Care recipient');

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
  MODIFY `User_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
