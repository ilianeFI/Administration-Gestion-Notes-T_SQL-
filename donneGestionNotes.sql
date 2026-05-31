use GestionNotes
go

INSERT INTO Etudiants (NomETD, PrenomETD, CinETD, ClasseETD)
VALUES
('El Amrani', 'Youssef', 'AB123456', 'GI3'),
('Bennani', 'Sara', 'CD234567', 'GI3'),
('Alaoui', 'Hamza', 'EF345678', 'GI2'),
('Fassi', 'Meryem', 'GH456789', 'GI2'),
('Raji', 'Iliane', 'IJ567890', 'GI3');

INSERT INTO Cours (NomCours, VoiHCours)
VALUES
('Base de données', 40),
('Programmation C++', 50),
('Réseaux informatiques', 35),
('Systèmes d’exploitation', 45);

INSERT INTO Notes_Examens (NumCours, NumETD, NoteExamCours)
VALUES
(1, 1, 15.50),
(1, 2, 17.00),
(1, 3, 12.75),
(2, 1, 14.00),
(2, 4, 16.25),
(3, 2, 13.50),
(3, 5, 18.00),
(4, 1, 11.00),
(4, 3, 15.25),
(4, 5, 19.00);

go 
