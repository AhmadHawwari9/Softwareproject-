-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 20 نوفمبر 2024 الساعة 13:13
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
-- بنية الجدول `filemannager`
--

CREATE TABLE `filemannager` (
  `file_id` int(10) NOT NULL,
  `old_name` varchar(255) NOT NULL,
  `new_name` varchar(255) NOT NULL,
  `folder` varchar(255) NOT NULL,
  `path` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `filemannager`
--

INSERT INTO `filemannager` (`file_id`, `old_name`, `new_name`, `folder`, `path`) VALUES
(56, 'smiling-young-man-illustration_1308-173524.jpg', 'smiling-young-man-illustration_1308-173524-1730720054577.jpg', './public/Uploade', 'Uploade\\smiling-young-man-illustration_1308-173524-1730720054577.jpg'),
(57, 'smiling-young-man-illustration_1308-173524.jpg', 'smiling-young-man-illustration_1308-173524-1730720206273.jpg', './public/Uploade', 'Uploade\\smiling-young-man-illustration_1308-173524-1730720206273.jpg'),
(58, 'smiling-young-man-illustration_1308-173524.jpg', 'smiling-young-man-illustration_1308-173524-1730720831394.jpg', './public/Uploade', 'Uploade\\smiling-young-man-illustration_1308-173524-1730720831394.jpg'),
(59, 'smiling-young-man-illustration_1308-173524.jpg', 'smiling-young-man-illustration_1308-173524-1730721711564.jpg', './public/Uploade', 'Uploade\\smiling-young-man-illustration_1308-173524-1730721711564.jpg'),
(60, 'smiling-young-man-illustration_1308-173524.jpg', 'smiling-young-man-illustration_1308-173524-1730722581332.jpg', './public/Uploade', 'Uploade\\smiling-young-man-illustration_1308-173524-1730722581332.jpg'),
(61, 'smiling-young-man-illustration_1308-173524.jpg', 'smiling-young-man-illustration_1308-173524-1730722861151.jpg', './public/Uploade', 'Uploade\\smiling-young-man-illustration_1308-173524-1730722861151.jpg'),
(62, 'smiling-young-man-illustration_1308-173524.jpg', 'smiling-young-man-illustration_1308-173524-1730727795013.jpg', './public/Uploade', 'Uploade\\smiling-young-man-illustration_1308-173524-1730727795013.jpg'),
(63, 'smiling-young-man-illustration_1308-173524.jpg', 'smiling-young-man-illustration_1308-173524-1730795326054.jpg', './public/Uploade', 'Uploade\\smiling-young-man-illustration_1308-173524-1730795326054.jpg'),
(64, 'FB_IMG_1729427761155.jpg', 'FB_IMG_1729427761155-1730882850921.jpg', './public/Uploade', 'Uploade/FB_IMG_1729427761155-1730882850921.jpg'),
(65, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731676007765.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731676007765.jpg'),
(67, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731678301299.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731678301299.jpg'),
(68, 'Screenshot 2024-10-07 145258.png', 'Screenshot 2024-10-07 145258-1731755877917.png', './public/Uploade', 'Uploade/Screenshot 2024-10-07 145258-1731755877917.png'),
(69, 'Screenshot 2024-10-07 145258.png', 'Screenshot 2024-10-07 145258-1731756047590.png', './public/Uploade', 'Uploade/Screenshot 2024-10-07 145258-1731756047590.png'),
(70, 'Screenshot 2024-10-07 145258.png', 'Screenshot 2024-10-07 145258-1731756564041.png', './public/Uploade', 'Uploade/Screenshot 2024-10-07 145258-1731756564041.png'),
(71, 'Screenshot 2024-10-07 145258.png', 'Screenshot 2024-10-07 145258-1731756565734.png', './public/Uploade', 'Uploade/Screenshot 2024-10-07 145258-1731756565734.png'),
(72, 'Screenshot 2024-10-07 145258.png', 'Screenshot 2024-10-07 145258-1731756638635.png', './public/Uploade', 'Uploade/Screenshot 2024-10-07 145258-1731756638635.png'),
(73, 'Screenshot 2024-10-07 145258.png', 'Screenshot 2024-10-07 145258-1731756709366.png', './public/Uploade', 'Uploade/Screenshot 2024-10-07 145258-1731756709366.png'),
(74, 'Screenshot 2024-10-07 145258.png', 'Screenshot 2024-10-07 145258-1731757241727.png', './public/Uploade', 'Uploade/Screenshot 2024-10-07 145258-1731757241727.png'),
(75, 'Screenshot 2024-10-07 145258.png', 'Screenshot 2024-10-07 145258-1731757541308.png', './public/Uploade', 'Uploade/Screenshot 2024-10-07 145258-1731757541308.png'),
(76, 'Screenshot 2024-10-07 145258.png', 'Screenshot 2024-10-07 145258-1731757879505.png', './public/Uploade', 'Uploade/Screenshot 2024-10-07 145258-1731757879505.png'),
(80, 'Screenshot 2024-10-07 145258.png', 'Screenshot 2024-10-07 145258-1731758251111.png', './public/Uploade', 'Uploade/Screenshot 2024-10-07 145258-1731758251111.png'),
(81, 'Screenshot 2024-10-07 145258.png', 'Screenshot 2024-10-07 145258-1731759700800.png', './public/Uploade', 'Uploade/Screenshot 2024-10-07 145258-1731759700800.png'),
(82, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731835806062.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731835806062.jpg'),
(84, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731838588277.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731838588277.jpg'),
(85, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731840458691.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731840458691.jpg'),
(86, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731840803593.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731840803593.jpg'),
(87, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731840892535.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731840892535.jpg'),
(88, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731840979897.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731840979897.jpg'),
(89, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731841804218.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731841804218.jpg'),
(90, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731842340078.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731842340078.jpg'),
(91, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731845443292.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731845443292.jpg'),
(92, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731845750271.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731845750271.jpg'),
(93, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731845811199.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731845811199.jpg'),
(94, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731850108033.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731850108033.jpg'),
(95, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731851046857.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731851046857.jpg'),
(96, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731919719697.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731919719697.jpg'),
(97, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1731928697132.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1731928697132.jpg'),
(98, 'recording.wav', 'recording-1731931609417.wav', './public/Uploade', 'Uploade/recording-1731931609417.wav'),
(99, 'recording.wav', 'recording-1731937289004.wav', './public/Uploade', 'Uploade/recording-1731937289004.wav'),
(100, 'recording.wav', 'recording-1731940006941.wav', './public/Uploade', 'Uploade/recording-1731940006941.wav'),
(101, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732006907814.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732006907814.jpg'),
(102, 'recording.wav', 'recording-1732007647413.wav', './public/Uploade', 'Uploade/recording-1732007647413.wav'),
(103, 'recording.wav', 'recording-1732012003907.wav', './public/Uploade', 'Uploade/recording-1732012003907.wav'),
(104, 'recording.wav', 'recording-1732012074909.wav', './public/Uploade', 'Uploade/recording-1732012074909.wav'),
(105, 'recording.wav', 'recording-1732013443083.wav', './public/Uploade', 'Uploade/recording-1732013443083.wav'),
(106, 'recording.wav', 'recording-1732015724622.wav', './public/Uploade', 'Uploade/recording-1732015724622.wav'),
(107, 'recording.wav', 'recording-1732016416885.wav', './public/Uploade', 'Uploade/recording-1732016416885.wav'),
(108, 'recording.wav', 'recording-1732103511956.wav', './public/Uploade', 'Uploade/recording-1732103511956.wav'),
(109, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732103538951.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732103538951.jpg');

-- --------------------------------------------------------

--
-- بنية الجدول `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `timestamp` datetime DEFAULT current_timestamp(),
  `is_read` tinyint(1) DEFAULT 0,
  `img_id` int(10) DEFAULT NULL,
  `Audio_id` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `messages`
--

INSERT INTO `messages` (`id`, `sender_id`, `receiver_id`, `message`, `timestamp`, `is_read`, `img_id`, `Audio_id`) VALUES
(54, 84, 83, 'hello', '2024-11-14 11:10:15', 1, NULL, NULL),
(55, 84, 83, 'hello', '2024-11-14 11:10:17', 1, NULL, NULL),
(82, 84, 83, 'كيف حالك؟', '2024-11-16 14:21:31', 1, NULL, NULL),
(83, 84, 83, 'Uploade/Screenshot 2024-10-07 145258-1731759700800.png', '2024-11-16 14:21:40', 1, 81, NULL),
(99, 83, 84, 'Uploade/man-male-young-person-icon_24877-30218-1731919719697.jpg', '2024-11-18 10:48:39', 0, 96, NULL),
(100, 83, 84, 'Uploade/man-male-young-person-icon_24877-30218-1731928697132.jpg', '2024-11-18 13:18:17', 0, 97, NULL),
(101, 83, 84, 'hello', '2024-11-18 13:18:28', 0, NULL, NULL),
(102, 84, 83, 'Uploade/recording-1731931609417.wav', '2024-11-18 14:06:49', 1, NULL, 98),
(103, 83, 84, 'Uploade/recording-1731937289004.wav', '2024-11-18 15:41:29', 0, NULL, 99),
(104, 83, 84, 'Uploade/recording-1731940006941.wav', '2024-11-18 16:26:47', 0, NULL, 100),
(105, 83, 84, 'Uploade/man-male-young-person-icon_24877-30218-1732006907814.jpg', '2024-11-19 11:01:47', 0, 101, NULL),
(106, 83, 84, 'Uploade/recording-1732007647413.wav', '2024-11-19 11:14:07', 0, NULL, 102),
(107, 83, 84, 'Uploade/recording-1732012003907.wav', '2024-11-19 12:26:43', 0, NULL, 103),
(108, 83, 84, 'Uploade/recording-1732012074909.wav', '2024-11-19 12:27:54', 0, NULL, 104),
(109, 83, 84, 'Uploade/recording-1732013443083.wav', '2024-11-19 12:50:43', 0, NULL, 105),
(110, 83, 84, 'Uploade/recording-1732015724622.wav', '2024-11-19 13:28:44', 0, NULL, 106),
(111, 83, 84, 'Uploade/recording-1732016416885.wav', '2024-11-19 13:40:16', 0, NULL, 107),
(112, 83, 84, 'Uploade/recording-1732103511956.wav', '2024-11-20 13:51:52', 0, NULL, 108),
(113, 83, 84, 'hi', '2024-11-20 13:52:06', 0, NULL, NULL),
(114, 83, 84, 'Uploade/man-male-young-person-icon_24877-30218-1732103538951.jpg', '2024-11-20 13:52:19', 0, 109, NULL);

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
  `Type_oftheuser` text NOT NULL,
  `image_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `users`
--

INSERT INTO `users` (`User_id`, `First_name`, `Last_name`, `Email`, `Age`, `Password`, `Type_oftheuser`, `image_id`) VALUES
(76, 'Ahmad', 'Hawwari', 'a.haw@gmail.com', 22, '$2b$10$tcQq1I1cWR.SIbgzWHTJSugIIjQXASttRE/rlr7POq0AADM/ub.Ey', 'Admin', 56),
(77, 'sd', 'sd', 'sd@gmail.com', 22, '$2b$10$TENLq9GtczfMypgd40QWn.jRO2lVtnohOj9QQ12UhjWvgfpj.DT7e', 'Care giver', 57),
(78, 'f', 'hh', 'h@gmail.com', 22, '$2b$10$2MPmPu8nKxdNddplEuCGrOtruFWtAeLNq/UtSGmSjenJtJC6t2gB6', 'Care recipient', 58),
(79, 'k', 'k', 'k@gmail.com', 60, '$2b$10$m3q5/Rd.CHMUPRw0j8U0M.B4igcrz5bO2uaN74r5kaadlPSxm22MW', 'Care recipient', 59),
(80, 'v', 'v', 'v@gmail.com', 89, '$2b$10$mClfY/ieqKUcfgtdxEEE7elxNxxABlQSYGyztGeW3v7pHCrtvXqQS', 'Care recipient', 60),
(81, 'n', 'n', 'n@gmail.com', 56, '$2b$10$ymrOe0fFhgwEG76Gv6d5seTd0.KQQ0PQ7Gyf3SuYuAeSyxcTmwmR.', 'Care recipient', 61),
(82, 'o', 'ol', 'o@gmail.com', 56, '$2b$10$8/UBq/IhAXNhVbYsG2mouuGVS8MpaiovpgK0jxkh5LShgKi4Lu.hW', 'Care recipient', 62),
(83, 'bg', 'bg', 'bg@gmail.com', 55, '$2b$10$1CF1dKlL0JxOB6G4lqvedebia/ICotjtyrQ1C8JpKM2a9GaQZC.9u', 'Care recipient', 63),
(84, 'ahmad', 'hawwari', 'ahmadhawwari1092@gmail.com', 22, '$2b$10$WqzfGZKWrhJW8tu72oDhYOuov3hAHII.GmE2XiJ9eZbvSFiHnAxmK', 'Care giver', 64),
(85, 's', 's', 's@gmail.com', 55, '$2b$10$HanD0Zn3crVwctR06jHKqOuuw.0MSnQWxHXArvwGxSEekqkLKHM5m', 'Care recipient', 65),
(87, 'kj', 'kj', 'kj@gmail.com', 22, '$2b$10$lkzJwu5wEMHpjviENTnb9eTx3dDM4Eem8iRTxejqsmap5WtN/XSey', 'Care giver', 67);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `filemannager`
--
ALTER TABLE `filemannager`
  ADD PRIMARY KEY (`file_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `messages1ss` (`sender_id`),
  ADD KEY `messages2ss` (`receiver_id`),
  ADD KEY `imagemessages2ss` (`img_id`),
  ADD KEY `Audiomessages2ss` (`Audio_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`User_id`),
  ADD UNIQUE KEY `Email` (`Email`),
  ADD KEY `imageid` (`image_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `filemannager`
--
ALTER TABLE `filemannager`
  MODIFY `file_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=110;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=115;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `User_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=88;

--
-- قيود الجداول المُلقاة.
--

--
-- قيود الجداول `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `Audiomessages2ss` FOREIGN KEY (`Audio_id`) REFERENCES `filemannager` (`file_id`);

--
-- قيود الجداول `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `imageid` FOREIGN KEY (`image_id`) REFERENCES `filemannager` (`file_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
