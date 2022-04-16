USE PECI_PROJ;
-- -- -- -- -- -- -- -- -- -- 
-- SPs FOR MOBILE COMPONENT -
-- -- -- -- -- -- -- -- -- -- 
DELIMITER $$
CREATE PROCEDURE spCreateClient (IN INemail NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		INSERT INTO PECI_PROJ.SysUser (email, firstName, lastName, birthdate, sex, street, postCode, city, country) VALUES (AES_ENCRYPT(INemail, dbKey), AES_ENCRYPT(INfirstName, dbKey), AES_ENCRYPT(INlastName, dbKey), INbirthdate, INsex, AES_ENCRYPT(INstreet, dbKey), AES_ENCRYPT(INpostCode, dbKey), AES_ENCRYPT(INcity, dbKey), AES_ENCRYPT(INcountry, dbKey));
		SELECT userID INTO @cID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INemail;
		INSERT INTO PECI_PROJ.SysClient (clientId) VALUES (@cID);
    COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectClient (IN INemail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
					pathologies AS pathologies
			FROM PECI_PROJ.SysUser INNER JOIN PECI_PROJ.SysClient ON PECI_PROJ.SysUser.userID = PECI_PROJ.SysClient.clientID) AS t1 WHERE t1.mail = INemail;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spDeleteClient (IN INemail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INemail;
		DELETE FROM PECI_PROJ.SysUser WHERE userID <> 0 AND AES_DECRYPT(email, dbKey) = INemail;
		DELETE FROM PECI_PROJ.PrivateExercise WHERE instID <> 0 AND exeID <> 0 AND forClientID = @uID;
		DELETE FROM PECI_PROJ.PrivateProgram WHERE instID <> 0 AND progID <> 0 AND forClientID = @uID;
	COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spAddClientInfo (IN INemail NVARCHAR(255), IN INheight INT, IN INweight INT, IN INfitness NVARCHAR(255), IN INbmi INT, IN INpathologies NVARCHAR(1024), IN dbKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INemail;
		UPDATE PECI_PROJ.SysClient
			SET pathologies = INpathologies
			WHERE clientID = @uID;
		INSERT INTO PECI_PROJ.PhysicalData (height, weight, fitness, BMI) VALUES (INheight, INweight, INfitness, INbmi);
		SELECT LAST_INSERT_ID() INTO @pid;
		INSERT INTO PECI_PROJ.ProgressLog (progClientID, physicDataID) VALUES (@uid, @pid);
	COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectClientInfo(IN INemail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	SELECT userID INTO @uID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INemail;
    SELECT height, weight, BMI, fitness, pathologies, measureDate 
		FROM ((PECI_PROJ.ProgressLog INNER JOIN PECI_PROJ.PhysicalData ON PECI_PROJ.ProgressLog.physicDataID = PECI_PROJ.PhysicalData.PhysicalDataID)
			INNER JOIN PECI_PROJ.SysClient ON PECI_PROJ.SysClient.ClientID = PECI_PROJ.ProgressLog.progClientID)
			ORDER BY physicDataID DESC
			LIMIT 1;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spFinalizeClientPayment(IN INemail NVARCHAR(255), IN INmodality NVARCHAR(255), IN INammount NUMERIC(10,4), IN dbKey NVARCHAR(255))
BEGIN
	SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INemail;
	INSERT INTO PECI_PROJ.ClientPayment (paidClientID, modality, ammount) VALUES (@uID, INmodality, INammount);
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spAssociateInstructor (IN INclientEmail NVARCHAR(255), IN INinstructorEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	SELECT userID INTO @cID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail;
	SELECT userID INTO @iID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INinstructorEmail;

    SELECT affiliationID INTO @currentlyAssociated	
		FROM ((SELECT * FROM PECI_PROJ.Affiliation INNER JOIN PECI_PROJ.AffiliationLog ON PECI_PROJ.Affiliation.affiliationID = PECI_PROJ.AffiliationLog.affID) AS res
			INNER JOIN PECI_PROJ.SysUser ON  PECI_PROJ.SysUser.userID = res.affClientID) 
			WHERE canceledDate IS NULL AND CONVERT(AES_DECRYPT(email, dbKey) USING utf8) = INclientEmail;  
            
	IF (@currentlyAssociated = 0 OR @currentlyAssociated IS NULL) THEN
		START TRANSACTION;
			INSERT INTO PECI_PROJ.Affiliation (signedDate) VALUES (CURRENT_TIMESTAMP);
			SELECT LAST_INSERT_ID() INTO @pid;
			INSERT INTO PECI_PROJ.AffiliationLog (affClientID, affInstID) VALUES (@cID, @iID);
		COMMIT;
	ELSE
		START TRANSACTION;
			UPDATE PECI_PROJ.Affiliation
			SET canceledDate = CURRENT_TIMESTAMP
			WHERE affiliationID = @currentlyAssociated;
            INSERT INTO PECI_PROJ.Affiliation (signedDate) VALUES (CURRENT_TIMESTAMP);
			SELECT LAST_INSERT_ID() INTO @pid;
			INSERT INTO PECI_PROJ.AffiliationLog (affClientID, affInstID) VALUES (@cID, @iID);
		COMMIT;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spClientReviewInstructor (IN INclientEmail NVARCHAR(255), IN INinstructorEmail NVARCHAR(255), IN INrating INT, INreview NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	SELECT userID INTO @cID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INclientEmail;
	SELECT userID INTO @iID FROM (SELECT userID, CONVERT(AES_DECRYPT(email, dbKey) USING utf8) AS mail FROM PECI_PROJ.SysUser) AS t1 WHERE t1.mail = INinstructorEmail;
    
    IF(INreview IS NULL OR INreview = "") THEN
		INSERT INTO PECI_PROJ.ReviewLog(revClientID, revInstID, rating) VALUES (@cID, @iID, INrating);
    ELSE
		INSERT INTO PECI_PROJ.ReviewLog(revClientID, revInstID, rating, review) VALUES (@cID, @iID, INrating, INreview);
    END IF;
    
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectClientPaymentHistory (IN INemail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INemail;
	SELECT * FROM PECI_PROJ.ClientPayment WHERE paymentID <> 0 AND paidClientID = @uID;
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectInstructorHistory (IN INemail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INemail;	
    SELECT 	mail,
			firstName,
            lastName,
            signedDate,
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
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spAddClientRewards (IN INemail NVARCHAR(255), IN INrewardID INT, IN dbKey NVARCHAR(255))
BEGIN
	SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INemail;	
    INSERT INTO PECI_PROJ.RewardLog (rewID, rewClientID) VALUES (INrewardID, @uID);
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE spSelectClientRewards (IN INemail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
	SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INemail;	
    SELECT 	rewardName,
			rDescription,
            thumbnailPath, 
            DATE(receivedDate) AS receivedDate
    FROM (PECI_PROJ.Reward INNER JOIN PECI_PROJ.RewardLog ON PECI_PROJ.Reward.rewardID = PECI_PROJ.RewardLog.rewID)
    WHERE PECI_PROJ.RewardLog.rewClientID = @uID;
END $$
DELIMITER ;


-- -- -- -- -- -- -- -- -- 
-- SPs FOR WEB COMPONENT 
-- -- -- -- -- -- -- -- -- 
DELIMITER $$
CREATE PROCEDURE spCreateInstructor (IN INemail NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN IncontactNumber NVARCHAR(255), IN InpaypalAccount NVARCHAR(255), IN InmaxClients INT, IN dbKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		INSERT INTO PECI_PROJ.SysUser (email, firstName, lastName, birthdate, sex, street, postCode, city, country) VALUES (AES_ENCRYPT(INemail, dbKey), AES_ENCRYPT(INfirstName, dbKey), AES_ENCRYPT(INlastName, dbKey), INbirthdate, INsex, AES_ENCRYPT(INstreet, dbKey), AES_ENCRYPT(INpostCode, dbKey), AES_ENCRYPT(INcity, dbKey), AES_ENCRYPT(INcountry, dbKey));
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, dbKey) USING utf8) = INemail;
        IF(InmaxClients = 0) THEN
			INSERT INTO PECI_PROJ.SysInstructor (instructorID, contactNumber, paypalAccount) VALUES (@iID, AES_ENCRYPT(IncontactNumber, dbKey), AES_ENCRYPT(InpaypalAccount, dbKey));
        ELSE
			INSERT INTO PECI_PROJ.SysInstructor VALUES (@iID, AES_ENCRYPT(IncontactNumber, dbKey), AES_ENCRYPT(InpaypalAccount, dbKey), InmaxClients); 
		END IF;
    COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructor (IN INemail NVARCHAR(255), IN dbKey NVARCHAR(255))
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
						FROM PECI_PROJ.SysUser JOIN PECI_PROJ.SysInstructor ON PECI_PROJ.SysUser.userID = PECI_PROJ.SysInstructor.InstructorID) AS t1 WHERE t1.mail = INemail;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectInstructorClients (IN INInstructorEmail NVARCHAR(255), IN dbKey NVARCHAR(255))
BEGIN
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
			WHERE canceledDate IS NULL AND affInstID=@iID) AS finalTbl;    
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectAllExercises ()
BEGIN
     SELECT eName ,difficulty , eDescription , targetMuscle, thumbnailPath   FROM PECI_PROJ.Exercise as t1;
    
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectAllPrograms ()
BEGIN
     SELECT pName  , pDescription , thumbnailPath   FROM PECI_PROJ.Program as t1;
    
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spCreateExercise (IN ename NVARCHAR(255), IN edifficulty NVARCHAR(32), IN edescription NVARCHAR(255), IN etargetMuscle NVARCHAR(255), IN ethumbnailPath NVARCHAR(255), IN evideoPath NVARCHAR(255), IN ispublic BIT(1))
BEGIN
	-- START TRANSACTION;
       INSERT INTO PECI_PROJ.Exercise (eName, difficulty, eDescription, targetMuscle, thumbnailPath, videoPath, isPublic) VALUES (ename, edifficulty, edescription, etargetMuscle, ethumbnailPath, evideoPath, ispublic);
	-- INSERT INTO PECI_PROJ.PrivateExercises (e_name, difficulty, e_description, targetMuscle, thumbnailPath, videoPath) VALUES (ename, edifficulty, edescription, etargetMuscle, ethumbnailPath, evideoPath);
   -- COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spCreateProgram (IN pname NVARCHAR(255), IN  pdescription NVARCHAR(1024), IN pthumbnailPath NVARCHAR(255),IN pvideoPath NVARCHAR(255))
BEGIN
	INSERT INTO PECI_PROJ.Program (pName, pDescription, thumbnailPath, videoPath) VALUES (pname, pdescription, pthumbnailPath, pvideoPath);
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE spSelectExerFromThumb (IN ethumbnailPath NVARCHAR(255))
BEGIN
    SELECT * FROM  PECI_PROJ.Exercise AS t1 WHERE t1.thumbnailPath = ethumbnailPath;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectProgramFromName (IN pname NVARCHAR(255))
BEGIN
    SELECT * FROM  PECI_PROJ.Program AS t1 WHERE t1.pName = pname;
END $$
DELIMITER ;   
 

-- TESTES MOBILE APP --
INSERT INTO Reward (rewardName, rDescription, thumbnailPath) VALUES ('Reward 1', 'Registration Completed!', 'path');

CALL spCreateClient('client@mail.com','teste','1234', '1999-01-01', 'M', 'rua', '3000-500', 'cidade', 'pais', 'chave');
CALL spSelectClient('client@mail.com','chave');

CALL spAddClientInfo('client@mail.com', 180, 80, 'begginer', 20, 'pathologies', 'chave');
CALL spAddClientInfo('client@mail.com', 185, 85, 'intermediate', 20, 'pathologies', 'chave');
CALL spAddClientInfo('client@mail.com', 190, 90, 'advanced', 20, 'pathologies', 'chave');
CALL spSelectClientInfo('client@mail.com','chave');

CALL spFinalizeClientPayment('client@mail.com', 'monthly', 49.99, 'chave');
CALL spFinalizeClientPayment('client@mail.com', 'yearly ', 199.99, 'chave');
CALL spSelectClientPaymentHistory('client@mail.com', 'chave');

CALL spAssociateInstructor('client@mail.com', 'instructor@mail.com', 'chave');
CALL spAssociateInstructor('client@mail.com', 'instructorNumber2@mail.com', 'chave');
CALL spSelectInstructorHistory('client@mail.com', 'chave');

CALL spClientReviewInstructor('client@mail.com', 'instructor@mail.com', 5, null, 'chave');
CALL spClientReviewInstructor('client@mail.com', 'instructorNumber2@mail.com', 5, 'Very good, has the best plans!', 'chave');

CALL spAddClientRewards('client@mail.com', 1, 'chave');
CALL spSelectClientRewards('client@mail.com', 'chave');

CALL spDeleteClient('client@mail.com','chave');


-- TESTES WEB APP --
CALL spCreateInstructor('instructor@mail.com','teste','1234', '1999-01-01', 'M', 'rua', '3000-500', 'cidade', 'pais', 'contactNumber', 'paypalAccount', 0, 'chave');
CALL spCreateInstructor('instructorNumber2@mail.com','teste','1234', '2005-02-23', 'M', 'rua', '3000-500', 'cidade', 'pais', 'contactNumber123', 'paypalAccount123', 123, 'chave');
CALL spSelectInstructor('instructor@mail.com','chave');
CALL spSelectInstructorClients('instructor@mail.com', 'chave');
CALL spCreateExercise('teeqweqwedasdsawqste','x','teqweqweqeste' ,'teeqweqwste' ,'teseqwewqte' ,'teste', 1 );
CALL spCreateProgram('teste','x','teste','teste');
CALL spCreateInstructor('teste','teste','123123134', '123', 'chave');
CALL spSelectAllClients('chave');
CALL spSelectAllExercises();
CALL spSelectAllPrograms();
CALL spSelectExerFromThumb("public/exercises/bfe2373c0092bd0623e692e97499ad10");
CALL spSelectProgramFromName("dsadass");