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

-- Testes --
CALL spCreateUser('teste@mail.com','teste','1234','chave');

CALL spSelectUser('teste@mail.com','chave');