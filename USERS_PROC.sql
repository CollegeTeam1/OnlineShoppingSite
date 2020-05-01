-- unregistered USER ------------------------------
use ms2
GO

CREATE PROC customerRegister
@username VARCHAR(20),@first_name VARCHAR(20), @last_name VARCHAR(20),@password VARCHAR(20), @email
VARCHAR(50)
AS 
INSERT INTO Users VALUES 
(@username, @password, @first_name, @last_name, @email)
INSERT INTO Customer VALUES 
(@username, 0)
GO

EXEC customerRegister 'ahmed.ashraf','ahmed','ashraf','pass123', 'ahmed@yahoo.com'

GO
CREATE PROC vendorRegister
@username VARCHAR(20),@first_name VARCHAR(20), @last_name VARCHAR(20),@password VARCHAR(20), @email
VARCHAR(50), @company_name VARCHAR(20), @bank_acc_no VARCHAR(20)
AS 
INSERT INTO Users VALUES 
(@username, @password, @first_name, @last_name, @email)
INSERT INTO Vendor(username, activated, company_name, bank_acc_no )
VALUES (@username, '0', @company_name, @bank_acc_no)

GO

EXEC vendorRegister 'eslam.mahmod','eslam' ,'mahmod','pass1234',
'hopa@gmail.com' , 'Market',  '132132513'

-- registered USER ------------------------------
GO

CREATE PROC userLogin
@username VARCHAR(20),@password VARCHAR(20),
@success BIT OUTPUT, @type INT OUTPUT
AS 

IF(EXISTS (SELECT username,password FROM Users WHERE username = @username
AND password = @password))
SET @success = '1'

ELSE
BEGIN
SET @success = '0'
SET @type= '-1'
END

IF @success='1'
BEGIN

IF(EXISTS (SELECT username FROM Customer WHERE username = @username))
SET @type = 0

ELSE IF(EXISTS (SELECT username FROM Vendor WHERE username = @username))
SET @type = 1

ELSE IF(EXISTS (SELECT username FROM Admins WHERE username = @username))
SET @type = 2

ELSE
SET @type = 3
END
GO


GO
DECLARE @success BIT
DECLARE @type INT
EXEC userLogin 'ahmed.ashraf', 'pass', @success OUTPUT , @type OUTPUT
PRINT @success
PRINT @type


GO


CREATE PROC addMobile
@username VARCHAR(20), @mobile_number VARCHAR(20)
AS 
INSERT INTO User_mobile_numbers 
VALUES (@username, @mobile_number)
GO

EXEC addMobile 'ahmed.ashraf', '01111211122'
EXEC addMobile 'ahmed.ashraf', '0124262652'

GO
CREATE PROC addAddress
@username VARCHAR(20), @address VARCHAR(100)
AS 
INSERT INTO User_Addresses 
VALUES (@username, @address)
GO

EXEC addAddress 'ahmed.ashraf','nasr city'