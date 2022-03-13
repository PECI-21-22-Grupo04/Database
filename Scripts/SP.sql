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

-- SPs FOR WEB COMPONENT --


-- Testes --
CALL spCreateClient('teste@mail.com','teste','1234','chave');

CALL spSelectClient('teste@mail.com','chave');

CALL spDeleteClient('teste@mail.com','chave');

CALL spAddClientInfo('teste@mail.com', '20', '123', '123', 'fitness', 'pathologies', 'chave');

CALL spSelectClientInfo('teste@mail.com','chave');