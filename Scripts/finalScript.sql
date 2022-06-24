-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema PECI_PROJ
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `PECI_PROJ` ;

-- -----------------------------------------------------
-- Schema PECI_PROJ
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `PECI_PROJ` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `PECI_PROJ` ;

-- -----------------------------------------------------
-- Table `PECI_PROJ`.`Affiliation`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`Affiliation` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`Affiliation` (
  `affiliationID` INT NOT NULL AUTO_INCREMENT,
  `signedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `canceledDate` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`affiliationID`))
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`AffiliationLog`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`AffiliationLog` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`AffiliationLog` (
  `affID` INT NOT NULL,
  `affClientID` INT NOT NULL,
  `affInstID` INT NOT NULL,
  PRIMARY KEY (`affID`, `affClientID`, `affInstID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`SysUser`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`SysUser` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`SysUser` (
  `userID` INT NOT NULL AUTO_INCREMENT,
  `email` VARBINARY(255) NOT NULL,
  `firstName` VARBINARY(255) NOT NULL,
  `lastName` VARBINARY(255) NOT NULL,
  `birthdate` DATE NOT NULL,
  `sex` VARCHAR(32) CHARACTER SET 'utf8' NOT NULL,
  `street` VARBINARY(255) NOT NULL,
  `postCode` VARBINARY(255) NOT NULL,
  `city` VARBINARY(255) NOT NULL,
  `country` VARBINARY(255) NOT NULL,
  `imagePath` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `registerDate` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userID`),
  UNIQUE INDEX `email` (`email` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 5
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`SysClient`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`SysClient` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`SysClient` (
  `clientID` INT NOT NULL,
  `pathologies` VARCHAR(1024) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `firebaseID` VARBINARY(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`clientID`),
  UNIQUE INDEX `firebaseID` (`firebaseID` ASC) VISIBLE,
  CONSTRAINT `FK_sysClient_userID`
    FOREIGN KEY (`clientID`)
    REFERENCES `PECI_PROJ`.`SysUser` (`userID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`ClientPayment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`ClientPayment` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`ClientPayment` (
  `paymentID` INT NOT NULL AUTO_INCREMENT,
  `paidClientID` INT NOT NULL,
  `modality` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL,
  `amount` DECIMAL(10,4) NOT NULL,
  `paypalTransID` VARCHAR(64) CHARACTER SET 'utf8' NOT NULL,
  `paymentDate` DATE NOT NULL,
  PRIMARY KEY (`paymentID`, `paidClientID`),
  INDEX `FK_clientPayment_clientID` (`paidClientID` ASC) VISIBLE,
  CONSTRAINT `FK_clientPayment_clientID`
    FOREIGN KEY (`paidClientID`)
    REFERENCES `PECI_PROJ`.`SysClient` (`clientID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`SysInstructor`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`SysInstructor` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`SysInstructor` (
  `instructorID` INT NOT NULL,
  `firebaseID` VARBINARY(255) NOT NULL,
  `contactNumber` VARBINARY(255) NULL DEFAULT NULL,
  `paypalAccount` VARBINARY(255) NULL DEFAULT NULL,
  `maxClients` INT NOT NULL DEFAULT '100',
  `aboutMe` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT '',
  PRIMARY KEY (`instructorID`),
  UNIQUE INDEX `firebaseID` (`firebaseID` ASC) VISIBLE,
  UNIQUE INDEX `contactNumber` (`contactNumber` ASC) VISIBLE,
  UNIQUE INDEX `paypalAccount` (`paypalAccount` ASC) VISIBLE,
  CONSTRAINT `FK_sysInstructor_userID`
    FOREIGN KEY (`instructorID`)
    REFERENCES `PECI_PROJ`.`SysUser` (`userID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`Program`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`Program` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`Program` (
  `programID` INT NOT NULL AUTO_INCREMENT,
  `pName` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL,
  `pDescription` VARCHAR(1024) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `forPathology` VARCHAR(64) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `thumbnailPath` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `videoPath` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `isPublic` BIT(1) NOT NULL DEFAULT b'0',
  `createDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `isShowcaseProg` BIT(1) NOT NULL DEFAULT b'0',
  `creatorIntsID` INT NULL DEFAULT NULL,
  PRIMARY KEY (`programID`),
  INDEX `FK_Program_instructorID` (`creatorIntsID` ASC) VISIBLE,
  INDEX `isPublicProgramIndex` (`isPublic` ASC) VISIBLE,
  CONSTRAINT `FK_Program_instructorID`
    FOREIGN KEY (`creatorIntsID`)
    REFERENCES `PECI_PROJ`.`SysInstructor` (`instructorID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`ClientPrograms`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`ClientPrograms` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`ClientPrograms` (
  `forClientID` INT NOT NULL,
  `progID` INT NOT NULL,
  `associateDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`forClientID`, `progID`),
  INDEX `FK_clientPrograms_programID` (`progID` ASC) VISIBLE,
  CONSTRAINT `FK_clientPrograms_clientID`
    FOREIGN KEY (`forClientID`)
    REFERENCES `PECI_PROJ`.`SysUser` (`userID`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_clientPrograms_programID`
    FOREIGN KEY (`progID`)
    REFERENCES `PECI_PROJ`.`Program` (`programID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`Exercise`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`Exercise` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`Exercise` (
  `exerciseID` INT NOT NULL AUTO_INCREMENT,
  `firebaseRef` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `eName` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL,
  `difficulty` VARCHAR(32) CHARACTER SET 'utf8' NOT NULL,
  `eDescription` VARCHAR(1024) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `forPathology` VARCHAR(64) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `targetMuscle` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `thumbnailPath` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `videoPath` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `isPublic` BIT(1) NOT NULL DEFAULT b'0',
  `createDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `creatorIntsID` INT NULL DEFAULT NULL,
  PRIMARY KEY (`exerciseID`),
  INDEX `FK_Exercise_instructorID` (`creatorIntsID` ASC) VISIBLE,
  INDEX `isPublicExerciseIndex` (`isPublic` ASC) VISIBLE,
  CONSTRAINT `FK_Exercise_instructorID`
    FOREIGN KEY (`creatorIntsID`)
    REFERENCES `PECI_PROJ`.`SysInstructor` (`instructorID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 8
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`InstructorRemun`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`InstructorRemun` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`InstructorRemun` (
  `renumID` INT NOT NULL AUTO_INCREMENT,
  `receivedInstID` INT NOT NULL,
  `amount` DECIMAL(10,4) NOT NULL,
  `remunDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`renumID`, `receivedInstID`),
  INDEX `FK_instructorRemun_instructorID` (`receivedInstID` ASC) VISIBLE,
  CONSTRAINT `FK_instructorRemun_instructorID`
    FOREIGN KEY (`receivedInstID`)
    REFERENCES `PECI_PROJ`.`SysInstructor` (`instructorID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`PhysicalData`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`PhysicalData` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`PhysicalData` (
  `physicalDataID` INT NOT NULL AUTO_INCREMENT,
  `height` INT NULL DEFAULT NULL,
  `weight` INT NULL DEFAULT NULL,
  `fitness` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT NULL,
  `BMI` INT NULL DEFAULT NULL,
  PRIMARY KEY (`physicalDataID`))
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`PlanIncludes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`PlanIncludes` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`PlanIncludes` (
  `progID` INT NOT NULL,
  `exeID` INT NOT NULL,
  `exerciseOrder` INT NULL DEFAULT NULL,
  `numSets` INT NULL DEFAULT '1',
  `numReps` INT NULL DEFAULT '1',
  `durationTime` TIME NULL DEFAULT '00:00:30',
  `includedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`progID`, `exeID`),
  INDEX `FK_planIncludes_exerciseID` (`exeID` ASC) VISIBLE,
  CONSTRAINT `FK_planIncludes_exerciseID`
    FOREIGN KEY (`exeID`)
    REFERENCES `PECI_PROJ`.`Exercise` (`exerciseID`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_planIncludes_programID`
    FOREIGN KEY (`progID`)
    REFERENCES `PECI_PROJ`.`Program` (`programID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`ProgressLog`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`ProgressLog` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`ProgressLog` (
  `progClientID` INT NOT NULL,
  `physicDataID` INT NOT NULL,
  `measureDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`progClientID`, `physicDataID`),
  INDEX `FK_progressLog_physicaldataID` (`physicDataID` ASC) VISIBLE,
  CONSTRAINT `FK_progressLog_clientID`
    FOREIGN KEY (`progClientID`)
    REFERENCES `PECI_PROJ`.`SysClient` (`clientID`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_progressLog_physicaldataID`
    FOREIGN KEY (`physicDataID`)
    REFERENCES `PECI_PROJ`.`PhysicalData` (`physicalDataID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`ReviewLog`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`ReviewLog` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`ReviewLog` (
  `revClientID` INT NOT NULL,
  `revInstID` INT NOT NULL,
  `rating` INT NULL DEFAULT NULL,
  `review` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT '',
  `reviewDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`revClientID`, `revInstID`),
  INDEX `FK_reviewLog_instructorID` (`revInstID` ASC) VISIBLE,
  CONSTRAINT `FK_reviewLog_clientID`
    FOREIGN KEY (`revClientID`)
    REFERENCES `PECI_PROJ`.`SysClient` (`clientID`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_reviewLog_instructorID`
    FOREIGN KEY (`revInstID`)
    REFERENCES `PECI_PROJ`.`SysInstructor` (`instructorID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`Reward`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`Reward` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`Reward` (
  `rewardID` INT NOT NULL AUTO_INCREMENT,
  `rewardName` VARCHAR(1024) CHARACTER SET 'utf8' NOT NULL,
  `rDescription` VARCHAR(1024) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  `thumbnailPath` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL DEFAULT '',
  PRIMARY KEY (`rewardID`),
  UNIQUE INDEX `rewardName` (`rewardName` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`RewardLog`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`RewardLog` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`RewardLog` (
  `rewID` INT NOT NULL,
  `rewClientID` INT NOT NULL,
  `receivedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rewID`, `rewClientID`),
  INDEX `FK_rewardLog_clientID` (`rewClientID` ASC) VISIBLE,
  CONSTRAINT `FK_reviewLog_rewardID`
    FOREIGN KEY (`rewID`)
    REFERENCES `PECI_PROJ`.`Reward` (`rewardID`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_rewardLog_clientID`
    FOREIGN KEY (`rewClientID`)
    REFERENCES `PECI_PROJ`.`SysClient` (`clientID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`SysAdmin`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`SysAdmin` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`SysAdmin` (
  `adminID` INT NOT NULL,
  `permissionLvl` CHAR(1) NULL DEFAULT NULL,
  PRIMARY KEY (`adminID`),
  CONSTRAINT `FK_sysAdmin_userID`
    FOREIGN KEY (`adminID`)
    REFERENCES `PECI_PROJ`.`SysUser` (`userID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `PECI_PROJ`.`WorkoutLog`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`WorkoutLog` ;

CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`WorkoutLog` (
  `logID` INT NOT NULL AUTO_INCREMENT,
  `doneByClientID` INT NOT NULL,
  `progID` INT NOT NULL,
  `timeTaken` TIME NULL DEFAULT NULL,
  `heartRate` INT NULL DEFAULT '120',
  `caloriesBurnt` INT NULL DEFAULT '30',
  `doneDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`logID`, `doneByClientID`, `progID`),
  INDEX `FK_workoutLog_clientID` (`doneByClientID` ASC) VISIBLE,
  INDEX `FK_workoutLog_programID` (`progID` ASC) VISIBLE,
  CONSTRAINT `FK_workoutLog_clientID`
    FOREIGN KEY (`doneByClientID`)
    REFERENCES `PECI_PROJ`.`SysClient` (`clientID`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_workoutLog_programID`
    FOREIGN KEY (`progID`)
    REFERENCES `PECI_PROJ`.`Program` (`programID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `PECI_PROJ` ;

-- -----------------------------------------------------
-- Placeholder table for view `PECI_PROJ`.`freePublicExercises`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`freePublicExercises` (`exerciseID` INT, `firebaseRef` INT, `eName` INT, `difficulty` INT, `eDescription` INT, `forPathology` INT, `targetMuscle` INT, `thumbnailPath` INT, `videoPath` INT, `isPublic` INT, `createDate` INT, `creatorIntsID` INT);

-- -----------------------------------------------------
-- Placeholder table for view `PECI_PROJ`.`freePublicPrograms`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `PECI_PROJ`.`freePublicPrograms` (`programID` INT, `pName` INT, `pDescription` INT, `forPathology` INT, `thumbnailPath` INT, `videoPath` INT, `isPublic` INT, `createDate` INT, `isShowcaseProg` INT, `creatorIntsID` INT);

-- -----------------------------------------------------
-- procedure spAddClientInfo
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spAddClientInfo`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spAddClientInfo`(IN INclientEmail NVARCHAR(255), IN INheight INT, IN INweight INT, IN INfitness NVARCHAR(255), IN INbmi INT, IN INpathologies NVARCHAR(1024), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
			UPDATE PECI_PROJ.SysClient
			SET pathologies = INpathologies
			WHERE clientID = @uID;
			
			INSERT INTO PECI_PROJ.PhysicalData (height, weight, fitness, BMI) VALUES (INheight, INweight, INfitness, INbmi);
			SELECT LAST_INSERT_ID() INTO @pid;
			INSERT INTO PECI_PROJ.ProgressLog (progClientID, physicDataID) VALUES (@uid, @pid);
		COMMIT;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spAddClientRewards
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spAddClientRewards`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spAddClientRewards`(IN INclientEmail NVARCHAR(255), IN INrewardID INT, IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;	
		INSERT INTO PECI_PROJ.RewardLog (rewID, rewClientID) VALUES (INrewardID, @uID);
    END IF;    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spAddExerciseToProgram
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spAddExerciseToProgram`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spAddExerciseToProgram`(IN INprogramID INT, INexerciseID INT, IN INexerciseOrder INT, IN INnumSets INT, IN INnumReps INT, IN INdurationTime NVARCHAR(64))
BEGIN
	INSERT INTO PECI_PROJ.PlanIncludes (progID, exeID, exerciseOrder, numSets, numReps, durationTime) VALUES (INprogramID, INexerciseID, INexerciseOrder, INnumSets, INnumReps, INdurationTime);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spAssociateInstructor
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spAssociateInstructor`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spAssociateInstructor`(IN INclientEmail NVARCHAR(255), IN INinstructorEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	
    IF ((SELECT COUNT(*) FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail) <> 1 OR (SELECT COUNT(*) FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @cID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail;
		SELECT userID INTO @iID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INinstructorEmail;

		SELECT affiliationID INTO @currentlyAssociated	
			FROM ((SELECT * FROM PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID) AS res
				INNER JOIN PECI_PROJ.SysUser ON  PECI_PROJ.SysUser.userID = res.affClientID) 
				WHERE canceledDate IS NULL AND CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) = INclientEmail;  
				
		IF (@currentlyAssociated = 0 OR @currentlyAssociated IS NULL) THEN
			START TRANSACTION;
				INSERT INTO PECI_PROJ.Affiliation (signedDate) VALUES (CURRENT_TIMESTAMP);
				SELECT LAST_INSERT_ID() INTO @aID;
				INSERT INTO PECI_PROJ.AffiliationLog VALUES (@aID, @cID, @iID);
			COMMIT;
		ELSE
			START TRANSACTION;
				UPDATE PECI_PROJ.Affiliation
				SET canceledDate = CURRENT_TIMESTAMP
				WHERE affiliationID = @currentlyAssociated;
				INSERT INTO PECI_PROJ.Affiliation (signedDate) VALUES (CURRENT_TIMESTAMP);
				SELECT LAST_INSERT_ID() INTO @aID;
				INSERT INTO PECI_PROJ.AffiliationLog VALUES (@aID, @cID, @iID);
			COMMIT;
		END IF;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spAssociateProgramToClient
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spAssociateProgramToClient`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spAssociateProgramToClient`(IN INclientEmail NVARCHAR(255), IN INprogramID INT, IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @cID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
		INSERT INTO PECI_PROJ.ClientPrograms (forClientID, progID) VALUES (@cID, INprogramID);
    END IF;    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spClientReviewInstructor
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spClientReviewInstructor`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spClientReviewInstructor`(IN INclientEmail NVARCHAR(255), IN INinstructorEmail NVARCHAR(255), IN INrating INT, INreview NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail) <> 1 OR (SELECT COUNT(*) FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @cID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail;
		SELECT userID INTO @iID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INinstructorEmail;
		
		IF(INreview IS NULL OR INreview = "") THEN
			INSERT INTO PECI_PROJ.ReviewLog(revClientID, revInstID, rating) VALUES (@cID, @iID, INrating) ON DUPLICATE KEY UPDATE revClientID = @cID, revInstID = @iID, rating = INrating;
		ELSE
			INSERT INTO PECI_PROJ.ReviewLog(revClientID, revInstID, rating, review) VALUES (@cID, @iID, INrating, INreview) ON DUPLICATE KEY UPDATE revClientID = @cID, revInstID = @iID, rating = INrating, review = Inreview;
		END IF;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spCreateClient
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spCreateClient`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spCreateClient`(IN INclientEmail NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		INSERT INTO PECI_PROJ.SysUser (email, firstName, lastName, birthdate, sex, street, postCode, city, country) VALUES (AES_ENCRYPT(INclientEmail, dbKey), AES_ENCRYPT(INfirstName, dbKey), AES_ENCRYPT(INlastName, dbKey), INbirthdate, INsex, AES_ENCRYPT(INstreet, dbKey), AES_ENCRYPT(INpostCode, dbKey), AES_ENCRYPT(INcity, dbKey), AES_ENCRYPT(INcountry, dbKey));
		SELECT userID INTO @cID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
		INSERT INTO PECI_PROJ.SysClient (clientId) VALUES (@cID);
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spCreateExercise
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spCreateExercise`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spCreateExercise`(IN INinstructorEmail NVARCHAR(255), IN INname NVARCHAR(255), IN INfirebaseRef NVARCHAR(255), IN INdifficulty NVARCHAR(32), IN INdescription NVARCHAR(1024), IN INforPathology NVARCHAR(64), IN INtargetMuscle NVARCHAR(255), IN INthumbnailPath NVARCHAR(255), IN INvideoPath NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		INSERT INTO PECI_PROJ.Exercise (eName, firebaseRef, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath) VALUES (INname, INfirebaseRef, INdifficulty, INdescription, INforPathology, INtargetMuscle, INthumbnailPath, INvideoPath);
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		INSERT INTO PECI_PROJ.Exercise (eName, firebaseRef, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, creatorIntsID) VALUES (INname, INfirebaseRef, INdifficulty, INdescription, INforPathology, INtargetMuscle, INthumbnailPath, INvideoPath, @iID);
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spCreateInstructor
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spCreateInstructor`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spCreateInstructor`(IN INinstructorEmail NVARCHAR(255), IN INfirebaseID NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN INcontactNumber NVARCHAR(255), IN INpaypalAccount NVARCHAR(255), IN INmaxClients INT, IN INaboutMe NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		INSERT INTO PECI_PROJ.SysUser (email, firstName, lastName, birthdate, sex, street, postCode, city, country) VALUES (AES_ENCRYPT(INinstructorEmail, dbKey), AES_ENCRYPT(INfirstName, dbKey), AES_ENCRYPT(INlastName, dbKey), INbirthdate, INsex, AES_ENCRYPT(INstreet, dbKey), AES_ENCRYPT(INpostCode, dbKey), AES_ENCRYPT(INcity, dbKey), AES_ENCRYPT(INcountry, dbKey));
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
        IF(INmaxClients = 0 OR INmaxClients IS NULL) THEN
			IF(INaboutMe = "" OR INaboutMe IS NULL) THEN
				INSERT INTO PECI_PROJ.SysInstructor (instructorID, firebaseID, contactNumber, paypalAccount) VALUES (@iID, AES_ENCRYPT(INfirebaseID, dbKey), AES_ENCRYPT(INcontactNumber, dbKey), AES_ENCRYPT(INpaypalAccount, dbKey));
			ELSE
				INSERT INTO PECI_PROJ.SysInstructor (instructorID, firebaseID, contactNumber, paypalAccount, aboutMe) VALUES (@iID, AES_ENCRYPT(INfirebaseID, dbKey), AES_ENCRYPT(INcontactNumber, dbKey), AES_ENCRYPT(INpaypalAccount, dbKey), INaboutMe);
			END IF;
        ELSE
			IF(INaboutMe = "" OR INaboutMe IS NULL) THEN
				INSERT INTO PECI_PROJ.SysInstructor (instructorID, firebaseID, contactNumber, paypalAccount, maxClients) VALUES (@iID, AES_ENCRYPT(INfirebaseID, dbKey), AES_ENCRYPT(INcontactNumber, dbKey), AES_ENCRYPT(INpaypalAccount, dbKey), INmaxClients);
			ELSE
				INSERT INTO PECI_PROJ.SysInstructor VALUES (@iID, AES_ENCRYPT(INfirebaseID, dbKey) ,AES_ENCRYPT(INcontactNumber, dbKey), AES_ENCRYPT(INpaypalAccount, dbKey), INmaxClients, INaboutMe); 
			END IF;
		END IF;
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spCreateProgram
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spCreateProgram`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spCreateProgram`(IN INinstructorEmail NVARCHAR(255), IN INname NVARCHAR(255), IN INdescription NVARCHAR(1024), IN INforPathology NVARCHAR(64), IN INthumbnailPath NVARCHAR(255), IN INvideoPath NVARCHAR(255), IN INshowcaseProg BIT(1), dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		INSERT INTO PECI_PROJ.Program (pName, pDescription, forPathology, thumbnailPath, videoPath) VALUES (INname, INdescription, INforPathology, INthumbnailPath, INvideoPath);
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		IF(INshowcaseProg = 0) THEN
			INSERT INTO PECI_PROJ.Program (pName, pDescription, forPathology, thumbnailPath, videoPath, creatorIntsID) VALUES (INname, INdescription, INforPathology, INthumbnailPath, INvideoPath, @iID);
		ELSE
			INSERT INTO PECI_PROJ.Program (pName, pDescription, forPathology, thumbnailPath, videoPath, isShowcaseProg, creatorIntsID) VALUES (INname, INdescription, INforPathology, INthumbnailPath, INvideoPath, INshowcaseProg, @iID);
		END IF;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spDeleteClient
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spDeleteClient`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spDeleteClient`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
			DELETE FROM PECI_PROJ.SysUser WHERE userID <> 0 AND AES_DECRYPT(email, dbKey) = INclientEmail;
		COMMIT;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spDeleteExercise
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spDeleteExercise`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spDeleteExercise`(IN INexerciseID INT, IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT exerciseID, eName FROM PECI_PROJ.Exercise) AS t1 WHERE t1.exerciseID = INexerciseID) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			DELETE FROM PECI_PROJ.Exercise WHERE exerciseID <> 0 AND exerciseID = INexerciseID;
		COMMIT;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spDeleteProgram
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spDeleteProgram`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spDeleteProgram`(IN INprogramID INT, IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT programID, pName FROM PECI_PROJ.Program) AS t1 WHERE t1.programID = INprogramID) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			DELETE FROM PECI_PROJ.Program WHERE programID <> 0 AND programID = INprogramID;
		COMMIT;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spFinalizeClientPayment
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spFinalizeClientPayment`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spFinalizeClientPayment`(IN INclientEmail NVARCHAR(255), IN INmodality NVARCHAR(255), IN INamount NUMERIC(10,4), IN INtransID NVARCHAR(64), IN INdate DATE, IN dbKey NVARCHAR(255))
BEGIN
    IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
		INSERT INTO PECI_PROJ.ClientPayment (paidClientID, modality, amount, paypalTransID, paymentDate) VALUES (@uID, INmodality, INamount, INtransID, INdate);
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spFinishWorkout
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spFinishWorkout`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spFinishWorkout`(IN INclientEmail NVARCHAR(255), IN INprogramID INT, INtimeTaken TIME, IN INheartRate INT, INcaloriesBurnt INT, IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;	
		INSERT INTO PECI_PROJ.WorkoutLog (doneByClientID, progID, timeTaken, heartRate, caloriesBurnt) VALUES (@uID, INprogramID, INtimeTaken, INheartRate, INcaloriesBurnt);
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spIsClientAssociated
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spIsClientAssociated`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spIsClientAssociated`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;	
		SELECT 	mail,
				firstName,
				lastName,
				CAST(signedDate AS CHAR) AS signedDate,
				canceledDate,
				rating,
				review
		FROM (SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail,
						CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS firstName,
						CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS lastName,
						DATE(signedDate) AS signedDate,
						DATE(canceledDate) AS canceledDate,
						affClientID,
						affInstID
				FROM PECI_PROJ.SysUser 
				INNER JOIN (SELECT *
							FROM PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID
							WHERE affClientID = @uID) AS res ON PECI_PROJ.SysUser.userID = res.affInstID) AS res2 
				LEFT JOIN PECI_PROJ.ReviewLog ON (PECI_PROJ.ReviewLog.revClientID = res2.affClientID AND PECI_PROJ.ReviewLog.revInstID = res2.affInstID)
                WHERE canceledDate IS NULL
				ORDER BY canceledDate ASC
                LIMIT 1;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spRemoveExerciseFromPlan
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spRemoveExerciseFromPlan`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spRemoveExerciseFromPlan`(IN INprogID INT, INexeID INT)
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT progID, exeID FROM PECI_PROJ.PlanIncludes) AS t1 WHERE t1.progID = INprogID AND t1.exeID = INexeID) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			DELETE FROM PECI_PROJ.PlanIncludes WHERE progID <> 0 AND progID = INprogID AND exeID = INexeID;
		COMMIT;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spRemoveInstructorAssociation
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spRemoveInstructorAssociation`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spRemoveInstructorAssociation`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;	
		SELECT 	affiliationID INTO @affID FROM
		(SELECT affiliationID 
			FROM (SELECT 	*
				FROM PECI_PROJ.SysUser 
				INNER JOIN (SELECT *
							FROM PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID
							WHERE affClientID = @uID) AS res ON PECI_PROJ.SysUser.userID = res.affInstID) AS res2 
				LEFT JOIN PECI_PROJ.ReviewLog ON (PECI_PROJ.ReviewLog.revClientID = res2.affClientID AND PECI_PROJ.ReviewLog.revInstID = res2.affInstID)
                WHERE canceledDate IS NULL
				ORDER BY canceledDate ASC
                LIMIT 1 ) AS res4;
		UPDATE 	PECI_PROJ.affiliation
        SET		canceledDate = CURRENT_TIMESTAMP
        WHERE	affiliationID = @affID;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spRemovePlanFromClient
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spRemovePlanFromClient`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spRemovePlanFromClient`(IN INprogID INT, IN INclientID INT)
BEGIN
	DELETE FROM	PECI_PROJ.ClientPrograms WHERE forClientID = INclientID AND progID = INprogID;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectAllProgramExercises
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectAllProgramExercises`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectAllProgramExercises`()
BEGIN
	SELECT 	progID AS programID, exerciseID, eName, firebaseRef, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, DATE(includedDate) AS includedDate, numSets, exerciseOrder, numReps, durationTime, creatorIntsID AS creatorID 
    FROM 	PECI_PROJ.Exercise INNER JOIN PECI_PROJ.PlanIncludes ON PECI_PROJ.Exercise.exerciseID = PECI_PROJ.PlanIncludes.exeID 
    ORDER BY progID ASC;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectAssociatedInstructor
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectAssociatedInstructor`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectAssociatedInstructor`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;	
		SELECT 	res3.mail,
				res3.firstName,
                res3.lastName,
                res3.birthDate,
                res3.sex,
                res3.country,
                res3.registerDate,
                res3.maxClients,
                res3.currentClients,
                res3.averageRating,
                res3.aboutMe,
                res3.imagePath,
                res3.firebaseID
        FROM (SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail,
						CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS firstName,
						CONVERT(AES_DECRYPT(lastName, dbKey) USING UTF8MB4) AS lastName,
						DATE(birthDate) AS birthDate,
						sex AS sex,
						CONVERT(AES_DECRYPT(country, dbKey) USING UTF8MB4) AS country,
						CAST(DATE(registerDate) AS CHAR) AS registerDate,
						maxClients,
						currentClients,
						averageRating,
						aboutMe,
						imagePath,
						CONVERT(AES_DECRYPT(firebaseID, dbKey) USING UTF8MB4) AS firebaseID
						FROM 	(SELECT * 
								FROM 	PECI_PROJ.SysUser INNER JOIN PECI_PROJ.SysInstructor ON PECI_PROJ.SysUser.userID = PECI_PROJ.SysInstructor.instructorID) AS res1
						LEFT JOIN (SELECT 	affInstID, COUNT(*) AS currentClients
									FROM 	PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID
									WHERE 	canceledDate IS NULL
									GROUP BY affInstID) AS res2 ON res2.affInstID = res1.userID
						LEFT JOIN (SELECT 	revInstID,
											AVG(rating) AS averageRating
									FROM	PECI_PROJ.ReviewLog
									GROUP BY revInstID) AS res3 ON res3.revInstID = res1.userID) AS res3
			INNER JOIN (SELECT 	mail,
								firstName,
								lastName,
								CAST(signedDate AS CHAR) AS signedDate,
								canceledDate,
								rating,
								review
						FROM (SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail,
										CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS firstName,
										CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS lastName,
										DATE(signedDate) AS signedDate,
										DATE(canceledDate) AS canceledDate,
										affClientID,
										affInstID
								FROM PECI_PROJ.SysUser 
								INNER JOIN (SELECT *
											FROM PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID
											WHERE affClientID = @uID) AS res ON PECI_PROJ.SysUser.userID = res.affInstID) AS res2 
								LEFT JOIN PECI_PROJ.ReviewLog ON (PECI_PROJ.ReviewLog.revClientID = res2.affClientID AND PECI_PROJ.ReviewLog.revInstID = res2.affInstID)
								WHERE canceledDate IS NULL
								ORDER BY canceledDate ASC
								LIMIT 1) AS res4 ON res3.mail = res4.mail;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectAvailableInstructors
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectAvailableInstructors`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectAvailableInstructors`(IN dbKey NVARCHAR(255))
BEGIN
	SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail,
			CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS firstName,
			CONVERT(AES_DECRYPT(lastName, dbKey) USING UTF8MB4) AS lastName,
			DATE(birthDate) AS birthDate,
			sex AS sex,
			CONVERT(AES_DECRYPT(country, dbKey) USING UTF8MB4) AS country,
			CAST(DATE(registerDate) AS CHAR) AS registerDate,
			maxClients,
			currentClients,
			averageRating,
            aboutMe,
            imagePath,
            CONVERT(AES_DECRYPT(firebaseID, dbKey) USING UTF8MB4) AS firebaseID
	FROM 	(SELECT * 
			FROM 	PECI_PROJ.SysUser INNER JOIN PECI_PROJ.SysInstructor ON PECI_PROJ.SysUser.userID = PECI_PROJ.SysInstructor.instructorID) AS res1
	LEFT JOIN (SELECT 	affInstID, COUNT(*) AS currentClients
				FROM 	PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID
				WHERE 	canceledDate IS NULL
                GROUP BY affInstID) AS res2 ON res2.affInstID = res1.userID
	LEFT JOIN (SELECT 	revInstID,
						AVG(rating) AS averageRating
				FROM	PECI_PROJ.ReviewLog
				GROUP BY revInstID) AS res3 ON res3.revInstID = res1.userID
	WHERE	(currentClients IS NULL OR currentClients <= maxClients);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectClient
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectClient`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectClient`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
    SELECT * 
	FROM (SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail,
					CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS firstName,
					CONVERT(AES_DECRYPT(lastName, dbKey) USING UTF8MB4) AS lastName,
					DATE(birthDate) AS birthDate,
					sex AS sex,
					CONVERT(AES_DECRYPT(street, dbKey) USING UTF8MB4) AS street,
					CONVERT(AES_DECRYPT(postCode, dbKey) USING UTF8MB4) AS postCode,
					CONVERT(AES_DECRYPT(city, dbKey) USING UTF8MB4) AS city,
					CONVERT(AES_DECRYPT(country, dbKey) USING UTF8MB4) AS country,
                    CAST(DATE(registerDate) AS CHAR) AS registerDate,
					pathologies AS pathologies,
                    imagePath AS imagePath,
                    CONVERT(AES_DECRYPT(firebaseID, dbKey) USING UTF8MB4) AS firebaseID
			FROM PECI_PROJ.SysUser INNER JOIN PECI_PROJ.SysClient ON PECI_PROJ.SysUser.userID = PECI_PROJ.SysClient.clientID) AS t1 WHERE t1.mail = INclientEmail;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectClientInfo
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectClientInfo`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectClientInfo`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail;
		SELECT physicalDataID, height, weight, BMI, fitness, pathologies, CAST(DATE(measureDate) AS CHAR) AS measuredDate
			FROM ((PECI_PROJ.ProgressLog INNER JOIN PECI_PROJ.PhysicalData ON PECI_PROJ.ProgressLog.physicDataID = PECI_PROJ.PhysicalData.PhysicalDataID)
				INNER JOIN PECI_PROJ.SysClient ON PECI_PROJ.SysClient.clientID = PECI_PROJ.ProgressLog.progClientID)
				WHERE clientID=@uID
				ORDER BY physicDataID DESC;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectClientInstructorHistory
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectClientInstructorHistory`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectClientInstructorHistory`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;	
		SELECT 	mail,
				firstName,
				lastName,
				CAST(signedDate AS CHAR) AS signedDate,
				canceledDate,
				rating,
				review,
                imagePath
		FROM (SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail,
						CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS firstName,
						CONVERT(AES_DECRYPT(lastName, dbKey) USING UTF8MB4) AS lastName,
						DATE(signedDate) AS signedDate,
						DATE(canceledDate) AS canceledDate,
						affClientID,
						affInstID,
                        imagePath
				FROM PECI_PROJ.SysUser 
				INNER JOIN (SELECT *
							FROM PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID
							WHERE affClientID = @uID) AS res ON PECI_PROJ.SysUser.userID = res.affInstID) AS res2 
				LEFT JOIN PECI_PROJ.ReviewLog ON (PECI_PROJ.ReviewLog.revClientID = res2.affClientID AND PECI_PROJ.ReviewLog.revInstID = res2.affInstID)
				ORDER BY canceledDate ASC;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectClientPaymentHistory
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectClientPaymentHistory`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectClientPaymentHistory`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
		SELECT 	paymentID,
				modality,
                amount,
                CAST(DATE(paymentDate) AS CHAR) AS paymentDate
        FROM PECI_PROJ.ClientPayment WHERE paymentID <> 0 AND paidClientID = @uID;
    END IF;    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectClientPrograms
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectClientPrograms`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectClientPrograms`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;	
		SELECT	programID,
				pName,
                pDescription,
                forPathology,
                thumbnailPath,
                videoPath,
                isPublic,
                isShowcaseProg,
                creatorIntsID
        FROM PECI_PROJ.Program INNER JOIN PECI_PROJ.ClientPrograms ON PECI_PROJ.Program.ProgramID = PECI_PROJ.ClientPrograms.progID
		WHERE PECI_PROJ.ClientPrograms.forClientID = @uID;
	END IF;    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectClientRewards
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectClientRewards`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectClientRewards`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;	
		SELECT 	rewardName,
				rDescription,
				thumbnailPath, 
				CAST(DATE(receivedDate) AS CHAR) AS receivedDate
		FROM (PECI_PROJ.Reward INNER JOIN PECI_PROJ.RewardLog ON PECI_PROJ.Reward.rewardID = PECI_PROJ.RewardLog.rewID)
		WHERE PECI_PROJ.RewardLog.rewClientID = @uID;
	END IF;    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectClientWorkoutHistory
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectClientWorkoutHistory`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectClientWorkoutHistory`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;	
		SELECT 	logID, 
				progID, 
                pName,
                timeTaken, 
                heartRate, 
                caloriesBurnt, 
                doneDate
		FROM PECI_PROJ.WorkoutLog
		INNER JOIN  PECI_PROJ.Program
		ON  PECI_PROJ.Program.programID = PECI_PROJ.WorkoutLog.progID
        WHERE doneByClientID=@uID
        ORDER BY logID DESC;
	END IF;    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectDefaultExercises
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectDefaultExercises`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectDefaultExercises`()
BEGIN
     SELECT * FROM PECI_PROJ.freePublicExercises;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectDefaultPrograms
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectDefaultPrograms`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectDefaultPrograms`()
BEGIN
     SELECT * FROM PECI_PROJ.freePublicPrograms;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectInstructor
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectInstructor`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectInstructor`(IN INinstructorEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
    SELECT * 
		FROM (SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail,
						CONVERT(AES_DECRYPT(firebaseID, dbKey) USING UTF8MB4) AS fireBaseID,
						CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS firstName,
						CONVERT(AES_DECRYPT(lastName, dbKey) USING UTF8MB4) AS lastName,
						birthdate AS birthDate,
						sex AS sex,
						CONVERT(AES_DECRYPT(street, dbKey) USING UTF8MB4) AS street,
						CONVERT(AES_DECRYPT(postCode, dbKey) USING UTF8MB4) AS postCode,
						CONVERT(AES_DECRYPT(city, dbKey) USING UTF8MB4) AS city,
						CONVERT(AES_DECRYPT(country, dbKey) USING UTF8MB4) AS country,
						CONVERT(AES_DECRYPT(paypalAccount, dbKey) USING UTF8MB4) AS paypalAcc,
						CONVERT(AES_DECRYPT(contactNumber, dbKey) USING UTF8MB4) AS contactNumber,
						maxClients,
                        aboutMe,
                        imagePath
						FROM PECI_PROJ.SysUser JOIN PECI_PROJ.SysInstructor ON PECI_PROJ.SysUser.userID = PECI_PROJ.SysInstructor.InstructorID) AS t1 WHERE t1.mail = INinstructorEmail;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectInstructorClients
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectInstructorClients`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectInstructorClients`(IN INInstructorEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INInstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INInstructorEmail;
		SELECT 	userID AS clientID,
				CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail,
				CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS firstName,
				CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS lastName,
				birthdate,
				sex,
				DATE(signedDate) AS clientSince,
				imagePath,
				CONVERT(AES_DECRYPT(firebaseID, dbKey) USING UTF8MB4) AS firebaseID
			FROM (SELECT 	*
			FROM ((SELECT * FROM PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID) AS res
				INNER JOIN PECI_PROJ.SysUser ON  PECI_PROJ.SysUser.userID = res.affClientID) 
				WHERE canceledDate IS NULL AND affInstID = @iID) AS finalTbl
                INNER JOIN PECI_PROJ.SysClient ON PECI_PROJ.SysClient.clientID = finalTbl.userID;   
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectInstructorClientsFromID
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectInstructorClientsFromID`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectInstructorClientsFromID`(IN INInstructorEmail NVARCHAR(255), IN INclientID INT, IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INInstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INInstructorEmail;
		SELECT 	userID AS clientID,
				CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) AS mail,
				CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8MB4) AS firstName,
				CONVERT(AES_DECRYPT(lastName, dbKey) USING UTF8MB4) AS lastName,
				birthdate,
				sex,
				DATE(signedDate) AS clientSince,
				imagePath,
				CONVERT(AES_DECRYPT(firebaseID, dbKey) USING UTF8MB4) AS firebaseID 
			FROM (SELECT *
			FROM ((SELECT * FROM PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID) AS res
				INNER JOIN PECI_PROJ.SysUser ON  PECI_PROJ.SysUser.userID = res.affClientID) 
				WHERE canceledDate IS NULL AND affInstID = @iID AND affClientID = INclientID ) AS finalTbl
                INNER JOIN PECI_PROJ.SysClient ON PECI_PROJ.SysClient.clientID = finalTbl.userID;  
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectInstructorExerciseFromID
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectInstructorExerciseFromID`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectInstructorExerciseFromID`(IN INinstructorEmail NVARCHAR(255),IN INeid INT ,IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		SELECT 	exerciseID, firebaseRef, eName,difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, createDate 
		FROM 	PECI_PROJ.Exercise
		WHERE 	creatorIntsID = @iID AND exerciseID = INeid;
	END IF;     
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectInstructorExercises
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectInstructorExercises`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectInstructorExercises`(IN INinstructorEmail NVARCHAR(255), IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		SELECT 	exerciseID, eName, firebaseRef, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, createDate 
		FROM 	PECI_PROJ.Exercise
		WHERE 	creatorIntsID = @iID;
	END IF;     
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectInstructorProgramFromID
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectInstructorProgramFromID`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectInstructorProgramFromID`(IN INinstructorEmail NVARCHAR(255), IN pid INT,IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		SELECT programID, pName, pDescription, forPathology, thumbnailPath, videoPath, isShowcaseProg, createDate
		FROM PECI_PROJ.Program
		WHERE creatorIntsID = @iID AND programID = pid;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectInstructorPrograms
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectInstructorPrograms`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectInstructorPrograms`(IN INinstructorEmail NVARCHAR(255), IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		SELECT programID, pName, pDescription, forPathology, thumbnailPath, videoPath, isShowcaseProg, createDate
		FROM PECI_PROJ.Program
		WHERE creatorIntsID = @iID;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectInstructorShowcasePrograms
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectInstructorShowcasePrograms`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectInstructorShowcasePrograms`(IN INinstructorEmail NVARCHAR(255), IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		SELECT programID, pName, pDescription, forPathology, thumbnailPath, videoPath, isShowcaseProg, createDate
		FROM PECI_PROJ.Program 
		WHERE (creatorIntsID = @iID AND isShowcaseProg = 1);
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectLatestClientPayment
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectLatestClientPayment`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectLatestClientPayment`(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
		SELECT 	paymentID,
				modality,
                amount,
                CAST(DATE(paymentDate) AS CHAR) AS paymentDate
        FROM PECI_PROJ.ClientPayment WHERE paymentID <> 0 AND paidClientID = @uID AND paymentID=(SELECT max(paymentID) FROM PECI_PROJ.ClientPayment WHERE paidClientID=@uID);
    END IF;    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spSelectProgramExercises
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spSelectProgramExercises`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spSelectProgramExercises`(IN INprogramID INT)
BEGIN
	SELECT 	progID AS programID, exerciseID, eName, firebaseRef, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, DATE(includedDate) AS includedDate, numSets, exerciseOrder, numReps, durationTime, creatorIntsID AS creatorID 
    FROM 	PECI_PROJ.Exercise INNER JOIN PECI_PROJ.PlanIncludes ON PECI_PROJ.Exercise.exerciseID = PECI_PROJ.PlanIncludes.exeID 
    WHERE	progID = INprogramID
    ORDER BY exerciseOrder ASC;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spUpdateClient
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spUpdateClient`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spUpdateClient`(IN INclientEmail NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
			CALL spRaiseError();
	ELSE
		SELECT userID INTO @cID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
		UPDATE 	PECI_PROJ.SysUser
        SET 	firstName 	= AES_ENCRYPT(INfirstName, dbKey),
				lastName	= AES_ENCRYPT(INlastName, dbKey),
				birthdate 	= INbirthdate,
				sex			= INsex,
				street		= AES_ENCRYPT(INstreet, dbKey),
				postCode	= AES_ENCRYPT(INpostCode, dbKey),
				city		= AES_ENCRYPT(INcity, dbKey),
				country		= AES_ENCRYPT(INcountry, dbKey)
        WHERE	userID=@cID; 
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spUpdateExercise
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spUpdateExercise`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spUpdateExercise`(IN INexerciseID INT, IN INname NVARCHAR(255), IN INfirebaseRef NVARCHAR(255), IN INdifficulty NVARCHAR(32), IN INdescription NVARCHAR(1024), IN INforPathology NVARCHAR(64), IN INtargetMuscle NVARCHAR(255), IN INthumbnailPath NVARCHAR(255), IN INvideoPath NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT exerciseID, eName FROM PECI_PROJ.Exercise) AS t1 WHERE t1.exerciseID = INexerciseID) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			UPDATE PECI_PROJ.Exercise
			SET eName = INname, firebaseRef = INfirebaseRef, difficulty = INdifficulty, eDescription = INdescription, forPathology = INforPathology, targetMuscle = INtargetMuscle, thumbnailPath = INthumbnailPath, videoPath = INvideoPath
			WHERE exerciseID = INexerciseID;
		COMMIT;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spUpdateFirebaseID
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spUpdateFirebaseID`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spUpdateFirebaseID`(IN INclientEmail NVARCHAR(255), IN INfirebaseID NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @cID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
		UPDATE 	PECI_PROJ.SysClient
        SET		firebaseID = AES_ENCRYPT(INfirebaseID, dbKey)
        WHERE	clientID=@cID; 
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spUpdateProgramData
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spUpdateProgramData`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spUpdateProgramData`(IN INprogramID INT, IN INname NVARCHAR(255), IN INdescription NVARCHAR(1024), IN INforPathology NVARCHAR(64), IN INthumbnailPath NVARCHAR(255), IN INvideoPath NVARCHAR(255), IN INshowcaseProg BIT(1), dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT programID, pName FROM PECI_PROJ.Program) AS t1 WHERE t1.programID = INprogramID) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			IF(INshowcaseProg = 0) THEN
				UPDATE PECI_PROJ.Program
				SET pName = INname, pDescription = INdescription, forPathology = INforPathology, thumbnailPath = INthumbnailPath, videoPath = INvideoPath
				WHERE programID = INprogramID;
			ELSE
				UPDATE PECI_PROJ.Program
				SET pName = INname, pDescription = INdescription, forPathology = INforPathology, thumbnailPath = INthumbnailPath, videoPath = INvideoPath, isShowcaseProg = INshowcaseProg
				WHERE programID = INprogramID;
			END IF;
		COMMIT;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spUpdateProgramExercise
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spUpdateProgramExercise`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spUpdateProgramExercise`(IN INprogID INT, INexeID INT, IN INexerciseOrder INT, IN INnumSets INT, IN INnumReps INT, IN INdurationTime NVARCHAR(64))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT progID, exeID FROM PECI_PROJ.PlanIncludes) AS t1 WHERE t1.progID = INprogID AND t1.exeID = INexeID) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			UPDATE PECI_PROJ.PlanIncludes
			SET exerciseOrder = INexerciseOrder, numSets = INnumSets, numReps = INnumReps, durationTime = INdurationTime
			WHERE progID = INprogID AND exeID = INexeID;
		COMMIT;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure spUserAddImage
-- -----------------------------------------------------

USE `PECI_PROJ`;
DROP procedure IF EXISTS `PECI_PROJ`.`spUserAddImage`;

DELIMITER $$
USE `PECI_PROJ`$$
CREATE DEFINER=`root`@`%` PROCEDURE `spUserAddImage`(IN INemail  NVARCHAR(255), IN INimagePath NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INemail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			UPDATE PECI_PROJ.SysUser 
				SET imagePath = INimagePath
                WHERE CONVERT(AES_DECRYPT(email, dbKey) USING UTF8MB4) = INemail;
		COMMIT;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `PECI_PROJ`.`freePublicExercises`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`freePublicExercises`;
DROP VIEW IF EXISTS `PECI_PROJ`.`freePublicExercises` ;
USE `PECI_PROJ`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `PECI_PROJ`.`freePublicExercises` AS select `PECI_PROJ`.`Exercise`.`exerciseID` AS `exerciseID`,`PECI_PROJ`.`Exercise`.`firebaseRef` AS `firebaseRef`,`PECI_PROJ`.`Exercise`.`eName` AS `eName`,`PECI_PROJ`.`Exercise`.`difficulty` AS `difficulty`,`PECI_PROJ`.`Exercise`.`eDescription` AS `eDescription`,`PECI_PROJ`.`Exercise`.`forPathology` AS `forPathology`,`PECI_PROJ`.`Exercise`.`targetMuscle` AS `targetMuscle`,`PECI_PROJ`.`Exercise`.`thumbnailPath` AS `thumbnailPath`,`PECI_PROJ`.`Exercise`.`videoPath` AS `videoPath`,`PECI_PROJ`.`Exercise`.`isPublic` AS `isPublic`,`PECI_PROJ`.`Exercise`.`createDate` AS `createDate`,`PECI_PROJ`.`Exercise`.`creatorIntsID` AS `creatorIntsID` from `PECI_PROJ`.`Exercise` where (`PECI_PROJ`.`Exercise`.`isPublic` = 1);

-- -----------------------------------------------------
-- View `PECI_PROJ`.`freePublicPrograms`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PECI_PROJ`.`freePublicPrograms`;
DROP VIEW IF EXISTS `PECI_PROJ`.`freePublicPrograms` ;
USE `PECI_PROJ`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `PECI_PROJ`.`freePublicPrograms` AS select `PECI_PROJ`.`Program`.`programID` AS `programID`,`PECI_PROJ`.`Program`.`pName` AS `pName`,`PECI_PROJ`.`Program`.`pDescription` AS `pDescription`,`PECI_PROJ`.`Program`.`forPathology` AS `forPathology`,`PECI_PROJ`.`Program`.`thumbnailPath` AS `thumbnailPath`,`PECI_PROJ`.`Program`.`videoPath` AS `videoPath`,`PECI_PROJ`.`Program`.`isPublic` AS `isPublic`,`PECI_PROJ`.`Program`.`createDate` AS `createDate`,`PECI_PROJ`.`Program`.`isShowcaseProg` AS `isShowcaseProg`,`PECI_PROJ`.`Program`.`creatorIntsID` AS `creatorIntsID` from `PECI_PROJ`.`Program` where (`PECI_PROJ`.`Program`.`isPublic` = 1);

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
