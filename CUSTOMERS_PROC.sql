
use ms2


GO
CREATE PROC showProducts
AS
 SELECT serial_no, product_name, category, product_description, final_price, color, available, rate, vendor_username

 FROM Product

 GO

exec showProducts
GO
 ------------------------------
 CREATE PROC ShowProductsbyPrice
 AS
 SELECT serial_no, product_name, category, product_description, final_price, color, available, rate, vendor_username 
 FROM Product
 ORDER BY price ASC
 GO
exec ShowProductsbyPrice
GO
 ------------------------------
CREATE PROC searchbyname
 @text VARCHAR(20)
 AS
 SELECT serial_no, product_name, category, product_description, final_price, color, available, rate, vendor_username
 FROM Product
 WHERE Product.product_name LIKE '%' + @text + '%'

 GO

 exec searchbyname 'blue'

 GO

 ------------------------------
CREATE PROC AddQuestion
 @serial int, @customer VARCHAR(20), @Question VARCHAR(50)
 AS
 INSERT INTO Customer_Quesiton_Product (serial_no, customer_name,question)
 VALUES (@serial, @customer,@Question)

GO
EXEC AddQuestion 1,'ahmed.ashraf' , 'size?'
GO
 ------------------------------
CREATE PROC addToCart
 @customername VARCHAR(20), @serial int
 AS
 INSERT INTO CustomerAddstoCartProduct VALUES (@serial,@customername)
 
 GO
 EXEC addToCart 'ahmed.ashraf',1
  EXEC addToCart 'ahmed.ashraf',3
 GO 
 ------------------------------
CREATE PROC removefromCart
 @customername VARCHAR(20), @serial int
 AS
 DELETE FROM CustomerAddstoCartProduct 
 WHERE username=@customername AND serial_no=@serial

GO

  EXEC removefromCart 'ahmed.ashraf',3

 GO
 ------------------------------
CREATE PROC createWishlist
@customername VARCHAR(20), @name VARCHAR(20)
AS
INSERT INTO Wishlist VALUES (@customername, @name)
GO 

EXEC createWishlist 'ahmed.ashraf', 'fashion'

GO
------------------------------
CREATE PROC AddtoWishlist
@customername VARCHAR(20), @wishlistname VARCHAR(20), @serial int
AS
INSERT INTO Wishlist_Product VALUES (@customername,@wishlistname, @serial)
 
 GO

 EXEC AddtoWishlist 'ahmed.ashraf', 'fashion', 1
 EXEC AddtoWishlist 'ahmed.ashraf', 'fashion', 3

GO
------------------------------
CREATE PROC removefromWishlist
@customername VARCHAR(20), @wishlistname VARCHAR(20), @serial int
AS
DELETE FROM Wishlist_Product 
WHERE customer_username=@customername AND wish_name=@wishlistname AND serial_no=@serial

GO

EXEC  removefromWishlist 'ahmed.ashraf','fashion', 1
GO 

------------------------------
CREATE PROC showWishlistProduct
@customername VARCHAR(20), @name VARCHAR(20)
AS
SELECT p.serial_no , p.product_name, p.category, p.product_description, p.final_price, p.color,
p.available, p.rate
FROM Product p INNER JOIN  Wishlist_Product WP
ON p.serial_no=WP.serial_no
WHERE WP.customer_username=@customername AND WP.wish_name=@name

GO 

EXEC showWishlistProduct 'ahmed.ashraf','fashion'

GO
--sofia

------------------------------
CREATE PROC viewMyCart
@customer VARCHAR(20)

AS
SELECT p.serial_no , p.product_name, p.category, p.product_description, p.final_price, p.color,
p.available, p.rate
FROM CustomerAddstoCartProduct c INNER JOIN Product p
ON c.serial_no = p.serial_no
WHERE c.username = @customer
GO
exec viewMyCart 'ahmed.ashraf'

GO

------------------------------
CREATE PROC calcuatepriceOrder
@customername VARCHAR(20), @sum decimal(10,2) OUTPUT
AS
SELECT @sum = sum(p.final_price)
FROM CustomerAddstoCartProduct c INNER JOIN Product p
ON c.serial_no = p.serial_no
WHERE c.username = @customername

GO

------------------------------
CREATE PROC productsinorder
@customername varchar(20), @orderID int
AS

UPDATE Product 
SET customer_username = @customername , customer_order_id= @orderID, available='0'
WHERE serial_no IN
(SELECT p.serial_no
FROM Orders o INNER JOIN CustomerAddstoCartProduct p ON o.customer_name = p.username
WHERE o.customer_name = @customername AND o.order_no = @orderID
)

SELECT p.*
FROM Orders o INNER JOIN Product p ON o.order_no = p.customer_order_id
WHERE o.customer_name = @customername AND o.order_no = @orderID

DELETE CustomerAddstoCartProduct
WHERE username<>@customername AND 
serial_no IN (SELECT p.serial_no
FROM Orders o INNER JOIN Product p ON o.order_no = p.customer_order_id
WHERE o.customer_name = @customername AND o.order_no = @orderID)

go
 --exec productsinorder 'ahmed.ashraf' , 18


GO
------------------------------
CREATE PROC emptyCart
@customername VARCHAR(20)
AS
DELETE FROM CustomerAddstoCartProduct WHERE username = @customername 
GO

------------------------------
CREATE PROC makeOrder
@customername VARCHAR(20)
AS
DECLARE @priceOrder DECIMAL(10,2)
DECLARE @order_id INT
DECLARE @giftcardcode VARCHAR(10)

EXEC calcuatepriceOrder  @customername , @priceOrder OUTPUT

SELECT @giftcardcode=a.code
FROM Admin_Customer_Giftcard a INNER JOIN Giftcard g ON a.code=g.code
WHERE a.customer_name=@customername AND g.expiry_date>CURRENT_TIMESTAMP

print 'gift card'
print @giftcardcode

INSERT INTO Orders (order_date,total_amount,order_status, customer_name,gift_card_code_used)
VALUES (CURRENT_TIMESTAMP, @priceOrder, 'not processed' , @customername,@giftcardcode)


DECLARE @price DECIMAL(10,2)

SELECT @order_id=MAX(o.order_no)
FROM Orders o  

EXEC productsinorder @customername,@order_id
EXEC emptyCart @customername

GO 


EXEC makeOrder 'ahmed.ashraf'


GO



------------------------------
GO
CREATE PROC cancelOrder
@orderid int 
AS
DECLARE @cash_amount decimal(10,2)
DECLARE @credit_amount decimal(10,2)
DECLARE @total_amount DECIMAL(10,2)
if exists(select * FROM Orders WHERE order_no = @orderid AND ( order_status = 'not processed' OR order_status = 'In process'))
BEGIN
UPDATE Product
Set available='1',customer_username=null,customer_order_id=null
Where customer_order_id=@orderid 


SELECT @cash_amount=o.cash_amount,@credit_amount=o.credit_amount,@total_amount=o.total_amount
FROM Orders o
WHERE o.order_no=@orderid

if(exists(SELECT *
FROM Orders o INNER JOIN Giftcard g ON o.gift_card_code_used=g.code
WHERE g.expiry_date>CURRENT_TIMESTAMP AND o.order_no=@orderid))
BEGIN
if(@cash_amount is null)
BEGIN
UPDATE Customer
SET points= points + (@total_amount - @credit_amount )
WHERE username=(
SELECT o.customer_name
FROM  Orders o 
WHERE o.order_no=@orderid)

UPDATE Admin_Customer_Giftcard
SET remaining_points=remaining_points+((@total_amount - @credit_amount))
WHERE code=
(SELECT o.gift_card_code_used
FROM Orders o
WHERE o.order_no=@orderid)
END

ELSE
BEGIN
UPDATE Customer
SET points= points + (@total_amount - @cash_amount )
WHERE username=(
SELECT o.customer_name
FROM  Orders o 
WHERE o.order_no=@orderid)

UPDATE Admin_Customer_Giftcard
SET remaining_points=remaining_points+((@total_amount -@cash_amount))
WHERE code=
(SELECT o.gift_card_code_used
FROM Orders o
WHERE o.order_no=@orderid)

END

END

DELETE FROM Orders
WHERE order_no = @orderid AND ( order_status = 'not processed' OR order_status = 'In process')
END

GO

EXEC cancelOrder 5
GO

------------------------------
CREATE PROC returnProduct
@serialno int , @orderid int
AS
--check payment method and reverse it 

DECLARE @cash_amount decimal(10,2)
DECLARE @credit_amount decimal(10,2)
DECLARE @total_amount decimal(10,2)

SELECT @cash_amount=o.cash_amount,@credit_amount=o.credit_amount,@total_amount=o.total_amount
FROM Orders o
WHERE o.order_no=@orderid
 
UPDATE Product 
SET  available = '1',customer_username=null,customer_order_id=null
WHERE serial_no = @serialno 

UPDATE Orders
SET total_amount=total_amount-(SELECT p.final_price FROM Product p WHERE p.serial_no=@serialno)
WHERE order_no=@orderid


IF((@credit_amount IS null) AND ((@total_amount-@cash_amount)<>0))
BEGIN

if(exists(SELECT *
FROM Orders o INNER JOIN Giftcard g ON o.gift_card_code_used=g.code
WHERE g.expiry_date>CURRENT_TIMESTAMP AND o.order_no=@orderid))
BEGIN
UPDATE Customer
SET points=points+((SELECT p.final_price FROM Product p WHERE p.serial_no=@serialno)-@cash_amount)
WHERE username=(
SELECT c.username
FROM Customer c INNER JOIN Orders o ON c.username=o.customer_name
WHERE o.order_no=@orderid)


UPDATE Admin_Customer_Giftcard
SET remaining_points=remaining_points+((SELECT p.final_price FROM Product p WHERE p.serial_no=@serialno)-@cash_amount)
WHERE code=
(SELECT o.gift_card_code_used
FROM Orders o
WHERE o.order_no=@orderid)
END
END

ELSE
BEGIN

if(exists(SELECT *
FROM Orders o INNER JOIN Giftcard g ON o.gift_card_code_used=g.code
WHERE g.expiry_date>CURRENT_TIMESTAMP AND o.order_no=@orderid))
BEGIN
UPDATE Customer
SET points=points+((SELECT p.final_price FROM Product p WHERE p.serial_no=@serialno)-@credit_amount)
WHERE username=(
SELECT c.username
FROM Customer c INNER JOIN Orders o ON c.username=o.customer_name
WHERE o.order_no=@orderid)


UPDATE Admin_Customer_Giftcard
SET remaining_points=remaining_points+((SELECT p.final_price FROM Product p WHERE p.serial_no=@serialno)-@credit_amount)
(SELECT o.gift_card_code_used
FROM Orders o
WHERE o.order_no=@orderid)
END
END
GO

EXEC returnProduct 1,11
GO
------------------------------
CREATE PROC showproductsIbought
@customername VARCHAR(20)
AS
SELECT p.* 
FROM Orders o INNER JOIN Product p ON o.order_no = p.customer_order_id
WHERE o.order_status = 'Delivered' AND o.customer_name = @customername

GO
UPDATE Orders
SET order_status='Delivered'
WHERE order_no=12

GO

EXEC showproductsIbought 'ahmed.ashraf'
GO

------------------------------
CREATE PROC rate
@serialno INT , @rate INT , @customername VARCHAR(20)
AS

-- UPDATE 
DECLARE @table TABLE(serial_no INT PRIMARY KEY,
    product_name VARCHAR(20) ,
    category VARCHAR(20) ,
    product_description TEXT,
    price DECIMAL(10,2) ,
    final_price  DECIMAL(10,2) ,
    color VARCHAR(20) ,
    available BIT ,
    rate INT DEFAULT 0 ,
    vendor_username VARCHAR(20),
    customer_username VARCHAR(20),
    customer_order_id INT);

    
INSERT INTO @table exec showproductsIbought @customername

IF (EXISTS ( SELECT * 
FROM @table 
WHERE serial_no = @serialno) )
BEGIN
UPDATE Product 
SET  rate = @rate
WHERE serial_no = @serialno
END 
GO 
EXEC rate 1,22,'ahmed.ashraf'
GO

------------------------------
CREATE PROC SpecifyAmount 
@customername VARCHAR(20), @orderID INT , @cash DECIMAL(10,2), @credit DECIMAL(10,2) 

AS
UPDATE Orders 
SET  credit_amount = @credit, cash_amount = @cash
WHERE order_no = @orderID

Declare @price decimal(10,2)
Declare @code VARCHAR(10)


SELECT @price = total_amount,@code=o.gift_card_code_used
FROM Orders o
WHERE order_no =@orderID


IF(@cash is null)
BEGIN
UPDATE Orders
SET payment_type='Credit'
WHERE order_no=@orderID

if(exists(SELECT *
FROM Orders o INNER JOIN Giftcard g ON o.gift_card_code_used=g.code
WHERE g.expiry_date>CURRENT_TIMESTAMP AND o.order_no=@orderid))
BEGIN
UPDATE Customer 
SET  points = points - (@price - @credit) 
WHERE @customername = username
 
UPDATE Admin_Customer_Giftcard
SET remaining_points=remaining_points - (@price - @credit) 
WHERE code=@code
END
END
ELSE
BEGIN
UPDATE Orders
SET payment_type='Cash'
WHERE order_no=@orderID

if(exists(SELECT *
FROM Orders o INNER JOIN Giftcard g ON o.gift_card_code_used=g.code
WHERE g.expiry_date>CURRENT_TIMESTAMP AND o.order_no=@orderid))
BEGIN 
UPDATE Customer 
SET  points = points - (@price- @cash) 
WHERE @customername = username
 
UPDATE Admin_Customer_Giftcard
SET remaining_points=remaining_points - (@price-@cash) 
WHERE code=@code
END

END
GO
---


-- DROP PROC SpecifyAmount
EXEC SpecifyAmount 'ahmed.ashraf',1,null , 95
EXEC SpecifyAmount 'ahmed.ashraf',2,null , 100

UPDATE Orders
SET credit_amount=0,payment_type=null,gift_card_code_used='G101'
WHERE order_no=5
----
	GO
------------------------------
CREATE PROC addCreditCard
@creditcardnumber VARCHAR(20), @expirydate DATE , @cvv VARCHAR(4), @customername VARCHAR(20)
AS
INSERT INTO Credit_Card
VALUES(@creditcardnumber , @expirydate, @cvv)

INSERT INTO Customer_CreditCard
VALUES(@customername,@creditcardnumber)

GO
SELECT *
FROM Customer_CreditCard

EXEC addCreditCard '4444-5555-6666-8888' ,'10/19/2028' ,'232','ahmed.ashraf'

GO
------------------------------
CREATE PROC  ChooseCreditCard
@creditcard VARCHAR(20), @orderid int
AS
UPDATE Orders 
SET creditCard_number = @creditcard
WHERE order_no = @orderid

GO
EXEC ChooseCreditCard '4444-5555-6666-8888' , 1


GO
------------------------------
CREATE PROC  viewDeliveryTypes
AS

SELECT DISTINCT (type) , fees , time_duration  
FROM Delivery

GO
EXEC viewDeliveryTypes
GO
--MISTAKEEE

------------------------------
CREATE PROC  specifydeliverytype
@orderID int, @deliveryID  INT
AS
DECLARE @deliveryfees Decimal(5,3)
DECLARE @remdays INT
DECLARE @type VARCHAR(20)


SELECT  @remdays = time_duration, @type = type
FROM Delivery
WHERE id = @deliveryID

UPDATE Orders 
SET delivery_id = @deliveryID ,  remaining_days = @remdays
WHERE order_no = @orderID
GO
--SHOULD ADD FEES IN ORDER total_amount = total_amount + @deliveryfees ,
EXEC specifydeliverytype 1 ,2

select *
from orders
GO
------------------------------

---
CREATE PROC trackRemainingDays
@orderid int, @customername varchar(20), @days INT OUTPUT
AS



UPDATE Orders
set remaining_days = remaining_days - (SELECT DATEDIFF (DAY, order_date , CURRENT_TIMESTAMP) AS DATEDIFF)
WHERE order_no = @orderid

set @days = (SELECT remaining_days FROM Orders WHERE order_no =  @orderid)


GO

DECLARE @days INT  
EXEC trackRemainingDays 1, 'ahmed.ashraf' , @days OUTPUT
print @days


SELECT *
FROM orders

GO
------------------------------

CREATE PROC recommmend1
@customername varchar(20)
AS
DECLARE @temp TABLE (
serial_no INT
)
INSERT INTO @temp (serial_no)
SELECT w.serial_no
	FROM Wishlist_Product w INNER JOIN Product p ON w.serial_no=p.serial_no
    where p.category in((SELECT TOP 3 p.category
    FROM CustomerAddstoCartProduct C INNER JOIN Product  p
	on C.serial_no= p.serial_no
    GROUP BY p.category,C.username
	having C.username=@customername
    ORDER BY COUNT(*) DESC))

SELECT TOP 3 serial_no
FROM @temp t
GROUP BY t.serial_no
ORDER BY count(*) DESC
Go

CREATE PROC recommend2
@customername VARCHAR(20)
AS
---table that has serial no. of the customer that we want to compare with

-------table that has usernames and serial no.of all users except sofia
DECLARE  @others TABLE(
username VARCHAR(20),
serial_no VARCHAR(20)) 
-----OTHERS HAS SERIAL NO. OF THE CUSTOMER WE WANT TO COMPARE WITH
INSERT INTO @others(username,serial_no)
(SELECT c.username,c.serial_no
FROM CustomerAddstoCartProduct c
WHERE c.username<>@customername AND
c.serial_no IN (SELECT c.serial_no
FROM CustomerAddstoCartProduct c
WHERE c.username=@customername))

DECLARE @temp TABLE (
serial_no INT
)
INSERT INTO @temp (serial_no)
SELECT w.serial_no
FROM Wishlist_Product w
where w.customer_username IN(
	SELECT TOP 3 o.username 
FROM @others o
GROUP BY o.username
ORDER BY COUNT(*) DESC
	)

SELECT TOP 3 t.serial_no 
FROM @temp t
GROUP BY t.serial_no
ORDER BY COUNT(*) DESC


								---top 3 similar customers
--SELECT TOP 3 o.username 
--FROM @others o
--GROUP BY o.username
---ORDER BY COUNT(*) DESC


-----SELECTING TOP 3 CUSTOMERS FROM THE MOST SIMILAR CUSTOMERS----


GO


CREATE PROC recommend
@customername VARCHAR(20)
AS
DECLARE @recommend1 TABLE(
serial_no int
)
DECLARE @recommend2 TABLE(
serial_no int
)
INSERT INTO @recommend1 
EXEC  recommmend1 @customername
INSERT INTO @recommend2 
EXEC  recommend2 @customername



DECLARE @union TABLE(
serial_no int
)
INSERT INTO @union(serial_no)
SELECT *
FROM @recommend1 
--r INNER JOIN Product p on r.serial_no=p.serial_no
UNION
SELECT *
FROM @recommend2 r1 
--INNER JOIN Product p1 on r1.serial_no=p1.serial_no

SELECT p.serial_no,p.product_name,p.product_description,p.available,p.category,p.color,p.rate,p.final_price,p.vendor_username
FROM Product p INNER JOIN @union u ON p.serial_no=u.serial_no
GO
 
 --ai kalam
 
EXEC recommend2 'ahmed.ashraf'
EXEC recommmend1 'ahmed.ashraf'
EXEC recommend 'ahmed.ashraf'
