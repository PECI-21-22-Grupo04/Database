USE PECI_PROJ;

CREATE VIEW freePublicExercises AS
SELECT	exerciseID, eName, forPathology, difficulty, eDescription, targetMuscle, thumbnailPath, videoPath, isPublic
FROM	PECI_PROJ.Exercise
WHERE	isPublic = 1;

CREATE VIEW freePublicPrograms AS
SELECT 	programID, pName, forPathology, pDescription, thumbnailPath, videoPath, isPublic
FROM	PECI_PROJ.Program
WHERE	isPublic = 1;

