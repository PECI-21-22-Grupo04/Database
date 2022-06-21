USE PECI_PROJ;

-- CRIAR EXERCICIOS GRATIS --
INSERT INTO PECI_PROJ.Exercise (eName, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, isPublic, creatorIntsID) VALUES ('Flexão', 'Fácil', 'Deite-se de bruços no chão com as mãos ligeiramente mais afastadas do que a largura dos ombros.
Levante o corpo do chão estendendo os braços, mantendo postura reta e abdominal contraído.
Mantendo a mesma postura reta, abaixe o corpo até ao chão dobrando os braços
', 'Público Geral', 'Peito' ,'https://firebasestorage.googleapis.com/v0/b/runx-be658.appspot.com/o/freeExercises%2Fthumbnail%2Fpushup.PNG?alt=media&token=3b47452f-15a6-445d-8c71-c72fd42140ec', 'https://firebasestorage.googleapis.com/v0/b/runx-be658.appspot.com/o/freeExercises%2Fvideo%2Fpushup.mp4?alt=media&token=fd459a3b-a3fa-4831-a395-7b2b28254bc0', 1, null);

INSERT INTO PECI_PROJ.Exercise (eName, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, isPublic, creatorIntsID) VALUES ('Agachamento', 'Fácil', 'Em pé, com os pés afastados à largura dos ombros, sente-se enquanto flexiona os quadris e mantém os joelhos levemente apontados para fora.
Continue a descer até à posição inferior, certificando-se que mantém as costas direitas e o peso distribuído uniformemente por ambos os pés.
Empurre para cima a partir da posição inferior, empurrando os joelhos para fora.
', 'Público Geral', 'Pernas' ,'https://firebasestorage.googleapis.com/v0/b/runx-be658.appspot.com/o/freeExercises%2Fthumbnail%2Fsquat.PNG?alt=media&token=f7b34bca-165c-49f7-b5e7-3788a6c6a0aa', 'https://firebasestorage.googleapis.com/v0/b/runx-be658.appspot.com/o/freeExercises%2Fvideo%2Fsquat.mp4?alt=media&token=db36e08b-04a2-47a8-923e-3ff33a8ad34b', 1, null);

INSERT INTO PECI_PROJ.Exercise (eName, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, isPublic, creatorIntsID) VALUES ('Crunch', 'Fácil', 'Mantenha os pés bem firmes no chão, com os joelhos dobrados.
Coloque as mãos ao lado da cabeça com as costas no chão.
Contraindo o abdômen, levante o tronco até fazer um V com as coxas.
Retorne à posição inicial enquanto inspira.
', 'Público Geral', 'Abdominais' ,'https://firebasestorage.googleapis.com/v0/b/runx-be658.appspot.com/o/freeExercises%2Fthumbnail%2Fsitup.PNG?alt=media&token=00889256-a25c-4c3f-ac92-9a9c94af68ae', 'https://firebasestorage.googleapis.com/v0/b/runx-be658.appspot.com/o/freeExercises%2Fvideo%2Fsitup.mp4?alt=media&token=e2c60e74-04ed-406d-bf89-85bf3396b6b2', 1, null);

INSERT INTO PECI_PROJ.Exercise (eName, difficulty, eDescription, forPathology, targetMuscle, thumbnailPath, videoPath, isPublic, creatorIntsID) VALUES ('Jumping Jack', 'Fácil', 'Começando com os pés juntos e os braços ao lado do corpo, dobre levemente os joelhos.
Salte enquanto levanta as mãos até estas se juntarem em cima da cabeça, e aterre com os pés ligeiramente fora da largura dos ombros.
Salte novamente para retornar à posição inicial, trazendo os braço para baixo.
', 'Público Geral', 'Corpo Inteiro' ,'https://firebasestorage.googleapis.com/v0/b/runx-be658.appspot.com/o/freeExercises%2Fthumbnail%2FjumpingJack.PNG?alt=media&token=495169bb-e9d9-4da3-950e-8d935fff7961', 'https://firebasestorage.googleapis.com/v0/b/runx-be658.appspot.com/o/freeExercises%2Fvideo%2FjumpingJack.mp4?alt=media&token=bcb197e7-b5a2-4778-b264-4fa065515661', 1, null);

-- CRIAR PLANOS GRATIS --
INSERT INTO PECI_PROJ.Program (pName, pDescription, forPathology, thumbnailPath, videoPath, isPublic, creatorIntsID) VALUES ('Treino de Calistenia', 'Treino de calistenia com equipamento minimo', 'Público Geral', 'thumbnailpath/here', 'videopath/here', 1, null);
CALL spAddExerciseToProgram(1, 1, 1, 3, 12, '00:00:30');
CALL spAddExerciseToProgram(1, 2, 2, 3, 10, '00:00:30');
CALL spAddExerciseToProgram(1, 3, 3, 3, 30, '00:00:30');
CALL spAddExerciseToProgram(1, 4, 4, 3, 30, '00:00:30');