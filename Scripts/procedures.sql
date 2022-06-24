USE PECI_PROJ;

-- -- -- -- -- -- -- -- -- -- 
-- SPs FOR MOBILE COMPONENT -
-- -- -- -- -- -- -- -- -- -- 
DELIMITER $$
CREATE PROCEDURE spCreateClient (IN INclientEmail NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		INSERT INTO PECI_PROJ.SysUser (email, firstName, lastName, birthdate, sex, street, postCode, city, country) VALUES (AES_ENCRYPT(INclientEmail, dbKey), AES_ENCRYPT(INfirstName, dbKey), AES_ENCRYPT(INlastName, dbKey), INbirthdate, INsex, AES_ENCRYPT(INstreet, dbKey), AES_ENCRYPT(INpostCode, dbKey), AES_ENCRYPT(INcity, dbKey), AES_ENCRYPT(INcountry, dbKey));
		SELECT userID INTO @cID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
		INSERT INTO PECI_PROJ.SysClient (clientId) VALUES (@cID);
    COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spUpdateClient (IN INclientEmail NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spUpdateFirebaseID (IN INclientEmail NVARCHAR(255), IN INfirebaseID NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @cID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
		UPDATE 	PECI_PROJ.SysClient
        SET		firebaseID = AES_ENCRYPT(INfirebaseID, dbKey)
        WHERE	clientID=@cID; 
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectClient (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spDeleteClient (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
			DELETE FROM PECI_PROJ.SysUser WHERE userID <> 0 AND AES_DECRYPT(email, dbKey) = INclientEmail;
		COMMIT;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spAddClientInfo (IN INclientEmail NVARCHAR(255), IN INheight INT, IN INweight INT, IN INfitness NVARCHAR(255), IN INbmi INT, IN INpathologies NVARCHAR(1024), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectClientInfo(IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spFinalizeClientPayment(IN INclientEmail NVARCHAR(255), IN INmodality NVARCHAR(255), IN INamount NUMERIC(10,4), IN INtransID NVARCHAR(64), IN INdate DATE, IN dbKey NVARCHAR(255))
BEGIN
    IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
		INSERT INTO PECI_PROJ.ClientPayment (paidClientID, modality, amount, paypalTransID, paymentDate) VALUES (@uID, INmodality, INamount, INtransID, INdate);
    END IF;
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spAssociateInstructor (IN INclientEmail NVARCHAR(255), IN INinstructorEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spClientReviewInstructor (IN INclientEmail NVARCHAR(255), IN INinstructorEmail NVARCHAR(255), IN INrating INT, INreview NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectClientPaymentHistory (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectLatestClientPayment (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectClientInstructorHistory (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spIsClientAssociated (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectAssociatedInstructor (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spAddClientRewards (IN INclientEmail NVARCHAR(255), IN INrewardID INT, IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;	
		INSERT INTO PECI_PROJ.RewardLog (rewID, rewClientID) VALUES (INrewardID, @uID);
    END IF;    
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectClientRewards (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectClientPrograms (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectAvailableInstructors(IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectAllProgramExercises()
BEGIN
	SELECT 	progID AS programID, exerciseID, eName, firebaseRef, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, DATE(includedDate) AS includedDate, numSets, exerciseOrder, numReps, durationTime, creatorIntsID AS creatorID 
    FROM 	PECI_PROJ.Exercise INNER JOIN PECI_PROJ.PlanIncludes ON PECI_PROJ.Exercise.exerciseID = PECI_PROJ.PlanIncludes.exeID 
    ORDER BY progID ASC;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spFinishWorkout(IN INclientEmail NVARCHAR(255), IN INprogramID INT, INtimeTaken TIME, IN INheartRate INT, INcaloriesBurnt INT, IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;	
		INSERT INTO PECI_PROJ.WorkoutLog (doneByClientID, progID, timeTaken, heartRate, caloriesBurnt) VALUES (@uID, INprogramID, INtimeTaken, INheartRate, INcaloriesBurnt);
	END IF;
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spRemoveInstructorAssociation (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectClientWorkoutHistory (IN INclientEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;


-- -- -- -- -- -- -- -- --- 
-- SPs FOR WEB COMPONENT --
-- -- -- -- -- -- -- -- --- 
DELIMITER $$
CREATE PROCEDURE spCreateInstructor (IN INinstructorEmail NVARCHAR(255), IN INfirebaseID NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN INcontactNumber NVARCHAR(255), IN INpaypalAccount NVARCHAR(255), IN INmaxClients INT, IN INaboutMe NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructor (IN INinstructorEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructorClients (IN INInstructorEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructorClientsFromID (IN INInstructorEmail NVARCHAR(255), IN INclientID INT, IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spCreateExercise (IN INinstructorEmail NVARCHAR(255), IN INname NVARCHAR(255), IN INfirebaseRef NVARCHAR(255), IN INdifficulty NVARCHAR(32), IN INdescription NVARCHAR(1024), IN INforPathology NVARCHAR(64), IN INtargetMuscle NVARCHAR(255), IN INthumbnailPath NVARCHAR(255), IN INvideoPath NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		INSERT INTO PECI_PROJ.Exercise (eName, firebaseRef, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath) VALUES (INname, INfirebaseRef, INdifficulty, INdescription, INforPathology, INtargetMuscle, INthumbnailPath, INvideoPath);
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		INSERT INTO PECI_PROJ.Exercise (eName, firebaseRef, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, creatorIntsID) VALUES (INname, INfirebaseRef, INdifficulty, INdescription, INforPathology, INtargetMuscle, INthumbnailPath, INvideoPath, @iID);
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spCreateProgram (IN INinstructorEmail NVARCHAR(255), IN INname NVARCHAR(255), IN INdescription NVARCHAR(1024), IN INforPathology NVARCHAR(64), IN INthumbnailPath NVARCHAR(255), IN INvideoPath NVARCHAR(255), IN INshowcaseProg BIT(1), dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructorExercises (IN INinstructorEmail NVARCHAR(255), IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		SELECT 	exerciseID, eName, firebaseRef, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, createDate 
		FROM 	PECI_PROJ.Exercise
		WHERE 	creatorIntsID = @iID;
	END IF;     
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructorExerciseFromID (IN INinstructorEmail NVARCHAR(255),IN INeid INT ,IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		SELECT 	exerciseID, firebaseRef, eName,difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, createDate 
		FROM 	PECI_PROJ.Exercise
		WHERE 	creatorIntsID = @iID AND exerciseID = INeid;
	END IF;     
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructorPrograms (IN INinstructorEmail NVARCHAR(255), IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		SELECT programID, pName, pDescription, forPathology, thumbnailPath, videoPath, isShowcaseProg, createDate
		FROM PECI_PROJ.Program
		WHERE creatorIntsID = @iID;
	END IF;
END $$
DELIMITER ;
DELIMITER $$
CREATE PROCEDURE spSelectInstructorProgramFromID (IN INinstructorEmail NVARCHAR(255), IN pid INT,IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		SELECT programID, pName, pDescription, forPathology, thumbnailPath, videoPath, isShowcaseProg, createDate
		FROM PECI_PROJ.Program
		WHERE creatorIntsID = @iID AND programID = pid;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spAddExerciseToProgram (IN INprogramID INT, INexerciseID INT, IN INexerciseOrder INT, IN INnumSets INT, IN INnumReps INT, IN INdurationTime NVARCHAR(64))
BEGIN
	INSERT INTO PECI_PROJ.PlanIncludes (progID, exeID, exerciseOrder, numSets, numReps, durationTime) VALUES (INprogramID, INexerciseID, INexerciseOrder, INnumSets, INnumReps, INdurationTime);
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectProgramExercises (IN INprogramID INT)
BEGIN
	SELECT 	progID AS programID, exerciseID, eName, firebaseRef, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, DATE(includedDate) AS includedDate, numSets, exerciseOrder, numReps, durationTime, creatorIntsID AS creatorID 
    FROM 	PECI_PROJ.Exercise INNER JOIN PECI_PROJ.PlanIncludes ON PECI_PROJ.Exercise.exerciseID = PECI_PROJ.PlanIncludes.exeID 
    WHERE	progID = INprogramID
    ORDER BY exerciseOrder ASC;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spAssociateProgramToClient (IN INclientEmail NVARCHAR(255), IN INprogramID INT, IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @cID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INclientEmail;
		INSERT INTO PECI_PROJ.ClientPrograms (forClientID, progID) VALUES (@cID, INprogramID);
    END IF;    
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spDeleteExercise (IN INexerciseID INT, IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT exerciseID, eName FROM PECI_PROJ.Exercise) AS t1 WHERE t1.exerciseID = INexerciseID) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			DELETE FROM PECI_PROJ.Exercise WHERE exerciseID <> 0 AND exerciseID = INexerciseID;
		COMMIT;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spDeleteProgram (IN INprogramID INT, IN dbKey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT programID, pName FROM PECI_PROJ.Program) AS t1 WHERE t1.programID = INprogramID) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			DELETE FROM PECI_PROJ.Program WHERE programID <> 0 AND programID = INprogramID;
		COMMIT;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spUpdateExercise (IN INexerciseID INT, IN INname NVARCHAR(255), IN INfirebaseRef NVARCHAR(255), IN INdifficulty NVARCHAR(32), IN INdescription NVARCHAR(1024), IN INforPathology NVARCHAR(64), IN INtargetMuscle NVARCHAR(255), IN INthumbnailPath NVARCHAR(255), IN INvideoPath NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spUpdateProgramData (IN INprogramID INT, IN INname NVARCHAR(255), IN INdescription NVARCHAR(1024), IN INforPathology NVARCHAR(64), IN INthumbnailPath NVARCHAR(255), IN INvideoPath NVARCHAR(255), IN INshowcaseProg BIT(1), dbKey NVARCHAR(255))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spUpdateProgramExercise (IN INprogID INT, INexeID INT, IN INexerciseOrder INT, IN INnumSets INT, IN INnumReps INT, IN INdurationTime NVARCHAR(64))
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spRemoveExerciseFromPlan (IN INprogID INT, INexeID INT)
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT progID, exeID FROM PECI_PROJ.PlanIncludes) AS t1 WHERE t1.progID = INprogID AND t1.exeID = INexeID) <> 1) THEN
		CALL spRaiseError();
    ELSE
		START TRANSACTION;
			DELETE FROM PECI_PROJ.PlanIncludes WHERE progID <> 0 AND progID = INprogID AND exeID = INexeID;
		COMMIT;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spRemovePlanFromClient (IN INprogID INT, IN INclientID INT)
BEGIN
	DELETE FROM	PECI_PROJ.ClientPrograms WHERE forClientID = INclientID AND progID = INprogID;
END $$
DELIMITER ;


-- -- -- -- -- --
-- SHARED SPs ---
-- -- -- -- -- --
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
CREATE PROCEDURE spSelectInstructorShowcasePrograms (IN INinstructorEmail NVARCHAR(255), IN dbkey NVARCHAR(255))
BEGIN
	IF ((SELECT COUNT(*) FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail) <> 1) THEN
		CALL spRaiseError();
    ELSE
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING UTF8MB4) = INinstructorEmail;
		SELECT programID, pName, pDescription, forPathology, thumbnailPath, videoPath, isShowcaseProg, createDate
		FROM PECI_PROJ.Program 
		WHERE (creatorIntsID = @iID AND isShowcaseProg = 1);
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spUserAddImage (IN INemail  NVARCHAR(255), IN INimagePath NVARCHAR(255), IN dbKey NVARCHAR(255))
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
END $$
DELIMITER ;