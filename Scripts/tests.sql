-- TESTES MOBILE APP --
CALL spCreateClient('client@mail.com','teste','1234', '1999-01-01', 'M', 'rua', '3000-500', 'cidade', 'pais', 'chave');
CALL spCreateClient('clientNumber2@mail.com','testeNumber2','4321', '2005-01-01', 'M', 'rua', '5000-600', 'cidade2', 'pais2', 'chave');
CALL spSelectClient('client@mail.com','chave');

CALL spAddClientInfo('client@mail.com', 180, 80, 'begginer', 20, 'pathologies', 'chave');
CALL spAddClientInfo('client@mail.com', 185, 85, 'intermediate', 20, 'pathologies', 'chave');
CALL spAddClientInfo('client@mail.com', 190, 90, 'advanced', 20, 'pathologies', 'chave');
CALL spSelectClientInfo('client@mail.com','chave');

CALL spFinalizeClientPayment('client@mail.com', 'monthly', 49.99, 'chave');
CALL spFinalizeClientPayment('client@mail.com', 'yearly ', 199.99, 'chave');
CALL spSelectClientPaymentHistory('client@mail.com', 'chave');

CALL spSelectAvailableInstructors('chave');

CALL spAssociateInstructor('client@mail.com', 'instructor@mail.com', 'chave');
CALL spAssociateInstructor('client@mail.com', 'instructorNumber2@mail.com', 'chave');
CALL spSelectClientInstructorHistory('client@mail.com', 'chave');

CALL spClientReviewInstructor('client@mail.com', 'instructor@mail.com', 3, null, 'chave');
CALL spClientReviewInstructor('client@mail.com', 'instructorNumber2@mail.com', 5, 'Very good, has the best plans!', 'chave');

CALL spAddClientRewards('client@mail.com', 1, 'chave');
CALL spSelectClientRewards('client@mail.com', 'chave');

CALL spSelectClientPrograms('client@mail.com', 'chave');

CALL spDeleteClient('client@mail.com','chave');


-- TESTES WEB APP --
CALL spCreateInstructor('instructor@mail.com','teste','1234', '1999-01-01', 'M', 'rua', '3000-500', 'cidade', 'pais', 'contactNumber', 'paypalAccount', 0, 'chave');
CALL spCreateInstructor('instructorNumber2@mail.com','teste','1234', '2005-02-23', 'M', 'rua', '3000-500', 'cidade', 'pais', 'contactNumber123', 'paypalAccount123', 123, 'chave');
CALL spSelectInstructor('instructor@mail.com','chave');

CALL spSelectInstructorClients('instructorNumber2@mail.com', 'chave');

CALL spCreateExercise('instructor@mail.com', 'exer123', 'advanced', 'Lie on the floor and do a pushup', 'Pregnant', 'chest' ,'thumbnailpath/here', 'videopath/here', 'chave');
CALL spCreateExercise('instructorNumber2@mail.com', '123xer', 'beginner', 'Do a pullup', '', 'back' ,'thumbnailpath/here', 'videopath/here', 'chave');
CALL spSelectInstructorExercises('instructor@mail.com', 'chave');

CALL spCreateProgram('instructor@mail.com', 'prog123', 'Very easy program', 'Pregnant', 'thumbnailpath/here', 'videopath/here', 0, 'chave');
CALL spCreateProgram('instructor@mail.com', 'progShowcase', 'Somewhat hard', 'AVC', 'thumbnailpath/here', 'videopath/here', 1, 'chave');
CALL spCreateProgram('instructorNumber2@mail.com', '123prog', 'idk', '', 'thumbnailpath/here', 'videopath/here', 1,'chave');
CALL spSelectInstructorPrograms('instructor@mail.com', 'chave');
CALL spSelectInstructorShowcasePrograms('instructor@mail.com', 'chave');

CALL spAddExerciseToProgram(3, 2, 1, 1, '00:00:10');
CALL spAddExerciseToProgram(2, 3, 1, 1, '00:00:30');
CALL spSelectProgramExercises(3);
CALL spAssociateProgramToClient('client@mail.com', 3, 'chave');

CALL spSelectDefaultExercises();
CALL spSelectDefaultPrograms();
