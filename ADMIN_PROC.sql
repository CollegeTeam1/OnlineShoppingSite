use ms2

GO

CREATE PROC activateVendors
@admin_username VARCHAR(20),@vendor_username VARCHAR(20)
AS
UPDATE Vendor 
SET activated='1' , admin_username=@admin_username
WHERE  username=@vendor_username

GO
---BEFOR KAN FI ESLAM W HADEEL 
EXEC activateVendors 'hana.aly' , 'eslam.mahmod'

---check(should I just update the user?)
GO
CREATE PROC inviteDeliveryPerson
@delivery_username VARCHAR(20), @delivery_email VARCHAR(50)
AS
INSERT INTO Users (username,email) VALUES (@delivery_username,@delivery_email)
INSERT INTO Delivery_Person (username) VALUES (@delivery_username)

GO
----AFTER :mohamed tamer kan fi values mesh null w activated kanet 1
EXEC inviteDeliveryPerson 'mohamed.tamer1' , 'moha@gmail.com'

GO
CREATE PROC reviewOrders
AS
SELECT *
FROM Orders

GO
EXEC reviewOrders

GO
CREATE PROC updateOrderStatusInProcess
@order_no int
AS
update Orders
set order_status='in process'
where order_no=@order_no

EXEC updateOrderStatusInProcess 1

GO
CREATE PROC addDelivery
@delivery_type VARCHAR(20),@time_duration int,@fees decimal(5,3),@admin_username VARCHAR(20)

AS
insert into Delivery (type,time_duration,fees,username)VALUES(@delivery_type,@time_duration,@fees,@admin_username)

EXEC addDelivery 'pick-up' , 7 , 10 , 'hana.aly'

GO
CREATE PROC assignOrdertoDelivery
@delivery_username VARCHAR(20),@order_no int,@admin_username VARCHAR(20)
AS
INSERT INTO	Admin_Delivery_Order(delivery_username,order_no,admin_username)
VALUES(@delivery_username,@order_no,@admin_username)

EXEC assignOrdertoDelivery 'mohamed.tamer',1,'hana.aly'

GO
CREATE PROC createTodaysDeal
@deal_amount int,@admin_username VARCHAR(20),@expiry_date datetime
AS
INSERT INTO Todays_Deals(deal_amount,admin_username,expiry_date)
VALUES(@deal_amount,@admin_username,@expiry_date)

EXEC createTodaysDeal 30,'hana.aly', '2019/11/30'

GO
CREATE PROC checkTodaysDealOnProduct
@serial_no INT,
@activeDeal BIT OUTPUT
AS
IF(EXISTS (SELECT deal_id FROM Todays_Deals_Product WHERE  serial_no =@serial_no))
SET @activeDeal='1'
ELSE 
SET @activeDeal='0'


----NO OUTPUT MESH 3ARFA ATALA3O EZAY BE2OLY COMMAND COMLETED SUCCESSFULLY BAS
DECLARE @activeDeal BIT
EXEC checkTodaysDealOnProduct 1 , @activeDeal OUTPUT

GO
---should we add the date? , yes sara - nahla
CREATE PROC addTodaysDealOnProduct
@deal_id int, @serial_no int
AS



INSERT INTO Todays_Deals_Product(deal_id,serial_no)
VALUES(@deal_id,@serial_no)


DECLARE @deal_amount INT
DECLARE @perc DECIMAL(5,2)

SELECT @deal_amount = deal_amount
FROM Todays_Deals
WHERE deal_id = @deal_id

SET @perc =  @deal_amount *0.01

UPDATE Product
SET  final_price = final_price-(final_price * @perc)
WHERE serial_no=@serial_no



GO
drop proc addTodaysDealOnProduct

----ERROR FOREIGN KEY i set all update to NO ACTION
EXEC addTodaysDealOnProduct 4 , 1

SELECT * 
from Todays_Deals_Product

GO
CREATE PROC removeExpiredDeal
@deal_iD int
AS

DECLARE @flag BIT
IF(exists(SELECT * FROM Todays_Deals WHERE  deal_id=@deal_iD AND expiry_date <= CURRENT_TIMESTAMP))
SET @flag='1';
ELSE
SET @flag='0'

IF @flag = '1'
BEGIN
DECLARE @amount INT 
SELECT @amount = deal_amount
FROM Todays_Deals
WHERE  deal_id = @deal_iD 

DECLARE  @serial INT
SELECT @serial = serial_no 
FROM  Todays_Deals_Product
WHERE deal_id = @deal_iD 

UPDATE Product
SET final_price = price 
WHERE serial_no = @serial

DELETE FROM Todays_Deals
WHERE deal_id=@deal_iD 


DELETE FROM Todays_Deals_Product
WHERE deal_id=@deal_iD 

END

EXEC removeExpiredDeal 2

GO


CREATE PROC checkandremoveExpiredoffer
@offerid int
AS
DECLARE @flag BIT
IF(exists(SELECT * FROM offer WHERE  offer_id=@offerid AND expiry_date <= CURRENT_TIMESTAMP))
SET @flag='1'
else
SET @flag='0'

IF @flag = '1'
BEGIN

DECLARE @amount INT 
SELECT @amount = offer_amount
FROM Offer
WHERE  offer_id = @offerid 

DECLARE  @serial INT
SELECT @serial = serial_no 
FROM  OffersOnProduct
WHERE offer_id = @offerid 

UPDATE Product
SET final_price = price
WHERE serial_no = @serial


DELETE FROM Offer
WHERE offer_id = @offerid 

DELETE FROM OffersOnProduct
WHERE offer_id = @offerid 


END


GO

CREATE PROC createGiftCard
@code VARCHAR(10),@expiry_date date,@amount int,@admin_username VARCHAR(20)
AS
INSERT INTO  Giftcard(code,expiry_date,deal_amount,admin_username)
VALUES(@code,@expiry_date,@amount,@admin_username)

GO

/* delete from giftcard
where code = 'G101' */
EXEC createGiftCard 'G101' ,'2019-12-30',100,'hana.aly'
EXEC createGiftCard	'G102' ,'2019-11-17',100,'hana.aly'
GO

CREATE PROC removeExpiredGiftCard
@code VARCHAR(10)
AS
declare @flag BIT
if(exists (select * from giftcard where code = @code AND ((expiry_date)<=(CURRENT_TIMESTAMP))))
SET @flag='1'
else 
SET @flag='0'

IF @flag = '1'
BEGIN
DELETE FROM GiftCard
WHERE code = @code 

DELETE FROM Admin_Customer_Giftcard
WHERE code = @code  

DECLARE @gift_points INT
DECLARE @customer_point INT
DECLARE @customer_username VARCHAR(20)

SELECT @gift_points=remaining_points , @customer_username=username
FROM Admin_Customer_Giftcard
WHERE code=@code

UPDATE Customer
SET points=points-@gift_points
WHERE username=@customer_username

END
GO

EXEC removeExpiredGiftCard 'G101'
EXEC removeExpiredGiftCard 'G102'


GO
CREATE PROC checkGiftCardOnCustomer
@code VARCHAR(10) , @activeGiftCard BIT OUTPUT
AS
IF(EXISTS (SELECT code FROM Admin_Customer_Giftcard WHERE  code =@code ))
SET @activeGiftCard='1'
ELSE 
SET @activeGiftCard='0'


GO
DECLARE @activeGiftCard BIT 
EXEC checkGiftCardOnCustomer 'G101', @activeGiftCard OUTPUT
PRINT @activeGiftCard

DECLARE @activeGiftCard2 BIT 
EXEC checkGiftCardOnCustomer 'G102', @activeGiftCard2 OUTPUT
PRINT @activeGiftCard2

GO
--not sure about the points part
CREATE PROC giveGiftCardtoCustomer
@code VARCHAR(10),@customer_name VARCHAR(20),@admin_username VARCHAR(20)
AS
DECLARE @currentpoints INT 
DECLARE @cardamount INT 


SELECT @currentpoints = points
FROM Customer
WHERE username = @customer_name

SELECT @cardamount =deal_amount
FROM Giftcard
WHERE code = @code

INSERT INTO Admin_Customer_Giftcard(code,customer_name,admin_username,remaining_points) VALUES(@code,@customer_name,@admin_username,@cardamount)

UPDATE Customer
SET points = @currentpoints + @cardamount
WHERE username = @customer_name
GO
EXEC giveGiftCardtoCustomer 'G101','ahmed.ashraf','hana.aly'
EXEC giveGiftCardtoCustomer 'G102','ahmed.ashraf','hana.aly'

GO
