-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 19, 2025 at 03:26 PM
-- Server version: 9.3.0
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `paws`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `name`, `username`, `password`, `created_at`, `updated_at`) VALUES
(1, 'ISHA', 'ish23@gmail.com', '1234', '2025-05-19 08:25:55', '2025-05-19 08:25:55');

-- --------------------------------------------------------

--
-- Table structure for table `adoption_requests`
--

CREATE TABLE `adoption_requests` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `animal_id` int NOT NULL,
  `request_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `notes` text,
  `processed_by` int DEFAULT NULL,
  `processed_date` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `adoption_requests`
--

INSERT INTO `adoption_requests` (`id`, `user_id`, `animal_id`, `request_date`, `status`, `notes`, `processed_by`, `processed_date`) VALUES
(1, 1, 2, '2025-05-16 14:27:15', 'approved', 'Foster request', NULL, NULL),
(3, 3, 2, '2025-05-19 06:55:25', 'approved', NULL, 1, '2025-05-19 08:48:14'),
(5, 2, 2, '2025-05-19 07:15:45', 'approved', NULL, 1, '2025-05-19 08:47:29'),
(7, 2, 3, '2025-05-19 07:57:26', 'approved', NULL, 1, '2025-05-19 08:47:09');

--
-- Triggers `adoption_requests`
--
DELIMITER $$
CREATE TRIGGER `after_adoption_request_delete` AFTER DELETE ON `adoption_requests` FOR EACH ROW BEGIN
    INSERT INTO cancellations (request_id, user_id, animal_id, original_request_date)
    VALUES (OLD.id, OLD.user_id, OLD.animal_id, OLD.request_date);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `animals`
--

CREATE TABLE `animals` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `animal_type` enum('dog','cat','bird','small_animal') NOT NULL,
  `breed` varchar(100) DEFAULT NULL,
  `description` text,
  `age_group` enum('baby','young','adult','senior') NOT NULL,
  `size` enum('small','medium','large') NOT NULL,
  `gender` enum('male','female') NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `status` enum('available','pending','adopted','fostered') DEFAULT 'available',
  `foster_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `animals`
--

INSERT INTO `animals` (`id`, `name`, `animal_type`, `breed`, `description`, `age_group`, `size`, `gender`, `image_url`, `status`, `foster_id`, `created_at`, `updated_at`) VALUES
(1, 'Buddy', 'dog', 'Golden Retriever', 'Friendly and playful golden retriever who loves to run and play fetch.', 'young', 'large', 'male', 'images/animals/buddy.jpg', 'adopted', 1, '2025-05-16 14:13:54', '2025-05-16 14:56:13'),
(2, 'Luna', 'cat', 'Siamese', 'Calm and affectionate Siamese cat who enjoys sitting on laps and window watching.', 'adult', 'medium', 'female', 'images/animals/luna.jpg', 'adopted', NULL, '2025-05-16 14:13:54', '2025-05-19 08:47:29'),
(3, 'Charlie', 'dog', 'Beagle', 'Energetic beagle with a great nose. Loves to explore and play.', 'young', 'medium', 'male', 'images/animals/charlie.jpg', 'adopted', 1, '2025-05-16 14:13:54', '2025-05-19 08:47:09'),
(4, 'Max', 'dog', 'German Shepherd', 'Intelligent and loyal German Shepherd. Good with children and other pets.', 'adult', 'large', 'male', 'images/animals/max.jpg', 'available', NULL, '2025-05-16 14:13:54', '2025-05-16 14:13:54'),
(5, 'Daisy', 'cat', 'Tabby', 'Sweet tabby cat who loves to cuddle and play with toys.', 'young', 'small', 'female', 'images/animals/daisy.jpg', 'available', NULL, '2025-05-16 14:13:54', '2025-05-16 14:13:54'),
(6, 'Coco', 'bird', 'Cockatiel', 'Playful cockatiel who enjoys whistling and interacting with people.', 'adult', 'small', 'female', 'images/animals/coco.jpg', 'available', NULL, '2025-05-16 14:13:54', '2025-05-16 14:13:54'),
(7, 'Oliver', 'cat', 'Maine Coon', 'Fluffy Maine Coon who is gentle and loves to be brushed.', 'adult', 'large', 'male', 'images/animals/oliver.jpg', 'available', NULL, '2025-05-16 14:13:54', '2025-05-16 14:13:54'),
(8, 'Milo', 'small_animal', 'Rabbit', 'Adorable dwarf rabbit who enjoys fresh vegetables and gentle petting.', 'young', 'small', 'male', 'images/animals/milo.jpg', 'available', NULL, '2025-05-16 14:13:54', '2025-05-16 14:13:54'),
(9, 'shiru', 'dog', 'Labrador', 'Friendly Labrador who loves water and playing fetch.', 'adult', 'large', 'female', 'images/animals/bella.jpg', 'available', NULL, '2025-05-16 14:13:54', '2025-05-19 08:58:10'),
(10, 'Rocky', 'dog', 'Bulldog', 'Laid-back bulldog who enjoys short walks and lots of naps.', 'senior', 'medium', 'male', 'images/animals/rocky.jpg', 'available', NULL, '2025-05-16 14:13:54', '2025-05-16 14:13:54'),
(11, 'Sophie', 'cat', 'Persian', 'Beautiful Persian cat with a gentle temperament.', 'adult', 'medium', 'female', 'images/animals/sophie.jpg', 'available', NULL, '2025-05-16 14:13:54', '2025-05-16 14:13:54'),
(12, 'Cooper', 'small_animal', 'Guinea Pig', 'Social guinea pig who loves fresh vegetables and making soft noises.', 'young', 'small', 'male', 'images/animals/cooper.jpg', 'available', NULL, '2025-05-16 14:13:54', '2025-05-16 14:13:54');

-- --------------------------------------------------------

--
-- Table structure for table `cancellations`
--

CREATE TABLE `cancellations` (
  `id` int NOT NULL,
  `request_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  `animal_id` int NOT NULL,
  `cancelled_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `reason` enum('changed_mind','found_another_pet','personal_circumstances','other') DEFAULT NULL,
  `additional_notes` text,
  `original_request_date` timestamp NULL DEFAULT NULL,
  `cancelled_by` enum('user','admin') NOT NULL DEFAULT 'user',
  `status` enum('pending','reviewed','resolved','approved','rejected','processed') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `cancellations`
--

INSERT INTO `cancellations` (`id`, `request_id`, `user_id`, `animal_id`, `cancelled_date`, `reason`, `additional_notes`, `original_request_date`, `cancelled_by`, `status`) VALUES
(1, 4, 2, 2, '2025-05-19 08:13:35', 'personal_circumstances', NULL, '2025-05-19 07:04:42', 'user', 'approved'),
(2, 4, 2, 2, '2025-05-19 08:13:35', NULL, NULL, '2025-05-19 07:04:42', 'user', 'approved'),
(3, 6, 2, 3, '2025-05-19 08:15:11', 'found_another_pet', NULL, '2025-05-19 07:34:08', 'user', 'pending'),
(4, 6, 2, 3, '2025-05-19 08:15:11', NULL, NULL, '2025-05-19 07:34:08', 'user', 'pending'),
(5, 2, 3, 2, '2025-05-19 08:56:29', 'changed_mind', 'sry, pls cancel my request.', '2025-05-19 05:20:34', 'user', 'pending'),
(6, 2, 3, 2, '2025-05-19 08:56:29', NULL, NULL, '2025-05-19 05:20:34', 'user', 'pending');

-- --------------------------------------------------------

--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `animal_id` varchar(20) NOT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `favorites`
--

INSERT INTO `favorites` (`id`, `user_id`, `animal_id`, `created_at`) VALUES
(1, 2, '2', '2025-05-19 12:21:41'),
(2, 2, '5', '2025-05-19 18:46:44');

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `id` int NOT NULL,
  `email` varchar(100) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `password` varchar(255) NOT NULL,
  `user_type` enum('adopter','volunteer','foster') NOT NULL DEFAULT 'adopter',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `address`, `password`, `user_type`, `created_at`, `updated_at`) VALUES
(1, 'isha', 'jain', 'ishajainbtech24@rvu.edu.in', '09148559242', 'qQAWAAW', '$2y$10$1af1gDn/fU3MkKvF5fTic.Qn06XHjmJfdM4D6t7hWXLRsQ2VlGqz.', 'foster', '2025-05-16 13:23:09', '2025-05-16 13:23:09'),
(2, 'nandini', 'reddy', 'nandini45396@gmail.com', '9448162767', 'zsvzdbg', '$2y$10$asKUBvB2CDEW50qsxvPbOOmwmOOjb7m9h/ns9yY3O99tZvn1V.Hju', 'adopter', '2025-05-16 19:06:28', '2025-05-16 19:06:28'),
(3, 'indhu', 'sin', 'in@gmail.com', '09448162767', 'zsvzdbg', '$2y$10$mIdbqnTTKEtC8iB8Dq7Ol.0iCOpJvy1oHf80BDRmq9xLrtun7BJWK', 'adopter', '2025-05-19 04:24:51', '2025-05-19 04:24:51');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `adoption_requests`
--
ALTER TABLE `adoption_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `animal_id` (`animal_id`),
  ADD KEY `processed_by` (`processed_by`);

--
-- Indexes for table `animals`
--
ALTER TABLE `animals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `foster_id` (`foster_id`);

--
-- Indexes for table `cancellations`
--
ALTER TABLE `cancellations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_animal_id` (`animal_id`);

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_favorite` (`user_id`,`animal_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_animal_id` (`animal_id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `email` (`email`,`token`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `adoption_requests`
--
ALTER TABLE `adoption_requests`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `animals`
--
ALTER TABLE `animals`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `cancellations`
--
ALTER TABLE `cancellations`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `adoption_requests`
--
ALTER TABLE `adoption_requests`
  ADD CONSTRAINT `adoption_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `adoption_requests_ibfk_2` FOREIGN KEY (`animal_id`) REFERENCES `animals` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `adoption_requests_ibfk_3` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `animals`
--
ALTER TABLE `animals`
  ADD CONSTRAINT `animals_ibfk_1` FOREIGN KEY (`foster_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `cancellations`
--
ALTER TABLE `cancellations`
  ADD CONSTRAINT `cancellations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cancellations_ibfk_2` FOREIGN KEY (`animal_id`) REFERENCES `animals` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
