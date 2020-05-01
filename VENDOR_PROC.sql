use ms2

GO

CREATE PROC postProduct
@vendorUsername VARCHAR(20), @product_name VARCHAR(20) , @category VARCHAR(20), 
@product_description text , @price decimal(10,2), @color VARCHAR(20)
AS
INSERT INTO Product (vendor_username,product_name,category,product_description,price,final_price,color,available)
VALUES (@vendorUsername,@product_name,@category,@product_description,@price,@price,@color, '1')

GO
EXEC postProduct 'eslam.mahmod','pencil','stationary','HB0.7', 10, 'red'

GO

CREATE PROC vendorviewProducts
@vendorname VARCHAR(20)
AS
SELECT p.*
FROM Product p
WHERE p.vendor_username = @vendorname

GO
EXEC vendorviewProducts 'eslam.mahmod'

GO
CREATE PROC EditProduct
@vendorname VARCHAR(20), @serialnumber int, @product_name VARCHAR(20)= null ,
@category VARCHAR(20)= null, @product_description text = null , @price decimal(10,2)= null, @color VARCHAR(20)= null
AS



IF EXISTS(
    SELECT *
    FROM Product
    WHERE serial_no = @serialnumber AND vendor_username = @vendorname
) 
BEGIN
IF @product_name IS NOT NULL 
UPDATE Product 
SET product_name = @product_name
WHERE serial_no=@serialnumber

IF @category IS NOT NULL 
UPDATE Product 
SET category = @category
WHERE serial_no=@serialnumber

IF @product_description IS NOT NULL 
UPDATE Product 
SET product_description = @product_description
WHERE serial_no=@serialnumber


IF @price IS NOT NULL 
UPDATE Product 
SET price = @price
WHERE serial_no=@serialnumber


IF @color IS NOT NULL 
UPDATE Product 
SET color = @color
WHERE serial_no=@serialnumber

END

GO
EXEC EditProduct  @vendorname='eslam.mahmod',@serialnumber= 6,@color= 'blue'
--drop proc EditProduct
GO
CREATE PROC deleteProduct
@vendorname VARCHAR(20), @serialnumber int
AS
--CHECK CASCADE 
DECLARE @flag BIT
IF(EXISTS(SELECT * FROM Product WHERE vendor_username= @vendorname  AND serial_no=@serialnumber ))
 SET @flag='1'
ELSE
SET @flag='0'


if(@flag='1')
BEGIN
DELETE FROM Product
WHERE serial_no=@serialnumber
END
GO
--DROP PROC deleteProduct



EXEC deleteProduct 'eslam.mahmod',5
GO

CREATE PROC viewQuestions
@vendorname VARCHAR(20)
AS
SELECT q.*
FROM Product p INNER JOIN Customer_Quesiton_Product q 
ON p.serial_no=q.serial_no
WHERE p.vendor_username=@vendorname

GO
EXEC viewQuestions  'hadeel.adel'
GO

CREATE PROC answerQuestions
@vendorname VARCHAR(20), @serialno int, @customername VARCHAR(20), @answer text
AS
IF EXISTS(
SELECT *
FROM Product 
WHERE @vendorname = vendor_username AND @serialno = serial_no
)
BEGIN
UPDATE Customer_Quesiton_Product
SET answer = @answer
WHERE serial_no = @serialno AND customer_name = @customername 
END
GO

EXEC answerQuestions 'hadeel.adel',1 , 'ahmed.ashraf', '40'



 GO

CREATE PROC addOffer
@offeramount int, @expiry_date datetime
AS
INSERT INTO Offer (offer_amount,expiry_date) VALUES (@offeramount,@expiry_date)

GO
EXEC addOffer 50, '11/10/2019'
EXEC addOffer 50, '11/12/2019'

GO


CREATE PROC checkOfferonProduct
@serial int, @activeoffer bit OUTPUT
AS
IF (EXISTS (SELECT * FROM OffersOnProduct O WHERE O.serial_no=@serial))
BEGIN SET @activeoffer='1' END

ELSE
BEGIN SET @activeoffer = '0' END

GO

DECLARE @op BIT
EXEC checkOfferonProduct 1, @op OUTPUT
print @op 
--check cascade
GO

CREATE PROC checkandremoveExpiredoffer
@offerid int
AS
DECLARE @flag BIT
IF(exists(SELECT * FROM offer WHERE  offer_id=@offerid AND expiry_date <= CURRENT_TIMESTAMP))
BEGIN


UPDATE Product 
SET final_price = price 
WHERE serial_no  IN (
    SELECT serial_no
    FROM OffersOnProduct 
    WHERE @offerid = offer_id
)


DELETE 
FROM Offer 
WHERE offer_id=@offerid 

DELETE
FROM offersOnProduct
WHERE offer_id=@offerid

END



GO

exec checkandremoveExpiredoffer 2

GO



CREATE PROC applyOffer
@vendorname VARCHAR(20), @offerid int, @serial int
AS 
IF (EXISTS(
SELECT *
FROM Product 
WHERE @vendorname = vendor_username AND @serial = serial_no
)) AND  (EXISTS(
SELECT *
FROM Offer 
WHERE @offerid = offer_id AND expiry_date > CURRENT_TIMESTAMP
)) AND (NOT EXISTS ( SELECT *
from offersOnProduct op INNER JOIN offer o on o.offer_id = op.offer_id
where serial_no = @serial and o.expiry_date > CURRENT_TIMESTAMP))
BEGIN
--UPDATE PRICE OF THE PRODUCT
DECLARE @offer_amount INT
DECLARE @perc DECIMAL(5,2)

SELECT @offer_amount = offer_amount
FROM Offer
WHERE offer_id = @offerid

SET @perc = @offer_amount *0.01



UPDATE Product
SET final_price = final_price- (final_price * @perc)
WHERE serial_no=@serial

INSERT INTO OffersOnProduct VALUES (@offerid,@serial)
END
GO



EXEC applyOffer 'hadeel.adel',9 ,3
EXEC applyOffer 'hadeel.adel',10 ,3

EXEC applyOffer 'hadeel.adel',1, 3


