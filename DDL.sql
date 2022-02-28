USE [master]
GO
ALTER DATABASE [PECI_PROJ] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
DROP DATABASE [PECI_PROJ]
GO

IF NOT EXISTS( SELECT	* 
				FROM	sys.databases 
				WHERE	name = 'PECI_PROJ')
	BEGIN
		CREATE DATABASE PECI_PROJ;
	END
GO
;

USE PECI_PROJ;
GO
;

IF NOT EXISTS (SELECT	*
                FROM    sys.schemas
                WHERE   name = N'proj')
	BEGIN
		EXEC('CREATE SCHEMA [proj]');
	END
GO
;

-- Tables --
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='proj.Users' and xtype='U')
CREATE TABLE proj.Users (
		userID			INT IDENTITY(1,1),
		mail			NVARCHAR(255) NOT NULL UNIQUE,
		firstName		NVARCHAR(255) NOT NULL,
		lastName		NVARCHAR(255) NOT NULL,
		u_age			INT,
		u_height		INT,	
		u_weight		INT,		
		u_fitness		NVARCHAR(255),
		pathologies		NVARCHAR(512), 
		PRIMARY KEY (userID),
		CHECK (u_age > 0 AND u_age < 120),			-- age in year
		CHECK (u_height > 0 AND u_height < 250),	-- height in cm
		CHECK (u_weight > 0 AND u_weight < 250)		-- weight in kg
);
GO
;