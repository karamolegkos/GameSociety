-- MySQL dump 10.13  Distrib 8.0.22, for Win64 (x86_64)
--
-- Host: localhost    Database: gamesocietydb
-- ------------------------------------------------------
-- Server version	8.0.22

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `comment`
--

DROP TABLE IF EXISTS `comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comment` (
  `commentID` int NOT NULL AUTO_INCREMENT,
  `postID` int NOT NULL,
  `userID` int NOT NULL,
  `text` varchar(100) NOT NULL,
  `dateTime` datetime NOT NULL,
  PRIMARY KEY (`commentID`),
  KEY `postID` (`postID`),
  KEY `userID` (`userID`),
  CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`postID`) REFERENCES `post` (`postID`),
  CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment`
--

LOCK TABLES `comment` WRITE;
/*!40000 ALTER TABLE `comment` DISABLE KEYS */;
INSERT INTO `comment` VALUES (2,3,4,'No','2021-02-21 18:49:19'),(6,4,5,'Good job Dude!!','2021-02-21 18:51:47'),(7,3,5,'LETS GOO','2021-02-21 18:52:30'),(8,3,2,'LoL no','2021-02-21 21:08:31'),(10,6,2,'Hello new here UwU','2021-02-21 23:29:22'),(11,6,9,'Hahaha','2021-02-21 23:29:29'),(12,6,4,'HELLO FRIEND','2021-02-21 23:29:45'),(13,4,9,'Nice!','2021-02-21 23:30:12');
/*!40000 ALTER TABLE `comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `game`
--

DROP TABLE IF EXISTS `game`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `game` (
  `gameID` int NOT NULL AUTO_INCREMENT,
  `userID` int NOT NULL,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`gameID`),
  KEY `userID` (`userID`),
  CONSTRAINT `game_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `game`
--

LOCK TABLES `game` WRITE;
/*!40000 ALTER TABLE `game` DISABLE KEYS */;
INSERT INTO `game` VALUES (2,2,'League of Legends'),(3,2,'Minecraft'),(4,2,'Rocket League'),(5,2,'BattleField Heroes'),(6,2,'Battlerfield 4'),(7,7,'Tetris'),(9,4,'Minecraft'),(10,4,'Friv'),(11,6,'Empire Earth'),(12,6,'Second Life'),(13,5,'Candy Crush'),(15,9,'Minecraft'),(16,1,'DOOM');
/*!40000 ALTER TABLE `game` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message` (
  `messageID` int NOT NULL AUTO_INCREMENT,
  `theUserID` int NOT NULL,
  `friendUserID` int NOT NULL,
  `content` varchar(300) NOT NULL,
  `dateTime` datetime NOT NULL,
  PRIMARY KEY (`messageID`),
  KEY `theUserID` (`theUserID`),
  KEY `friendUserID` (`friendUserID`),
  CONSTRAINT `message_ibfk_1` FOREIGN KEY (`theUserID`) REFERENCES `user` (`userID`),
  CONSTRAINT `message_ibfk_2` FOREIGN KEY (`friendUserID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message`
--

LOCK TABLES `message` WRITE;
/*!40000 ALTER TABLE `message` DISABLE KEYS */;
INSERT INTO `message` VALUES (3,2,1,'Hello','2021-02-21 22:33:53'),(4,9,2,'Hello brotherrr','2021-02-21 23:28:39'),(5,2,9,'Hey you!','2021-02-21 23:28:42'),(6,9,2,'what are you doing today','2021-02-21 23:28:48'),(7,2,9,'not much','2021-02-21 23:28:54'),(8,9,2,'lets go play Minecraft','2021-02-21 23:29:02'),(9,2,9,'OK','2021-02-21 23:29:05'),(10,2,1,'yo are you there','2021-02-21 23:30:51'),(11,1,2,'yeah dude talk to me','2021-02-21 23:31:12'),(12,2,1,'i forgot what i wanted to tell you LOL bye','2021-02-21 23:31:25'),(13,1,2,'bruh','2021-02-21 23:31:31');
/*!40000 ALTER TABLE `message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post`
--

DROP TABLE IF EXISTS `post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post` (
  `postID` int NOT NULL AUTO_INCREMENT,
  `content` varchar(250) NOT NULL,
  `userID` int NOT NULL,
  `dateTime` datetime NOT NULL,
  PRIMARY KEY (`postID`),
  KEY `userID` (`userID`),
  CONSTRAINT `post_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post`
--

LOCK TABLES `post` WRITE;
/*!40000 ALTER TABLE `post` DISABLE KEYS */;
INSERT INTO `post` VALUES (3,'Anyone who wants to playing tetris',7,'2021-02-21 18:49:01'),(4,'I just won a game in Empire Earth!',6,'2021-02-21 18:51:20'),(5,'Hello World',2,'2021-02-21 22:18:15'),(6,'I am new here UwU',9,'2021-02-21 23:27:47');
/*!40000 ALTER TABLE `post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `upvote`
--

DROP TABLE IF EXISTS `upvote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `upvote` (
  `postID` int NOT NULL,
  `userID` int NOT NULL,
  PRIMARY KEY (`postID`,`userID`),
  KEY `userID` (`userID`),
  CONSTRAINT `upvote_ibfk_1` FOREIGN KEY (`postID`) REFERENCES `post` (`postID`),
  CONSTRAINT `upvote_ibfk_2` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `upvote`
--

LOCK TABLES `upvote` WRITE;
/*!40000 ALTER TABLE `upvote` DISABLE KEYS */;
INSERT INTO `upvote` VALUES (3,2),(4,2),(6,2),(3,4),(6,4),(3,5),(4,5),(6,6),(4,9);
/*!40000 ALTER TABLE `upvote` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `userID` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `surname` varchar(45) NOT NULL,
  `profilePicturePath` varchar(200) NOT NULL,
  `nickName` varchar(45) NOT NULL,
  `isAdmin` int NOT NULL,
  `password` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL,
  PRIMARY KEY (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','admin','11','admin',1,'admin','admin@admin.com'),(2,'Panagiotis','Karamolegkos','3','SONEM',1,'12345','p.karamolegos@yahoo.gr'),(4,'Peni','Mpoumpouli','7','FireQueen',0,'12345','peni@gmail.com'),(5,'Paraskevas','Mpoumpoulis','2','Rikos',0,'12345','paris@gmai.com'),(6,'Manolis','Karamolegkos','4','Lino',0,'12345','manolis@gmail.com'),(7,'Stavroula','Tsekoura','1','Roro',0,'12345','roula@gmail.com'),(8,'Giouli','Xatzinova','1','Goulia',0,'12345','gioulia@gmail.com'),(9,'Anastasia','Karamolegkou','9','NastiaEz',0,'12345','nastia@gmail.com');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-02-23 15:53:48
