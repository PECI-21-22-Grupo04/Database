DROP DATABASE IF EXISTS PECI_PROJ;
CREATE DATABASE PECI_PROJ; 
USE PECI_PROJ;

-- Tables --
CREATE TABLE IF NOT EXISTS PECI_PROJ.SysUser(
	userID			INT				AUTO_INCREMENT,
    email			VARBINARY(255) 	NOT NULL UNIQUE,	
    firstName		VARBINARY(255) 	NOT NULL,
	lastName		VARBINARY(255) 	NOT NULL,
    birthdate		DATE			NOT NULL,
    sex				NVARCHAR(32)	NOT NULL,
    street			VARBINARY(255) 	NOT NULL,
    postCode		VARBINARY(255) 	NOT NULL,
    city			VARBINARY(255) 	NOT NULL,
    country			VARBINARY(255) 	NOT NULL,
    registerDate	DATETIME		DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(userID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.SysAdmin(
	adminID			INT,
    permissionLvl	CHAR(1),
    PRIMARY KEY (adminID),
    CHECK(permissionLvl IN ('0', '1', '2', '3')) 
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.SysInstructor(
	instructorID	INT,
    contactNumber	VARBINARY(255)	UNIQUE,
    paypalAccount	VARBINARY(255)	UNIQUE,
    maxClients		INT				NOT NULL DEFAULT 100,
    PRIMARY KEY(instructorID),
	CHECK(maxClients > 0) 
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.SysClient(
	clientID		INT,
    pathologies		NVARCHAR(1024)  NOT NULL DEFAULT "", 
    PRIMARY KEY(clientID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.Exercise(
	exerciseID		INT				AUTO_INCREMENT,
    eName			NVARCHAR(255)	NOT NULL,
    difficulty		NVARCHAR(255)	NOT NULL,
    eDescription	NVARCHAR(1024)	NOT NULL DEFAULT "",
    targetMuscle	NVARCHAR(128)	NOT NULL DEFAULT "",
    thumbnailPath	NVARCHAR(255)	NOT NULL,
    videoPath		NVARCHAR(255)	NOT NULL,
    isPublic		BIT				NOT NULL DEFAULT 0, -- 1 -> public, 0 -> not public
    PRIMARY KEY(exerciseID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.Program(
	programID		INT				AUTO_INCREMENT,
    pName			NVARCHAR(255)	NOT NULL,
    pDescription	NVARCHAR(1024)	NOT NULL DEFAULT "",
    thumbnailPath	NVARCHAR(255)	NOT NULL,
    videoPath		NVARCHAR(255)	NOT NULL,
    isPublic		BIT				NOT NULL DEFAULT 0, -- 1 -> public, 0 -> not public
    PRIMARY KEY(programID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.PhysicalData(
	physicalDataID	INT				AUTO_INCREMENT,
    height			INT,
    weight			INT,
    fitness			NVARCHAR(255),
    BMI				INT,
    PRIMARY KEY(physicalDataID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.Affiliation(
	affiliationID	INT				AUTO_INCREMENT,
    signedDate		DATETIME		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    canceledDate	DATETIME		DEFAULT NULL,
    PRIMARY KEY(affiliationID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.Reward(
	rewardID		INT				AUTO_INCREMENT,
    rewardName		NVARCHAR(1024)	NOT NULL UNIQUE,
	rDescription	NVARCHAR(1024)	NOT NULL DEFAULT "",
    thumbnailPath	NVARCHAR(255)	NOT NULL,
    PRIMARY KEY(rewardID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.ClientPayment(
	paymentID		INT				AUTO_INCREMENT,
	paidClientID	INT,
    modality		NVARCHAR(255)	NOT NULL,
	ammount			NUMERIC(10,4)	NOT NULL,
    paymentDate		DATETIME		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(paymentID, paidClientID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.InstructorRemun(
	renumID			INT				AUTO_INCREMENT,
	receivedInstID	INT,
	ammount			NUMERIC(10,4)	NOT NULL,
    remunDate		DATETIME		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(renumID, receivedInstID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.PlanIncludes(
	progID			INT,
	exeID			INT,
    numSets			INT,
    numReps			INT,
    durationTime	TIME,
    includedDate	DATETIME		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(progID, exeID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.PrivateExercise(
	instID			INT,
	exeID			INT,
    forClientID		INT,
    createdDate		DATETIME		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(instID, exeID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.PrivateProgram(
	instID			INT,
	progID			INT,
    forClientID		INT,
    createdDate		DATETIME		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    showcaseProg	BIT				NOT NULL DEFAULT 0, -- 1 -> for showcase, 0 -> not showcase
    PRIMARY KEY(instID, progID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.WorkoutLog(
	doneByClientID	INT,
	progID			INT,
    timeTaken		TIME,
    heartRate		INT,
	caloriesBurnt	INT,
    doneDate		DATETIME		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(doneByClientID, progID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.ProgressLog(
	progClientID	INT,
	physicDataID	INT,
    measureDate		DATETIME		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(progClientID, physicDataID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.AffiliationLog(
	affID			INT			AUTO_INCREMENT,
	affClientID		INT,
    affInstID		INT,
    PRIMARY KEY(affID, affClientID, affInstID)
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.ReviewLog(
	revClientID		INT,
	revIntsID		INT,
    rating			INT,
    review			NVARCHAR(255)	DEFAULT "",
    reviewDate		DATETIME		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(revClientID, revIntsID),
    CHECK (rating IN (0, 1, 2, 3, 4, 5))
);

CREATE TABLE IF NOT EXISTS PECI_PROJ.RewardLog(
	rewID			INT				AUTO_INCREMENT,
	rewClientID		INT,
    receivedDate	DATETIME		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(rewID, rewClientID)
);

-- FOREIGN KEYS --
ALTER TABLE PECI_PROJ.SysAdmin
ADD CONSTRAINT FK_sysAdmin_userID
FOREIGN KEY (adminID) REFERENCES PECI_PROJ.SysUser(userID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.SysInstructor
ADD CONSTRAINT FK_sysInstructor_userID
FOREIGN KEY (InstructorID) REFERENCES PECI_PROJ.SysUser(userID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.SysClient
ADD CONSTRAINT FK_sysClient_userID
FOREIGN KEY (clientID) REFERENCES PECI_PROJ.SysUser(userID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.ClientPayment
ADD CONSTRAINT FK_clientPayment_clientID
FOREIGN KEY (paidClientID) REFERENCES PECI_PROJ.SysClient(clientID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.InstructorRemun
ADD CONSTRAINT FK_instructorRemun_instructorID
FOREIGN KEY (receivedInstID) REFERENCES PECI_PROJ.SysInstructor(instructorID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.PlanIncludes
ADD CONSTRAINT FK_planIncludes_programID
FOREIGN KEY (progID) REFERENCES PECI_PROJ.Program(programID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.PlanIncludes
ADD CONSTRAINT FK_planIncludes_exerciseID
FOREIGN KEY (exeID) REFERENCES PECI_PROJ.Exercise(exerciseID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.PrivateExercise
ADD CONSTRAINT FK_privateExercise_instructorID
FOREIGN KEY (instID) REFERENCES PECI_PROJ.SysInstructor(instructorID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.PrivateExercise
ADD CONSTRAINT FK_privateExercise_exerciseID
FOREIGN KEY (exeID) REFERENCES PECI_PROJ.Exercise(exerciseID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.PrivateProgram
ADD CONSTRAINT FK_privateProgram_instructorID
FOREIGN KEY (instID) REFERENCES PECI_PROJ.SysInstructor(instructorID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.PrivateProgram
ADD CONSTRAINT FK_privateProgram_programID
FOREIGN KEY (progID) REFERENCES PECI_PROJ.Program(programID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.WorkoutLog
ADD CONSTRAINT FK_workoutLog_clientID
FOREIGN KEY (doneByClientID) REFERENCES PECI_PROJ.SysClient(ClientID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.WorkoutLog
ADD CONSTRAINT FK_workoutLog_programID
FOREIGN KEY (progID) REFERENCES PECI_PROJ.Program(programID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.ProgressLog
ADD CONSTRAINT FK_progressLog_clientID
FOREIGN KEY (progClientID) REFERENCES PECI_PROJ.SysClient(ClientID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.ProgressLog
ADD CONSTRAINT FK_progressLog_physicaldataID
FOREIGN KEY (physicDataID) REFERENCES PECI_PROJ.PhysicalData(physicalDataID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.AffiliationLog
ADD CONSTRAINT FK_affiliationLog_affiliationID
FOREIGN KEY (affID) REFERENCES PECI_PROJ.Affiliation(affiliationID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.AffiliationLog
ADD CONSTRAINT FK_affiliationLog_clientID
FOREIGN KEY (affClientID) REFERENCES PECI_PROJ.SysClient(ClientID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.AffiliationLog
ADD CONSTRAINT FK_affiliationLog_instructorID
FOREIGN KEY (affInstID) REFERENCES PECI_PROJ.SysInstructor(instructorID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.ReviewLog
ADD CONSTRAINT FK_reviewLog_clientID
FOREIGN KEY (revClientID) REFERENCES PECI_PROJ.SysClient(ClientID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.ReviewLog
ADD CONSTRAINT FK_reviewLog_instructorID
FOREIGN KEY (revIntsID) REFERENCES PECI_PROJ.SysInstructor(instructorID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.RewardLog
ADD CONSTRAINT FK_reviewLog_rewardID
FOREIGN KEY (rewID) REFERENCES PECI_PROJ.Reward(rewardID) ON DELETE CASCADE;

ALTER TABLE PECI_PROJ.RewardLog
ADD CONSTRAINT FK_rewardLog_clientID
FOREIGN KEY (rewClientID) REFERENCES PECI_PROJ.SysClient(ClientID) ON DELETE CASCADE;