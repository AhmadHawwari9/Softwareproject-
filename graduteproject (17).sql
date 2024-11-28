-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 28 نوفمبر 2024 الساعة 18:31
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
(180, 'test-1732359035085.pdf-1732609457788.pdf', 'test-1732359035085-1732609458192.pdf', './public/Uploade', 'Uploade/test-1732359035085-1732609458192.pdf');

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
(115, 83, 84, 'Uploade/recording-1732115807530.wav', '2024-11-20 17:16:47', 1, NULL, 110),
(116, 83, 84, 'hello', '2024-11-21 13:52:25', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- بنية الجدول `mymedicalreports`
--

CREATE TABLE `mymedicalreports` (
  `report_id` int(10) NOT NULL,
  `user_id` int(10) NOT NULL,
  `filemannager_id` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `mymedicalreports`
--

INSERT INTO `mymedicalreports` (`report_id`, `user_id`, `filemannager_id`) VALUES
(2, 83, 112),
(3, 83, 113),
(4, 83, 114),
(5, 83, 115),
(6, 83, 116),
(10, 84, 120),
(11, 84, 121),
(12, 84, 122),
(13, 84, 123),
(14, 84, 124),
(15, 84, 125),
(16, 84, 126),
(17, 84, 127),
(18, 84, 128),
(19, 84, 129),
(20, 84, 130),
(21, 84, 131),
(22, 84, 132),
(23, 84, 133),
(24, 84, 134),
(25, 84, 135),
(26, 84, 136),
(27, 84, 137),
(28, 84, 138),
(29, 84, 139),
(30, 84, 140),
(31, 84, 141),
(32, 84, 142),
(33, 84, 143),
(34, 84, 144),
(35, 84, 145),
(36, 84, 146),
(37, 84, 147),
(38, 84, 148),
(39, 84, 149),
(40, 83, 179),
(41, 83, 180);

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
(84, 'b b', '22/12/2024', '12:00', 1),
(84, 'S S', '22/12/2024', '11:00', 2),
(84, 'ol o', '21/12/2024', '13:00 ', 3),
(84, 'n n', '21/12/2024', '12:00', 4),
(84, 'b b', '21/11/2024', '11:00', 7),
(84, 'n n', '2024-12-01', '10:00', 11),
(84, 'm m', '20/12/2024', '10:30', 12),
(84, 'n n', '21/1/2025', '11:30', 13),
(84, 'n n', '22/1/2025', '11:00', 14),
(84, 'm m', '21/1/2025', '10:00', 15),
(84, 'm m', '21/12', '9:30', 16),
(84, '.ss', '233', '123', 17),
(84, '.ss', '233', '123', 18),
(84, '.ss', '233', '12', 19),
(84, '.ss', '233', '12', 20),
(84, 'ahmad', '22/11/2025', '11:30', 21),
(84, 'ha', '232', '1', 22),
(84, 'j', '3232', '23', 23),
(84, 'fgfd', '323', '98', 24),
(84, 'fff', '11321', '66', 25),
(84, 'ASa', '233', '323', 27),
(84, '2', '2', '1', 31),
(84, 'mi', '5/12/2024', '10:30', 39),
(84, '9', '9', '9', 40),
(84, '11', '11', '11', 41),
(84, '11', '11', '1', 42);

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
  `Bio` varchar(1000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `users`
--

INSERT INTO `users` (`User_id`, `First_name`, `Last_name`, `Email`, `Age`, `Password`, `Type_oftheuser`, `image_id`, `Bio`) VALUES
(76, 'Ahmad', 'Hawwari', 'a.haw@gmail.com', 22, '$2b$10$tcQq1I1cWR.SIbgzWHTJSugIIjQXASttRE/rlr7POq0AADM/ub.Ey', 'Admin', 56, NULL),
(77, 'sd', 'sd', 'sd@gmail.com', 22, '$2b$10$TENLq9GtczfMypgd40QWn.jRO2lVtnohOj9QQ12UhjWvgfpj.DT7e', 'Care giver', 57, NULL),
(78, 'f', 'hh', 'h@gmail.com', 22, '$2b$10$2MPmPu8nKxdNddplEuCGrOtruFWtAeLNq/UtSGmSjenJtJC6t2gB6', 'Care recipient', 58, NULL),
(79, 'k', 'k', 'k@gmail.com', 60, '$2b$10$m3q5/Rd.CHMUPRw0j8U0M.B4igcrz5bO2uaN74r5kaadlPSxm22MW', 'Care recipient', 59, NULL),
(80, 'v', 'v', 'v@gmail.com', 89, '$2b$10$mClfY/ieqKUcfgtdxEEE7elxNxxABlQSYGyztGeW3v7pHCrtvXqQS', 'Care recipient', 60, NULL),
(81, 'n', 'n', 'n@gmail.com', 56, '$2b$10$ymrOe0fFhgwEG76Gv6d5seTd0.KQQ0PQ7Gyf3SuYuAeSyxcTmwmR.', 'Care recipient', 61, NULL),
(82, 'o', 'ol', 'o@gmail.com', 56, '$2b$10$8/UBq/IhAXNhVbYsG2mouuGVS8MpaiovpgK0jxkh5LShgKi4Lu.hW', 'Care recipient', 62, NULL),
(83, 'bg', 'bg', 'bg@gmail.com', 55, '$2b$10$1CF1dKlL0JxOB6G4lqvedebia/ICotjtyrQ1C8JpKM2a9GaQZC.9u', 'Care recipient', 178, 'I am bg !!!!!'),
(84, 'ahmad', 'hawwari', 'ahmadhawwari1092@gmail.com', 22, '$2b$10$WqzfGZKWrhJW8tu72oDhYOuov3hAHII.GmE2XiJ9eZbvSFiHnAxmK', 'Care giver', 64, 'I am a care Giver !'),
(85, 's', 's', 's@gmail.com', 55, '$2b$10$HanD0Zn3crVwctR06jHKqOuuw.0MSnQWxHXArvwGxSEekqkLKHM5m', 'Care recipient', 65, NULL),
(87, 'kj', 'kj', 'kj@gmail.com', 22, '$2b$10$lkzJwu5wEMHpjviENTnb9eTx3dDM4Eem8iRTxejqsmap5WtN/XSey', 'Care giver', 67, NULL);

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
-- AUTO_INCREMENT for table `filemannager`
--
ALTER TABLE `filemannager`
  MODIFY `file_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=181;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;

--
-- AUTO_INCREMENT for table `mymedicalreports`
--
ALTER TABLE `mymedicalreports`
  MODIFY `report_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `schedule`
--
ALTER TABLE `schedule`
  MODIFY `scedual_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

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
-- قيود الجداول `mymedicalreports`
--
ALTER TABLE `mymedicalreports`
  ADD CONSTRAINT `fileid` FOREIGN KEY (`filemannager_id`) REFERENCES `filemannager` (`file_id`);

--
-- قيود الجداول `schedule`
--
ALTER TABLE `schedule`
  ADD CONSTRAINT `userid` FOREIGN KEY (`id`) REFERENCES `users` (`User_id`);

--
-- قيود الجداول `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `imageid` FOREIGN KEY (`image_id`) REFERENCES `filemannager` (`file_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
