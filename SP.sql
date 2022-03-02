USE PECI_PROJ;

-- STORED PROCEDURES --
DELIMITER $$
CREATE PROCEDURE spCreateUser (IN email NVARCHAR(255), IN fName NVARCHAR(255), IN lName NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
	INSERT INTO PECI_PROJ.Users (Users.mail, Users.firstName, Users.lastName) VALUES (AES_ENCRYPT(email, userKey), AES_ENCRYPT(fName, userKey), AES_ENCRYPT(lName, userKey));
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectUser (IN email NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
    SELECT * FROM (SELECT CONVERT(AES_DECRYPT(mail, userKey) USING utf8) AS mail , CONVERT(AES_DECRYPT(firstName, userKey) USING utf8) AS fName , CONVERT(AES_DECRYPT(lastName, userKey) USING utf8) AS lName FROM PECI_PROJ.Users) AS t1 WHERE t1.mail = email;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spDeleteUser (IN email NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
	SELECT userID INTO @uID FROM (SELECT userID, mail FROM PECI_PROJ.Users) AS t1 WHERE t1.mail = CONVERT(AES_ENCRYPT(mail, userKey) USING utf8);
    DELETE FROM PECI_PROJ.Users WHERE userID = @uID AND AES_DECRYPT(mail, userKey) = email;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spAddUserInfo (IN email NVARCHAR(255), IN age INT, IN height INT, IN weight INT, IN fitness NVARCHAR(255), IN pathologies NVARCHAR(1024), IN userKey NVARCHAR(255))
BEGIN
	SELECT userID INTO @uID FROM (SELECT userID, CONVERT(AES_DECRYPT(mail, userKey) USING utf8) AS mail FROM PECI_PROJ.Users) AS t1 WHERE t1.mail = email;
    UPDATE PECI_PROJ.Users
    SET u_age = age,
		u_height = height,
        u_weight = weight,
        u_fitness = fitness,
        pathologies = pathologies
	WHERE userID = @uID AND AES_DECRYPT(mail, userKey) = email;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE spSelectUserInfo(IN email NVARCHAR(255), IN userKey NVARCHAR(255))
BEGIN
	SELECT userID INTO @uID FROM (SELECT userID, CONVERT(AES_DECRYPT(mail, userKey) USING utf8) AS mail FROM PECI_PROJ.Users) AS t1 WHERE t1.mail = email;
    SELECT u_age, u_height, u_weight, u_fitness, pathologies FROM PECI_PROJ.Users WHERE userID = @uID;
END $$
DELIMITER ;

-- Testes --
CALL spCreateUser('teste@mail.com','teste','1234','chave');

CALL spSelectUser('teste@mail.com','chave');

CALL spDeleteUser('teste@mail.com','chave');

CALL spAddUserInfo('teste@mail.com', '20', '123', '123', 'fitness', 'pathologies', 'chave');

CALL spSelectUserInfo('teste@mail.com','chave');