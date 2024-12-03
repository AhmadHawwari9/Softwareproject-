-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 03 ديسمبر 2024 الساعة 15:40
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
-- بنية الجدول `caregiverrequesttoadmin`
--

CREATE TABLE `caregiverrequesttoadmin` (
  `Request_id` int(10) NOT NULL,
  `First_name` varchar(255) NOT NULL,
  `Last_name` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `Age` int(10) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Type_oftheuser` text NOT NULL,
  `image_id` int(10) NOT NULL,
  `cv_id` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `caregiverrequesttoadmin`
--

INSERT INTO `caregiverrequesttoadmin` (`Request_id`, `First_name`, `Last_name`, `Email`, `Age`, `Password`, `Type_oftheuser`, `image_id`, `cv_id`) VALUES
(20, 'ahmad', 'haw', 'jh11@gmail.com', 30, '$2b$10$.nYS/XLHEHtvGJx8gjiUhOTyKq5Pxo5N17ddg9gcTPgLR4VJDObLO', 'Caregiver', 241, 242);

-- --------------------------------------------------------

--
-- بنية الجدول `carerecipientlist`
--

CREATE TABLE `carerecipientlist` (
  `CareRecipientList_id` int(10) NOT NULL,
  `Care_giverid` int(10) NOT NULL,
  `carerecipient_id` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `carerecipientlist`
--

INSERT INTO `carerecipientlist` (`CareRecipientList_id`, `Care_giverid`, `carerecipient_id`) VALUES
(1, 84, 83);

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
(109, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732103538951.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732103538951.jpg'),
(110, 'recording.wav', 'recording-1732115807530.wav', './public/Uploade', 'Uploade/recording-1732115807530.wav'),
(112, 'report form.pdf', 'report form-1732287659959.pdf', './public/Uploade', 'Uploade/report form-1732287659959.pdf'),
(113, 'report form.pdf', 'report form-1732295520640.pdf', './public/Uploade', 'Uploade/report form-1732295520640.pdf'),
(114, 'uploaded_file.pdf', 'uploaded_file-1732358614470.pdf', './public/Uploade', 'Uploade/uploaded_file-1732358614470.pdf'),
(115, 'uploaded_file.pdf', 'uploaded_file-1732358806512.pdf', './public/Uploade', 'Uploade/uploaded_file-1732358806512.pdf'),
(116, 'test.pdf-1732358982646.pdf', 'test-1732358982468.pdf', './public/Uploade', 'Uploade/test-1732358982468.pdf'),
(120, 'reportform.pdf-1732437302133.pdf', 'reportform-1732437302482.pdf', './public/Uploade', 'Uploade/reportform-1732437302482.pdf'),
(121, 'reportform.pdf-1732437371372.pdf', 'reportform-1732437371713.pdf', './public/Uploade', 'Uploade/reportform-1732437371713.pdf'),
(122, 'reportform.pdf-1732439510865.pdf', 'reportform-1732439511203.pdf', './public/Uploade', 'Uploade/reportform-1732439511203.pdf'),
(123, 'reportform.pdf-1732439596103.pdf', 'reportform-1732439596444.pdf', './public/Uploade', 'Uploade/reportform-1732439596444.pdf'),
(124, 'reportform.pdf-1732439921072.pdf', 'reportform-1732439921473.pdf', './public/Uploade', 'Uploade/reportform-1732439921473.pdf'),
(125, 'reportform.pdf-1732440068565.pdf', 'reportform-1732440068900.pdf', './public/Uploade', 'Uploade/reportform-1732440068900.pdf'),
(126, 'reportform.pdf-1732440207434.pdf', 'reportform-1732440207767.pdf', './public/Uploade', 'Uploade/reportform-1732440207767.pdf'),
(127, 'reportform.pdf-1732440355124.pdf', 'reportform-1732440355456.pdf', './public/Uploade', 'Uploade/reportform-1732440355456.pdf'),
(128, 'reportform.pdf-1732440398736.pdf', 'reportform-1732440399069.pdf', './public/Uploade', 'Uploade/reportform-1732440399069.pdf'),
(129, 'reportform.pdf-1732440465489.pdf', 'reportform-1732440465819.pdf', './public/Uploade', 'Uploade/reportform-1732440465819.pdf'),
(130, 'reportform.pdf-1732440601935.pdf', 'reportform-1732440602265.pdf', './public/Uploade', 'Uploade/reportform-1732440602265.pdf'),
(131, 'reportform.pdf-1732440869337.pdf', 'reportform-1732440869671.pdf', './public/Uploade', 'Uploade/reportform-1732440869671.pdf'),
(132, 'reportform.pdf-1732441023836.pdf', 'reportform-1732441024196.pdf', './public/Uploade', 'Uploade/reportform-1732441024196.pdf'),
(133, 'reportform.pdf-1732444988948.pdf', 'reportform-1732444989315.pdf', './public/Uploade', 'Uploade/reportform-1732444989315.pdf'),
(134, 'reportform.pdf-1732445220768.pdf', 'reportform-1732445221168.pdf', './public/Uploade', 'Uploade/reportform-1732445221168.pdf'),
(135, 'reportform.pdf-1732445239027.pdf', 'reportform-1732445239384.pdf', './public/Uploade', 'Uploade/reportform-1732445239384.pdf'),
(136, 'reportform.pdf-1732445508800.pdf', 'reportform-1732445509201.pdf', './public/Uploade', 'Uploade/reportform-1732445509201.pdf'),
(137, 'reportform.pdf-1732445617887.pdf', 'reportform-1732445618223.pdf', './public/Uploade', 'Uploade/reportform-1732445618223.pdf'),
(138, 'reportform.pdf-1732445879121.pdf', 'reportform-1732445879470.pdf', './public/Uploade', 'Uploade/reportform-1732445879470.pdf'),
(139, 'reportform.pdf-1732446223398.pdf', 'reportform-1732446223732.pdf', './public/Uploade', 'Uploade/reportform-1732446223732.pdf'),
(140, 'reportform.pdf-1732446292300.pdf', 'reportform-1732446292742.pdf', './public/Uploade', 'Uploade/reportform-1732446292742.pdf'),
(141, 'reportform.pdf-1732446501680.pdf', 'reportform-1732446502025.pdf', './public/Uploade', 'Uploade/reportform-1732446502025.pdf'),
(142, 'reportform.pdf-1732446819960.pdf', 'reportform-1732446820325.pdf', './public/Uploade', 'Uploade/reportform-1732446820325.pdf'),
(143, 'reportform.pdf-1732446896184.pdf', 'reportform-1732446896588.pdf', './public/Uploade', 'Uploade/reportform-1732446896588.pdf'),
(144, 'reportform.pdf-1732446963155.pdf', 'reportform-1732446963504.pdf', './public/Uploade', 'Uploade/reportform-1732446963504.pdf'),
(145, 'reportform.pdf-1732447282335.pdf', 'reportform-1732447282721.pdf', './public/Uploade', 'Uploade/reportform-1732447282721.pdf'),
(146, 'reportform.pdf-1732447301204.pdf', 'reportform-1732447301531.pdf', './public/Uploade', 'Uploade/reportform-1732447301531.pdf'),
(147, 'reportform.pdf-1732447721668.pdf', 'reportform-1732447722011.pdf', './public/Uploade', 'Uploade/reportform-1732447722011.pdf'),
(148, 'reportform.pdf-1732447734768.pdf', 'reportform-1732447735098.pdf', './public/Uploade', 'Uploade/reportform-1732447735098.pdf'),
(149, 'reportform.pdf-1732447759715.pdf', 'reportform-1732447760065.pdf', './public/Uploade', 'Uploade/reportform-1732447760065.pdf'),
(150, '1.png', '1-1732543740017.png', './public/Uploade', 'Uploade/1-1732543740017.png'),
(151, '1.png', '1-1732543777278.png', './public/Uploade', 'Uploade/1-1732543777278.png'),
(152, '1.png', '1-1732543818382.png', './public/Uploade', 'Uploade/1-1732543818382.png'),
(153, '1.png', '1-1732543873661.png', './public/Uploade', 'Uploade/1-1732543873661.png'),
(154, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732545022030.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732545022030.jpg'),
(155, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732545122775.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732545122775.jpg'),
(156, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732545383297.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732545383297.jpg'),
(157, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732545497119.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732545497119.jpg'),
(158, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732546081396.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732546081396.jpg'),
(159, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732546451235.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732546451235.jpg'),
(160, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732546569475.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732546569475.jpg'),
(161, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732546989274.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732546989274.jpg'),
(162, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732547045316.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732547045316.jpg'),
(163, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732547074891.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732547074891.jpg'),
(164, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732548908834.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732548908834.jpg'),
(165, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732548919544.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732548919544.jpg'),
(166, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732549076458.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732549076458.jpg'),
(167, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732549142662.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732549142662.jpg'),
(168, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732549368776.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732549368776.jpg'),
(169, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732549493913.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732549493913.jpg'),
(170, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732549522415.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732549522415.jpg'),
(171, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732549590912.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732549590912.jpg'),
(172, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732549598701.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732549598701.jpg'),
(173, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732550155815.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732550155815.jpg'),
(174, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732550184067.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732550184067.jpg'),
(175, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732550413615.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732550413615.jpg'),
(176, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732550421930.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732550421930.jpg'),
(177, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1732550443005.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1732550443005.jpg'),
(178, 'man-male-young-person-icon_24877-30218.jpg', 'man-male-young-person-icon_24877-30218-1732550449125.jpg', './public/Uploade', 'Uploade/man-male-young-person-icon_24877-30218-1732550449125.jpg'),
(179, 'reportform-1732437302482.pdf-1732609113109.pdf', 'reportform-1732437302482-1732609113485.pdf', './public/Uploade', 'Uploade/reportform-1732437302482-1732609113485.pdf'),
(180, 'test-1732359035085.pdf-1732609457788.pdf', 'test-1732359035085-1732609458192.pdf', './public/Uploade', 'Uploade/test-1732359035085-1732609458192.pdf'),
(182, 'reportform.pdf-1732890170098.pdf', 'reportform-1732890170302.pdf', './public/Uploade', 'Uploade/reportform-1732890170302.pdf'),
(183, 'reportform.pdf-1732890230789.pdf', 'reportform-1732890230882.pdf', './public/Uploade', 'Uploade/reportform-1732890230882.pdf'),
(184, 'reportform.pdf-1732893261230.pdf', 'reportform-1732893261465.pdf', './public/Uploade', 'Uploade/reportform-1732893261465.pdf'),
(185, 'reportform.pdf-1732893426274.pdf', 'reportform-1732893426556.pdf', './public/Uploade', 'Uploade/reportform-1732893426556.pdf'),
(186, 'reportform.pdf-1732893613504.pdf', 'reportform-1732893613786.pdf', './public/Uploade', 'Uploade/reportform-1732893613786.pdf'),
(187, 'reportform.pdf-1732893772132.pdf', 'reportform-1732893772278.pdf', './public/Uploade', 'Uploade/reportform-1732893772278.pdf'),
(188, 'reportform.pdf-1732893876091.pdf', 'reportform-1732893876287.pdf', './public/Uploade', 'Uploade/reportform-1732893876287.pdf'),
(189, 'reportform.pdf-1732894054626.pdf', 'reportform-1732894054850.pdf', './public/Uploade', 'Uploade/reportform-1732894054850.pdf'),
(190, 'reportform.pdf-1732894673369.pdf', 'reportform-1732894673706.pdf', './public/Uploade', 'Uploade/reportform-1732894673706.pdf'),
(191, 'reportform.pdf-1732954769807.pdf', 'reportform-1732954770152.pdf', './public/Uploade', 'Uploade/reportform-1732954770152.pdf'),
(192, 'reportform.pdf-1732954857310.pdf', 'reportform-1732954858016.pdf', './public/Uploade', 'Uploade/reportform-1732954858016.pdf'),
(193, 'reportform.pdf-1732954910017.pdf', 'reportform-1732954910409.pdf', './public/Uploade', 'Uploade/reportform-1732954910409.pdf'),
(194, 'reportform.pdf-1732955014349.pdf', 'reportform-1732955014771.pdf', './public/Uploade', 'Uploade/reportform-1732955014771.pdf'),
(195, 'reportform.pdf-1732955184772.pdf', 'reportform-1732955185039.pdf', './public/Uploade', 'Uploade/reportform-1732955185039.pdf'),
(196, 'reportform.pdf-1732955532239.pdf', 'reportform-1732955532669.pdf', './public/Uploade', 'Uploade/reportform-1732955532669.pdf'),
(197, 'reportform.pdf-1732955712627.pdf', 'reportform-1732955713048.pdf', './public/Uploade', 'Uploade/reportform-1732955713048.pdf'),
(198, 'reportform.pdf-1732956564268.pdf', 'reportform-1732956564588.pdf', './public/Uploade', 'Uploade/reportform-1732956564588.pdf'),
(199, 'reportform.pdf-1732956900587.pdf', 'reportform-1732956900848.pdf', './public/Uploade', 'Uploade/reportform-1732956900848.pdf'),
(200, 'reportform.pdf-1732957143815.pdf', 'reportform-1732957144207.pdf', './public/Uploade', 'Uploade/reportform-1732957144207.pdf'),
(201, 'reportform.pdf-1732957246880.pdf', 'reportform-1732957247289.pdf', './public/Uploade', 'Uploade/reportform-1732957247289.pdf'),
(202, 'reportform.pdf-1732957471963.pdf', 'reportform-1732957472234.pdf', './public/Uploade', 'Uploade/reportform-1732957472234.pdf'),
(203, '1.png', '1-1733121334926.png', './public/Uploade', 'Uploade/1-1733121334926.png'),
(204, 'hardware presentation.pdf', 'hardware presentation-1733121334977.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977.pdf'),
(205, '1.png', '1-1733130565564.png', './public/Uploade', 'Uploade/1-1733130565564.png'),
(206, 'hardware presentation.pdf', 'hardware presentation-1733130565576.pdf', './public/Uploade', 'Uploade/hardware presentation-1733130565576.pdf'),
(207, '1.png', '1-1733130573973.png', './public/Uploade', 'Uploade/1-1733130573973.png'),
(208, 'hardware presentation.pdf', 'hardware presentation-1733130573973.pdf', './public/Uploade', 'Uploade/hardware presentation-1733130573973.pdf'),
(209, '1.png', '1-1733130581194.png', './public/Uploade', 'Uploade/1-1733130581194.png'),
(210, 'hardware presentation.pdf', 'hardware presentation-1733130581195.pdf', './public/Uploade', 'Uploade/hardware presentation-1733130581195.pdf'),
(211, '1.png', '1-1733130604149.png', './public/Uploade', 'Uploade/1-1733130604149.png'),
(212, 'hardware presentation.pdf', 'hardware presentation-1733130604150.pdf', './public/Uploade', 'Uploade/hardware presentation-1733130604150.pdf'),
(213, '1.png', '1-1733130611284.png', './public/Uploade', 'Uploade/1-1733130611284.png'),
(214, 'hardware presentation.pdf', 'hardware presentation-1733130611284.pdf', './public/Uploade', 'Uploade/hardware presentation-1733130611284.pdf'),
(215, '1.png', '1-1733130617444.png', './public/Uploade', 'Uploade/1-1733130617444.png'),
(216, 'hardware presentation.pdf', 'hardware presentation-1733130617445.pdf', './public/Uploade', 'Uploade/hardware presentation-1733130617445.pdf'),
(217, '1.png', '1-1733136988599.png', './public/Uploade', 'Uploade/1-1733136988599.png'),
(218, 'hardware presentation.pdf', 'hardware presentation-1733136988600.pdf', './public/Uploade', 'Uploade/hardware presentation-1733136988600.pdf'),
(219, '1.png', '1-1733137023248.png', './public/Uploade', 'Uploade/1-1733137023248.png'),
(220, 'hardware presentation.pdf', 'hardware presentation-1733137023249.pdf', './public/Uploade', 'Uploade/hardware presentation-1733137023249.pdf'),
(221, '1.png', '1-1733137058834.png', './public/Uploade', 'Uploade/1-1733137058834.png'),
(222, 'hardware presentation.pdf', 'hardware presentation-1733137058835.pdf', './public/Uploade', 'Uploade/hardware presentation-1733137058835.pdf'),
(223, '1.png', '1-1733137084162.png', './public/Uploade', 'Uploade/1-1733137084162.png'),
(224, 'hardware presentation.pdf', 'hardware presentation-1733137084163.pdf', './public/Uploade', 'Uploade/hardware presentation-1733137084163.pdf'),
(225, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1733140382026.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1733140382026.pdf'),
(226, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1733140385998.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1733140385998.pdf'),
(227, 'reportform.pdf', 'reportform-1733140443614.pdf', './public/Uploade', 'Uploade/reportform-1733140443614.pdf'),
(228, 'reportform.pdf', 'reportform-1733140444164.pdf', './public/Uploade', 'Uploade/reportform-1733140444164.pdf'),
(229, '1.png', '1-1733215144818.png', './public/Uploade', 'Uploade/1-1733215144818.png'),
(230, 'hardware presentation.pdf', 'hardware presentation-1733215144968.pdf', './public/Uploade', 'Uploade/hardware presentation-1733215144968.pdf'),
(231, '1.png', '1-1733215156709.png', './public/Uploade', 'Uploade/1-1733215156709.png'),
(232, 'hardware presentation.pdf', 'hardware presentation-1733215156719.pdf', './public/Uploade', 'Uploade/hardware presentation-1733215156719.pdf'),
(233, '1.png', '1-1733215162390.png', './public/Uploade', 'Uploade/1-1733215162390.png'),
(234, 'hardware presentation.pdf', 'hardware presentation-1733215162392.pdf', './public/Uploade', 'Uploade/hardware presentation-1733215162392.pdf'),
(235, '1.png', '1-1733215167568.png', './public/Uploade', 'Uploade/1-1733215167568.png'),
(236, 'hardware presentation.pdf', 'hardware presentation-1733215167571.pdf', './public/Uploade', 'Uploade/hardware presentation-1733215167571.pdf'),
(237, '1.png', '1-1733215174334.png', './public/Uploade', 'Uploade/1-1733215174334.png'),
(238, 'hardware presentation.pdf', 'hardware presentation-1733215174335.pdf', './public/Uploade', 'Uploade/hardware presentation-1733215174335.pdf'),
(239, '1.png', '1-1733215179523.png', './public/Uploade', 'Uploade/1-1733215179523.png'),
(240, 'hardware presentation.pdf', 'hardware presentation-1733215179523.pdf', './public/Uploade', 'Uploade/hardware presentation-1733215179523.pdf'),
(241, '1.png', '1-1733215183809.png', './public/Uploade', 'Uploade/1-1733215183809.png'),
(242, 'hardware presentation.pdf', 'hardware presentation-1733215183809.pdf', './public/Uploade', 'Uploade/hardware presentation-1733215183809.pdf');

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
(99, 83, 84, 'Uploade/man-male-young-person-icon_24877-30218-1731919719697.jpg', '2024-11-18 10:48:39', 1, 96, NULL),
(100, 83, 84, 'Uploade/man-male-young-person-icon_24877-30218-1731928697132.jpg', '2024-11-18 13:18:17', 1, 97, NULL),
(101, 83, 84, 'hello', '2024-11-18 13:18:28', 1, NULL, NULL),
(102, 84, 83, 'Uploade/recording-1731931609417.wav', '2024-11-18 14:06:49', 1, NULL, 98),
(103, 83, 84, 'Uploade/recording-1731937289004.wav', '2024-11-18 15:41:29', 1, NULL, 99),
(104, 83, 84, 'Uploade/recording-1731940006941.wav', '2024-11-18 16:26:47', 1, NULL, 100),
(105, 83, 84, 'Uploade/man-male-young-person-icon_24877-30218-1732006907814.jpg', '2024-11-19 11:01:47', 1, 101, NULL),
(106, 83, 84, 'Uploade/recording-1732007647413.wav', '2024-11-19 11:14:07', 1, NULL, 102),
(107, 83, 84, 'Uploade/recording-1732012003907.wav', '2024-11-19 12:26:43', 1, NULL, 103),
(108, 83, 84, 'Uploade/recording-1732012074909.wav', '2024-11-19 12:27:54', 1, NULL, 104),
(109, 83, 84, 'Uploade/recording-1732013443083.wav', '2024-11-19 12:50:43', 1, NULL, 105),
(110, 83, 84, 'Uploade/recording-1732015724622.wav', '2024-11-19 13:28:44', 1, NULL, 106),
(111, 83, 84, 'Uploade/recording-1732016416885.wav', '2024-11-19 13:40:16', 1, NULL, 107),
(112, 83, 84, 'Uploade/recording-1732103511956.wav', '2024-11-20 13:51:52', 1, NULL, 108),
(113, 83, 84, 'hi', '2024-11-20 13:52:06', 1, NULL, NULL),
(114, 83, 84, 'Uploade/man-male-young-person-icon_24877-30218-1732103538951.jpg', '2024-11-20 13:52:19', 1, 109, NULL),
(115, 83, 84, 'Uploade/recording-1732115807530.wav', '2024-11-20 14:21:47', 1, NULL, 110);

-- --------------------------------------------------------

--
-- بنية الجدول `mymedicalreports`
--

CREATE TABLE `mymedicalreports` (
  `report_id` int(10) NOT NULL,
  `user_id` int(10) NOT NULL,
  `filemannager_id` int(10) NOT NULL,
  `Date` varchar(255) NOT NULL,
  `Heartrate` varchar(255) NOT NULL,
  `FastingBloodSugar` varchar(255) NOT NULL,
  `Haemoglobin` varchar(255) NOT NULL,
  `whitebloodcells` varchar(255) NOT NULL,
  `Bloodpressure` varchar(255) NOT NULL,
  `HDL` varchar(255) NOT NULL,
  `LDL` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `mymedicalreports`
--

INSERT INTO `mymedicalreports` (`report_id`, `user_id`, `filemannager_id`, `Date`, `Heartrate`, `FastingBloodSugar`, `Haemoglobin`, `whitebloodcells`, `Bloodpressure`, `HDL`, `LDL`) VALUES
(64, 83, 201, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(65, 83, 202, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100');

-- --------------------------------------------------------

--
-- بنية الجدول `schedule`
--

CREATE TABLE `schedule` (
  `id` int(10) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Date` varchar(255) NOT NULL,
  `Time` varchar(255) NOT NULL,
  `scedual_id` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `schedule`
--

INSERT INTO `schedule` (`id`, `Name`, `Date`, `Time`, `scedual_id`) VALUES
(84, 'b ', '22/12/2024', '12:00', 1),
(84, 'S S', '22/12/2024', '11:00', 2),
(84, 'ol o', '21/12/2024', '13:00 ', 3),
(84, 'n n', '21/12/2024', '12:00', 4),
(84, 'b b', '21/11/2024', '11:00', 7),
(84, 'n n', '2024-12-01', '10:00', 11),
(84, 'm m', '20/12/2024', '10:30', 12),
(84, 'n n', '21/1/2025', '11:30', 13),
(84, 'n n', '22/1/2025', '11:00', 14),
(84, 'm m', '21/1/2025', '10:00', 15);

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
  `image_id` int(11) DEFAULT NULL,
  `Bio` varchar(1000) DEFAULT NULL,
  `cv_id` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `users`
--

INSERT INTO `users` (`User_id`, `First_name`, `Last_name`, `Email`, `Age`, `Password`, `Type_oftheuser`, `image_id`, `Bio`, `cv_id`) VALUES
(76, 'Ahmad', 'Hawwari', 'ahaw@gmail.com', 22, '$2b$10$tcQq1I1cWR.SIbgzWHTJSugIIjQXASttRE/rlr7POq0AADM/ub.Ey', 'Admin', 56, NULL, 0),
(83, 'bg', 'bg', 'bg@gmail.com', 55, '$2b$10$LIHM8PR57GTh3V./3jo5fuNDwaTIZXF90vLv2jLVdisyLqACLigMC', 'Care recipient', 178, 'I am bg !!!!!', 0),
(84, 'ahmad', 'hawwari', 'ahmadhawwari1092@gmail.com', 22, '$2b$10$WqzfGZKWrhJW8tu72oDhYOuov3hAHII.GmE2XiJ9eZbvSFiHnAxmK', 'Care giver', 64, 'I am a care Giver !', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `caregiverrequesttoadmin`
--
ALTER TABLE `caregiverrequesttoadmin`
  ADD PRIMARY KEY (`Request_id`),
  ADD UNIQUE KEY `email11` (`Email`),
  ADD KEY `cv_id11` (`cv_id`),
  ADD KEY `image_id11` (`image_id`);

--
-- Indexes for table `carerecipientlist`
--
ALTER TABLE `carerecipientlist`
  ADD PRIMARY KEY (`CareRecipientList_id`),
  ADD KEY `Care_giverid11` (`Care_giverid`),
  ADD KEY `11carerecipient_id` (`carerecipient_id`);

--
-- Indexes for table `filemannager`
--
ALTER TABLE `filemannager`
  ADD PRIMARY KEY (`file_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mymedicalreports`
--
ALTER TABLE `mymedicalreports`
  ADD PRIMARY KEY (`report_id`),
  ADD KEY `userid` (`user_id`),
  ADD KEY `fileid` (`filemannager_id`);

--
-- Indexes for table `schedule`
--
ALTER TABLE `schedule`
  ADD PRIMARY KEY (`scedual_id`),
  ADD KEY `userid` (`id`);

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
-- AUTO_INCREMENT for table `caregiverrequesttoadmin`
--
ALTER TABLE `caregiverrequesttoadmin`
  MODIFY `Request_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `carerecipientlist`
--
ALTER TABLE `carerecipientlist`
  MODIFY `CareRecipientList_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `filemannager`
--
ALTER TABLE `filemannager`
  MODIFY `file_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=243;

--
-- AUTO_INCREMENT for table `mymedicalreports`
--
ALTER TABLE `mymedicalreports`
  MODIFY `report_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=66;

--
-- AUTO_INCREMENT for table `schedule`
--
ALTER TABLE `schedule`
  MODIFY `scedual_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `User_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=100;

--
-- قيود الجداول المُلقاة.
--

--
-- قيود الجداول `caregiverrequesttoadmin`
--
ALTER TABLE `caregiverrequesttoadmin`
  ADD CONSTRAINT `cv_id11` FOREIGN KEY (`cv_id`) REFERENCES `filemannager` (`file_id`),
  ADD CONSTRAINT `image_id11` FOREIGN KEY (`image_id`) REFERENCES `filemannager` (`file_id`);

--
-- قيود الجداول `carerecipientlist`
--
ALTER TABLE `carerecipientlist`
  ADD CONSTRAINT `11carerecipient_id` FOREIGN KEY (`carerecipient_id`) REFERENCES `users` (`User_id`),
  ADD CONSTRAINT `Care_giverid11` FOREIGN KEY (`Care_giverid`) REFERENCES `users` (`User_id`);

--
-- قيود الجداول `mymedicalreports`
--
ALTER TABLE `mymedicalreports`
  ADD CONSTRAINT `fileid` FOREIGN KEY (`filemannager_id`) REFERENCES `filemannager` (`file_id`);

--
-- قيود الجداول `schedule`
--
ALTER TABLE `schedule`
  ADD CONSTRAINT `userid` FOREIGN KEY (`id`) REFERENCES `users` (`User_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
