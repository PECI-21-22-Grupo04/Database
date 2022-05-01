USE PECI_PROJ;
-- -- -- -- -- -- -- -- -- -- 
-- SPs FOR MOBILE COMPONENT -
-- -- -- -- -- -- -- -- -- -- 
DELIMITER $$
CREATE PROCEDURE spCreateClient (IN INclientEmail NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		INSERT INTO PECI_PROJ.SysUser (email, firstName, lastName, birthdate, sex, street, postCode, city, country) VALUES (AES_ENCRYPT(INclientEmail, dbKey), AES_ENCRYPT(INfirstName, dbKey), AES_ENCRYPT(INlastName, dbKey), INbirthdate, INsex, AES_ENCRYPT(INstreet, dbKey), AES_ENCRYPT(INpostCode, dbKey), AES_ENCRYPT(INcity, dbKey), AES_ENCRYPT(INcountry, dbKey));
		SELECT userID INTO @cID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail;
		INSERT INTO PECI_PROJ.SysClient (clientId) VALUES (@cID);
    COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectClient (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
    SELECT * 
	FROM (SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail,
					CONVERT(AES_DECRYPT(firstName, dbKey) USING utf8) AS firstName,
					CONVERT(AES_DECRYPT(lastName, dbKey) USING utf8) AS lastName,
					DATE(birthDate) AS birthDate,
					sex AS sex,
					CONVERT(AES_DECRYPT(street, dbKey) USING utf8) AS street,
					CONVERT(AES_DECRYPT(postCode, dbKey) USING utf8) AS postCode,
					CONVERT(AES_DECRYPT(city, dbKey) USING utf8) AS city,
					CONVERT(AES_DECRYPT(country, dbKey) USING utf8) AS country,
                    CAST(DATE(registerDate) AS CHAR) AS registerDate,
					pathologies AS pathologies
			FROM PECI_PROJ.SysUser INNER JOIN PECI_PROJ.SysClient ON PECI_PROJ.SysUser.userID = PECI_PROJ.SysClient.clientID) AS t1 WHERE t1.mail = INclientEmail;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spDeleteClient (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail;
			DELETE FROM PECI_PROJ.SysUser WHERE userID <> 0 AND AES_DECRYPT(email, dbKey) = INclientEmail;
		COMMIT;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spAddClientInfo (IN INclientEmail NVARCHAR(255), IN INheight INT, IN INweight INT, IN INfitness NVARCHAR(255), IN INbmi INT, IN INpathologies NVARCHAR(1024), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail;
			UPDATE PECI_PROJ.SysClient
			SET pathologies = INpathologies
			WHERE clientID = @uID;
			
			INSERT INTO PECI_PROJ.PhysicalData (height, weight, fitness, BMI) VALUES (INheight, INweight, INfitness, INbmi);
			SELECT LAST_INSERT_ID() INTO @pid;
			INSERT INTO PECI_PROJ.ProgressLog (progClientID, physicDataID) VALUES (@uid, @pid);
		COMMIT;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectClientInfo(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail;
		SELECT height, weight, BMI, fitness, pathologies, CAST(DATE(measureDate) AS CHAR)
			FROM ((PECI_PROJ.ProgressLog INNER JOIN PECI_PROJ.PhysicalData ON PECI_PROJ.ProgressLog.physicDataID = PECI_PROJ.PhysicalData.PhysicalDataID)
				INNER JOIN PECI_PROJ.SysClient ON PECI_PROJ.SysClient.ClientID = PECI_PROJ.ProgressLog.progClientID)
				ORDER BY physicDataID DESC
				LIMIT 1;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spFinalizeClientPayment(IN INclientEmail NVARCHAR(255), IN INmodality NVARCHAR(255), IN INamount NUMERIC(10,4), IN dbKey NVARCHAR(255))
BEGIN
    IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail;
		INSERT INTO PECI_PROJ.ClientPayment (paidClientID, modality, amount) VALUES (@uID, INmodality, INamount);
    END IF;
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spAssociateInstructor (IN INclientEmail NVARCHAR(255), IN INinstructorEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	
    IF ((SELECT COUNT(*) FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail) <> 1 OR (SELECT COUNT(*) FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @cID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail;
		SELECT userID INTO @iID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INinstructorEmail;

		SELECT affiliationID INTO @currentlyAssociated	
			FROM ((SELECT * FROM PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID) AS res
				INNER JOIN PECI_PROJ.SysUser ON  PECI_PROJ.SysUser.userID = res.affClientID) 
				WHERE canceledDate IS NULL AND CONVERT(AES_DECRYPT(email, dbKey) USING utf8) = INclientEmail;  
				
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spClientReviewInstructor (IN INclientEmail NVARCHAR(255), IN INinstructorEmail NVARCHAR(255), IN INrating INT, INreview NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail) <> 1 OR (SELECT COUNT(*) FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @cID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail;
		SELECT userID INTO @iID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INinstructorEmail;
		
		IF(INreview IS NULL OR INreview = "") THEN
			INSERT INTO PECI_PROJ.ReviewLog(revClientID, revInstID, rating) VALUES (@cID, @iID, INrating);
		ELSE
			INSERT INTO PECI_PROJ.ReviewLog(revClientID, revInstID, rating, review) VALUES (@cID, @iID, INrating, INreview);
		END IF;
    END IF;
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectClientPaymentHistory (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail;
		SELECT 	paymentID,
				modality,
                amount,
                CAST(DATE(paymentDate) AS CHAR) AS paymentDate
        FROM PECI_PROJ.ClientPayment WHERE paymentID <> 0 AND paidClientID = @uID;
    END IF;    
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectClientInstructorHistory (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail;	
		SELECT 	mail,
				firstName,
				lastName,
				CAST(signedDate AS CHAR),
				canceledDate,
				rating,
				review
		FROM (SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING UTF8) AS mail,
						CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8) AS firstName,
						CONVERT(AES_DECRYPT(firstName, dbKey) USING UTF8) AS lastName,
						DATE(signedDate) AS signedDate,
						DATE(canceledDate) AS canceledDate,
						affClientID,
						affInstID
				FROM PECI_PROJ.SysUser 
				INNER JOIN (SELECT *
							FROM PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID
							WHERE affClientID = @uID) AS res ON PECI_PROJ.SysUser.userID = res.affInstID) AS res2 
				LEFT JOIN PECI_PROJ.ReviewLog ON (PECI_PROJ.ReviewLog.revClientID = res2.affClientID AND PECI_PROJ.ReviewLog.revInstID = res2.affInstID)
				ORDER BY canceledDate ASC;
	END IF;
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spAddClientRewards (IN INclientEmail NVARCHAR(255), IN INrewardID INT, IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail;	
		INSERT INTO PECI_PROJ.RewardLog (rewID, rewClientID) VALUES (INrewardID, @uID);
    END IF;    
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectClientRewards (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail;	
		SELECT 	rewardName,
				rDescription,
				thumbnailPath, 
				CAST(DATE(receivedDate) AS CHAR) AS receivedDate
		FROM (PECI_PROJ.Reward INNER JOIN PECI_PROJ.RewardLog ON PECI_PROJ.Reward.rewardID = PECI_PROJ.RewardLog.rewID)
		WHERE PECI_PROJ.RewardLog.rewClientID = @uID;
	END IF;    
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectClientPrograms (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail;	
		SELECT	programID,
				pName,
                pDescription,
                forPathology,
                thumbnailPath,
                videoPath,
                creatorIntsID
        FROM PECI_PROJ.Program INNER JOIN PECI_PROJ.ClientPrograms ON PECI_PROJ.Program.ProgramID = PECI_PROJ.ClientPrograms.progID
		WHERE PECI_PROJ.ClientPrograms.forClientID = @uID;
	END IF;    
END $$
DELIMITER ;


DELIMITER $$ 
CREATE PROCEDURE spSelectAvailableInstructors(IN dbKey NVARCHAR(255))
BEGIN
	SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail,
			CONVERT(AES_DECRYPT(firstName, dbKey) USING utf8) AS firstName,
			CONVERT(AES_DECRYPT(lastName, dbKey) USING utf8) AS lastName,
			DATE(birthDate) AS birthDate,
			sex AS sex,
			CONVERT(AES_DECRYPT(country, dbKey) USING utf8) AS country,
			CAST(DATE(registerDate) AS CHAR) AS registerDate,
			maxClients,
			currentClients,
			averageRating
	FROM 	(SELECT * 
			FROM 	PECI_PROJ.SysUser INNER JOIN PECI_PROJ.SysInstructor ON PECI_PROJ.SysUser.userID = PECI_PROJ.SysInstructor.instructorID) AS res1
	LEFT JOIN (SELECT 	affInstID, COUNT(*) AS currentClients
				FROM 	PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID
				WHERE 	canceledDate IS NULL) AS res2 ON res2.affInstID = res1.userID
	LEFT JOIN (SELECT 	revInstID,
						AVG(rating) AS averageRating
				FROM	PECI_PROJ.ReviewLog
				GROUP BY revInstID) AS res3 ON res3.revInstID = res1.userID
	WHERE	(currentClients IS NULL OR currentClients <= maxClients);
END $$
DELIMITER ;

-- -- -- -- -- -- -- -- -- 
-- SPs FOR WEB COMPONENT 
-- -- -- -- -- -- -- -- -- 
DELIMITER $$
CREATE PROCEDURE spCreateInstructor (IN INinstructorEmail NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN INcontactNumber NVARCHAR(255), IN INpaypalAccount NVARCHAR(255), IN INmaxClients INT, IN dbKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		INSERT INTO PECI_PROJ.SysUser (email, firstName, lastName, birthdate, sex, street, postCode, city, country) VALUES (AES_ENCRYPT(INinstructorEmail, dbKey), AES_ENCRYPT(INfirstName, dbKey), AES_ENCRYPT(INlastName, dbKey), INbirthdate, INsex, AES_ENCRYPT(INstreet, dbKey), AES_ENCRYPT(INpostCode, dbKey), AES_ENCRYPT(INcity, dbKey), AES_ENCRYPT(INcountry, dbKey));
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INinstructorEmail;
        IF(INmaxClients = 0) THEN
			INSERT INTO PECI_PROJ.SysInstructor (instructorID, contactNumber, paypalAccount) VALUES (@iID, AES_ENCRYPT(INcontactNumber, dbKey), AES_ENCRYPT(INpaypalAccount, dbKey));
        ELSE
			INSERT INTO PECI_PROJ.SysInstructor VALUES (@iID, AES_ENCRYPT(INcontactNumber, dbKey), AES_ENCRYPT(INpaypalAccount, dbKey), INmaxClients); 
		END IF;
    COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructor (IN INinstructorEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
    SELECT * 
		FROM (SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail,
						CONVERT(AES_DECRYPT(firstName, dbKey) USING utf8) AS firstName,
						CONVERT(AES_DECRYPT(lastName, dbKey) USING utf8) AS lastName,
						birthdate AS birthDate,
						sex AS sex,
						CONVERT(AES_DECRYPT(street, dbKey) USING utf8) AS street,
						CONVERT(AES_DECRYPT(postCode, dbKey) USING utf8) AS postCode,
						CONVERT(AES_DECRYPT(city, dbKey) USING utf8) AS city,
						CONVERT(AES_DECRYPT(country, dbKey) USING utf8) AS country,
						CONVERT(AES_DECRYPT(paypalAccount, dbKey) USING utf8) AS paypalAcc,
						CONVERT(AES_DECRYPT(contactNumber, dbKey) USING utf8) AS contactNumber,
						maxClients
						FROM PECI_PROJ.SysUser JOIN PECI_PROJ.SysInstructor ON PECI_PROJ.SysUser.userID = PECI_PROJ.SysInstructor.InstructorID) AS t1 WHERE t1.mail = INinstructorEmail;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructorClients (IN INInstructorEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INInstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INInstructorEmail;
		SELECT * 
			FROM (SELECT 	CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail,
							CONVERT(AES_DECRYPT(firstName, dbKey) USING utf8) AS firstName,
							CONVERT(AES_DECRYPT(firstName, dbKey) USING utf8) AS lastName,
							birthdate,
							sex,
							DATE(signedDate) AS clientSince	
			FROM ((SELECT * FROM PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID) AS res
				INNER JOIN PECI_PROJ.SysUser ON  PECI_PROJ.SysUser.userID = res.affClientID) 
				WHERE canceledDate IS NULL AND affInstID = @iID) AS finalTbl;   
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectDefaultExercises()
BEGIN
     SELECT * FROM PECI_PROJ.freePublicExercises;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectDefaultPrograms()
BEGIN
     SELECT * FROM PECI_PROJ.freePublicPrograms;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spCreateExercise (IN INinstructorEmail NVARCHAR(255), IN INname NVARCHAR(255), IN INdifficulty NVARCHAR(32), IN INdescription NVARCHAR(1024), IN INforPathology NVARCHAR(64), IN INtargetMuscle NVARCHAR(255), IN INthumbnailPath NVARCHAR(255), IN INvideoPath NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INinstructorEmail) <> 1) THEN
		INSERT INTO PECI_PROJ.Exercise (eName, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath) VALUES (INname, INdifficulty, INdescription, INforPathology, INtargetMuscle, INthumbnailPath, INvideoPath);
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INinstructorEmail;
		INSERT INTO PECI_PROJ.Exercise (eName, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, creatorIntsID) VALUES (INname, INdifficulty, INdescription, INforPathology, INtargetMuscle, INthumbnailPath, INvideoPath, @iID);
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spCreateProgram (IN INinstructorEmail NVARCHAR(255), IN INname NVARCHAR(255), IN INdescription NVARCHAR(1024), IN INforPathology NVARCHAR(64), IN INthumbnailPath NVARCHAR(255), IN INvideoPath NVARCHAR(255), IN INshowcaseProg BIT(1), dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INinstructorEmail) <> 1) THEN
		INSERT INTO PECI_PROJ.Program (pName, pDescription, forPathology, thumbnailPath, videoPath) VALUES (INname, INdescription, INforPathology, INthumbnailPath, INvideoPath);
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INinstructorEmail;
		IF(INshowcaseProg = 0) THEN
			INSERT INTO PECI_PROJ.Program (pName, pDescription, forPathology, thumbnailPath, videoPath, creatorIntsID) VALUES (INname, INdescription, INforPathology, INthumbnailPath, INvideoPath, @iID);
		ELSE
			INSERT INTO PECI_PROJ.Program (pName, pDescription, forPathology, thumbnailPath, videoPath, isShowcaseProg, creatorIntsID) VALUES (INname, INdescription, INforPathology, INthumbnailPath, INvideoPath, INshowcaseProg, @iID);
		END IF;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructorExercises (IN INinstructorEmail NVARCHAR(255), IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INinstructorEmail;
		SELECT 	exerciseID, eName, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, createDate 
		FROM 	PECI_PROJ.Exercise
		WHERE 	creatorIntsID = @iID;
	END IF;     
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructorPrograms (IN INinstructorEmail NVARCHAR(255), IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INinstructorEmail;
		SELECT programID, pName, pDescription, forPathology, thumbnailPath, videoPath, isShowcaseProg, createDate
		FROM PECI_PROJ.Program
		WHERE creatorIntsID = @iID;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructorShowcasePrograms (IN INinstructorEmail NVARCHAR(255), IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INinstructorEmail;
		SELECT programID, pName, pDescription, forPathology, thumbnailPath, videoPath, isShowcaseProg, createDate
		FROM PECI_PROJ.Program 
		WHERE (creatorIntsID = @iID AND isShowcaseProg = 1);
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spAddExerciseToProgram (IN INprogramID INT, INexerciseID INT, IN INnumSets INT, IN INnumReps INT, IN INdurationTime NVARCHAR(64))
BEGIN
	INSERT INTO PECI_PROJ.PlanIncludes (progID, exeID, numSets, numReps, durationTime) VALUES (INprogramID, INexerciseID, INnumSets, INnumReps, INdurationTime);
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectProgramExercises (IN INprogramID INT)
BEGIN
	SELECT 	exerciseID, eName, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, createDate, numSets, numReps, durationTime 
    FROM 	PECI_PROJ.Exercise INNER JOIN PECI_PROJ.PlanIncludes ON PECI_PROJ.Exercise.exerciseID = PECI_PROJ.PlanIncludes.exeID 
    WHERE	progID = INprogramID;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spAssociateProgramToClient (IN INclientEmail NVARCHAR(255), IN INprogramID INT, IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @cID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INclientEmail;
		INSERT INTO PECI_PROJ.ClientPrograms (forClientID, progID) VALUES (@cID, INprogramID);
    END IF;    
END $$
DELIMITER ;


-- INSERIR DADOS NA BD --
INSERT INTO PECI_PROJ.Reward (rewardName, rDescription, thumbnailPath) VALUES ('Reward 1', 'Registration Completed!', 'path');
INSERT INTO PECI_PROJ.Exercise (eName, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, isPublic, creatorIntsID) VALUES ('defaultExercise1', 'Beginner', 'Do Pilates exercise 1', 'Pregnant', 'chest' ,'thumbnailpath/here', 'videopath/here', 1, null);
INSERT INTO PECI_PROJ.Exercise (eName, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, isPublic, creatorIntsID) VALUES ('defaultExercise2', 'Advanced', 'Do Yoga exercise 1', 'Back Surgery', 'legs' ,'thumbnailpath/here', 'videopath/here', 1, null);
INSERT INTO PECI_PROJ.Program (pName, pDescription, forPathology, thumbnailPath, videoPath, isPublic, creatorIntsID) VALUES ('defaultPogram1', 'Do Pilates program 1', 'Pregnant', 'thumbnailpath/here', 'videopath/here', 1, null);
INSERT INTO PECI_PROJ.Program (pName, pDescription, forPathology, thumbnailPath, videoPath, isPublic, creatorIntsID) VALUES ('defaultPogram2', 'Do Yoga program 1', '', 'thumbnailpath/here', 'videopath/here', 1, null);


-- TESTES MOBILE APP --
CALL spCreateClient('client@mail.com','teste','1234', '1999-01-01', 'M', 'rua', '3000-500', 'cidade', 'pais', 'chave');
CALL spCreateClient('clientNumber2@mail.com','testeNumber2','4321', '2005-01-01', 'M', 'rua', '5000-600', 'cidade2', 'pais2', 'chave');
CALL spSelectClient('client@mail.com','chave');

CALL spAddClientInfo('client@mail.com', 180, 80, 'begginer', 20, 'pathologies', 'chave');
CALL spAddClientInfo('client@mail.com', 185, 85, 'intermediate', 20, 'pathologies', 'chave');
CALL spAddClientInfo('client@mail.com', 190, 90, 'advanced', 20, 'pathologies', 'chave');
CALL spSelectClientInfo('client@mail.com','chave');

CALL spFinalizeClientPayment('client@mail.com', 'monthly', 49.99, 'chave');
CALL spFinalizeClientPayment('client@mail.com', 'yearly ', 199.99, 'chave');
CALL spSelectClientPaymentHistory('client@mail.com', 'chave');

CALL spSelectAvailableInstructors('chave');

CALL spAssociateInstructor('client@mail.com', 'instructor@mail.com', 'chave');
CALL spAssociateInstructor('client@mail.com', 'instructorNumber2@mail.com', 'chave');
CALL spSelectClientInstructorHistory('client@mail.com', 'chave');

CALL spClientReviewInstructor('client@mail.com', 'instructor@mail.com', 3, null, 'chave');
CALL spClientReviewInstructor('client@mail.com', 'instructorNumber2@mail.com', 5, 'Very good, has the best plans!', 'chave');

CALL spAddClientRewards('client@mail.com', 1, 'chave');
CALL spSelectClientRewards('client@mail.com', 'chave');

CALL spSelectClientPrograms('client@mail.com', 'chave');

CALL spDeleteClient('client@mail.com','chave');


-- TESTES WEB APP --
CALL spCreateInstructor('instructor@mail.com','teste','1234', '1999-01-01', 'M', 'rua', '3000-500', 'cidade', 'pais', 'contactNumber', 'paypalAccount', 0, 'chave');
CALL spCreateInstructor('instructorNumber2@mail.com','teste','1234', '2005-02-23', 'M', 'rua', '3000-500', 'cidade', 'pais', 'contactNumber123', 'paypalAccount123', 123, 'chave');
CALL spSelectInstructor('instructor@mail.com','chave');

CALL spSelectInstructorClients('instructorNumber2@mail.com', 'chave');

CALL spCreateExercise('instructor@mail.com', 'exer123', 'advanced', 'Lie on the floor and do a pushup', 'Pregnant', 'chest' ,'thumbnailpath/here', 'videopath/here', 'chave');
CALL spCreateExercise('instructorNumber2@mail.com', '123xer', 'beginner', 'Do a pullup', '', 'back' ,'thumbnailpath/here', 'videopath/here', 'chave');
CALL spSelectInstructorExercises('instructor@mail.com', 'chave');

CALL spCreateProgram('instructor@mail.com', 'prog123', 'Very easy program', 'Pregnant', 'thumbnailpath/here', 'videopath/here', 0, 'chave');
CALL spCreateProgram('instructor@mail.com', 'progShowcase', 'Somewhat hard', 'AVC', 'thumbnailpath/here', 'videopath/here', 1, 'chave');
CALL spCreateProgram('instructorNumber2@mail.com', '123prog', 'idk', '', 'thumbnailpath/here', 'videopath/here', 1,'chave');
CALL spSelectInstructorPrograms('instructor@mail.com', 'chave');
CALL spSelectInstructorShowcasePrograms('instructor@mail.com', 'chave');

CALL spAddExerciseToProgram(3, 3, 1, 1, '00:00:10');
CALL spAddExerciseToProgram(2, 3, 1, 1, '00:00:30');
CALL spSelectProgramExercises(3);
CALL spAssociateProgramToClient('client@mail.com', 3, 'chave');

CALL spSelectDefaultExercises();
CALL spSelectDefaultPrograms();
