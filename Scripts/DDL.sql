DROP DATABASE IF EXISTS PECI_PROJ;
CREATE DATABASE PECI_PROJ; 
USE PECI_PROJ;

-- Tables --
CREATE TABLE IF NOT EXISTS PECI_PROJ.Clients (
	clientID		INT 		 	AUTO_INCREMENT,
	email			VARBINARY(255) 	NOT NULL UNIQUE,
	firstName		VARBINARY(255) 	NOT NULL,
	lastName		VARBINARY(255) 	NOT NULL,
	age				INT,
	height			INT,	
	weight			INT,		
	fitness			NVARCHAR(255),
	pathologies		NVARCHAR(1024)  DEFAULT "", 
	registerDate	DATETIME 		DEFAULT CURRENT_TIMESTAMP,
	affiliatedInsID INT				DEFAULT NULL,
    paymentFreq		INT 			DEFAULT NULL,
    lastPayment		DATETIME 		DEFAULT NULL,
	PRIMARY KEY (clientID),
	CHECK (age > 0 AND age < 120),			-- age in years
	CHECK (height > 0 AND height < 250),	-- height in cm
	CHECK (weight > 0 AND weight < 250),	-- weight in kg
    CHECK (paymentFreq IN (1,2))            -- 1=monthly, 2=yearly
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.Instructors (
	instructorID	INT 		 	AUTO_INCREMENT,
	email			VARBINARY(255) 	NOT NULL UNIQUE,
	firstName		VARBINARY(255) 	NOT NULL,
	lastName		VARBINARY(255) 	NOT NULL,	
	phoneNumber		VARBINARY(255),
	registerDate	DATETIME 		DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (instructorID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.Exercises (
	exerciseID		INT 		 	AUTO_INCREMENT,
	e_name			NVARCHAR(128)	NOT NULL UNIQUE,
	difficulty		NVARCHAR(32)	NOT NULL,
	e_description	NVARCHAR(255)	NOT NULL DEFAULT "",
	targetMuscle	NVARCHAR(255)	NOT NULL DEFAULT "",
	thumbnailPath	NVARCHAR(128)	NOT NULL,
	videoPath		NVARCHAR(128)	NOT NULL,
	public			BIT 			NOT NULL DEFAULT 0, -- 0 is public, 1 is private
	PRIMARY KEY (exerciseID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.Programs (
	programID		INT 		 	AUTO_INCREMENT,
	p_name			NVARCHAR(128)	NOT NULL UNIQUE,
	p_description	NVARCHAR(255)	NOT NULL DEFAULT "",
	thumbnailPath	NVARCHAR(128)	NOT NULL,
	public			BIT 			NOT NULL DEFAULT 0, -- 0 is public, 1 is private
	PRIMARY KEY (programID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.Included (
	progID			INT,
	exeID			INT,
	createDate		DATETIME 		DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (progID, exeID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.PrivateExercises (
	exeID			INT,
	insID			INT,
	clntID			INT				DEFAULT NULL,
	createDate		DATETIME 		DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (exeID, insID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.PrivatePrograms (
    progID 				INT,
    insID 				INT,
    uID 				INT			DEFAULT NULL,
    createDate 			DATETIME 	DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (progID , insID)
);

-- FOREIGN KEYS --
ALTER TABLE PECI_PROJ.Clients
ADD CONSTRAINT FK_instructor_ID
FOREIGN KEY (affiliatedInsID) REFERENCES PECI_PROJ.Instructors(instructorID) ON DELETE SET NULL;

ALTER TABLE PECI_PROJ.Included
ADD CONSTRAINT FK_included_programID
FOREIGN KEY (progID) REFERENCES PECI_PROJ.Programs(programID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.Included
ADD CONSTRAINT FK_included_exerciseID
FOREIGN KEY (exeID) REFERENCES PECI_PROJ.Exercises(exerciseID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.PrivateExercises
ADD CONSTRAINT FK_privateExercises_exerciseID
FOREIGN KEY (exeID) REFERENCES PECI_PROJ.Exercises(exerciseID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.PrivateExercises
ADD CONSTRAINT FK_privateExercises_instructorID
FOREIGN KEY (insID) REFERENCES PECI_PROJ.Instructors(instructorID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.PrivatePrograms
ADD CONSTRAINT FK_privatePrograms_programID
FOREIGN KEY (progID) REFERENCES PECI_PROJ.Programs(programID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.PrivatePrograms
ADD CONSTRAINT FK_privatePrograms_instructorID
FOREIGN KEY (insID) REFERENCES PECI_PROJ.Instructors(instructorID) ON DELETE CASCADE;
