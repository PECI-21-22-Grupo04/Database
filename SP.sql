USE PECI_PROJ
GO
;

-- STORED PROCEDURES --
CREATE PROC CREATE_USER
		@email NVARCHAR(255),
		@fName NVARCHAR(255),
		@lName NVARCHAR(255)
AS
	INSERT INTO proj.Users (Users.mail, Users.firstName, Users.lastName)
	VALUES (@email, @fName, @lName);
GO
;

CREATE PROC SELECT_USER
		@email NVARCHAR(255)
AS
	SELECT * FROM proj.Users WHERE Users.mail = @email
GO
;

-- Testes --
EXEC CREATE_USER 'teste@mail.com','teste','1234'
GO
;

EXEC SELECT_USER 'teste@mail.com'
GO
;