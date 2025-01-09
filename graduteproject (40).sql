-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 09 يناير 2025 الساعة 14:18
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
-- بنية الجدول `articles`
--

CREATE TABLE `articles` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `articles`
--

INSERT INTO `articles` (`id`, `title`, `content`, `image_path`, `created_at`) VALUES
(1, 'Overview', 'Heart disease is the leading cause of death for both men and women in the United States. Take steps today to lower your risk of heart disease.\n\nTo help prevent heart disease, you can:\n\n• Eat a heart-healthy diet\n• Get active\n• Stay at a healthy weight\n• Quit smoking and stay away from secondhand smoke\n• Control your cholesterol, blood glucose (sugar), and blood pressure\n• Drink alcohol only in moderation\n• Manage stress\n• Get enough sleep\n\nAm I at risk for heart disease?\n\nAnyone can get heart disease, but you’re at higher risk if you:\n\n• Have high cholesterol, high blood pressure, or diabetes\n• Smoke\n• Have overweight or obesity\n• Don\'t get enough physical activity\n• Don\'t eat a healthy diet\n• Had a condition called preeclampsia during pregnancy\n\nYour age and family history also affect your risk for heart disease. Your risk is higher if:\n\n• You’re a woman over age 55\n• You’re a man over age 45\n• Your father or brother had heart disease before age 55\n• Your mother or sister had heart disease before age 65\n\nBut the good news is there\'s a lot you can do to prevent heart disease.\n\nWhat Is Heart Disease?\n\nWhen people talk about heart disease, they’re usually talking about coronary heart disease (CHD). It’s also sometimes called coronary artery disease (CAD). This is the most common type of heart disease.\n\nWhen someone has CHD, the coronary arteries (tubes) that take blood to the heart are narrow or blocked, which makes it hard for oxygen-rich blood to get to the heart. This happens when cholesterol and fatty material, called plaque, build up inside the arteries.\n\nSeveral things can lead to plaque building up inside your arteries, including:\n\n• Too much cholesterol in the blood\n• High blood pressure\n• Smoking\n• Too much sugar in the blood because of diabetes\n\nWhen plaque blocks an artery, it’s hard for blood to flow to the heart. A blocked artery can cause chest pain or a heart attack. Learn more about CHD.', 'Uploade/istockphoto-1266230179-612x612-new.jpg', '2024-12-08 07:05:10'),
(2, '8 Tips for Healthy Eating', 'These 8 practical tips cover the basics of healthy eating and can help you make healthier choices.\n\n1. Base your meals on higher fibre starchy carbohydrates\nStarchy carbohydrates should make up just over a third of the food you eat. They include potatoes, bread, rice, pasta, and cereals. Choose higher fibre or wholegrain varieties for extra health benefits.\n\n2. Eat lots of fruit and veg\nEat at least 5 portions of a variety of fruit and veg every day. Fresh, frozen, canned, dried, or juiced all count towards your daily intake.\n\n3. Eat more fish, including a portion of oily fish\nFish is a good source of protein and contains many vitamins and minerals. Aim for at least 2 portions of fish a week, including at least 1 portion of oily fish.\n\n4. Cut down on saturated fat and sugar\nLimit your intake of saturated fat to prevent health issues. Regularly consuming sugary foods increases the risk of obesity and tooth decay.\n\n5. Eat less salt: no more than 6g a day for adults\nConsuming too much salt can raise blood pressure. Try reducing your salt intake to reduce the risk of heart disease or stroke.\n\n6. Get active and be a healthy weight\nRegular exercise helps reduce the risk of serious health conditions. Being active is key for your overall health and wellbeing.\n\n7. Do not get thirsty\nStay hydrated by drinking 6 to 8 glasses of water a day. This helps keep your body functioning at its best.\n\n8. Do not skip breakfast\nA healthy breakfast is important to start your day right. It provides the energy and nutrients needed for good health.\n\nFollow these tips and make healthier choices every day!', 'Uploade/healthy-food-restaurants-640b5d1e9e8fc.png', '2024-12-08 07:06:17'),
(3, 'Brain Health Tips', 'The brain controls thought, movement, and emotion. Use the following brain health tips to help protect it.\n\nAt 3 pounds, the brain isn’t very large, but it is a powerhouse. Those 3 pounds hold your personality and all your memories. The brain coordinates your thoughts, emotions, and movements.\n\nBillions of nerve cells in your brain make it all possible. Called neurons, these brain cells send information to the rest of your body. If they aren’t working properly, your muscles may not move smoothly, and you might lose feeling in parts of your body. Your thinking could slow.\n\nThe brain doesn’t replace neurons that are damaged or destroyed. So it’s important to take care of them. Head injuries, drug use, and health conditions like Alzheimer’s and Parkinson’s disease can cause brain cell damage or loss.\n\nDeveloping brain health habits is a key way to keep your brain healthy. That includes following safety measures and keeping your brain active and engaged. Try these brain health tips:\n\n1. Work up a sweat\nPeople who are physically active are more likely to keep their minds sharp. Regular physical activity also helps improve balance, flexibility, strength, energy, and mood. Research suggests that exercise may lower the risk of developing Alzheimer’s disease.\n\n2. Protect your head\nA brain injury can have a significant long-term impact on a person’s life. To protect your brain, always wear a helmet when doing an activity where there’s a risk of head injuries.\n\n3. Take care of your health\nSome medical conditions like diabetes, heart disease, and high blood pressure can increase the risk of brain problems. Follow your healthcare professional’s directions to manage them.\n\n4. Meet up with friends\nSocial interaction helps ward off depression and stress, which can worsen memory loss. Social isolation has been linked to a higher risk of cognitive decline.\n\n5. Get a good night’s rest\nSleep is essential for brain function and memory. Aim for 7 to 9 hours of sleep each night to improve cognitive function and prevent mental decline.\n\n6. Make a salad\nEating a healthy diet, such as the MIND diet, can help improve mental focus and slow cognitive decline. This diet includes leafy greens, berries, nuts, and fish, while limiting butter and sweets.\n\n7. Challenge your brain\nJust like physical exercise, mental activities such as crossword puzzles, reading, or learning an instrument help keep your brain sharp.\n\n8. Be careful with medicines and limit alcohol\nSubstances like alcohol and drugs can interfere with brain function. Limit alcohol intake to up to one drink a day for women and two for men, and always follow medicine directions carefully.\n\n', 'Uploade/how-the-human-brain-decides-what-to-remember.jpg', '2024-12-08 07:08:22');

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
(50, 'ahmad', 'haw', 'jh18@gmail.com', 30, '$2b$10$.nYS/XLHEHtvGJx8gjiUhOTyKq5Pxo5N17ddg9gcTPgLR4VJDObLO', 'Care giver', 241, 242),
(53, 'ahmad', 'haw', 'jh21@gmail.com', 0, '$2b$10$.nYS/XLHEHtvGJx8gjiUhOTyKq5Pxo5N17ddg9gcTPgLR4VJDObLO', 'Hospital', 241, 242),
(56, 'alwatany', 'hospital', 'alwatany@gmail.com', 0, '$2b$10$Ujx3YmWfSy6YcV9ofpFgte5JQX3A682yKU./TVQuf3nC.Bl3bgbp6', 'Hospital', 292, 293),
(57, 's', 's', 's2@gmail.com', 30, '$2b$10$ViGHm/DGlaQ7TxFMh.r18OrYdMe1iVTv8IYQERUdJLe3qgDTq.O/W', 'Care giver', 295, 296),
(58, 's3', 's', 's3@gmail.com', 30, '$2b$10$s4FNm.Rh0WJJg20w7NtOUeAZ0e9UEOF7kBWdStodo6ndiZDXqer3i', 'Care giver', 297, 298),
(59, 's', 's', 's5@gmail.com', 30, '$2b$10$b41a/GOyAbrfgZkSQ/xgSetI5GJrU9LQethmzPi0.Bb8MAIICXUFO', 'Care giver', 299, 300),
(60, 'h', 'h', 'h2@gmail.com', 30, '$2b$10$.feT3yXaAgOaR3Wd2bH6U.Wwa6UwFY1uoAaHl8hnDVt7wCqaDtEUC', 'Care giver', 304, 305),
(61, 'h', 'h', 'h3@gmail.com', 30, '$2b$10$ktPq3OIWTeanHTnaJ0b.1u6hzNnHw7Pof7kf81vRm0gkJQ7/2LK3a', 'Care giver', 306, 307),
(62, 'h', 'h', 'h4@gmail.com', 30, '$2b$10$0aet4PVRRkbCzajhMuTU/eVvVL.8oBUnK.u/1JTXw8IdRGl8Xurvm', 'Care giver', 308, 309),
(63, 'h', 'h', 'h5@gmail.com', 30, '$2b$10$mw2GVd/20iBZooGqhu.lWeebB/IosKA7VBPtt4gRIr4SEM3BS1JtC', 'Care giver', 310, 311),
(64, 'h', 'h', 'h6@gmail.com', 30, '$2b$10$wyZMUBBk8R60ZOC1AiLgneeZ5Wa1lzq/b42zWsNkvzQSbaHccf8tm', 'Care giver', 312, 313),
(65, 'ho', 'h', 'ho1@gmail.com', 0, '$2b$10$a79bUEk7XHqvl3v7yqryZ.4ZI9v7ZaNdjIAHO4nsub9C7fwj/ERoK', 'Hospital', 314, 315),
(66, 'h', 'h', 'ho2@gmail.com', 0, '$2b$10$GYpqHu40iGhS5Cj.b4fDpeZqqcHToXRFPu67K9O4N52s53tgdb87.', 'Hospital', 316, 317),
(69, 'g', 'g', 'ho4@gmail.com', 0, '$2b$10$bbxJ3feQdjH0DxNvpd4SVO6W2f7eZzgpSEq7BGF1FkiVV5jSquPny', 'Hospital', 322, 323),
(70, 'g', 'g', 'ho5@gmail.com', 0, '$2b$10$ThFiQbp5bwOuGM7zYu.n2ewf2u5CSJ4fFQHHArX6L2Os4KAK9CkgG', 'Hospital', 324, 325),
(71, 'ho7', 'h', 'ho7@gmail.com', 0, '$2b$10$NvTpzN1C0UWQD.eGHZXf6OjY02zEF6gkzbi/8xJgQvu5TYRJVvUMO', 'Hospital', 326, 327);

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
(52, 84, 83);

-- --------------------------------------------------------

--
-- بنية الجدول `doctor_availability`
--

CREATE TABLE `doctor_availability` (
  `id` int(10) NOT NULL,
  `doctor_id` int(10) NOT NULL,
  `days` varchar(255) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `doctor_availability`
--

INSERT INTO `doctor_availability` (`id`, `doctor_id`, `days`, `start_time`, `end_time`) VALUES
(10, 84, 'Sunday, Monday, Tuesday, Wednesday, Thursday', '08:30:00', '15:00:00');

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
(203, '1.png', '1-1733121334926.png', './public/Uploade', 'Uploade/1-1733121334926.png'),
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
(242, 'hardware presentation.pdf', 'hardware presentation-1733215183809.pdf', './public/Uploade', 'Uploade/hardware presentation-1733215183809.pdf'),
(243, 'healthy-food-restaurants-640b5d1e9e8fc.png', 'healthy-food-restaurants-640b5d1e9e8fc-new.png', './public/Uploade', 'Uploade\\healthy-food-restaurants-640b5d1e9e8fc-new.png1730720054577.jpg'),
(244, 'istockphoto-1266230179-612x612.jpg', 'istockphoto-1266230179-612x612-new.jpg', './public/Uploade', 'Uploade\\istockphoto-1266230179-612x612-new.jpg'),
(247, 'how-the-human-brain-decides-what-to-remember.jpg', 'how-the-human-brain-decides-what-to-remember-new.jpg', './public/Uploade', 'Uploade\\how-the-human-brain-decides-what-to-remember-new.jpg'),
(248, 'istockphoto-1266230179-612x612.jpg', 'istockphoto-1266230179-612x612-1733666925344.jpg', './public/Uploade', 'Uploade/istockphoto-1266230179-612x612-1733666925344.jpg'),
(249, 'istockphoto-1266230179-612x612.jpg', 'istockphoto-1266230179-612x612-1733666976612.jpg', './public/Uploade', 'Uploade/istockphoto-1266230179-612x612-1733666976612.jpg'),
(250, 'istockphoto-1266230179-612x612.jpg', 'istockphoto-1266230179-612x612-1733667928591.jpg', './public/Uploade', 'Uploade/istockphoto-1266230179-612x612-1733667928591.jpg'),
(251, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1733668951769.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1733668951769.png'),
(252, 'istockphoto-1266230179-612x612.jpg', 'istockphoto-1266230179-612x612-1733669167635.jpg', './public/Uploade', 'Uploade/istockphoto-1266230179-612x612-1733669167635.jpg'),
(253, 'istockphoto-1266230179-612x612.jpg', 'istockphoto-1266230179-612x612-1733669251463.jpg', './public/Uploade', 'Uploade/istockphoto-1266230179-612x612-1733669251463.jpg'),
(254, 'istockphoto-1266230179-612x612.jpg', 'istockphoto-1266230179-612x612-1733669270515.jpg', './public/Uploade', 'Uploade/istockphoto-1266230179-612x612-1733669270515.jpg'),
(255, 'istockphoto-1266230179-612x612.jpg', 'istockphoto-1266230179-612x612-1733669422426.jpg', './public/Uploade', 'Uploade/istockphoto-1266230179-612x612-1733669422426.jpg'),
(256, 'istockphoto-1266230179-612x612.jpg', 'istockphoto-1266230179-612x612-1733669488855.jpg', './public/Uploade', 'Uploade/istockphoto-1266230179-612x612-1733669488855.jpg'),
(257, 'istockphoto-1266230179-612x612.jpg', 'istockphoto-1266230179-612x612-1733669581099.jpg', './public/Uploade', 'Uploade/istockphoto-1266230179-612x612-1733669581099.jpg'),
(258, 'istockphoto-1266230179-612x612.jpg', 'istockphoto-1266230179-612x612-1733669743916.jpg', './public/Uploade', 'Uploade/istockphoto-1266230179-612x612-1733669743916.jpg'),
(259, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1733670034315.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1733670034315.png'),
(260, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1733670084670.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1733670084670.png'),
(261, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1733732726938.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1733732726938.png'),
(263, 'reportform-1732957247289.pdf-1734434882419.pdf', 'reportform-1732957247289-1734434882284.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1734434882284.pdf'),
(264, 'hardware presentation-1733215183809.pdf-1734445499396.pdf', 'hardware presentation-1733215183809-1734445500148.pdf', './public/Uploade', 'Uploade/hardware presentation-1733215183809-1734445500148.pdf'),
(265, 'reportform-1732957472234.pdf-1734445513899.pdf', 'reportform-1732957472234-1734445514617.pdf', './public/Uploade', 'Uploade/reportform-1732957472234-1734445514617.pdf'),
(266, 'reportform-1732957472234.pdf-1734507732546.pdf', 'reportform-1732957472234-1734507733715.pdf', './public/Uploade', 'Uploade/reportform-1732957472234-1734507733715.pdf'),
(267, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1735128227292.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1735128227292.png'),
(268, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1735128294847.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1735128294847.png'),
(274, 'avatar-3637425_1280.png', '1735299009538-avatar-3637425_1280.png', './public/Uploade', 'Uploade/1735299009538-avatar-3637425_1280.png'),
(275, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1735299420218.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1735299420218.png'),
(276, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1735304364559.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735304364559.pdf'),
(277, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1735304367208.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735304367208.pdf'),
(278, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1735304749597.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735304749597.pdf'),
(279, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1735304752355.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735304752355.pdf'),
(280, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1735385504182.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735385504182.pdf'),
(281, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1735385506492.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735385506492.pdf'),
(282, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1735385802661.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1735385802661.png'),
(283, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1735387288607.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1735387288607.jpg'),
(284, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1735728075915.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1735728075915.jpg'),
(285, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1735729860892.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1735729860892.png'),
(286, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1735732624944.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1735732624944.png'),
(287, 'Screenshot 2024-09-10 140005-Photoroom.png', 'Screenshot 2024-09-10 140005-Photoroom-1735732984641.png', './public/Uploade', 'Uploade/Screenshot 2024-09-10 140005-Photoroom-1735732984641.png'),
(288, 'Screenshot 2023-08-29 113244.png', 'Screenshot 2023-08-29 113244-1735733432307.png', './public/Uploade', 'Uploade/Screenshot 2023-08-29 113244-1735733432307.png'),
(289, 'Screenshot 2024-09-10 140005-Photoroom.png', 'Screenshot 2024-09-10 140005-Photoroom-1735733627614.png', './public/Uploade', 'Uploade/Screenshot 2024-09-10 140005-Photoroom-1735733627614.png'),
(290, 'reportform-1732957247289-1734434858473.pdf', 'reportform-1732957247289-1734434858473-1735746723231.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1734434858473-1735746723231.pdf'),
(291, 'reportform-1732957247289-1734434858473.pdf', 'reportform-1732957247289-1734434858473-1735746723725.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1734434858473-1735746723725.pdf'),
(292, 'reportform-1732957247289.pdf', 'reportform-1732957247289-1735808228260.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1735808228260.pdf'),
(293, 'reportform-1732957247289.pdf', 'reportform-1732957247289-1735808228449.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1735808228449.pdf'),
(294, 'project_logo.png', 'project_logo-1735894946230.png', './public/Uploade', 'Uploade/project_logo-1735894946230.png'),
(295, 'hardware presentation-1733121334977-1735304752355.pdf', 'hardware presentation-1733121334977-1735304752355-1735902802049.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735304752355-1735902802049.pdf'),
(296, 'hardware presentation-1733121334977-1735304752355.pdf', 'hardware presentation-1733121334977-1735304752355-1735902806484.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735304752355-1735902806484.pdf'),
(297, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1735903118520.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735903118520.pdf'),
(298, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1735903122943.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735903122943.pdf'),
(299, 'reportform-1732957247289-1735808228449.pdf', 'reportform-1732957247289-1735808228449-1735906404060.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1735808228449-1735906404060.pdf'),
(300, 'reportform-1732957247289-1735808228449.pdf', 'reportform-1732957247289-1735808228449-1735906404281.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1735808228449-1735906404281.pdf'),
(301, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1735982776501.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1735982776501.jpg'),
(302, 'recording.wav', 'recording-1735982789568.wav', './public/Uploade', 'Uploade/recording-1735982789568.wav'),
(303, 'project_logo.png', 'project_logo-1736066313155.png', './public/Uploade', 'Uploade/project_logo-1736066313155.png'),
(304, 'project_logo.png', 'project_logo-1736069774601.png', './public/Uploade', 'Uploade/project_logo-1736069774601.png'),
(305, 'CEGP-AbstractForm (1).pdf', 'CEGP-AbstractForm (1)-1736069774601.pdf', './public/Uploade', 'Uploade/CEGP-AbstractForm (1)-1736069774601.pdf'),
(306, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1736070114946.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1736070114946.pdf'),
(307, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1736070117032.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1736070117032.pdf'),
(308, 'project_logo.png', 'project_logo-1736070152347.png', './public/Uploade', 'Uploade/project_logo-1736070152347.png'),
(309, 'CEGP-AbstractForm (1).pdf', 'CEGP-AbstractForm (1)-1736070152347.pdf', './public/Uploade', 'Uploade/CEGP-AbstractForm (1)-1736070152347.pdf'),
(310, 'hardware presentation-1733121334977-1735304752355.pdf', 'hardware presentation-1733121334977-1735304752355-1736070476268.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735304752355-1736070476268.pdf'),
(311, 'hardware presentation-1733121334977-1735304752355.pdf', 'hardware presentation-1733121334977-1735304752355-1736070478558.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1735304752355-1736070478558.pdf'),
(312, 'project_logo.png', 'project_logo-1736070517768.png', './public/Uploade', 'Uploade/project_logo-1736070517768.png'),
(313, 'CEGP-AbstractForm (1).pdf', 'CEGP-AbstractForm (1)-1736070517768.pdf', './public/Uploade', 'Uploade/CEGP-AbstractForm (1)-1736070517768.pdf'),
(314, 'project_logo.png', 'project_logo-1736074576867.png', './public/Uploade', 'Uploade/project_logo-1736074576867.png'),
(315, 'CEGP-AbstractForm (1).pdf', 'CEGP-AbstractForm (1)-1736074576867.pdf', './public/Uploade', 'Uploade/CEGP-AbstractForm (1)-1736074576867.pdf'),
(316, 'reportform-1732957472234-1734445514617.pdf', 'reportform-1732957472234-1734445514617-1736074817505.pdf', './public/Uploade', 'Uploade/reportform-1732957472234-1734445514617-1736074817505.pdf'),
(317, 'reportform-1732957472234-1734445514617.pdf', 'reportform-1732957472234-1734445514617-1736074817817.pdf', './public/Uploade', 'Uploade/reportform-1732957472234-1734445514617-1736074817817.pdf'),
(318, 'reportform-1732957472234-1734445514617.pdf', 'reportform-1732957472234-1734445514617-1736074994719.pdf', './public/Uploade', 'Uploade/reportform-1732957472234-1734445514617-1736074994719.pdf'),
(319, 'reportform-1732957472234-1734445514617.pdf', 'reportform-1732957472234-1734445514617-1736074995047.pdf', './public/Uploade', 'Uploade/reportform-1732957472234-1734445514617-1736074995047.pdf'),
(320, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1736075141190.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1736075141190.pdf'),
(321, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1736075144717.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1736075144717.pdf'),
(322, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1736075255819.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1736075255819.pdf'),
(323, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1736075259271.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1736075259271.pdf'),
(324, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1736075364900.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1736075364900.pdf'),
(325, 'hardware presentation-1733121334977.pdf', 'hardware presentation-1733121334977-1736075369199.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1736075369199.pdf'),
(326, 'project_logo.png', 'project_logo-1736075406307.png', './public/Uploade', 'Uploade/project_logo-1736075406307.png'),
(327, 'CEGP-AbstractForm (1).pdf', 'CEGP-AbstractForm (1)-1736075406308.pdf', './public/Uploade', 'Uploade/CEGP-AbstractForm (1)-1736075406308.pdf'),
(328, 'hardware presentation-1733121334977.pdf-1736078820893.pdf', 'hardware presentation-1733121334977-1736078821111.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1736078821111.pdf'),
(329, 'reportform-1732957247289-1734434858473.pdf-1736078831405.pdf', 'reportform-1732957247289-1734434858473-1736078831742.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1734434858473-1736078831742.pdf'),
(330, 'reportform-1732957247289-1735808228449.pdf-1736078843496.pdf', 'reportform-1732957247289-1735808228449-1736078843727.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1735808228449-1736078843727.pdf'),
(331, 'reportform-1732957472234-1734445514617.pdf-1736079268279.pdf', 'reportform-1732957472234-1734445514617-1736079268497.pdf', './public/Uploade', 'Uploade/reportform-1732957472234-1734445514617-1736079268497.pdf'),
(332, 'reportform.pdf-1736084434679.pdf', 'reportform-1736084434923.pdf', './public/Uploade', 'Uploade/reportform-1736084434923.pdf'),
(333, 'reportform-1732957247289-1734434858473.pdf-1736084458530.pdf', 'reportform-1732957247289-1734434858473-1736084458713.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1734434858473-1736084458713.pdf'),
(334, 'reportform-1732957247289-1735808228449.pdf-1736084486179.pdf', 'reportform-1732957247289-1735808228449-1736084486319.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1735808228449-1736084486319.pdf'),
(335, 'reportform-1732957247289.pdf-1736084495761.pdf', 'reportform-1732957247289-1736084495930.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1736084495930.pdf'),
(336, 'reportform.pdf-1736084572901.pdf', 'reportform-1736084573040.pdf', './public/Uploade', 'Uploade/reportform-1736084573040.pdf'),
(337, 'reportform-1732957472234-1734445514617.pdf-1736084623908.pdf', 'reportform-1732957472234-1734445514617-1736084624125.pdf', './public/Uploade', 'Uploade/reportform-1732957472234-1734445514617-1736084624125.pdf'),
(338, 'reportform.pdf-1736085042056.pdf', 'reportform-1736085042196.pdf', './public/Uploade', 'Uploade/reportform-1736085042196.pdf'),
(339, 'hardware presentation-1733121334977.pdf-1736085057355.pdf', 'hardware presentation-1733121334977-1736085057499.pdf', './public/Uploade', 'Uploade/hardware presentation-1733121334977-1736085057499.pdf'),
(340, 'reportform-1732957247289-1735808228449.pdf-1736085065636.pdf', 'reportform-1732957247289-1735808228449-1736085065803.pdf', './public/Uploade', 'Uploade/reportform-1732957247289-1735808228449-1736085065803.pdf'),
(341, 'project_logo.png', 'project_logo-1736155359161.png', './public/Uploade', 'Uploade/project_logo-1736155359161.png'),
(342, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1736155413034.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1736155413034.png'),
(343, 'project_logo.png', 'project_logo-1736155523654.png', './public/Uploade', 'Uploade/project_logo-1736155523654.png'),
(344, 'project_logo.png', 'project_logo-1736155632617.png', './public/Uploade', 'Uploade/project_logo-1736155632617.png'),
(345, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1736155671840.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1736155671840.jpg'),
(346, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1736155724878.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1736155724878.jpg'),
(347, 'project_logo.png', 'project_logo-1736155752618.png', './public/Uploade', 'Uploade/project_logo-1736155752618.png'),
(348, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1736155914120.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1736155914120.jpg'),
(349, 'project_logo.png', 'project_logo-1736156000411.png', './public/Uploade', 'Uploade/project_logo-1736156000411.png'),
(350, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1736160399414.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1736160399414.jpg'),
(351, 'avatar-3637425_1280.png', 'avatar-3637425_1280-1736160892043.png', './public/Uploade', 'Uploade/avatar-3637425_1280-1736160892043.png'),
(352, 'image.jpg', 'image-1736161734875.jpg', './public/Uploade', 'Uploade/image-1736161734875.jpg'),
(353, 'smiling-young-man-illustration_1308-174669.jpg', 'smiling-young-man-illustration_1308-174669-1736161779828.jpg', './public/Uploade', 'Uploade/smiling-young-man-illustration_1308-174669-1736161779828.jpg'),
(354, 'image.jpg', 'image-1736162292564.jpg', './public/Uploade', 'Uploade/image-1736162292564.jpg'),
(355, 'recording.wav', 'recording-1736165128642.wav', './public/Uploade', 'Uploade/recording-1736165128642.wav'),
(356, 'recording.wav', 'recording-1736173664067.wav', './public/Uploade', 'Uploade/recording-1736173664067.wav'),
(357, 'recording.wav', 'recording-1736243095759.wav', './public/Uploade', 'Uploade/recording-1736243095759.wav'),
(358, 'recording.wav', 'recording-1736243116036.wav', './public/Uploade', 'Uploade/recording-1736243116036.wav'),
(359, 'recording.wav', 'recording-1736243365041.wav', './public/Uploade', 'Uploade/recording-1736243365041.wav'),
(360, 'recording.wav', 'recording-1736243470711.wav', './public/Uploade', 'Uploade/recording-1736243470711.wav'),
(361, 'recording.wav', 'recording-1736246229204.wav', './public/Uploade', 'Uploade/recording-1736246229204.wav'),
(362, 'recording.wav', 'recording-1736246710607.wav', './public/Uploade', 'Uploade/recording-1736246710607.wav'),
(363, 'recording.wav', 'recording-1736246805150.wav', './public/Uploade', 'Uploade/recording-1736246805150.wav'),
(364, 'recording.wav', 'recording-1736248537802.wav', './public/Uploade', 'Uploade/recording-1736248537802.wav'),
(365, 'recording.wav', 'recording-1736249168559.wav', './public/Uploade', 'Uploade/recording-1736249168559.wav'),
(366, 'recording.wav', 'recording-1736249941335.wav', './public/Uploade', 'Uploade/recording-1736249941335.wav'),
(367, 'recording.wav', 'recording-1736250337719.wav', './public/Uploade', 'Uploade/recording-1736250337719.wav'),
(368, 'recording.wav', 'recording-1736255626056.wav', './public/Uploade', 'Uploade/recording-1736255626056.wav'),
(369, 'recording.wav', 'recording-1736260324943.wav', './public/Uploade', 'Uploade/recording-1736260324943.wav'),
(370, 'recording.wav', 'recording-1736260710179.wav', './public/Uploade', 'Uploade/recording-1736260710179.wav'),
(371, 'recording.wav', 'recording-1736261719602.wav', './public/Uploade', 'Uploade/recording-1736261719602.wav'),
(372, 'recording.wav', 'recording-1736411736765.wav', './public/Uploade', 'Uploade/recording-1736411736765.wav'),
(373, 'recording.wav', 'recording-1736421222464.wav', './public/Uploade', 'Uploade/recording-1736421222464.wav'),
(374, 'recording.wav', 'recording-1736423359771.wav', './public/Uploade', 'Uploade/recording-1736423359771.wav'),
(375, 'recording.wav', 'recording-1736423594998.wav', './public/Uploade', 'Uploade/recording-1736423594998.wav'),
(376, 'recording.wav', 'recording-1736423606050.wav', './public/Uploade', 'Uploade/recording-1736423606050.wav'),
(377, 'recording.wav', 'recording-1736423660823.wav', './public/Uploade', 'Uploade/recording-1736423660823.wav'),
(378, 'recording.wav', 'recording-1736424156678.wav', './public/Uploade', 'Uploade/recording-1736424156678.wav'),
(379, 'recording.wav', 'recording-1736424608288.wav', './public/Uploade', 'Uploade/recording-1736424608288.wav'),
(380, 'recording.wav', 'recording-1736424702483.wav', './public/Uploade', 'Uploade/recording-1736424702483.wav');

-- --------------------------------------------------------

--
-- بنية الجدول `hospitals`
--

CREATE TABLE `hospitals` (
  `id` int(11) NOT NULL,
  `User_id` int(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  `image_id` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `clinics` text DEFAULT NULL,
  `workingHours` varchar(255) DEFAULT NULL,
  `doctors` text DEFAULT NULL,
  `contact` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `hospitals`
--

INSERT INTO `hospitals` (`id`, `User_id`, `name`, `image_id`, `location`, `description`, `clinics`, `workingHours`, `doctors`, `contact`) VALUES
(2, 102, 'Green Valley Hospital', '268', '456 Green Valley Road, Greenfield', 'A family-oriented hospital offering a wide range of healthcare services.', 'Orthopedic Clinic, Maternity Clinic, Dental Care', 'Mon-Fri: 8:00 AM - 5:00 PM', 'Dr. Emma Brown (Orthopedist), Dr. Noah Green (Dentist)', '+0987654321'),
(12, 101, 'rafedia', '275', 'nablus', 'description', '1,2,3', '8-23', 'Ahmad hawwari', '123456789'),
(16, 108, 'rafidia', NULL, 'nablus', '.....', '......', '8-19', 'ahmad', '123456789'),
(17, 114, 'hj19', NULL, 'Ramallah', '........', '1,2,3', '8-23', 'ahmad mohmmad', '+123456789');

-- --------------------------------------------------------

--
-- بنية الجدول `medication_schedule`
--

CREATE TABLE `medication_schedule` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `medicine_name` varchar(255) NOT NULL,
  `dosage` varchar(255) NOT NULL,
  `timings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`timings`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `medication_schedule`
--

INSERT INTO `medication_schedule` (`id`, `patient_id`, `doctor_id`, `medicine_name`, `dosage`, `timings`, `created_at`) VALUES
(2, 83, 84, 'Paracetamol', '500 mg', '[\"08:00:00\", \"13:00:00\", \"19:00:00\"]', '2024-12-21 11:03:30'),
(3, 83, 100, 'Ibuprofen', '200 mg', '[\"11:15:00\", \"14:00:00\", \"20:00:00\"]', '2024-12-21 11:03:30'),
(4, 83, 84, 'Amoxicillin', '250 mg', '[\"08:00:00\",\"14:00:00\",\"20:00:00\"]', '2024-12-22 06:37:47');

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
(105, 83, 84, 'Uploade/man-male-young-person-icon_24877-30218-1732006907814.jpg', '2024-11-19 11:01:47', 1, 101, NULL),
(113, 83, 84, 'hi', '2024-11-20 13:52:06', 1, NULL, NULL),
(114, 83, 84, 'Uploade/man-male-young-person-icon_24877-30218-1732103538951.jpg', '2024-11-20 13:52:19', 1, 109, NULL),
(116, 83, 76, 'hi', '2024-12-17 14:25:07', 1, NULL, NULL),
(117, 83, 84, 'hi', '2024-12-17 14:25:20', 1, NULL, NULL),
(118, 83, 84, 'hello', '2024-12-17 15:09:00', 1, NULL, NULL),
(119, 83, 76, 'ho', '2025-01-04 11:05:16', 1, NULL, NULL),
(120, 76, 83, 'hi', '2025-01-04 11:06:40', 1, NULL, NULL),
(121, 83, 76, 'Uploade/smiling-young-man-illustration_1308-174669-1735982776501.jpg', '2025-01-04 11:26:16', 1, 301, NULL),
(123, 84, 83, 'Uploade/smiling-young-man-illustration_1308-174669-1736160399414.jpg', '2025-01-06 12:46:39', 1, 350, NULL),
(124, 83, 84, 'hhi', '2025-01-06 12:49:01', 1, NULL, NULL),
(125, 84, 83, 'Uploade/avatar-3637425_1280-1736160892043.png', '2025-01-06 12:54:52', 1, 351, NULL),
(126, 83, 84, 'Uploade/image-1736161734875.jpg', '2025-01-06 13:08:54', 1, 352, NULL),
(127, 84, 83, 'hi', '2025-01-06 13:09:33', 1, NULL, NULL),
(128, 84, 83, 'Uploade/smiling-young-man-illustration_1308-174669-1736161779828.jpg', '2025-01-06 13:09:39', 1, 353, NULL),
(129, 83, 84, 'Uploade/image-1736162292564.jpg', '2025-01-06 13:18:12', 1, 354, NULL),
(132, 84, 83, 'hhh', '2025-01-06 16:27:53', 1, NULL, NULL),
(140, 84, 83, 'hi', '2025-01-07 12:50:11', 1, NULL, NULL),
(156, 83, 84, 'Uploade/recording-1736424608288.wav', '2025-01-09 14:10:08', 1, NULL, 379),
(157, 84, 83, 'Uploade/recording-1736424702483.wav', '2025-01-09 14:11:42', 0, NULL, 380);

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
(69, 83, 263, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(71, 83, 265, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(72, 83, 266, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(73, 83, 328, '', '', '', '', '', '', '', ''),
(74, 83, 329, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(75, 83, 330, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(76, 83, 331, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(77, 83, 332, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(78, 83, 333, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(79, 83, 334, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(80, 83, 335, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(81, 83, 336, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(82, 83, 337, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(83, 83, 338, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100'),
(84, 83, 339, '', '', '', '', '', '', '', ''),
(85, 83, 340, '21/12/2024', '75', '90', '13.5', '5200', '120/80', '55', '100');

-- --------------------------------------------------------

--
-- بنية الجدول `notifications`
--

CREATE TABLE `notifications` (
  `Notifications_id` int(10) NOT NULL,
  `Sender_id` int(10) NOT NULL,
  `reciver_id` int(10) NOT NULL,
  `typeofnotifications` varchar(255) NOT NULL,
  `is_read` int(10) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `medication_time` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `notifications`
--

INSERT INTO `notifications` (`Notifications_id`, `Sender_id`, `reciver_id`, `typeofnotifications`, `is_read`, `created_at`, `medication_time`) VALUES
(510, 83, 84, 'approve_unfollow_request', 1, '2024-12-24 09:43:23', NULL),
(595, 100, 83, 'Reminder: It\'s time to take your medication: Ibuprofen', 1, '2024-12-24 13:12:28', '14:00:00'),
(628, 83, 84, 'approve_unfollow_request', 1, '2024-12-25 09:00:44', NULL),
(632, 83, 84, 'approve_unfollow_request', 1, '2024-12-25 09:15:10', NULL),
(700, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2024-12-25 22:00:00', '08:00:00'),
(701, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2024-12-25 22:00:00', '13:00:00'),
(703, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2024-12-25 22:00:00', '08:00:00'),
(720, 100, 83, 'Reminder: It\'s time to take your medication: Ibuprofen', 1, '2024-12-25 22:00:00', '11:15:00'),
(721, 100, 83, 'Reminder: It\'s time to take your medication: Ibuprofen', 1, '2024-12-25 22:00:00', '14:00:00'),
(723, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2024-12-25 22:00:00', '14:00:00'),
(736, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2024-12-27 22:00:00', '08:00:00'),
(737, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2024-12-27 22:00:00', '13:00:00'),
(738, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2024-12-27 22:00:00', '08:00:00'),
(742, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2024-12-27 22:00:00', '14:00:00'),
(755, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2024-12-28 22:00:00', '08:00:00'),
(756, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2024-12-28 22:00:00', '08:00:00'),
(779, 83, 84, 'Emergency Alert', 1, '2024-12-29 09:41:40', NULL),
(780, 83, 107, 'Emergency Alert', 0, '2024-12-29 09:41:40', NULL),
(785, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2024-12-29 22:00:00', '08:00:00'),
(786, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2024-12-29 22:00:00', '08:00:00'),
(792, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2024-12-29 22:00:00', '13:00:00'),
(806, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2024-12-30 22:00:00', '08:00:00'),
(807, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2024-12-30 22:00:00', '08:00:00'),
(808, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2025-01-02 22:00:00', '08:00:00'),
(809, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2025-01-02 22:00:00', '13:00:00'),
(810, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2025-01-02 22:00:00', '08:00:00'),
(811, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2025-01-02 22:00:00', '14:00:00'),
(832, 83, 84, 'Emergency Alert', 1, '2025-01-03 14:14:54', NULL),
(905, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2025-01-03 22:00:00', '08:00:00'),
(906, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2025-01-03 22:00:00', '08:00:00'),
(936, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2025-01-03 22:00:00', '13:00:00'),
(944, 84, 83, 'approve_follow_request', 1, '2025-01-04 11:22:23', NULL),
(958, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2025-01-03 22:00:00', '14:00:00'),
(967, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2025-01-04 22:00:00', '08:00:00'),
(968, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2025-01-04 22:00:00', '13:00:00'),
(969, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2025-01-04 22:00:00', '08:00:00'),
(1042, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2025-01-04 22:00:00', '14:00:00'),
(1143, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2025-01-05 22:00:00', '08:00:00'),
(1144, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2025-01-05 22:00:00', '08:00:00'),
(1196, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2025-01-05 22:00:00', '13:00:00'),
(1225, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2025-01-05 22:00:00', '14:00:00'),
(1274, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2025-01-06 22:00:00', '08:00:00'),
(1275, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2025-01-06 22:00:00', '08:00:00'),
(1307, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2025-01-06 22:00:00', '13:00:00'),
(1333, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2025-01-06 22:00:00', '14:00:00'),
(1390, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 1, '2025-01-08 22:00:00', '08:00:00'),
(1391, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 1, '2025-01-08 22:00:00', '08:00:00'),
(1415, 84, 83, 'Reminder: It\'s time to take your medication: Paracetamol', 0, '2025-01-08 22:00:00', '13:00:00'),
(1471, 84, 83, 'Reminder: It\'s time to take your medication: Amoxicillin', 0, '2025-01-08 22:00:00', '14:00:00');

-- --------------------------------------------------------

--
-- بنية الجدول `schedule`
--

CREATE TABLE `schedule` (
  `id` int(10) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Date` date DEFAULT NULL,
  `Time` varchar(255) NOT NULL,
  `scedual_id` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `schedule`
--

INSERT INTO `schedule` (`id`, `Name`, `Date`, `Time`, `scedual_id`) VALUES
(84, 'bg bg', '2025-01-22', '11:00', 59),
(84, 'bg', '2025-01-26', '13:00', 60);

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
(84, 'ahmad', 'hawwari', 'ahmadhawwari1092@gmail.com', 23, '$2b$10$Y42zT7WurVOPLR.2X.PiAuQungpX0j7.9yT3c/FcmZayKJrWBXceG', 'Care giver', 64, 'I am a care Giver ', 0),
(101, 'City', 'Hospital', 'cityhospital@gmail.com', 0, '$2b$10$o254KJkkiR2U6MYA5MFN7O9wW/qoKgv5IF2FqwigwVV26fqfCm5mW', 'Hospital', 275, NULL, 0),
(102, 'Green Valy', 'Hospital', 'Greenvalyhospital@gmail.com', 0, '$2b$10$RCMwJiTYZZGNbUYC8e/Fae9vEIpVSuIy3VR.atqXBxD4VdpaO/OrG', 'Hospital', 268, NULL, 0),
(106, 'ahmad', 'haw', 'jh13@gmail.com', 30, '$2b$10$.nYS/XLHEHtvGJx8gjiUhOTyKq5Pxo5N17ddg9gcTPgLR4VJDObLO', 'Hospital', 241, NULL, 242),
(107, 'ahmad', 'haw', 'jh11@gmail.com', 30, '$2b$10$.nYS/XLHEHtvGJx8gjiUhOTyKq5Pxo5N17ddg9gcTPgLR4VJDObLO', 'Care giver', 241, NULL, 242),
(108, 'rafedia', 'hospital', 'rafidia@gmail.com', 0, '$2b$10$BWys9Q5SDElNk/1YrQlq0.NByz82O590mKjVEskYI.n1Nd/acJqNO', 'Hospital', 283, NULL, 281),
(110, 'ahmad', 'haw', 'jh20mail.com', 30, '$2b$10$.nYS/XLHEHtvGJx8gjiUhOTyKq5Pxo5N17ddg9gcTPgLR4VJDObLO', 'Hospital', 241, NULL, 242),
(111, 'ahmad', 'haw', 'jh12@gmail.com', 30, '$2b$10$.nYS/XLHEHtvGJx8gjiUhOTyKq5Pxo5N17ddg9gcTPgLR4VJDObLO', 'Care giver', 343, NULL, 242),
(112, 'ahman', 'dff', 'f9@gmail.com', 30, '$2b$10$Fq2CMh9nBEeWDfmhyPXJo.euCxRdZs1zu58TvSqtxuJ8POB8Th2cu', 'Admin', 345, NULL, 291),
(113, 'ahmad', 'haw', 'jh15@gmail.com', 30, '$2b$10$.nYS/XLHEHtvGJx8gjiUhOTyKq5Pxo5N17ddg9gcTPgLR4VJDObLO', 'Care giver', 241, NULL, 242),
(114, 'ahmad', 'haw', 'jh19@gmail.com', 30, '$2b$10$9eEeTn64KfmglO2IVy5Ml.F86W5FhqlqzSftl.Ws2ciw5xXA3kSj.', 'Hospital', 349, 'No bio available', 242),
(115, 's1', 's', 's1@gmail.com', 66, '$2b$10$JmrMtyARisACbOhLaVP6fOEWl9.lykuta/ECsmhFo/Wr7ilsB7DUu', 'Care recipient', 347, NULL, 0),
(116, 'h1', 'h', 'h1@gmail.com', 65, '$2b$10$yVA8AD94XugCn6ThlY.U9eKYU8caXAZCZVkEJU8BKInpX1Di9m/4C', 'Care recipient', 303, NULL, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `articles`
--
ALTER TABLE `articles`
  ADD PRIMARY KEY (`id`);

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
-- Indexes for table `doctor_availability`
--
ALTER TABLE `doctor_availability`
  ADD PRIMARY KEY (`id`),
  ADD KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `filemannager`
--
ALTER TABLE `filemannager`
  ADD PRIMARY KEY (`file_id`);

--
-- Indexes for table `hospitals`
--
ALTER TABLE `hospitals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `ipopo` (`User_id`);

--
-- Indexes for table `medication_schedule`
--
ALTER TABLE `medication_schedule`
  ADD PRIMARY KEY (`id`),
  ADD KEY `doctor_id111` (`doctor_id`),
  ADD KEY `patiantid` (`patient_id`);

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
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`Notifications_id`),
  ADD UNIQUE KEY `unique_notification` (`reciver_id`,`medication_time`,`typeofnotifications`,`created_at`),
  ADD KEY `senderid11` (`Sender_id`);

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
-- AUTO_INCREMENT for table `articles`
--
ALTER TABLE `articles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `caregiverrequesttoadmin`
--
ALTER TABLE `caregiverrequesttoadmin`
  MODIFY `Request_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT for table `carerecipientlist`
--
ALTER TABLE `carerecipientlist`
  MODIFY `CareRecipientList_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT for table `doctor_availability`
--
ALTER TABLE `doctor_availability`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `filemannager`
--
ALTER TABLE `filemannager`
  MODIFY `file_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=381;

--
-- AUTO_INCREMENT for table `hospitals`
--
ALTER TABLE `hospitals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `medication_schedule`
--
ALTER TABLE `medication_schedule`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=158;

--
-- AUTO_INCREMENT for table `mymedicalreports`
--
ALTER TABLE `mymedicalreports`
  MODIFY `report_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `Notifications_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1496;

--
-- AUTO_INCREMENT for table `schedule`
--
ALTER TABLE `schedule`
  MODIFY `scedual_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `User_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;

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
-- قيود الجداول `doctor_availability`
--
ALTER TABLE `doctor_availability`
  ADD CONSTRAINT `doctor_id` FOREIGN KEY (`doctor_id`) REFERENCES `users` (`User_id`);

--
-- قيود الجداول `medication_schedule`
--
ALTER TABLE `medication_schedule`
  ADD CONSTRAINT `patiantid` FOREIGN KEY (`patient_id`) REFERENCES `users` (`User_id`);

--
-- قيود الجداول `mymedicalreports`
--
ALTER TABLE `mymedicalreports`
  ADD CONSTRAINT `fileid` FOREIGN KEY (`filemannager_id`) REFERENCES `filemannager` (`file_id`);

--
-- قيود الجداول `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `reciverid11` FOREIGN KEY (`reciver_id`) REFERENCES `users` (`User_id`);

--
-- قيود الجداول `schedule`
--
ALTER TABLE `schedule`
  ADD CONSTRAINT `userid` FOREIGN KEY (`id`) REFERENCES `users` (`User_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
