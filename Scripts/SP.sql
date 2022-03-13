USE PECI_PROJ;

-- SPs FOR MOBILE COMPONENT --
DELIMITER $$
CREATE PROCEDURE spCreateClient (IN Inemail NVARCHAR(255), IN fName NVARCHAR(255), IN lName NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
	INSERT INTO PECI_PROJ.Clients (email, firstName, lastName) VALUES (AES_ENCRYPT(Inemail, userKey), AES_ENCRYPT(fName, userKey), AES_ENCRYPT(lName, userKey));
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectClient (IN Inemail NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
    SELECT * FROM (SELECT CONVERT(AES_DECRYPT(email, userKey) USING utf8) AS mail , CONVERT(AES_DECRYPT(firstName, userKey) USING utf8) AS fName , CONVERT(AES_DECRYPT(lastName, userKey) USING utf8) AS lName FROM PECI_PROJ.Clients) AS t1 WHERE t1.mail = Inemail;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spDeleteClient (IN Inemail NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
	SELECT clientID INTO @uID FROM (SELECT clientID, email FROM PECI_PROJ.Clients) AS t1 WHERE CONVERT(AES_DECRYPT(t1.email, userKey) USING utf8) = Inemail;
    DELETE FROM PECI_PROJ.Clients WHERE clientID = @uID AND AES_DECRYPT(email, userKey) = Inemail;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spAddClientInfo (IN Inemail NVARCHAR(255), IN age INT, IN height INT, IN weight INT, IN fitness NVARCHAR(255), IN pathologies NVARCHAR(1024), IN userKey NVARCHAR(255))
BEGIN
	SELECT clientID INTO @uID FROM (SELECT clientID, CONVERT(AES_DECRYPT(email, userKey) USING utf8) AS mail FROM PECI_PROJ.Clients) AS t1 WHERE t1.mail = Inemail;
    UPDATE PECI_PROJ.Clients
    SET age = age,
		height = height,
        weight = weight,
        fitness = fitness,
        pathologies = pathologies
	WHERE clientID = @uID AND AES_DECRYPT(email, userKey) = Inemail;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectClientInfo(IN Inemail NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
	SELECT clientID INTO @uID FROM (SELECT clientID, CONVERT(AES_DECRYPT(email, userKey) USING utf8) AS mail FROM PECI_PROJ.Clients) AS t1 WHERE t1.mail = Inemail;
    SELECT age, height, weight, fitness, pathologies, registerDate FROM PECI_PROJ.Clients WHERE clientID = @uID;
END $$
DELIMITER ;


--
-- SPs FOR WEB COMPONENT --
--



DELIMITER $$
CREATE PROCEDURE spSelectAllClients (IN userKey NVARCHAR(255))
BEGIN
      SELECT * FROM (SELECT CONVERT(AES_DECRYPT(email, userKey) USING utf8) AS mail , CONVERT(AES_DECRYPT(firstName, userKey) USING utf8) AS fName , CONVERT(AES_DECRYPT(lastName, userKey) USING utf8) AS lName FROM PECI_PROJ.Clients)  AS t1;
    
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectAllExercises ()
BEGIN
     SELECT e_name ,difficulty , e_description , targetMuscle, thumbnailPath   FROM PECI_PROJ.Exercises as t1;
    
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectAllPrograms ()
BEGIN
     SELECT p_name  , p_description , thumbnailPath   FROM PECI_PROJ.Programs as t1;
    
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spCreateExercise (IN ename NVARCHAR(255), IN edifficulty NVARCHAR(32), IN edescription NVARCHAR(255), IN etargetMuscle NVARCHAR(255), IN ethumbnailPath NVARCHAR(255), IN evideoPath NVARCHAR(255))
BEGIN
	-- START TRANSACTION;
        INSERT INTO PECI_PROJ.Exercises (e_name, difficulty, e_description, targetMuscle, thumbnailPath, videoPath) VALUES (ename, edifficulty, edescription, etargetMuscle, ethumbnailPath, evideoPath);
	-- INSERT INTO PECI_PROJ.PrivateExercises (e_name, difficulty, e_description, targetMuscle, thumbnailPath, videoPath) VALUES (ename, edifficulty, edescription, etargetMuscle, ethumbnailPath, evideoPath);
   -- COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spCreateProgram (IN pname NVARCHAR(128), IN  pdescription NVARCHAR(255), IN pthumbnailPath NVARCHAR(128))
BEGIN
	INSERT INTO PECI_PROJ.Programs (p_name, p_description, thumbnailPath) VALUES (pname, pdescription, pthumbnailPath);
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
    SELECT * FROM  PECI_PROJ.Exercises AS t1 WHERE t1.thumbnailPath = ethumbnailPath;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectProgramFromName (IN pname NVARCHAR(255))
BEGIN
    SELECT * FROM  PECI_PROJ.Programs AS t1 WHERE t1.p_name = pname;
END $$
DELIMITER ;   
 

DELIMITER $$
CREATE PROCEDURE spAddExerToProgram (IN pname NVARCHAR(255))
START TRANSACTION;

SELECT


FROM
    
    
COMMIT;
DELIMITER


-- Testes --


CALL spCreateClient('t321312este@mail.com','te31231231ste','1234','chave');
CALL spCreateClient('te31231231ste@mail.com','te312312ste','1234','chave');
CALL spCreateClient('tes3231231te@mail.com','tes312312te','1234','chave');


CALL spSelectClient('teste@mail.com','chave');

CALL spDeleteClient('teste@mail.com','chave');

CALL spAddClientInfo('teste@mail.com', '20', '123', '123', 'fitness', 'pathologies', 'chave');

CALL spSelectClientInfo('teste@mail.com','chave');

-- webapp

CALL spCreateClient('teste@mail.com','teste','123123134','chave');
CALL spCreateExercise('teeqweqwedasdsawqste','x','teqweqweqeste' ,'teeqweqwste' ,'teseqwewqte' ,'teste');
CALL spCreateProgram('teste','x','teste');
CALL spCreateInstructor('teste','teste','123123134', '123', 'chave');
CALL spSelectAllClients('chave');
CALL spSelectAllExercises();
CALL spSelectAllPrograms();
CALL spSelectExerFromThumb("public/exercises/bfe2373c0092bd0623e692e97499ad10");
CALL spSelectProgramFromName("dsadass");