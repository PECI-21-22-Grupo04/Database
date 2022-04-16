USE PECI_PROJ;

CREATE UNIQUE INDEX userEmailIndex ON PECI_PROJ.SysUser (email);
CREATE INDEX isPublicExerciseIndex ON PECI_PROJ.Exercise (isPublic);
CREATE INDEX isPublicProgramIndex ON PECI_PROJ.Program (isPublic);
