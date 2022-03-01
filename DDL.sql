DROP DATABASE IF EXISTS `PECI_PROJ`;
CREATE DATABASE `PECI_PROJ`; 
USE `PECI_PROJ`;

-- Tables --
CREATE TABLE IF NOT EXISTS PECI_PROJ.Users (
		userID			INT NOT NULL auto_increment,
		mail			VARBINARY(255) NOT NULL UNIQUE,
		firstName		VARBINARY(255) NOT NULL,
		lastName		VARBINARY(255) NOT NULL,
		u_age			INT,
		u_height		INT,	
		u_weight		INT,		
		u_fitness		NVARCHAR(255),
		pathologies		NVARCHAR(1024)  DEFAULT "", 
		PRIMARY KEY (userID),
		CHECK (u_age > 0 AND u_age < 120),			-- age in year
		CHECK (u_height > 0 AND u_height < 250),	-- height in cm
		CHECK (u_weight > 0 AND u_weight < 250)		-- weight in kg
);