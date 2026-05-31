use GestionNotes
go

--Q1
--1.1
CREATE OR ALTER FUNCTION fn_MoyGenEtd(@pk int)
RETURNS FLOAT
as
BEGIN 
	declare @moyen FLOAT
	select @moyen=AVG(NoteExamCours) from Notes_Examens where NumETD=@pk
	return @moyen
END
go

--Q2
--1.2
DECLARE c_myn_ETD CURSOR LOCAL FORWARD_ONLY DYNAMIC READ_ONLY
FOR select NumETD,NomETD from Etudiants

Declare @id INT,@nom varchar(25),@myn float;

OPEN c_myn_ETD
FETCH c_myn_ETD INTO @id,@nom;
WHILE @@FETCH_STATUS = 0

	BEGIN
		select @myn = dbo.fn_MoyGenEtd(@id)
		print @nom +' '+ cast(@myn as varchar)
		--select dbo.fn_MoyGenEtd(@id) as moyenne
		FETCH c_myn_ETD INTO @id,@nom
	END

CLOSE c_myn_ETD

deallocate c_myn_ETD
go
--q2

CREATE OR ALTER FUNCTION fn_MoyGenCLS(@nCours INT ,@nClass Varchar(30)) returns float as
BEGIN
	if @nClass not in (select ClasseETD from Etudiants)
		return -1
	else if @nCours not in (select NumCours from Cours)
		return -2
	declare @moyennGen float;

	select @moyennGen = AVG(N.NoteExamCours) from Notes_Examens N 
	join Etudiants E on E.NumETD= N.NumETD
	where NumCours=@nCours AND E.ClasseETD=@nClass
		
	return @moyennGen
END
go
select dbo.fn_MoyGenCLS(1,'GI3') as moyennGen
go

--q3
CREATE TABLE TabSynthMoyenClassCours
(
    ClasseETD VARCHAR(30),
    NumCours INT,
    NomCours VARCHAR(100),
    MoyenneGenerale FLOAT,
    DateCalcul DATE
);
GO

CREATE OR ALTER PROCEDURE SP_SyntheseNote as 
BEGIN
	DECLARE c_curs1 CURSOR LOCAL FORWARD_ONLY DYNAMIC
	FOR SELECT N.NumCours,E.ClasseETD from Etudiants E
	join Notes_Examens N ON N.NumETD=E.NumETD

	Declare @class VARCHAR(30),@cours INT,@nomCR VARCHAR(30),@MoyeGen float,@DateCalcul DATE;
	OPEN c_curs1
	FETCH c_curs1 INTO @cours,@class
	WHILE @@FETCH_STATUS = 0
		BEGIN
			select @nomCR= nomCours from Cours where NumCours = @cours;
			select @MoyeGen = dbo.fn_MoyGenCLS(@cours,@class);
			select @DateCalcul = GETDATE();
			insert into TabSynthMoyenClassCours values(@class,@cours,@nomCR,@MoyeGen,@DateCalcul);
			FETCH c_curs1 INTO @cours,@class
		END
	CLOSE c_curs1
	DEALLOCATE c_curs1
	
END
go
--test procedure
EXEC SP_SyntheseNote
select * from TabSynthMoyenClassCours order by MoyenneGenerale DESC
--Q4
 CREATE TABLE ArchiModifsNotes
(
    NumCours INT,
    NumEtd INT,
    OldNote FLOAT,
    NewNote FLOAT,
    DtModif DATETIME,
    NomUser VARCHAR(100)
);
GO
CREATE OR ALTER TRIGGER trg_TrModifNotes ON NOTES_Examens
AFTER UPDATE 
AS
BEGIN
	INSERT INTO ArchiModifsNotes(NumCours,NumEtd,OldNote,NewNote,DtModif,NomUser)
	select i.NumCours,i.NumETD,d.NoteExamCours,i.NoteExamCours,GETDATE(),CURRENT_USER
	from inserted i
	join deleted d on i.NumETD = d.NumETD AND i.NumCours = d.NumCours
END
--test trigger
UPDATE Notes_Examens 
SET NoteExamCours = 17.50 where NumCours = 1 AND NumETD=2
select * from ArchiModifsNotes