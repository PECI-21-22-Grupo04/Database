USE PECI_PROJ;

CREATE VIEW freePublicExercises AS
SELECT	eName, difficulty, eDescription, targetMuscle, thumbnailPath, videoPath
FROM	 PECI_PROJ.Exercise
WHERE	isPublic = 1;

CREATE VIEW freePublicPrograms AS
SELECT 	pName, pDescription, thumbnailPath, videoPath
FROM	 PECI_PROJ.Program
WHERE	isPublic = 1;

