use ms2


GO
CREATE PROC acceptAdminInvitation
@delivery_username varchar(20)

AS 
UPDATE Delivery_Person
SET activated = '1'


GO
CREATE PROC deliveryPersonUpdateInfo
@username varchar(20),@first_name varchar(20),@last_name varchar(20),@password varchar(20),@email varchar(50)

AS 
UPDATE Users 
SET first_name = @first_name, last_name = @last_name , password = @password , email = @email 
WHERE @username = username 

EXEC deliveryPersonUpdateInfo 'mohamed.tamer', 'mohamed', ' tamer' , 'pass16' , 'mohamed.tamer@guc.edu.eg'

GO
CREATE PROC viewmyorders
@deliveryperson varchar(20)
AS 
SELECT o.*
FROM Orders o INNER JOIN Admin_Delivery_Order d 
ON d.order_no= o.order_no
WHERE d.delivery_username = @deliveryperson 

GO

EXEC viewmyorders 'mohamed.tamer'

GO
CREATE PROC specifyDeliveryWindow
@delivery_username varchar(20),@order_no int,@delivery_window varchar(50)
AS 

UPDATE Admin_Delivery_Order
SET delivery_window = @delivery_window
WHERE delivery_username = @delivery_username AND order_no = @order_no
 
 EXEC specifyDeliveryWindow 'mohamed.tamer', 1  ,'Today between 10 am and 3 pm'

GO

CREATE PROC updateOrderStatusOutforDelivery
@order_no int
AS 

UPDATE Orders
SET order_status = 'out for delivery'
WHERE order_no = @order_no

EXEC updateOrderStatusOutforDelivery 1

GO

CREATE PROC updateOrderStatusDelivered
@order_no int
AS 

UPDATE Orders
SET order_status = 'delivered'
WHERE order_no = @order_no

EXEC updateOrderStatusDelivered 1

GO