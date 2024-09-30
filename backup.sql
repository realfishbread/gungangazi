-- MySQL dump 10.13  Distrib 8.0.39, for Win64 (x86_64)
--
-- Host: localhost    Database: appdb
-- ------------------------------------------------------
-- Server version	8.0.39

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
-- Table structure for table `body part table`
--

DROP TABLE IF EXISTS `body part table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `body part table` (
  `body_part_id` int NOT NULL AUTO_INCREMENT,
  `body_part_name` varchar(45) NOT NULL DEFAULT '신체 부위 이름',
  `x_coordinate` varchar(45) NOT NULL DEFAULT '몸에서 해당부위의 x좌표''',
  `y_coordinate` varchar(45) NOT NULL DEFAULT '몸에서 해당 부위의 y좌표',
  PRIMARY KEY (`body_part_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `body part table`
--

LOCK TABLES `body part table` WRITE;
/*!40000 ALTER TABLE `body part table` DISABLE KEYS */;
/*!40000 ALTER TABLE `body part table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question`
--

DROP TABLE IF EXISTS `question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question` (
  `question_text` varchar(255) NOT NULL DEFAULT '질문내용',
  `chart_num` text,
  `question_num` int DEFAULT NULL,
  `answer_text` text,
  `question_id` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`question_id`)
) ENGINE=InnoDB AUTO_INCREMENT=448 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question`
--

LOCK TABLES `question` WRITE;
/*!40000 ALTER TABLE `question` DISABLE KEYS */;
INSERT INTO `question` VALUES ('38°C 이상으로 몸에서 열이 나나?','1',1,'그렇다',1),('38°C 이상으로 몸에서 열이 나나?','1',1,'아니다',2),('지난 10주 동안 일부러 식사 습관을 바꾸지 않았는데도 체중이 4Kg 이상 줄어들었나?','1',2,'4Kg 이상 감소했다',3),('지난 10주 동안 일부러 식사 습관을 바꾸지 않았는데도 체중이 4Kg 이상 줄어들었나?','1',2,'4Kg 미만으로 감소하거나 체중이 증가했다',4),('다음 중 해당하는 증상이 있나?','1',3,'항상 긴장되는 느낌이 든다',5),('다음 중 해당하는 증상이 있나?','1',3,'잠들기가 어렵고 자주 깨는 등 수면장애가 있다',6),('다음 중 해당하는 증상이 있나?','1',3,'집중력이 많이 떨어졌다',7),('다음 중 해당하는 증상이 있나?','1',3,'해당 사항이 없다',8),('다음 중 건망증이나 혼돈 현상과 함께 서서히 나타나는 증상이 있나?','16',8,'해당 사항이 없다',9),('다음 중 해당하는 증상이 있나?','17',1,'기운이 없고 활력이 떨어진다',12),('현재 임신한 상태인가?','1',5,'임신일 수 있다',13),('현재 임신한 상태인가?','1',5,'임신이 아니다',14),('평소보다 더 나른하고 피곤한가?','1',6,'더 피곤하다',15),('평소보다 더 나른하고 피곤한가?','1',6,'별다른 변화가 없다',16),('평소 술을 많이 마시는 편인가?','1',7,'과음하는 편이다',17),('평소 술을 많이 마시는 편인가?','1',7,'과음하지 않는다',18),('다음 중 해당하는 증상이 있나?','1',8,'평소보다 식욕이 떨어졌다',19),('다음 중 해당하는 증상이 있나?','17',1,'잠을 이루지 못하는 등 수면장애가 있다',20),('다음 중 해당하는 증상이 있나?','1',8,'속이 메스껍고 구역질이 난다',21),('다음 중 해당하는 증상이 있나?','17',1,'매사에 자신감이 없다',22),('다음 중 해당하는 증상이 있나?','1',8,'설사를 한다',23),('다음 중 해당하는 증상이 있나?','17',1,'집중력이 많이 떨어진다',24),('다음 중 해당하는 증상이 있나?','1',8,'해당 사항이 없다',25),('다음 중 해당하는 증상이 있나?','17',1,'성에 대한 관심과 흥미가 없다',26),('다음 중 해당하는 증상이 있나?','17',1,'해당 사항이 없다',27),('다음 중 어떤 사건 후에 우울증이 생겼나?','17',2,'가까운 사람의 죽음을 겪고 나서',28),('다음 중 어떤 사건 후에 우울증이 생겼나?','17',2,'이혼한 후',29),('다음 중 어떤 사건 후에 우울증이 생겼나?','17',2,'실직한 후',30),('다음 중 어떤 사건 후에 우울증이 생겼나?','17',2,'기타 힘든 사건을 겪고 나서',31),('다음 중 어떤 사건 후에 우울증이 생겼나?','17',2,'해당 사항이 없다',32),('다음 중 해당하는 사항이 있나?','17',3,'최근에 출산했다',33),('다음 중 해당하는 사항이 있나?','17',3,'최근에 감기를 앓았다',34),('다음 중 해당하는 사항이 있나?','17',3,'큰 수술이나 중병에서 회복중이다',35),('다음 중 해당하는 사항이 있나?','17',3,'해당 사항이 없다',36),('가정이나 직장에서 특별히 스트레스를 받는 일이 있나?','17',5,'그렇다',39),('가정이나 직장에서 특별히 스트레스를 받는 일이 있나?','17',5,'아니다',40),('성별은?','17',6,'남성',41),('성별은?','17',6,'여성',42),('생리를 시작하기 일주일 전에만 우울증을 느끼나?','17',7,'그렇다',43),('생리를 시작하기 일주일 전에만 우울증을 느끼나?','17',7,'아니다',44),('현재 처방약이나 마약류를 복용하고 있나?','17',8,'처방약을 복용하고 있다',45),('현재 처방약이나 마약류를 복용하고 있나?','17',8,'마약류를 복용하고 있다',46),('현재 처방약이나 마약류를 복용하고 있나?','17',8,'둘 다 아니다',47),('다음 중 어떤 경우에 불안감을 느끼나?','18',1,'특정 동물, 물건을 보거나 특정 상황에 처했을 경우',48),('다음 중 어떤 경우에 불안감을 느끼나?','18',1,'평상시 하던 방식대로 행동하지 못하게 되었을 경우',49),('다음 중 어떤 경우에 불안감을 느끼나?','18',1,'둘 다 아니다',50),('흡연이나 음주, 약물복용, 도박 같은 중독성 행위를 중단한 후에 불안감을 느끼나?','18',2,'아니다',51),('다음 중 해당하는 증상이 있나?','2',1,'어지럽거나 졸도한 적이 있다',52),('흡연이나 음주, 약물복용, 도박 같은 중독성 행위를 중단한 후에 불안감을 느끼나?','18',2,'그렇다',53),('다음 중 해당하는 증상이 있나?','18',3,'활력이 없다',54),('다음 중 해당하는 증상이 있나?','18',3,'매사에 자신감이 없다',55),('다음 중 해당하는 증상이 있나?','2',1,'특별한 이유 없이 숨이 차다',56),('현재 임신한 상태인가?','9',9,'임신이 아니다',57),('다음 중 해당하는 증상이 있나?','18',3,'성에 대한 관심과 흥미가 없다',58),('다음 중 해당하는 증상이 있나?','18',3,'해당 사항이 없다',59),('다음 중 해당하는 증상이 있나?','2',1,'혈색이 나쁘고 피부가 많이 창백하다',60),('지난 24시간 내에 머리를 부딪힌 적이 있나?','10',1,'있다',61),('주로 몸의 어느 부위가 가렵나?','19',1,'두피',65),('주로 몸의 어느 부위가 가렵나?','19',1,'남성 성기',66),('다음 중 해당하는 증상이 있나?','2',1,'해당 사항이 없다',67),('지난 10주 동안 일부러 식사 습관을 바꾸지 않았는데도 체중이 4Kg 이상 줄어들었나?','2',2,'4Kg 이상 감소했다',68),('지난 10주 동안 일부러 식사 습관을 바꾸지 않았는데도 체중이 4Kg 이상 줄어들었나?','2',2,'4Kg 미만으로 감소하거나 체중이 증가했다',69),('주로 몸의 어느 부위가 가렵나?','19',1,'여성 성기',70),('다음 중 해당하는 증상이 있나?','2',3,'예전보다 피부가 더 건조하고 거칠어졌다',71),('주로 몸의 어느 부위가 가렵나?','19',1,'항문',72),('다음 중 해당하는 증상이 있나?','2',3,'예전보다 추위를 많이 탄다',73),('주로 몸의 어느 부위가 가렵나?','19',1,'그 외의 부위',74),('다음 중 해당하는 증상이 있나?','2',3,'모발이 가늘어졌다',75),('가려운 부위에 발진이 생겼나?','19',2,'발진이 있다',76),('다음 중 해당하는 증상이 있나?','2',3,'해당 사항이 없다',77),('가려운 부위에 발진이 생겼나?','19',2,'발진이 없다',78),('현재 약을 복용하고 있나?','19',3,'그렇다',79),('지난 24시간 내에 머리를 부딪힌 적이 있나?','10',1,'없다',80),('앞서 말한 위험징후 중에 하나라도 나타난 적이 있나? 또 구토를 한 적이 있나?','10',2,'위험징후가 있었다',81),('앞서 말한 위험징후 중에 하나라도 나타난 적이 있나? 또 구토를 한 적이 있나?','10',2,'머리를 부딪힌 후 구토를 했다',82),('앞서 말한 위험징후 중에 하나라도 나타난 적이 있나? 또 구토를 한 적이 있나?','10',2,'위험징후나 구토가 없었다',83),('지금 38°C 이상으로 몸에서 열이 나나?','10',3,'체온이 38°C 이상이다',84),('현재 약을 복용하고 있나?','19',3,'아니다',86),('지금 38°C 이상으로 몸에서 열이 나나?','10',3,'체온이 38°C 미만이다',93),('어떤 종류의 피부 문제가 생겼나?','20',1,'발진이 생겼다',94),('현재 약을 복용하고 있나?','2',5,'그렇다',95),('어떤 종류의 피부 문제가 생겼나?','20',1,'그 외의 문제가 생겼다',96),('현재 약을 복용하고 있나?','2',5,'아니다',97),('38°C 이상으로 몸에서 열이 나나?','20',2,'체온이 38°C 이상이다',99),('평소 술을 많이 마시는 편인가?','2',6,'과음하는 편이다',100),('38°C 이상으로 몸에서 열이 나나?','20',2,'체온이 38°C 미만이다',102),('평소 술을 많이 마시는 편인가?','2',6,'과음하지 않는다',103),('다음 중 해당하는 사항이 있나?','20',3,'피부가 빨갛고 손으로 눌러보면 아프고 뜨겁다',104),('다음 중 해당하는 증상이 있나?','2',7,'자신감이 없고 스스로가 별볼일없는 사람으로 느껴진다',105),('다음 중 해당하는 사항이 있나?','20',3,'점이 새로 생겼거나, 이미 있던 점이 변했다',106),('다음 중 해당하는 증상이 있나?','2',7,'집중력이 많이 떨어졌다',107),('다음 중 해당하는 사항이 있나?','20',3,'상처가 생기고 3주가 지났는데도 낫지 않는다',108),('다음 중 해당하는 증상이 있나?','2',7,'성에 대한 관심과 흥미가 없어졌다',109),('최근 들어 시각적인 문제가 생기지는 않았나?','10',5,'눈앞이 흐릿하고 시력이 떨어진 것 같다',110),('최근 들어 시각적인 문제가 생기지는 않았나?','10',5,'시력 외의 다른 시각적 문제가 생겼다',111),('최근 들어 시각적인 문제가 생기지는 않았나?','10',5,'별다른 변화가 없다',112),('다음 중 해당하는 증상이 있나?','10',6,'이마와 눈 밑에 통증이 있다',113),('다음 중 해당하는 사항이 있나?','20',3,'손바닥, 발바닥에 딱딱하고 두꺼운 피부색의 종창이 생겼다',114),('다음 중 해당하는 증상이 있나?','10',6,'최근 들어 콧물이 나거나 코가 막힌다',115),('다음 중 해당하는 사항이 있나?','20',3,'해당 사항이 없다',116),('다음 중 해당하는 증상이 있나?','2',7,'해당 사항이 없다',117),('최근에 감기나 독감 같은 바이러스 질환에 걸린 적이 있나?','2',8,'있다',119),('최근에 감기나 독감 같은 바이러스 질환에 걸린 적이 있나?','2',8,'없다',120),('지난 10주 동안 체중이 얼마나 줄어들었나?','3',1,'4Kg 이상으로 감소했다',121),('다음 중 해당하는 증상이 있나?','10',6,'둘 다 아니다',122),('지난 10주 동안 체중이 얼마나 줄어들었나?','3',1,'4Kg 미만으로 감소했다',123),('주로 어느 부위에서 통증을 느끼나?','10',7,'한쪽이나 양쪽 관자놀이',124),('주로 어느 부위에서 통증을 느끼나?','10',7,'다른 부위',125),('현재 약을 복용하고 있나?','10',8,'그렇다',126),('현재 약을 복용하고 있나?','10',8,'아니다',128),('다음 중 해당하는 사항이 있나?','20',5,'아프고 물집이 있는 발진이 목의 한쪽에 생겼고 심하게 아프다',129),('최근 들어 식욕은 어떤 편인가?','3',2,'식욕이 별로 없다',130),('다음 중 해당하는 사항이 있나?','20',5,'은색의 비듬으로 덮인 붉은색 부스럼이 생겼다',131),('최근 들어 식욕은 어떤 편인가?','3',2,'보통이거나 좋다',132),('다음 중 해당하는 사항이 있나?','20',5,'입술 주위에 진물이 나는 물집이 생겼다',133),('다음 중 해당하는 증상이 있나?','3',3,'최근 들어 식욕이 좋아졌다',134),('다음 중 해당하는 사항이 있나?','20',5,'가운데는 노랗고 주변은 빨간 종창이 생겼는데 통증이 있다',135),('다음 중 해당하는 증상이 있나?','3',3,'소변을 자주 보게 된다',136),('다음 중 해당하는 사항이 있나?','20',5,'해당 사항이 없다',137),('다음 중 해당하는 증상이 있나?','3',3,'시력이 떨어진 것 같고 눈이 침침하다',138),('피부 문제를 일으킨 부위가 어떤 상태인가?','20',6,'염증이 있으면서 표면의 허물이 벗겨졌다',139),('피부 문제를 일으킨 부위가 어떤 상태인가?','20',6,'붉게 솟아오르고 중앙에 까만 점이 있다',140),('다음 중 해당하는 증상이 있나?','3',3,'해당 사항이 없다',141),('피부 문제를 일으킨 부위가 어떤 상태인가?','20',6,'여러 개가 솟아올랐는데 그 위치가 변하고 있다',145),('피부 문제를 일으킨 부위가 어떤 상태인가?','20',6,'해당 사항이 없다',147),('발진이 생긴 부위와 주위 피부가 뚜렷하게 구분되나?','20',7,'주위 피부와 구별이 안 된다',149),('다음 중 해당하는 증상이 있나?','3',5,'항상 긴장된 상태로 생활한다',150),('발진이 생긴 부위와 주위 피부가 뚜렷하게 구분되나?','20',7,'주위 피부와 뚜렷이 구별된다',151),('다음 중 해당하는 증상이 있나?','3',5,'유난히 땀이 많이 난다',152),('다음 중 해당하는 사항이 있나?','20',8,'가운데가 붉고 주위로 퍼져가는 발진이 있다',153),('다음 중 해당하는 증상이 있나?','3',5,'눈이 튀어나온 것 같다',154),('다음 중 해당하는 사항이 있나?','20',8,'진드기에 물렸다',155),('다음 중 해당하는 증상이 있나?','3',5,'해당 사항이 없다',156),('다음 중 해당하는 사항이 있나?','20',8,'둘 다 아니다',157),('현재 약을 복용하고 있나?','20',9,'그렇다',158),('현재 약을 복용하고 있나?','20',9,'아니다',159),('만약 발진이 생겼다면, 어떤 특징을 보이나?','21',1,'발진의 부위가 넓고 가려우면서 수포가 있다',160),('만약 발진이 생겼다면, 어떤 특징을 보이나?','21',1,'발진이 중심부의 붉은 점에서 주위로 퍼져나간다',161),('최근 들어 운동량을 늘렸나?','3',6,'운동량을 늘렸다',162),('최근 들어 운동량을 늘렸나?','3',6,'운동량을 늘리지 않았다',163),('다음 중 해당하는 증상이 있나?','3',7,'설사 증상이 계속 재발한다',164),('만약 발진이 생겼다면, 어떤 특징을 보이나?','21',1,'편평한 붉은색의 발진으로, 눌러도 없어지지 않는다',165),('다음 중 해당하는 증상이 있나?','3',7,'변비 증상이 계속 재발한다',166),('만약 발진이 생겼다면, 어떤 특징을 보이나?','21',1,'탁한 붉은색의 반점으로, 손으로 누르면 없어진다',167),('다음 중 해당하는 증상이 있나?','3',7,'복통 증상이 계속 재발한다',168),('다음 중 해당하는 증상이 있나?','3',7,'대변에 피가 섞여 나온다',169),('다음 중 해당하는 증상이 있나?','3',7,'해당 사항이 없다',170),('다음 중 해당하는 증상이 있나?','3',8,'잠을 못 자고 자주 깨는 등 수면장애가 있다',171),('만약 발진이 생겼다면, 어떤 특징을 보이나?','21',1,'밝은 색의 붉은 반점이 뺨에 생겼다',172),('만약 발진이 생겼다면, 어떤 특징을 보이나?','21',1,'분홍색 발진이 주로 몸통이나 얼굴에 생겼다',173),('만약 발진이 생겼다면, 어떤 특징을 보이나?','21',1,'해당 사항이 없다',174),('다음 중 해당하는 증상이 있나?','21',2,'두통이 심하다',175),('다음 중 해당하는 증상이 있나?','21',2,'졸리거나 의식이 혼미해지기도 한다',176),('다음 중 해당하는 증상이 있나?','21',2,'밝은 빛이 싫어진다',177),('다음 중 해당하는 증상이 있나?','3',8,'스스로가 별볼일없는 사람으로 느껴진다',178),('다음 중 해당하는 증상이 있나?','21',2,'머리를 숙이면 목에 통증을 느낀다',179),('다음 중 해당하는 증상이 있나?','3',8,'성에 대한 관심과 흥미가 없어졌다',180),('다음 중 해당하는 증상이 있나?','21',2,'구역질이 나고 구토를 하기도 한다',181),('다음 중 해당하는 증상이 있나?','21',2,'해당 사항이 없다',182),('최근에 다음과 같은 증상이 있었나?','21',3,'콧물이 난다',183),('최근에 다음과 같은 증상이 있었나?','21',3,'기침을 한다',184),('최근에 다음과 같은 증상이 있었나?','21',3,'눈이 충혈됐다',185),('최근에 다음과 같은 증상이 있었나?','21',3,'해당 사항이 없다',186),('예전에도 이런 두통으로 고생한 적이 있나?','10',9,'있었다',187),('예전에도 이런 두통으로 고생한 적이 있나?','10',9,'없었다',188),('다음 중 해당하는 증상이 있나?','11',1,'눈앞이 흐리고 시력이 떨어진 것 같다',189),('다음 중 해당하는 증상이 있나?','11',1,'감각이 없거나 저리다. 몸에서 힘이 빠질 때도 있다',190),('다음 중 해당하는 증상이 있나?','11',1,'의식이 혼미해진다',191),('다음 중 해당하는 증상이 있나?','11',1,'말투가 어눌해지는 등 말하기장애가 나타난다',192),('다음 중 해당하는 증상이 있나?','11',1,'해당 사항이 없다',193),('지금도 그런 증상이 여전히 나타나나?','11',2,'지금도 증상이 있다',194),('지금도 그런 증상이 여전히 나타나나?','11',2,'지금은 증상이 없다',195),('다음 중 해당하는 증상이 있나?','11',3,'귀가 먹먹하고 잘 들리지 않는다',196),('다음 중 해당하는 증상이 있나?','11',3,'귀에서 이상한 소리가 난다',197),('다음 중 해당하는 증상이 있나?','11',3,'둘 다 아니다',198),('현재 약을 복용하고 있나?','11',5,'그렇다',202),('현재 약을 복용하고 있나?','11',5,'아니다',203),('평소에 술을 마시나?','11',6,'마신다',204),('평소에 술을 마시나?','11',6,'마시지 않는다',205),('머리를 돌리거나 들어올릴 때 어지럼증이 생기나?','11',7,'그렇다',206),('머리를 돌리거나 들어올릴 때 어지럼증이 생기나?','11',7,'아니다',207),('현재 연령은?','11',8,'50세 이상이다',208),('다음 중 해당하는 증상이 있나?','3',8,'집중력이 많이 떨어졌다',209),('현재 연령은?','11',8,'50세 미만이다',210),('다음 중 어떤 경우에 감각이 없고 저린 증상이 나타나나?','12',1,'오랫동안 같은 자세로 앉아 있은 후에',211),('다음 중 해당하는 증상이 있나?','3',8,'기운이 없다',212),('다음 중 어떤 경우에 감각이 없고 저린 증상이 나타나나?','12',1,'깊은 잠에서 깨어날 때',213),('다음 중 어떤 경우에 감각이 없고 저린 증상이 나타나나?','12',1,'둘 다 아니다',214),('감각이 없고 저린 증상이 몸의 어느 부위에 생기나?','12',2,'손 또는 팔',215),('감각이 없고 저린 증상이 몸의 어느 부위에 생기나?','12',2,'다른 부위',216),('뒷목이 뻣뻣해진 적이 있나?','12',3,'없다',217),('뒷목이 뻣뻣해진 적이 있나?','12',3,'있다',218),('다음 중 해당하는 증상이 있나?','3',8,'해당 사항이 없다',220),('예전에는 늘 정상 체중을 유지했었나?','4',1,'예전에는 정상 체중이었다',222),('몸의 한쪽에서만 증상이 나타나나?','12',5,'한쪽에만 나타난다',224),('예전에는 늘 정상 체중을 유지했었나?','4',1,'예전에는 저체중이었다',225),('몸의 한쪽에서만 증상이 나타나나?','12',5,'양쪽 모두 나타난다',226),('예전에는 늘 정상 체중을 유지했었나?','4',1,'항상 과체중이다',227),('다음 중 해당하는 증상이 있나?','12',6,'어지럽거나 기절한 적이 있다',228),('부모가 현재 과체중이거나, 예전에 과체중이었던 적이 있나?','4',2,'과체중이다',229),('다음 중 해당하는 증상이 있나?','12',6,'눈앞이 흐리고 시력이 떨어진 것 같다',230),('다음 중 해당하는 증상이 있나?','12',6,'의식이 혼미하다',231),('부모가 현재 과체중이거나, 예전에 과체중이었던 적이 있나?','4',2,'정상 체중 또는 저체중이다',232),('다음 중 해당하는 증상이 있나?','12',6,'말투가 어눌해지는 등 말하기장애가 있다',233),('다음 중 해당하는 증상이 있나?','12',6,'팔다리에 힘이 없다',234),('다음 중 해당하는 증상이 있나?','12',6,'해당 사항이 없다',235),('다음 중 해당하는 증상이 있나?','4',3,'몸이 나른하고 피로하다',236),('다음 중 해당하는 증상이 있나?','4',3,'예전보다 피부가 건조하고 거칠어졌다',237),('언제 손가락이 무감각해지고 파랗게 변하나?','12',7,'날씨가 추울 때',238),('언제 손가락이 무감각해지고 파랗게 변하나?','12',7,'진동형 기계를 사용할 때',239),('다음 중 해당하는 증상이 있나?','4',3,'예전보다 추위를 많이 탄다',240),('언제 손가락이 무감각해지고 파랗게 변하나?','12',7,'둘 다 아니다',241),('다음 중 해당하는 증상이 있나?','4',3,'전체적으로 모발이 가늘어졌다',242),('지금도 그런 증상이 여전히 나타나나?','12',8,'지금도 증상이 있다',243),('다음 중 해당하는 증상이 있나?','4',3,'해당 사항이 없다',244),('지금도 그런 증상이 여전히 나타나나?','12',8,'지금은 증상이 없다',245),('다음 중 어떤 증상과 함께 경련이나 떨림 증상이 나타나나?','13',1,'의식을 잃으면서 나타난다',247),('다음 중 어떤 증상과 함께 경련이나 떨림 증상이 나타나나?','13',1,'집중력이 떨어지면서 나타난다',249),('다음 중 해당하는 증상이 있나?','4',5,'최근에 출산을 했다',250),('다음 중 해당하는 증상이 있나?','4',5,'최근에 금연했다',251),('다음 중 해당하는 증상이 있나?','4',5,'우울증이나 스트레스로 고생하고 있다',252),('다음 중 어떤 증상과 함께 경련이나 떨림 증상이 나타나나?','13',1,'둘 다 아니다',253),('다음 중 해당하는 증상이 있나?','4',5,'활동량이 줄어들었다',254),('경련과 떨림 증상이 어떤 형태로 나타나나?','13',2,'의지와 상관없이 손이 떨린다',255),('다음 중 해당하는 증상이 있나?','4',5,'해당 사항이 없다',256),('경련과 떨림 증상이 어떤 형태로 나타나나?','13',2,'눈꺼풀같이 몸의 일부에 경련이 생긴다',257),('경련과 떨림 증상이 어떤 형태로 나타나나?','13',2,'기타',258),('경련과 떨림 증상이 나타나기 전에 다음과 같은 일이 있었나?','13',3,'커피, 차, 콜라를 많이 마셨다',259),('경련과 떨림 증상이 나타나기 전에 다음과 같은 일이 있었나?','13',3,'한동안 과음하다가 술을 끊었다',260),('경련과 떨림 증상이 나타나기 전에 다음과 같은 일이 있었나?','13',3,'수면제나 진정제를 복용하다가 중단했다',261),('경련과 떨림 증상이 나타나기 전에 다음과 같은 일이 있었나?','13',3,'해당 사항이 없다',262),('현재 연령은?','13',5,'55세 미만이다',268),('현재 연령은?','13',5,'55세 이상이다',269),('다음 중 해당하는 증상이 있나?','13',6,'떨리는 부위를 가만히 두면 증상이 심해진다',270),('다음 중 해당하는 증상이 있나?','13',6,'얼굴이 무표정해진다',271),('다음 중 해당하는 증상이 있나?','13',6,'모든 동작을 시작하기가 힘들다',272),('다음 중 해당하는 증상이 있나?','13',6,'해당 사항이 없다',273),('현재 약을 복용하고 있나?','13',7,'그렇다',274),('현재 약을 복용하고 있나?','13',7,'아니다',275),('주로 얼굴의 어느 부위가 아픈가?','14',1,'한쪽이나 양쪽 관자놀이',276),('주로 얼굴의 어느 부위가 아픈가?','14',1,'눈의 안쪽이나 눈 주위',277),('주로 얼굴의 어느 부위가 아픈가?','14',1,'다른 부위',278),('현재 연령은?','4',6,'40세 미만이다',279),('현재 연령은?','4',6,'40세 이상이다',280),('어떤 종류의 수면장애를 겪고 있나?','5',1,'잠들기가 어렵다',281),('얼굴 통증의 양상은 어떠한가?','14',2,'얼굴을 만지거나 껌을 씹을 때 둔한 통증이 느껴진다',282),('얼굴 통증의 양상은 어떠한가?','14',2,'껌을 씹거나 하품을 할 때 몹시 아프다',283),('얼굴 통증의 양상은 어떠한가?','14',2,'한쪽 또는 양쪽 뺨 주위로 둔한 통증이 느껴진다',284),('어떤 종류의 수면장애를 겪고 있나?','5',1,'잠자다가 자주 깬다',285),('얼굴 통증의 양상은 어떠한가?','14',2,'해당 사항이 없다',286),('숨을 쉬기가 힘들어서 잠이 깨는 편인가?','5',2,'그렇지 않다',287),('다음 중 해당하는 증상이 있나?','14',3,'두피가 민감해져서 만지면 아프다',288),('숨을 쉬기가 힘들어서 잠이 깨는 편인가?','5',2,'그렇다',289),('다음 중 해당하는 증상이 있나?','14',3,'불편감이 있다',290),('다음 중 해당하는 증상이 있나?','5',3,'피곤하고 기운이 없다',291),('다음 중 해당하는 증상이 있나?','14',3,'껌을 씹을 때 통증이 느껴진다',292),('다음 중 해당하는 증상이 있나?','5',3,'스스로가 별볼일없는 사람으로 느껴진다',293),('다음 중 해당하는 증상이 있나?','14',3,'해당 사항이 없다',294),('다음 중 해당하는 증상이 있나?','5',3,'집중력이 많이 떨어졌다',295),('다음 중 해당하는 증상이 있나?','15',1,'눈앞이 흐리고 시력이 떨어진 것 같다',296),('다음 중 해당하는 증상이 있나?','5',3,'성에 대한 관심과 흥미가 없어졌다',297),('다음 중 해당하는 증상이 있나?','15',1,'감각이 없거나 저리고 몸에서 힘이 빠질 때도 있다',298),('다음 중 해당하는 증상이 있나?','5',3,'해당 사항이 없다',299),('다음 중 해당하는 증상이 있나?','15',1,'심하게 어지럽거나 기절한 적이 있다',302),('다음 중 해당하는 증상이 있나?','15',1,'의식이 혼미하다',304),('수면장애와 관련하여 다음과 같은 행동을 한 적이 있나?','5',5,'커피, 차, 콜라를 많이 마셨다',305),('다음 중 해당하는 증상이 있나?','15',1,'안면 근육 한쪽을 움직일 수가 없다',306),('다음 중 해당하는 증상이 있나?','15',1,'해당 사항이 없다',307),('지금도 그런 증상이 여전히 나타나고 있나?','15',2,'지금도 증상이 있다',308),('수면장애와 관련하여 다음과 같은 행동을 한 적이 있나?','5',5,'과음을 한 적이 있다',309),('지금도 그런 증상이 여전히 나타나고 있나?','15',2,'지금은 증상이 없다',310),('수면장애와 관련하여 다음과 같은 행동을 한 적이 있나?','5',5,'밤늦게 과식한 적이 있다',311),('다음 중 해당하는 증상이 있나?','15',3,'입이나 혀에 상처가 있다',312),('수면장애와 관련하여 다음과 같은 행동을 한 적이 있나?','5',5,'해당 사항이 없다',313),('다음 중 해당하는 증상이 있나?','15',3,'술을 마신다',314),('다음 중 해당하는 증상이 있나?','5',6,'항상 긴장된 상태로 생활한다',315),('다음 중 해당하는 증상이 있나?','15',3,'약을 복용하고 있다',316),('다음 중 해당하는 증상이 있나?','5',6,'집중력이 많이 떨어진 것 같다',317),('다음 중 해당하는 증상이 있나?','15',3,'해당 사항이 없다',318),('다음 중 해당하는 증상이 있나?','5',6,'둘 다 아니다',319),('건망증이나 혼돈 현상이 머리를 다친 후에 생겼나?','16',1,'머리 손상이 있었다',320),('현재 약을 복용하고 있나?','5',7,'그렇다',321),('현재 약을 복용하고 있나?','5',7,'아니다',322),('불면증과 관련하여 다음 중 해당하는 사항이 있나?','5',8,'낮에 낮잠을 잤다',323),('불면증과 관련하여 다음 중 해당하는 사항이 있나?','5',8,'깨어 있던 시간이 18시간 미만이다',324),('건망증이나 혼돈 현상이 머리를 다친 후에 생겼나?','16',1,'머리 손상이 없었다',325),('불면증과 관련하여 다음 중 해당하는 사항이 있나?','5',8,'둘 다 아니다',326),('다음 중 해당하는 증상이 있나?','16',2,'눈앞이 흐리고 시력이 떨어진 것 같다',327),('다음 중 해당하는 증상이 있나?','16',2,'감각이 없거나 저리고 몸에서 힘이 빠질 때도 있다',328),('다음 중 해당하는 증상이 있나?','16',2,'심하게 어지럽거나 의식을 잃기도 한다',329),('다음 중 해당하는 증상이 있나?','16',2,'말투가 어눌해지는 등 말하기장애가 있다',330),('다음 중 해당하는 증상이 있나?','16',2,'해당 사항이 없다',331),('낮에는 주로 어떤 활동을 많이 하나?','5',9,'대부분 앉아서 일을 한다',332),('지금도 그런 증상이 여전히 나타나나?','16',3,'지금도 증상이 있다',333),('낮에는 주로 어떤 활동을 많이 하나?','5',9,'신체적으로 활발하게 움직인다',334),('지금도 그런 증상이 여전히 나타나나?','16',3,'지금은 증상이 없다',335),('몸에 발진이 생겼나?','6',1,'그렇다',336),('몸에 발진이 생겼나?','6',1,'아니다',338),('두통이 있는가? 만약 있다면 어느 정도인가?','6',2,'두통이 심하다',340),('두통이 있는가? 만약 있다면 어느 정도인가?','6',2,'가벼운 두통이 있다',341),('두통이 있는가? 만약 있다면 어느 정도인가?','6',2,'두통은 없다',342),('다음 중 해당하는 증상이 있나?','6',3,'졸리거나 의식이 혼미하다',343),('다음 중 해당하는 증상이 있나?','6',3,'밝은 빛이 싫다',344),('다음 중 해당하는 증상이 있나?','6',3,'머리를 숙이면 목에 통증이 생긴다',345),('다음 중 해당하는 증상이 있나?','6',3,'해당 사항이 없다',346),('기침을 하나?','6',5,'그렇다',350),('기침을 하나?','6',5,'아니다',351),('가래가 나오나?','6',6,'가래가 나온다',352),('가래가 나오나?','6',6,'가래는 없다',353),('다음 중 해당하는 증상이 있나?','6',7,'전신에 통증을 느낀다',354),('다음 중 해당하는 증상이 있나?','6',7,'콧물이 나온다',355),('다음 중 해당하는 증상이 있나?','6',7,'둘 다 아니다',356),('소변 보는 데 어려움이 있나?','6',8,'소변 볼 때 통증을 느낀다',357),('소변 보는 데 어려움이 있나?','6',8,'예전보다 소변을 자주 본다',358),('소변 보는 데 어려움이 있나?','6',8,'둘 다 아니다',359),('인후통이 있나?','6',9,'있다',360),('인후통이 있나?','6',9,'없다',361),('지난 몇 주 동안 여러 차례 열이 난 적이 있나?','6',10,'열이 나는 증상이 자주 있었다',362),('지난 몇 주 동안 여러 차례 열이 난 적이 있나?','6',10,'최근에는 열이 난 적이 없다',363),('38°C 이상으로 몸에서 열이 나나?','7',1,'체온이 38°C 이상이다',364),('38°C 이상으로 몸에서 열이 나나?','7',1,'체온이 38°C 미만이다',365),('언제 땀을 많이 흘리나?','7',2,'주로 밤에 땀이 난다',366),('언제 땀을 많이 흘리나?','7',2,'시간과 상관없이 땀이 난다',367),('다음 중 해당하는 증상이 있나?','7',3,'식욕이 증가했거나 체중이 감소했다',368),('다음 중에서 지금 앓고 있는 병이 있나?','16',5,'심장병',369),('다음 중 해당하는 증상이 있나?','7',3,'항상 긴장된 상태이다',370),('다음 중 해당하는 증상이 있나?','7',3,'눈이 튀어나온 것 같다',371),('다음 중에서 지금 앓고 있는 병이 있나?','16',5,'폐질환',372),('다음 중에서 지금 앓고 있는 병이 있나?','16',5,'당뇨병',373),('다음 중 해당하는 증상이 있나?','7',3,'해당 사항이 없다',374),('다음 중에서 지금 앓고 있는 병이 있나?','16',5,'해당 사항이 없다',375),('현재 약을 복용하고 있나?','16',6,'그렇다',376),('현재 약을 복용하고 있나?','16',6,'아니다',377),('최근 몇 시간 내에 술을 마셨나?','16',7,'그렇다',378),('최근 몇 시간 내에 술을 마셨나?','16',7,'아니다',380),('다음 중 건망증이나 혼돈 현상과 함께 서서히 나타나는 증상이 있나?','16',8,'성격이 변한 것 같다',382),('다음 중 해당하는 증상이 있나?','7',5,'생리중에 땀이 많이 난다',383),('다음 중 건망증이나 혼돈 현상과 함께 서서히 나타나는 증상이 있나?','16',8,'개인 위생에 관심이 줄어든 것 같다',384),('다음 중 해당하는 증상이 있나?','7',5,'생리 주기가 불규칙해졌다',385),('다음 중 해당하는 증상이 있나?','7',5,'해당 사항이 없다',386),('현재 체중은 어떤 편인가?','7',6,'과체중이다',387),('다음 중 건망증이나 혼돈 현상과 함께 서서히 나타나는 증상이 있나?','16',8,'일상적인 문제를 해결할 능력이 없어진 것 같다',388),('현재 체중은 어떤 편인가?','7',6,'정상 체중이다',389),('현재 체중은 어떤 편인가?','7',6,'저체중이다',390),('자주 과음을 하는 편인가?','7',7,'과음하는 편이다',391),('자주 과음을 하는 편인가?','7',7,'과음하지 않는다',392),('현재 약을 복용하고 있나?','7',8,'그렇다',393),('현재 약을 복용하고 있나?','7',8,'아니다',394),('주로 신체의 어느 부위에서 땀이 많이 나나?','7',9,'손에 많이 난다',395),('주로 신체의 어느 부위에서 땀이 많이 나나?','7',9,'발에 많이 난다',396),('주로 신체의 어느 부위에서 땀이 많이 나나?','7',9,'다른 부위에 땀이 난다',397),('피부에 생긴 종괴의 특징은 어떠한가?','8',1,'붉은 색을 띠고 아프다',398),('피부에 생긴 종괴의 특징은 어떠한가?','8',1,'아프지 않다',399),('종괴가 몇 개 있나?','8',2,'한 개',400),('종괴가 몇 개 있나?','8',2,'여러 개',401),('38°C 이상으로 몸에서 열이 나나?','8',3,'체온이 38°C 이상이다',402),('38°C 이상으로 몸에서 열이 나나?','8',3,'체온이 38°C 미만이다',403),('종괴가 몸의 어느 부위에 생겼나?','8',5,'고환',406),('종괴가 몸의 어느 부위에 생겼나?','8',5,'사타구니',407),('종괴가 몸의 어느 부위에 생겼나?','8',5,'유방',408),('종괴가 몸의 어느 부위에 생겼나?','8',5,'귀와 턱 사이',409),('종괴가 몸의 어느 부위에 생겼나?','8',5,'목 뒤쪽나 옆쪽',410),('종괴가 몸의 어느 부위에 생겼나?','8',5,'기타 다른 부위',411),('부어오른 곳을 누르면 어떻게 되나?','8',6,'부어올랐던 곳이 없어진다',412),('부어오른 곳을 누르면 어떻게 되나?','8',6,'크기가 줄어든다',413),('부어오른 곳을 누르면 어떻게 되나?','8',6,'아무 변화가 없다',414),('목이 아프거나 따가운 것 같은 인후통이 있나?','8',7,'있다',415),('목이 아프거나 따가운 것 같은 인후통이 있나?','8',7,'없다',416),('최근에 부어오른 곳 주위를 다친 적이 있나?','8',8,'있다',417),('최근에 부어오른 곳 주위를 다친 적이 있나?','8',8,'없다',418),('다음 중 해당하는 증상이 있나?','9',1,'눈앞이 흐리고 시력이 떨어진 것 같다',419),('다음 중 해당하는 증상이 있나?','9',1,'감각이 없거나 저리다. 몸에서 힘이 빠질 때도 있다',420),('다음 중 해당하는 증상이 있나?','9',1,'의식이 혼미하다',421),('다음 중 해당하는 증상이 있나?','9',1,'말투가 어눌해지는 등 말하기장애가 있다',422),('다음 중 해당하는 증상이 있나?','9',1,'해당 사항이 없다',423),('지금도 그런 증상이 계속 나타나고 있나?','9',2,'지금도 있다',424),('지금도 그런 증상이 계속 나타나고 있나?','9',2,'지금은 없다',425),('다음 중 해당하는 증상이 있나?','9',3,'구토할 때 피가 섞여 나온다',426),('다음 중 해당하는 증상이 있나?','9',3,'대변에 피가 섞여 나온다',427),('다음 중 해당하는 증상이 있나?','9',3,'대변 색깔이 검다',428),('다음 중 해당하는 증상이 있나?','9',3,'해당 사항이 없다',429),('다음 중 언제 어지럼증을 느끼고 기절했나?','9',5,'갑자기 자리에서 일어났을 때',434),('다음 중 언제 어지럼증을 느끼고 기절했나?','9',5,'정신적으로 충격을 받았을 때',435),('다음 중 언제 어지럼증을 느끼고 기절했나?','9',5,'둘 다 아니다',436),('다음 중 해당하는 증상이 있나?','9',6,'당뇨병이 있다',437),('다음 중 해당하는 증상이 있나?','9',6,'기절하기 몇 시간 전부터 아무것도 못 먹었다',438),('다음 중 해당하는 증상이 있나?','9',6,'둘 다 아니다',439),('다음 중 해당하는 증상이 있나?','9',7,'숨이 가쁘다',440),('다음 중 해당하는 증상이 있나?','9',7,'혈색이 없고 정상보다 창백하다',441),('다음 중 해당하는 증상이 있나?','9',7,'비정상적으로 피곤함을 느낀다',442),('다음 중 해당하는 증상이 있나?','9',7,'해당 사항이 없다',443),('다음 중 해당하는 증상이 있나?','9',8,'가슴통증이 있었거나 심장병을 앓은 적이 있다',444),('다음 중 해당하는 증상이 있나?','9',8,'가슴이 두근거리는 증상이 있었다',445),('다음 중 해당하는 증상이 있나?','9',8,'둘 다 아니다',446),('현재 임신한 상태인가?','9',9,'임신이거나 임신했을 가능성이 있다',447);
/*!40000 ALTER TABLE `question` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `symptom`
--

DROP TABLE IF EXISTS `symptom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `symptom` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `severity` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `symptom`
--

LOCK TABLES `symptom` WRITE;
/*!40000 ALTER TABLE `symptom` DISABLE KEYS */;
/*!40000 ALTER TABLE `symptom` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `member_id` bigint NOT NULL AUTO_INCREMENT,
  `member_email` varchar(255) DEFAULT NULL,
  `member_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
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

-- Dump completed on 2024-09-21 22:17:36
