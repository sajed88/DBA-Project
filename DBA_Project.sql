
use DBA_PRO;
-- Create Branch table
CREATE TABLE Branch (
    BranchID INT PRIMARY KEY,
    BranchName NVARCHAR(255) NOT NULL,
    Location NVARCHAR(255) NOT NULL,
    ManagerID INT
);

-- Create Staff table
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Designation NVARCHAR(255) NOT NULL,
    BranchID INT,
    HireDate DATE NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);

-- Making sure ManagerID in Branch table references StaffID in Staff table
ALTER TABLE Branch
ADD FOREIGN KEY (ManagerID) REFERENCES Staff(StaffID);

-- Create Member table
CREATE TABLE Member (
    MemberID INT PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Address NVARCHAR(255),
    PhoneNumber NVARCHAR(20),
    RegistrationDate DATE NOT NULL
);

-- Create Book table
CREATE TABLE Book (
    ISBN NVARCHAR(13) PRIMARY KEY,
    Title NVARCHAR(255) NOT NULL,
    Author NVARCHAR(255) NOT NULL,
    Genre NVARCHAR(255)
);

-- Create BookCopy table
CREATE TABLE BookCopy (
    BookNumber INT PRIMARY KEY,
    ISBN NVARCHAR(13),
    BranchID INT,
    Status NVARCHAR(50) CHECK (Status IN ('Available', 'Rented')),
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN),
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);


-- Create Rental table
CREATE TABLE Rental (
    RentalID INT PRIMARY KEY,
    MemberID INT,
    BookNumber INT,
    BranchID INT,
    BorrowDate DATE NOT NULL,
    ReturnDate DATE,
    LateFees DECIMAL(5,2),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (BookNumber) REFERENCES BookCopy(BookNumber),
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);

-- Create Feedback table
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY,
    MemberID INT,
    ISBN NVARCHAR(13),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(1000),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN)
);

-- 1)use stored Procedure sp_addlogin to create logins under general database Security 
--   (logins folder)(PC --> Security --> Logins )

EXECUTE sp_addlogin @loginame =  'sajed', @passwd = '1234'

-- 2) after logins created a user should be created under 
--    ALBayan --> Security --> Users

EXECUTE sp_adduser @loginame = 'sajed', @name_in_db = 'sajed'


-- 1)use stored Procedure sp_addlogin to create logins under general database Security 
--   (logins folder)(PC --> Security --> Logins )

EXECUTE sp_addlogin @loginame =  'basil', @passwd = '1234'

-- 2) after logins created a user should be created under 
--    DreamHome --> Security --> Users

EXECUTE sp_adduser @loginame = 'basil', @name_in_db = 'basil'


--------
EXECUTE sp_addlogin @loginame =  'salah', @passwd = '1234'
EXECUTE sp_adduser @loginame = 'salah', @name_in_db = 'salah'

EXECUTE sp_addlogin @loginame =  'mohammad', @passwd = '1234'
EXECUTE sp_adduser @loginame = 'mohammad', @name_in_db = 'mohammad'

---------------------------------------------------------------------------


-- Add a user to the AssistantLibrarian role
--ALTER ROLE AssistantLibrarian ADD MEMBER sajed;

-- Add a user to the Member role
--ALTER ROLE Member ADD MEMBER basil;

-- Add a user to the Librarian role
--ALTER ROLE Librarian ADD MEMBER sajed;


-- Add a user to the Visitor role
--ALTER ROLE Visitor ADD MEMBER basil;

-------------------------------------------------------------------------

-- Create the Visitor role
execute sp_addrole @rolename = 'Visitor'

-- Create the Member role
execute sp_addrole @rolename = 'Member'

-- Create the Librarian role
execute sp_addrole @rolename = 'Librarian'

-- Create the AssistantLibrarian role
execute sp_addrole @rolename = 'AssistantLibrarian'

---------------------------------------- Assign Roles  TO  Users      -------------------------------

execute sp_addrolemember @rolename = 'Visitor' , @membername = 'salah'

execute sp_addrolemember @rolename = 'Member' , @membername = 'mohammad'

execute sp_addrolemember @rolename = 'Librarian' , @membername = 'basil'

execute sp_addrolemember @rolename = 'AssistantLibrarian' , @membername = 'sajed'


  -------------------------------------------------  Permissions ---------------------------------------------


-- Grant permissions to AssistantLibrarian
GRANT SELECT ON Branch TO AssistantLibrarian;
GRANT SELECT ON Staff TO AssistantLibrarian;
GRANT SELECT, INSERT, UPDATE ON Member TO AssistantLibrarian;
GRANT SELECT, INSERT ON BookCopy TO AssistantLibrarian;
GRANT SELECT ON Rental TO AssistantLibrarian;
GRANT SELECT ON Feedback TO AssistantLibrarian;


-- Grant permissions to Visitor
GRANT SELECT ON Branch TO Visitor;
GRANT SELECT ON Book TO Visitor;
GRANT SELECT ON BookCopy TO Visitor;


-- Grant permissions to Member
GRANT SELECT, INSERT ON Member TO Member;
GRANT SELECT ON Book TO Member;
GRANT SELECT ON BookCopy TO Member;
GRANT SELECT, INSERT ON Rental TO Member;
GRANT SELECT, INSERT ON Feedback TO Member;



-- Grant permissions to Librarian
GRANT SELECT, INSERT, UPDATE, DELETE ON Branch TO Librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Staff TO Librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Member TO Librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Book TO Librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON BookCopy TO Librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Rental TO Librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Feedback TO Librarian;




--------------------



------------------------------------------------------------------------------------------
-------------------------               Create Tirrgers  ---------------------

--The triggers will fire whenever a DML operation (INSERT, UPDATE, or DELETE) is executed on the table,
--and the changes will be stored in a corresponding audit table.
--create audit tables for Branch and Member


CREATE TABLE Audit_Branch (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    Operation NVARCHAR(50),
    DateChanged DATETIME DEFAULT CURRENT_TIMESTAMP,
    BranchID INT,
    BranchName NVARCHAR(255),
    Location NVARCHAR(255),
    ManagerID INT
);

CREATE TABLE Audit_Member (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    Operation NVARCHAR(50),
    DateChanged DATETIME DEFAULT CURRENT_TIMESTAMP,
    MemberID INT,
    Name NVARCHAR(255),
    Address NVARCHAR(255),
    PhoneNumber NVARCHAR(20),
    RegistrationDate DATE
);

-- Create audit table for Book
CREATE TABLE Audit_Book (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    Operation NVARCHAR(50),
    DateChanged DATETIME DEFAULT CURRENT_TIMESTAMP,
    ISBN NVARCHAR(13),
    Title NVARCHAR(255),
    Author NVARCHAR(255),
    Genre NVARCHAR(255)
);

-- Create audit table for Staff
CREATE TABLE Audit_Staff (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    Operation NVARCHAR(50),
    DateChanged DATETIME DEFAULT CURRENT_TIMESTAMP,
    StaffID INT,
    Name NVARCHAR(255),
    Designation NVARCHAR(255),
    BranchID INT,
    HireDate DATE
);


GO
-- Trigger for Branch table
CREATE TRIGGER trg_Audit_Branch
ON Branch
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
        IF EXISTS (SELECT * FROM deleted)
            INSERT INTO Audit_Branch (Operation, BranchID, BranchName, Location, ManagerID)
            SELECT 'UPDATE', inserted.BranchID, inserted.BranchName, inserted.Location, inserted.ManagerID 
            FROM inserted
        ELSE
            INSERT INTO Audit_Branch (Operation, BranchID, BranchName, Location, ManagerID)
            SELECT 'INSERT', inserted.BranchID, inserted.BranchName, inserted.Location, inserted.ManagerID 
            FROM inserted
    ELSE
        INSERT INTO Audit_Branch (Operation, BranchID, BranchName, Location, ManagerID)
        SELECT 'DELETE', deleted.BranchID, deleted.BranchName, deleted.Location, deleted.ManagerID 
        FROM deleted
END;

GO
-- Trigger for Member table
CREATE TRIGGER trg_Audit_Member
ON Member
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
        IF EXISTS (SELECT * FROM deleted)
            INSERT INTO Audit_Member (Operation, MemberID, Name, Address, PhoneNumber, RegistrationDate)
            SELECT 'UPDATE', inserted.MemberID, inserted.Name, inserted.Address, inserted.PhoneNumber, inserted.RegistrationDate 
            FROM inserted
        ELSE
            INSERT INTO Audit_Member (Operation, MemberID, Name, Address, PhoneNumber, RegistrationDate)
            SELECT 'INSERT', inserted.MemberID, inserted.Name, inserted.Address, inserted.PhoneNumber, inserted.RegistrationDate 
            FROM inserted
    ELSE
        INSERT INTO Audit_Member (Operation, MemberID, Name, Address, PhoneNumber, RegistrationDate)
        SELECT 'DELETE', deleted.MemberID, deleted.Name, deleted.Address, deleted.PhoneNumber, deleted.RegistrationDate 
        FROM deleted
END;

GO

-- Trigger for Book table
CREATE TRIGGER trg_Audit_Book
ON Book
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
        IF EXISTS (SELECT * FROM deleted)
            INSERT INTO Audit_Book (Operation, ISBN, Title, Author, Genre)
            SELECT 'UPDATE', inserted.ISBN, inserted.Title, inserted.Author, inserted.Genre
            FROM inserted
        ELSE
            INSERT INTO Audit_Book (Operation, ISBN, Title, Author, Genre)
            SELECT 'INSERT', inserted.ISBN, inserted.Title, inserted.Author, inserted.Genre
            FROM inserted
    ELSE
        INSERT INTO Audit_Book (Operation, ISBN, Title, Author, Genre)
        SELECT 'DELETE', deleted.ISBN, deleted.Title, deleted.Author, deleted.Genre
        FROM deleted
END;

GO
-- Trigger for Staff table
CREATE TRIGGER trg_Audit_Staff
ON Staff
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
        IF EXISTS (SELECT * FROM deleted)
            INSERT INTO Audit_Staff (Operation, StaffID, Name, Designation, BranchID, HireDate)
            SELECT 'UPDATE', inserted.StaffID, inserted.Name, inserted.Designation, inserted.BranchID, inserted.HireDate
            FROM inserted
        ELSE
            INSERT INTO Audit_Staff (Operation, StaffID, Name, Designation, BranchID, HireDate)
            SELECT 'INSERT', inserted.StaffID, inserted.Name, inserted.Designation, inserted.BranchID, inserted.HireDate
            FROM inserted
    ELSE
        INSERT INTO Audit_Staff (Operation, StaffID, Name, Designation, BranchID, HireDate)
        SELECT 'DELETE', deleted.StaffID, deleted.Name, deleted.Designation, deleted.BranchID, deleted.HireDate
        FROM deleted
END;

-------------------------------------

GO

ALTER TABLE Member
ADD SensitiveData VARBINARY(MAX);

-- Create a master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Admin121';
GO

-- Create a certificate protected by the master key
CREATE CERTIFICATE AlbayanCert WITH SUBJECT = 'Albayan Data Encryption';
GO

-- Create a symmetric key protected by the certificate
CREATE SYMMETRIC KEY AlbayanSymmetricKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE AlbayanCert;
GO

-- Now you can use the symmetric key to encrypt/decrypt data.
-- First, you need to open the key
OPEN SYMMETRIC KEY AlbayanSymmetricKey
DECRYPTION BY CERTIFICATE AlbayanCert;
GO

-- Now you can encrypt data. For example, you can update a text in 'SensitiveData' column in 'Member' table to its encrypted form
UPDATE Member
SET SensitiveData = ENCRYPTBYKEY(KEY_GUID('AlbayanSymmetricKey'), SensitiveData);
GO

-- To read the encrypted data, you can convert it back to a readable form using the same symmetric key
SELECT CONVERT(VARCHAR, DECRYPTBYKEY(SensitiveData)) AS DecryptedData
FROM Member;
GO

-- Remember to close the key when you're done
CLOSE SYMMETRIC KEY AlbayanSymmetricKey;

----------------------------------------------------------------------------


-- Create a Database Master Key (DMK) if it doesn't exist
IF NOT EXISTS 
    (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Password123!';
GO

-- Create a certificate protected by the DMK
CREATE CERTIFICATE Albayan_Cert
WITH SUBJECT = 'Data Protection';
GO

-- Create a symmetric key protected by the certificate
CREATE SYMMETRIC KEY Albayan_Key
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE Albayan_Cert;
GO

-- Create a table for demonstration
CREATE TABLE PersonalData(
    ID INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(50),
    SensitiveData VARBINARY(2000)
);
GO

select * from PersonalData;

-- Open the symmetric key for use
OPEN SYMMETRIC KEY Albayan_Key
DECRYPTION BY CERTIFICATE Albayan_Cert;
GO

-- Insert data into the table with sensitive data encrypted
INSERT INTO PersonalData (Name, SensitiveData)
VALUES 
    ('Basil Assi', 
    ENCRYPTBYKEY(KEY_GUID('Albayan_Key'), 'Basil''s sensitive data')),
    ('Sajed Abd', 
    ENCRYPTBYKEY(KEY_GUID('Albayan_Key'), 'Sajed''s sensitive data'));

-- Close the key after use
CLOSE SYMMETRIC KEY Albayan_Key;
GO

-- Select encrypted data from the table
SELECT ID, Name, SensitiveData AS 'EncryptedData'
FROM PersonalData;
GO

-- To decrypt and view data, we need to open the symmetric key again
OPEN SYMMETRIC KEY Albayan_Key
DECRYPTION BY CERTIFICATE Albayan_Cert;
GO

-- Select decrypted data from the table
SELECT ID, Name, 
CONVERT(NVARCHAR, DECRYPTBYKEY(SensitiveData)) AS 'DecryptedData'
FROM PersonalData;
GO

-- Don't forget to close the key after use
CLOSE SYMMETRIC KEY Albayan_Key;
GO


--------------------------------------------------------------------------------
/*
-- SELECT
SELECT * FROM Branch;

-- INSERT
INSERT INTO Branch (BranchID, BranchName, Location, ManagerID) VALUES (1, 'Main Branch', '123 Main St', NULL);

-- UPDATE
UPDATE Branch SET ManagerID = 1 WHERE BranchID = 1;

-- DELETE
DELETE FROM Branch WHERE BranchID = 1;

------------------------------------------------------


-- SELECT
SELECT * FROM Staff;

-- INSERT
INSERT INTO Staff (StaffID, Name, Designation, BranchID, HireDate) VALUES (1, 'John Doe', 'Manager', 1, '2023-07-11');

-- UPDATE
UPDATE Staff SET BranchID = 2 WHERE StaffID = 1;

-- DELETE
DELETE FROM Staff WHERE StaffID = 1;

------------------------------------------------------------

-- SELECT
SELECT * FROM Member;

-- INSERT
INSERT INTO Member (MemberID, Name, Address, PhoneNumber, RegistrationDate) VALUES (1, 'Jane Doe', '123 Main St', '1234567890', '2023-07-11');

-- UPDATE
UPDATE Member SET Address = '456 Main St' WHERE MemberID = 1;

-- DELETE
DELETE FROM Member WHERE MemberID = 1;

--------------------------------------------------------

-- SELECT
SELECT * FROM Book;

-- INSERT
INSERT INTO Book (ISBN, Title, Author, Genre) VALUES ('9781234567890', 'Example Book', 'John Smith', 'Fiction');

-- UPDATE
UPDATE Book SET Genre = 'Non-fiction' WHERE ISBN = '9781234567890';

-- DELETE
DELETE FROM Book WHERE ISBN = '9781234567890';
---------------------------------------------------

-- SELECT
SELECT * FROM BookCopy;

-- INSERT
INSERT INTO BookCopy (BookNumber, ISBN, BranchID, Status) VALUES (1, '9781234567890', 1, 'Available');

-- UPDATE
UPDATE BookCopy SET Status = 'Rented' WHERE BookNumber = 1;

-- DELETE
DELETE FROM BookCopy WHERE BookNumber = 1;
---------------------------------------------------

-- SELECT
SELECT * FROM Rental;

-- INSERT
INSERT INTO Rental (RentalID, MemberID, BookNumber, BranchID, BorrowDate, ReturnDate, LateFees) VALUES (1, 1, 1, 1, '2023-07-11', NULL, 0.00);

-- UPDATE
UPDATE Rental SET ReturnDate = '2023-07-25', LateFees = 5.00 WHERE RentalID = 1;

-- DELETE
DELETE FROM Rental WHERE RentalID = 1;
----------------------------------------------

-- SELECT
SELECT * FROM Feedback;

-- INSERT
INSERT INTO Feedback (FeedbackID, MemberID, ISBN, Rating, Comment) VALUES (1, 1, '9781234567890', 4, 'Great book!');

-- UPDATE
UPDATE Feedback SET Rating = 5 WHERE FeedbackID = 1;

-- DELETE
DELETE FROM Feedback WHERE FeedbackID = 1;






*/