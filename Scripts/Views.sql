USE PECI_PROJ;

CREATE VIEW freePublicExercises AS
SELECT	*
FROM	PECI_PROJ.Exercise
WHERE	isPublic = 1;

CREATE VIEW freePublicPrograms AS
SELECT 	*
FROM	PECI_PROJ.Program
WHERE	isPublic = 1;

