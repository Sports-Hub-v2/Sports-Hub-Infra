-- MySQL dump 10.13  Distrib 8.0.44, for Linux (x86_64)
--
-- Host: localhost    Database: sportshub_db
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` (`id`, `email`, `userid`, `password_hash`, `role`, `status`, `email_verified`, `last_login_at`, `last_login_ip`, `last_device_info`, `created_at`, `updated_at`, `deleted_at`) VALUES (2,'john@example.com',NULL,'$2a$10$8/8dRSBtVtCPp3N43rfWzuXeJl/M791RNdwmRp4DiEyHOQ2hPj4YS','USER','ACTIVE',1,'2025-11-11 22:48:53',NULL,NULL,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(3,'sarah@example.com',NULL,'$2a$10$8/8dRSBtVtCPp3N43rfWzuXeJl/M791RNdwmRp4DiEyHOQ2hPj4YS','USER','ACTIVE',1,'2025-11-11 22:48:53',NULL,NULL,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(4,'mike@example.com',NULL,'$2a$10$8/8dRSBtVtCPp3N43rfWzuXeJl/M791RNdwmRp4DiEyHOQ2hPj4YS','USER','ACTIVE',1,'2025-11-11 22:48:53',NULL,NULL,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(5,'emily@example.com',NULL,'$2a$10$8/8dRSBtVtCPp3N43rfWzuXeJl/M791RNdwmRp4DiEyHOQ2hPj4YS','USER','ACTIVE',1,'2025-11-11 22:48:53',NULL,NULL,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(6,'david@example.com',NULL,'$2a$10$8/8dRSBtVtCPp3N43rfWzuXeJl/M791RNdwmRp4DiEyHOQ2hPj4YS','USER','ACTIVE',1,'2025-11-11 22:48:53',NULL,NULL,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(7,'lisa@example.com',NULL,'$2a$10$8/8dRSBtVtCPp3N43rfWzuXeJl/M791RNdwmRp4DiEyHOQ2hPj4YS','USER','ACTIVE',1,'2025-11-11 22:48:53',NULL,NULL,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(8,'kevin@example.com',NULL,'$2a$10$8/8dRSBtVtCPp3N43rfWzuXeJl/M791RNdwmRp4DiEyHOQ2hPj4YS','USER','ACTIVE',1,'2025-11-11 22:48:53',NULL,NULL,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(9,'jessica@example.com',NULL,'$2a$10$8/8dRSBtVtCPp3N43rfWzuXeJl/M791RNdwmRp4DiEyHOQ2hPj4YS','USER','ACTIVE',1,'2025-11-11 22:48:53',NULL,NULL,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(10,'chris@example.com',NULL,'$2a$10$8/8dRSBtVtCPp3N43rfWzuXeJl/M791RNdwmRp4DiEyHOQ2hPj4YS','USER','ACTIVE',1,'2025-11-11 22:48:53',NULL,NULL,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(11,'anna@example.com',NULL,'$2a$10$8/8dRSBtVtCPp3N43rfWzuXeJl/M791RNdwmRp4DiEyHOQ2hPj4YS','USER','ACTIVE',1,'2025-11-11 22:48:53',NULL,NULL,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL);
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `admin_action_logs`
--

LOCK TABLES `admin_action_logs` WRITE;
/*!40000 ALTER TABLE `admin_action_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_action_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `applications`
--

LOCK TABLES `applications` WRITE;
/*!40000 ALTER TABLE `applications` DISABLE KEYS */;
/*!40000 ALTER TABLE `applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
INSERT INTO `comments` (`id`, `post_id`, `author_id`, `author_name`, `content`, `parent_comment_id`, `likes`, `is_reported`, `is_deleted`, `created_at`, `updated_at`) VALUES (1,1,3,'이영희','참석하겠습니다!',NULL,2,0,0,'2025-11-09 22:48:53','2025-11-11 22:48:53'),(2,1,5,'정수진','저도 참석할게요!',NULL,1,0,0,'2025-11-09 22:48:53','2025-11-11 22:48:53'),(3,1,8,'윤태민','늦을 수도 있는데 괜찮을까요?',NULL,0,0,0,'2025-11-10 22:48:53','2025-11-11 22:48:53'),(4,2,2,'김철수','나이키 레전드 9 추천드립니다!',NULL,3,0,0,'2025-11-07 22:48:53','2025-11-11 22:48:53'),(5,2,10,'임준호','아디다스 프레데터도 좋아요',NULL,2,0,0,'2025-11-07 22:48:53','2025-11-11 22:48:53'),(6,3,9,'한소희','저 가능합니다! 연락주세요',NULL,4,0,0,'2025-11-10 22:48:53','2025-11-11 22:48:53'),(7,3,3,'이영희','시간 맞으면 참여하고 싶습니다',NULL,2,0,0,'2025-11-10 22:48:53','2025-11-11 22:48:53'),(8,4,3,'이영희','남동구 치킨집 추천!',NULL,1,0,0,'2025-11-10 22:48:53','2025-11-11 22:48:53'),(9,4,7,'강지은','삼겹살 집도 괜찮을 것 같아요',NULL,2,0,0,'2025-11-11 10:48:53','2025-11-11 22:48:53');
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `match_lineups`
--

LOCK TABLES `match_lineups` WRITE;
/*!40000 ALTER TABLE `match_lineups` DISABLE KEYS */;
/*!40000 ALTER TABLE `match_lineups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `match_management_logs`
--

LOCK TABLES `match_management_logs` WRITE;
/*!40000 ALTER TABLE `match_management_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `match_management_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `match_notes`
--

LOCK TABLES `match_notes` WRITE;
/*!40000 ALTER TABLE `match_notes` DISABLE KEYS */;
/*!40000 ALTER TABLE `match_notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `matches`
--

LOCK TABLES `matches` WRITE;
/*!40000 ALTER TABLE `matches` DISABLE KEYS */;
/*!40000 ALTER TABLE `matches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` (`id`, `receiver_id`, `type`, `title`, `message`, `related_type`, `related_id`, `is_read`, `read_at`, `created_at`, `expires_at`, `receiver_profile_id`) VALUES (1,3,'TEAM_ANNOUNCEMENT','팀 공지사항','FC 강남에 새로운 공지사항이 등록되었습니다.','POST',1,0,NULL,'2025-11-08 22:48:53',NULL,3),(2,7,'TEAM_INVITATION','팀 초대','서울 유나이티드 팀에 초대되었습니다.','TEAM',3,0,NULL,'2025-11-06 22:48:53',NULL,7),(3,9,'POST_COMMENT','댓글 알림','회원님의 게시물에 새로운 댓글이 달렸습니다.','POST',3,1,NULL,'2025-11-10 22:48:53',NULL,9),(4,5,'SYSTEM','시스템 공지','서비스 점검이 예정되어 있습니다.',NULL,NULL,0,NULL,'2025-11-09 22:48:53',NULL,5),(5,10,'POST_LIKE','좋아요 알림','회원님의 게시물을 누군가 좋아합니다.','POST',3,1,NULL,'2025-11-11 16:48:53',NULL,10);
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `peer_surveys`
--

LOCK TABLES `peer_surveys` WRITE;
/*!40000 ALTER TABLE `peer_surveys` DISABLE KEYS */;
/*!40000 ALTER TABLE `peer_surveys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `post_edit_history`
--

LOCK TABLES `post_edit_history` WRITE;
/*!40000 ALTER TABLE `post_edit_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_edit_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `posts`
--

LOCK TABLES `posts` WRITE;
/*!40000 ALTER TABLE `posts` DISABLE KEYS */;
INSERT INTO `posts` (`id`, `author_id`, `author_name`, `post_type`, `team_id`, `title`, `content`, `image_url`, `category`, `tags`, `match_date`, `target_type`, `region`, `views`, `likes`, `comments_count`, `shares`, `status`, `is_pinned`, `is_reported`, `published_at`, `created_at`, `updated_at`, `deleted_at`) VALUES (1,2,'김철수','TEAM_NOTICE',2,'이번 주말 경기 안내','안녕하세요 팀원 여러분! 이번 주 토요일 오후 2시에 올림픽공원 축구장에서 친선경기가 있습니다. 많은 참여 부탁드립니다.',NULL,NULL,'[\"MATCH\", \"NOTICE\"]',NULL,NULL,'서울',45,8,3,0,'PUBLISHED',1,0,'2025-11-08 22:48:53','2025-11-08 22:48:53','2025-11-11 22:48:53',NULL),(2,4,'박민수','FREE_BOARD',3,'축구화 추천 부탁드립니다','새로 축구화를 사려고 하는데 추천 부탁드립니다. 예산은 10만원 정도입니다.',NULL,NULL,'[\"QUESTION\"]',NULL,NULL,'서울',32,5,7,0,'PUBLISHED',0,0,'2025-11-06 22:48:53','2025-11-06 22:48:53','2025-11-11 22:48:53',NULL),(3,10,'임준호','RECRUIT',6,'고양 지역 용병 모집','이번 주 일요일 오전 10시 경기에 미드필더 1명 급구합니다. 실력 상관없이 즐겁게 뛰실 분!',NULL,NULL,'[\"MERCENARY\", \"URGENT\"]',NULL,NULL,'경기',78,12,5,0,'PUBLISHED',0,0,'2025-11-09 22:48:53','2025-11-09 22:48:53','2025-11-11 22:48:53',NULL),(4,5,'정수진','FREE_BOARD',5,'팀 회식 어디서 할까요?','다음 주에 팀 회식 하려고 하는데 인천 남동구 쪽 맛집 추천 부탁드립니다!',NULL,NULL,'[\"QUESTION\"]',NULL,NULL,'인천',28,6,9,0,'PUBLISHED',0,0,'2025-11-10 22:48:53','2025-11-10 22:48:53','2025-11-11 22:48:53',NULL),(5,6,'최동욱','TEAM_NOTICE',4,'정기 훈련 시간 변경 안내','다음 주부터 정기 훈련 시간이 오후 7시에서 오후 8시로 변경됩니다.',NULL,NULL,'[\"NOTICE\", \"TRAINING\"]',NULL,NULL,'경기',55,10,2,0,'PUBLISHED',1,0,'2025-11-04 22:48:53','2025-11-04 22:48:53','2025-11-11 22:48:53',NULL);
/*!40000 ALTER TABLE `posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `profiles`
--

LOCK TABLES `profiles` WRITE;
/*!40000 ALTER TABLE `profiles` DISABLE KEYS */;
INSERT INTO `profiles` (`id`, `account_id`, `name`, `phone_number`, `birth_date`, `region`, `sub_region`, `preferred_position`, `skill_level`, `is_ex_player`, `height`, `weight`, `total_matches`, `win_rate`, `punctuality_rate`, `manner_temperature`, `no_show_count`, `consecutive_attendance`, `activity_start_date`, `activity_end_date`, `posts_count`, `comments_count`, `created_at`, `updated_at`, `deleted_at`) VALUES (2,2,'김철수','010-1234-5678','1990-05-15','서울','강남구','FW','INTERMEDIATE',0,175,70,25,60.00,95.00,38.50,0,8,'2022-03-01',NULL,5,12,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(3,3,'이영희','010-2345-6789','1992-08-22','서울','송파구','MF','BEGINNER',0,165,55,8,50.00,100.00,36.50,0,5,'2023-06-15',NULL,2,5,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(4,4,'박민수','010-3456-7890','1988-03-10','경기','성남시','DF','ADVANCED',1,180,75,50,70.00,98.00,40.00,0,15,'2015-01-10',NULL,8,20,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(5,5,'정수진','010-4567-8901','1995-11-30','서울','마포구','MF','INTERMEDIATE',0,168,60,18,55.56,94.44,37.20,1,6,'2023-01-20',NULL,3,8,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(6,6,'최동욱','010-5678-9012','1987-07-18','인천','남동구','GK','ADVANCED',1,185,80,60,65.00,100.00,39.50,0,20,'2010-03-15',NULL,10,25,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(7,7,'강지은','010-6789-0123','1993-02-25','서울','서초구','FW','BEGINNER',0,160,50,5,40.00,60.00,36.00,2,2,'2024-08-01',NULL,1,3,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(8,8,'윤태민','010-7890-1234','1991-09-12','경기','수원시','DF','INTERMEDIATE',0,178,73,30,60.00,96.67,37.80,0,10,'2022-06-01',NULL,4,15,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(9,9,'한소희','010-8901-2345','1994-06-05','서울','강동구','MF','INTERMEDIATE',0,170,58,22,59.09,95.45,38.00,0,7,'2023-03-10',NULL,6,18,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(10,10,'임준호','010-9012-3456','1989-12-20','경기','고양시','FW','ADVANCED',1,182,78,45,68.89,97.78,39.00,0,12,'2020-05-01',NULL,7,22,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL),(11,11,'서예린','010-0123-4567','1996-04-08','서울','영등포구','GK','BEGINNER',0,172,62,6,33.33,83.33,35.50,1,3,'2024-03-01',NULL,2,4,'2025-11-11 22:48:53','2025-11-11 22:48:53',NULL);
/*!40000 ALTER TABLE `profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `recruit_applications`
--

LOCK TABLES `recruit_applications` WRITE;
/*!40000 ALTER TABLE `recruit_applications` DISABLE KEYS */;
INSERT INTO `recruit_applications` (`id`, `applicant_profile_id`, `application_date`, `description`, `post_id`, `status`) VALUES (1,9,'2025-11-09 22:48:53.000000','안녕하세요! FC 강남에 가입하고 싶습니다. 주말 경기 참여 가능합니다.',1,'PENDING'),(2,7,'2025-11-08 22:48:53.000000','경력은 많지 않지만 열심히 하겠습니다!',1,'ACCEPTED'),(3,3,'2025-11-10 22:48:53.000000','미드필더 포지션 가능합니다. 연락 주세요!',2,'ACCEPTED'),(4,11,'2025-11-06 22:48:53.000000','초보지만 배우고 싶습니다.',4,'PENDING');
/*!40000 ALTER TABLE `recruit_applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `recruit_posts`
--

LOCK TABLES `recruit_posts` WRITE;
/*!40000 ALTER TABLE `recruit_posts` DISABLE KEYS */;
INSERT INTO `recruit_posts` (`id`, `team_id`, `writer_profile_id`, `title`, `content`, `region`, `sub_region`, `image_url`, `match_date`, `game_time`, `category`, `target_type`, `status`, `required_personnel`, `preferred_positions`, `age_group`, `skill_level`, `field_location`, `created_at`, `updated_at`) VALUES (2,6,10,'일요일 오전 용병 구합니다','고양에서 일요일 오전 10시 경기에 참여할 용병을 구합니다. 포지션은 MF입니다.','경기','일산동구',NULL,'2025-11-13','10:00:00','MERCENARY','USER','RECRUITING',3,'MF, FW','20-30대','중급','고양종합운동장 축구장','2025-11-09 13:48:53','2025-11-13 16:19:41'),(5,2,3,'[강남] 토요일 새벽 풋살 용병 급구!','강남 스포츠센터에서 토요일 새벽 6시 풋살 경기 예정입니다. FW 1명 급하게 구합니다!','서울','강남구',NULL,'2025-11-12','06:00:00','MERCENARY','USER','RECRUITING',1,'FW','20-40대','초중급','강남 스포츠센터','2025-11-11 13:48:53','2025-11-13 16:19:41'),(6,4,6,'[수원] 평일 저녁 조기축구 용병 모집','수원월드컵경기장에서 매주 수요일 저녁 8시 조기축구 하고 있습니다. MF/DF 2명 구합니다.','경기','팔달구',NULL,'2025-11-16','20:00:00','MERCENARY','USER','RECRUITING',2,'MF, DF','20-30대','초중급','수원월드컵경기장','2025-11-10 13:48:53','2025-11-13 16:19:41'),(7,4,7,'[경기] 긴급! 일요일 오후 경기 GK 구함','일요일 오후 2시 경기에 골키퍼가 부상으로 빠지게 되었습니다. GK 경험 있으신 분 급구합니다!','경기','일산서구',NULL,'2025-11-14','14:00:00','MERCENARY','USER','RECRUITING',1,'GK','전체','중급 이상','일산축구전용구장','2025-11-11 13:48:53','2025-11-13 16:20:14'),(8,1,8,'[용병 구함] 주말 조기축구 팀 찾습니다','주말 오전 조기축구 할 수 있는 팀을 찾고 있습니다. MF 포지션 선호하며, 중급 실력입니다. 성실하게 참여하겠습니다!','서울','송파구',NULL,'2025-11-16','09:00:00','MERCENARY','TEAM','RECRUITING',NULL,'MF, FW','20-30대','중급','잠실종합운동장','2025-11-13 17:39:32','2025-11-13 17:39:32'),(9,2,7,'[개인] 평일 저녁 풋살팀 구합니다','평일 저녁에 활동하는 풋살팀을 찾습니다. DF 포지션이며 초중급 수준입니다. 꾸준히 참여 가능합니다.','경기','분당구',NULL,'2025-11-18','19:00:00','MERCENARY','TEAM','RECRUITING',NULL,'DF, GK','30-40대','초중급','분당스포츠센터','2025-11-13 17:39:32','2025-11-13 17:41:44'),(10,2,3,'[FC서울] 주말 조기축구팀 팀원 모집','매주 토요일 오전 조기축구를 함께 할 팀원을 모집합니다. 20-30대 중급 이상 실력자 환영합니다. 즐거운 축구 함께해요!','서울','강남구',NULL,'2025-11-20','09:00:00','TEAM','USER','RECRUITING',5,'MF, FW, DF','20-30대','중급 이상','강남구민운동장','2025-11-13 17:54:52','2025-11-13 17:54:52'),(11,4,6,'[수원FC] 평일 저녁 풋살팀 신규 팀원 모집','평일 저녁 7시에 정기적으로 풋살하는 팀입니다. 친목 위주이며 초중급 실력 환영합니다. 꾸준히 참여 가능한 분 모집합니다.','경기','수원시',NULL,'2025-11-22','19:00:00','TEAM','USER','RECRUITING',3,'ALL','20-40대','초중급','수원실내체육관','2025-11-13 17:54:52','2025-11-13 17:54:52'),(12,1,1,'[부천유나이티드] 주말 축구팀 GK 모집','주말 오전 조기축구팀에서 골키퍼를 찾습니다. 경험자 우대하며, 초보도 환영합니다. 즐겁게 운동해요!','경기','부천시',NULL,'2025-11-17','10:00:00','TEAM','USER','RECRUITING',1,'GK','20-40대','무관','부천종합운동장','2025-11-13 17:54:52','2025-11-13 17:54:52'),(13,2,3,'[11월 16일] 토요일 오전 친선경기 상대팀 구합니다','11월 16일 토요일 오전 10시에 친선경기 할 팀을 찾습니다. 6:6 or 7:7 가능하며, 즐겁게 경기하실 팀 연락주세요!','서울','송파구',NULL,'2025-11-16','10:00:00','MATCH','TEAM','RECRUITING',NULL,NULL,'20-30대','중급','잠실종합운동장 보조구장','2025-11-13 17:54:52','2025-11-13 17:54:52'),(14,4,6,'[긴급] 일요일 오후 풋살 경기 상대 구함','일요일 오후 3시 풋살 경기 상대팀을 찾습니다. 5:5 경기이며, 실력 무관 친선경기입니다. 장소는 수원입니다.','경기','수원시',NULL,'2025-11-17','15:00:00','MATCH','TEAM','RECRUITING',NULL,NULL,'전연령','무관','수원월드컵경기장 풋살장','2025-11-13 17:54:52','2025-11-13 17:54:52'),(15,6,10,'[11월 23일] 주말 조기축구 경기 팀 모집','11월 23일 토요일 오전 조기축구 경기할 팀을 모집합니다. 8:8 경기이며, 중급 이상 실력의 팀 환영합니다.','경기','고양시',NULL,'2025-11-23','09:00:00','MATCH','TEAM','RECRUITING',NULL,NULL,'20-40대','중급 이상','고양종합운동장','2025-11-13 17:54:52','2025-11-13 17:54:52');
/*!40000 ALTER TABLE `recruit_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
INSERT INTO `refresh_tokens` (`id`, `account_id`, `token_hash`, `expires_at`, `revoked_at`, `device_info`, `ip_address`, `created_at`) VALUES (1,12,'0a57b16598b9686c7a31945491f8905a4de27c50be005aee89cbcb65cafa38ea','2025-11-19 01:45:34',NULL,'curl/8.12.1',NULL,'2025-11-11 16:45:34'),(2,2,'1b36a1fedabce29ce8dc6a3dbe8f65b3ff02c243491c309f7af6df183c4e7726','2025-11-19 01:46:38',NULL,'curl/8.12.1',NULL,'2025-11-11 16:46:37'),(3,2,'7e7f6634682c8bd450455429dc4e4481e2633f0be6eefcbe64cc3406cac3757e','2025-11-19 01:48:54',NULL,'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0',NULL,'2025-11-11 16:48:54'),(4,2,'801a101573948ccd093857c90632483446e8f913158c23218f9d6835b6f5322a','2025-11-19 02:03:16',NULL,'curl/8.12.1',NULL,'2025-11-11 17:03:16'),(5,2,'d35fab045c49a2261710585c64718e88a82de7c982878e5445a4b8892f4eab3d','2025-11-19 02:05:47',NULL,'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0',NULL,'2025-11-11 17:05:46');
/*!40000 ALTER TABLE `refresh_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `report_evidences`
--

LOCK TABLES `report_evidences` WRITE;
/*!40000 ALTER TABLE `report_evidences` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_evidences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `sanctions`
--

LOCK TABLES `sanctions` WRITE;
/*!40000 ALTER TABLE `sanctions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sanctions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `team_activity_logs`
--

LOCK TABLES `team_activity_logs` WRITE;
/*!40000 ALTER TABLE `team_activity_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `team_memberships`
--

LOCK TABLES `team_memberships` WRITE;
/*!40000 ALTER TABLE `team_memberships` DISABLE KEYS */;
INSERT INTO `team_memberships` (`team_id`, `profile_id`, `role_in_team`, `joined_at`, `left_at`, `is_active`, `created_at`, `updated_at`) VALUES (2,2,'CAPTAIN','2023-11-11 22:48:53',NULL,1,'2023-11-11 22:48:53','2025-11-11 22:48:53'),(2,3,'MEMBER','2024-11-11 22:48:53',NULL,1,'2024-11-11 22:48:53','2025-11-11 22:48:53'),(2,5,'MEMBER','2025-03-11 22:48:53',NULL,1,'2025-03-11 22:48:53','2025-11-11 22:48:53'),(2,8,'MEMBER','2025-05-11 22:48:53',NULL,1,'2025-05-11 22:48:53','2025-11-11 22:48:53'),(3,4,'CAPTAIN','2024-11-11 22:48:53',NULL,1,'2024-11-11 22:48:53','2025-11-11 22:48:53'),(3,7,'MEMBER','2025-06-11 22:48:53',NULL,1,'2025-06-11 22:48:53','2025-11-11 22:48:53'),(3,9,'MEMBER','2025-07-11 22:48:53',NULL,1,'2025-07-11 22:48:53','2025-11-11 22:48:53'),(3,11,'MEMBER','2025-09-11 22:48:53',NULL,1,'2025-09-11 22:48:53','2025-11-11 22:48:53'),(4,4,'VICE_CAPTAIN','2023-11-11 22:48:53',NULL,1,'2023-11-11 22:48:53','2025-11-11 22:48:53'),(4,6,'CAPTAIN','2022-11-11 22:48:53',NULL,1,'2022-11-11 22:48:53','2025-11-11 22:48:53'),(4,8,'MEMBER','2024-11-11 22:48:53',NULL,1,'2024-11-11 22:48:53','2025-11-11 22:48:53'),(4,10,'MEMBER','2024-11-11 22:48:53',NULL,1,'2024-11-11 22:48:53','2025-11-11 22:48:53'),(5,3,'MEMBER','2025-08-11 22:48:53',NULL,1,'2025-08-11 22:48:53','2025-11-11 22:48:53'),(5,5,'CAPTAIN','2025-05-11 22:48:53',NULL,1,'2025-05-11 22:48:53','2025-11-11 22:48:53'),(5,7,'MEMBER','2025-09-11 22:48:53',NULL,1,'2025-09-11 22:48:53','2025-11-11 22:48:53'),(6,2,'MEMBER','2025-08-11 22:48:53',NULL,1,'2025-08-11 22:48:53','2025-11-11 22:48:53'),(6,9,'MEMBER','2025-03-11 22:48:53',NULL,1,'2025-03-11 22:48:53','2025-11-11 22:48:53'),(6,10,'CAPTAIN','2024-11-11 22:48:53',NULL,1,'2024-11-11 22:48:53','2025-11-11 22:48:53'),(9,2,'CAPTAIN','2025-11-13 16:56:49',NULL,1,'2025-11-13 07:56:48','2025-11-13 07:56:48'),(9,4,'MEMBER','2025-11-13 16:56:49',NULL,1,'2025-11-13 07:56:48','2025-11-13 07:56:48'),(9,5,'MEMBER','2025-11-13 16:56:49',NULL,1,'2025-11-13 07:56:48','2025-11-13 07:56:48'),(9,6,'VICE_CAPTAIN','2025-11-13 16:56:49',NULL,1,'2025-11-13 07:56:49','2025-11-13 07:56:49'),(10,2,'MEMBER','2025-11-13 16:56:49',NULL,1,'2025-11-13 07:56:48','2025-11-13 07:56:48'),(10,3,'CAPTAIN','2025-11-13 16:56:49',NULL,1,'2025-11-13 07:56:48','2025-11-13 07:56:48'),(10,7,'MEMBER','2025-11-13 16:56:49',NULL,1,'2025-11-13 07:56:49','2025-11-13 07:56:49'),(10,8,'MEMBER','2025-11-13 16:56:49',NULL,1,'2025-11-13 07:56:49','2025-11-13 07:56:49'),(10,9,'VICE_CAPTAIN','2025-11-13 16:56:49',NULL,1,'2025-11-13 07:56:49','2025-11-13 07:56:49');
/*!40000 ALTER TABLE `team_memberships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `team_notices`
--

LOCK TABLES `team_notices` WRITE;
/*!40000 ALTER TABLE `team_notices` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_notices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `team_rivals`
--

LOCK TABLES `team_rivals` WRITE;
/*!40000 ALTER TABLE `team_rivals` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_rivals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `teams`
--

LOCK TABLES `teams` WRITE;
/*!40000 ALTER TABLE `teams` DISABLE KEYS */;
INSERT INTO `teams` (`id`, `team_name`, `captain_profile_id`, `region`, `sub_region`, `home_ground`, `description`, `logo_url`, `max_members`, `age_group`, `skill_level`, `activity_type`, `total_members`, `total_matches`, `wins`, `draws`, `losses`, `goals_scored`, `goals_conceded`, `win_rate`, `avg_age`, `status`, `verified`, `founded_date`, `created_at`, `updated_at`, `deleted_at`, `rival_teams`) VALUES (2,'FC 강남',2,'서울','강남구','올림픽공원 축구장','강남 지역 최고의 축구팀입니다. 주말마다 열정적으로 뛰고 있습니다!','https://via.placeholder.com/200/FF6B6B/ffffff?text=FC',25,NULL,'INTERMEDIATE',NULL,15,30,18,5,7,0,0,0.00,0.0,'ACTIVE',1,'2023-11-11','2023-11-11 22:48:53','2025-11-11 22:48:53',NULL,NULL),(3,'서울 유나이티드',4,'서울','송파구','잠실종합운동장','송파 지역 사회인 축구팀. 실력보다 친목을 중시합니다.','https://via.placeholder.com/200/4ECDC4/ffffff?text=SU',30,NULL,'BEGINNER',NULL,20,25,10,8,7,0,0,0.00,0.0,'ACTIVE',1,'2024-11-11','2024-11-11 22:48:53','2025-11-11 22:48:53',NULL,NULL),(4,'수원 블루윙즈',6,'경기','수원시','수원월드컵경기장','수원 지역 대표팀. 매주 토요일 훈련 및 경기.','https://via.placeholder.com/200/1A535C/ffffff?text=SW',28,NULL,'ADVANCED',NULL,22,45,28,10,7,0,0,0.00,0.0,'ACTIVE',1,'2022-11-11','2022-11-11 22:48:53','2025-11-11 22:48:53',NULL,NULL),(5,'인천 FC',5,'인천','남동구','인천축구전용경기장','인천 지역 축구 동호회. 초보자도 환영합니다!','https://via.placeholder.com/200/FFE66D/000000?text=IC',20,NULL,'INTERMEDIATE',NULL,12,18,8,4,6,0,0,0.00,0.0,'ACTIVE',1,'2025-05-11','2025-05-11 22:48:53','2025-11-11 22:48:53',NULL,NULL),(6,'고양 호랑이',10,'경기','고양시','고양체육관 축구장','고양시 기반 축구팀. 공격적인 플레이 추구.','https://via.placeholder.com/200/FF6B35/ffffff?text=GH',25,NULL,'ADVANCED',NULL,18,35,22,6,7,0,0,0.00,0.0,'ACTIVE',1,'2024-11-11','2024-11-11 22:48:53','2025-11-11 22:48:53',NULL,NULL),(9,'Thunder Strikers',2,'서울 마포구',NULL,NULL,'test1234가 이끄는 강력한 공격진',NULL,22,'20-35','ADVANCED','COMPETITIVE',0,0,0,0,0,0,0,0.00,0.0,'ACTIVE',0,NULL,'2025-11-13 16:56:48','2025-11-13 07:56:47',NULL,NULL),(10,'Seoul Warriors',3,'서울 용산구',NULL,NULL,'서울을 대표하는 전사들의 모임',NULL,20,'25-40','INTERMEDIATE','REGULAR',0,0,0,0,0,0,0,0.00,0.0,'ACTIVE',0,NULL,'2025-11-13 16:56:48','2025-11-13 07:56:47',NULL,NULL);
/*!40000 ALTER TABLE `teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `user_activity_logs`
--

LOCK TABLES `user_activity_logs` WRITE;
/*!40000 ALTER TABLE `user_activity_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `user_stats_summary`
--

LOCK TABLES `user_stats_summary` WRITE;
/*!40000 ALTER TABLE `user_stats_summary` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_stats_summary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `venues`
--

LOCK TABLES `venues` WRITE;
/*!40000 ALTER TABLE `venues` DISABLE KEYS */;
/*!40000 ALTER TABLE `venues` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-13 23:55:18
