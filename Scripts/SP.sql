USE PECI_PROJ;
-- -- -- -- -- -- -- -- -- -- 
-- SPs FOR MOBILE COMPONENT -
-- -- -- -- -- -- -- -- -- -- 
DELIMITER $$
CREATE PROCEDURE spCreateClient (IN INemail NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		INSERT INTO PECI_PROJ.SysUser (email, firstName, lastName, birthdate, sex, street, postCode, city, country) VALUES (AES_ENCRYPT(INemail, userKey), AES_ENCRYPT(INfirstName, userKey), AES_ENCRYPT(INlastName, userKey), INbirthdate, INsex, AES_ENCRYPT(INstreet, userKey), AES_ENCRYPT(INpostCode, userKey), AES_ENCRYPT(INcity, userKey), AES_ENCRYPT(INcountry, userKey));
		SELECT userID INTO @cID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, userKey) USING utf8) = Inemail;
		INSERT INTO PECI_PROJ.SysClient (clientId) VALUES (@cID);
    COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectClient (IN INemail NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
    SELECT * FROM (SELECT 	CONVERT(AES_DECRYPT(email, userKey) USING utf8) AS mail,
							CONVERT(AES_DECRYPT(firstName, userKey) USING utf8) AS firstName,
                            CONVERT(AES_DECRYPT(lastName, userKey) USING utf8) AS lastName,
                            birthdate AS birthDate,
                            sex AS sex,
                            CONVERT(AES_DECRYPT(street, userKey) USING utf8) AS street,
                            CONVERT(AES_DECRYPT(postCode, userKey) USING utf8) AS postCode,
                            CONVERT(AES_DECRYPT(city, userKey) USING utf8) AS city,
                            CONVERT(AES_DECRYPT(country, userKey) USING utf8) AS country,
                            pathologies AS pathologies
                            FROM PECI_PROJ.SysUser JOIN PECI_PROJ.SysClient ON SysUser.userID = SysClient.clientID) AS t1 WHERE t1.mail = INemail;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spDeleteClient (IN INemail NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, userKey) USING utf8) = INemail;
		DELETE FROM PECI_PROJ.SysUser WHERE userID = @uID AND AES_DECRYPT(email, userKey) = INemail;
		DELETE FROM PECI_PROJ.PrivateExercise WHERE instID <> 0 AND exeID <> 0 AND forClientID = @uID;
        DELETE FROM PECI_PROJ.PrivateProgram WHERE instID <> 0 AND progID <> 0 AND forClientID = @uID;
	COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spAddClientInfo (IN Inemail NVARCHAR(255), IN INheight INT, IN INweight INT, IN INfitness NVARCHAR(255), IN INbmi INT, IN INpathologies NVARCHAR(1024), IN userKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		SELECT userID INTO @uID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, userKey) USING utf8) = INemail;
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
CREATE PROCEDURE spSelectClientInfo(IN Inemail NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
	SELECT clientID INTO @uID FROM (SELECT clientID, CONVERT(AES_DECRYPT(email, userKey) USING utf8) AS mail FROM PECI_PROJ.Clients) AS t1 WHERE t1.mail = Inemail;
    SELECT age, height, weight, fitness, pathologies, registerDate FROM PECI_PROJ.Clients WHERE clientID = @uID;
END $$
DELIMITER ;


-- -- -- -- -- -- -- -- -- 
-- SPs FOR WEB COMPONENT 
-- -- -- -- -- -- -- -- -- 
DELIMITER $$
CREATE PROCEDURE spCreateInstructor (IN INemail NVARCHAR(255), IN INfirstName NVARCHAR(255), IN INlastName NVARCHAR(255), IN INbirthdate DATE, IN INsex NVARCHAR(32), IN INstreet NVARCHAR(255), IN INpostCode NVARCHAR(255), IN INcity NVARCHAR(255), IN INcountry NVARCHAR(255), IN IncontactNumber NVARCHAR(255), IN InpaypalAccount NVARCHAR(255), IN InmaxClients INT, IN userKey NVARCHAR(255))
BEGIN
	START TRANSACTION;
		INSERT INTO PECI_PROJ.SysUser (email, firstName, lastName, birthdate, sex, street, postCode, city, country) VALUES (AES_ENCRYPT(INemail, userKey), AES_ENCRYPT(INfirstName, userKey), AES_ENCRYPT(INlastName, userKey), INbirthdate, INsex, AES_ENCRYPT(INstreet, userKey), AES_ENCRYPT(INpostCode, userKey), AES_ENCRYPT(INcity, userKey), AES_ENCRYPT(INcountry, userKey));
		SELECT userID INTO @iID FROM (SELECT userID, email FROM PECI_PROJ.SysUser) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, userKey) USING utf8) = Inemail;
        IF(InmaxClients = 0) THEN
			INSERT INTO PECI_PROJ.SysInstructor (instructorID, contactNumber, paypalAccount) VALUES (@iID, AES_ENCRYPT(IncontactNumber, userKey), AES_ENCRYPT(InpaypalAccount, userKey));
        ELSE
			INSERT INTO PECI_PROJ.SysInstructor VALUES (@iID, AES_ENCRYPT(IncontactNumber, userKey), AES_ENCRYPT(InpaypalAccount, userKey), InmaxClients); 
		END IF;
    COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectAllClients (IN userKey NVARCHAR(255))
BEGIN
      SELECT * FROM (SELECT CONVERT(AES_DECRYPT(email, userKey) USING utf8) AS mail , CONVERT(AES_DECRYPT(firstName, userKey) USING utf8) AS fName , CONVERT(AES_DECRYPT(lastName, userKey) USING utf8) AS lName FROM PECI_PROJ.Clients)  AS t1;
    
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
CREATE PROCEDURE spCreateInstructor (IN iemail VARBINARY(255), IN  ifirst VARBINARY(255) , IN ilast VARBINARY(255) , IN iphoneNumber VARBINARY(255), IN userKey  NVARCHAR(255))
BEGIN
	INSERT INTO PECI_PROJ.Instructors (email, firstName, lastName, phoneNumber) VALUES (AES_ENCRYPT(iemail, userKey), AES_ENCRYPT(ifirst, userKey), AES_ENCRYPT(ilast, userKey), AES_ENCRYPT(iphoneNumber, userKey));
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
 

-- Testes --
CALL spCreateClient('t321312este@mail.com','teste','1234', '1999-01-01', 'M', 'rua', '3000-500', 'cidade', 'pais', 'chave');
CALL spAddClientInfo('t321312este@mail.com', '123', '123', 'fitness', '321', 'pathologies', 'chave');
CALL spSelectClient('t321312este@mail.com','chave');
CALL spDeleteClient('t321312este@mail.com','chave');


CALL spCreateClient('te31231231ste@mail.com','te312312ste','1234','chave');
CALL spCreateClient('tes3231231te@mail.com','tes312312te','1234','chave');

CALL spSelectClient('teste@mail.com','chave');

CALL spDeleteClient('teste@mail.com','chave');

CALL spAddClientInfo('teste@mail.com', '20', '123', '123', 'fitness', 'pathologies', 'chave');

CALL spSelectClientInfo('teste@mail.com','chave');


-- webapp
CALL spCreateInstructor('t321312este@mail.com','teste','1234', '1999-01-01', 'M', 'rua', '3000-500', 'cidade', 'pais', 'contactNumber', 'paypalAccount', 0, 'chave');
CALL spCreateExercise('teeqweqwedasdsawqste','x','teqweqweqeste' ,'teeqweqwste' ,'teseqwewqte' ,'teste', 1 );
CALL spCreateProgram('teste','x','teste','teste');
CALL spCreateInstructor('teste','teste','123123134', '123', 'chave');
CALL spSelectAllClients('chave');
CALL spSelectAllExercises();
CALL spSelectAllPrograms();
CALL spSelectExerFromThumb("public/exercises/bfe2373c0092bd0623e692e97499ad10");
CALL spSelectProgramFromName("dsadass");

