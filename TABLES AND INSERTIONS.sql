--use ms2


CREATE TABLE Users(
    username VARCHAR(20) PRIMARY KEY,
    password VARCHAR(20) ,
    first_name VARCHAR(20) ,
    last_name VARCHAR(20),
    email VARCHAR(50) 
);
--drop TABLE Users

CREATE TABLE User_Addresses(
    username VARCHAR(20),
    address VARCHAR(100),
    PRIMARY KEY (username, address),

    FOREIGN KEY(username) REFERENCES Users  ON DELETE CASCADE ON UPDATE CASCADE
);
--drop TABLE User_Addresses
CREATE TABLE User_mobile_numbers(
    username VARCHAR(20),
    mobile_number VARCHAR(20),
    PRIMARY KEY (username, mobile_number),

    FOREIGN KEY(username) REFERENCES Users  ON DELETE CASCADE ON UPDATE CASCADE
);
----drop TABLE User_mobile_numbers
CREATE TABLE Customer(
    username VARCHAR(20) PRIMARY KEY,
    points int DEFAULT 0,

    FOREIGN KEY(username) REFERENCES Users  ON DELETE CASCADE ON UPDATE CASCADE
);

----drop TABLE Customer

CREATE TABLE Admins(
    username VARCHAR(20) PRIMARY KEY,

    FOREIGN KEY(username) REFERENCES Users  ON DELETE CASCADE ON UPDATE CASCADE
  
);
--drop TABLE Admins
CREATE TABLE Vendor(
    username VARCHAR(20) PRIMARY KEY,
    activated BIT DEFAULT 0,
    company_name VARCHAR(50) ,
    bank_acc_no BIGINT ,
    admin_username VARCHAR(20),

    FOREIGN KEY(username) REFERENCES Users  ON DELETE cascade on UPDATE CASCADE,
    FOREIGN KEY(admin_username) REFERENCES Admins  ON DELETE no action ON UPDATE no action

);
ALTER TABLE Vendor
Alter column bank_acc_no BIGINT


--drop TABLE Vendor
CREATE TABLE Delivery_Person(
    username VARCHAR(20) PRIMARY KEY,
    activated BIT DEFAULT 0,

    FOREIGN KEY(username) REFERENCES Users  ON DELETE CASCADE ON UPDATE CASCADE
);

--drop TABLE Delivery_Person
CREATE TABLE Credit_card(
    number VARCHAR(20) PRIMARY KEY,
    expiry_date DATE ,
    cvv_code VARCHAR(4)
);
--drop TABLE Credit_card
CREATE TABLE Delivery(
    id INT IDENTITY,
    type VARCHAR(20),
    time_duration INT ,
    fees DECIMAL(5,3) ,
    username VARCHAR(20),
	
	PRIMARY KEY(id),
    FOREIGN KEY(username) REFERENCES Admins  ON DELETE NO ACTION ON UPDATE NO ACTION
);
 -- time_limit data type AND CONSTRAINTS

 --drop TABLE Delivery

CREATE TABLE Giftcard(
    code VARCHAR(10) PRIMARY KEY,
    expiry_date DATE ,
    deal_amount INT ,
    admin_username VARCHAR(20),

    FOREIGN KEY(admin_username) REFERENCES Admins ON DELETE NO ACTION ON UPDATE  NO ACTION

);

--drop TABLE  Giftcard

CREATE TABLE Orders(
    order_no INT PRIMARY KEY IDENTITY,
    order_date DATE ,
    total_amount DECIMAL(10,2) ,
    cash_amount DECIMAL(10,2),
    credit_amount DECIMAL(10,2),
    payment_type VARCHAR(35)   ,
    order_status VARCHAR(35) DEFAULT 'not processed',
    remaining_days INT,
    time_limit INT, 
    customer_name VARCHAR(20) ,
    creditCard_number VARCHAR(20),
	delivery_id INT,
    gift_card_code_used VARCHAR(10),
	

    FOREIGN KEY(customer_name) REFERENCES Customer ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY(delivery_id) REFERENCES Delivery ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(creditCard_number) REFERENCES Credit_Card ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(gift_card_code_used) REFERENCES Giftcard  ON DELETE CASCADE ON UPDATE CASCADE
);

--drop TABLE Orders

CREATE TABLE Product(
    serial_no INT PRIMARY KEY IDENTITY,
    product_name VARCHAR(20) ,
    category VARCHAR(20) ,
    product_description TEXT,
    price DECIMAL(10,2) ,
    final_price  DECIMAL(10,2),
    color VARCHAR(20) ,
    available BIT ,
    rate INT  ,
    vendor_username VARCHAR(20),
    customer_username VARCHAR(20),
    customer_order_id INT,
    

    FOREIGN KEY(customer_username) REFERENCES Customer ON DELETE no action ON UPDATE no action,
    FOREIGN KEY(vendor_username) REFERENCES Vendor ON DELETE no action ON UPDATE no action,
    FOREIGN KEY(customer_order_id) REFERENCES Orders ON DELETE CASCADE ON UPDATE CASCADE

);
--drop TABLE Product
CREATE TABLE CustomerAddstoCartProduct(
    serial_no INT,
    username VARCHAR(20),

    PRIMARY KEY (serial_no, username),
    FOREIGN KEY(serial_no) REFERENCES Product ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(username) REFERENCES Customer ON DELETE NO ACTION ON UPDATE NO ACTION

);
--drop TABLE CustomerAddstoCartProduct
--CHECK IDENTITY
CREATE TABLE Todays_Deals(
    deal_id INT PRIMARY KEY IDENTITY,
    deal_amount INT,
    expiry_date DATE ,
    admin_username VARCHAR(20),

    FOREIGN KEY(admin_username) REFERENCES Admins ON DELETE no action ON UPDATE no action

);
ALTER TABLE Todays_Deals
ALTER COLUMN expiry_date Date
--drop TABLE Todays_Deals

CREATE TABLE Todays_Deals_Product(
    deal_id INT,
    serial_no INT,


    PRIMARY KEY(deal_id, serial_no),
    FOREIGN KEY(serial_no) REFERENCES Product ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(deal_id) REFERENCES Todays_Deals ON DELETE no action ON UPDATE no action

);

--drop TABLE Todays_Deals_Product
CREATE TABLE Offer(
    offer_id INT IDENTITY PRIMARY KEY ,
    offer_amount DECIMAL(10,2) ,
    expiry_date DATETIME 

);

--drop TABLE Offer
CREATE TABLE OffersOnProduct(
    offer_id INT,
    serial_no INT,


    PRIMARY KEY(offer_id, serial_no),
    FOREIGN KEY(serial_no) REFERENCES Product ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(offer_id) REFERENCES Offer ON DELETE CASCADE ON UPDATE CASCADE

);
--drop TABLE OffersOnProduct

CREATE TABLE Customer_Quesiton_Product(
    customer_name VARCHAR(20),
    serial_no INT,
    question VARCHAR(50),
    answer TEXT,


    PRIMARY KEY(customer_name, serial_no),
    FOREIGN KEY(serial_no) REFERENCES Product ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(customer_name) REFERENCES Customer ON DELETE no action ON UPDATE no action

);
--drop TABLE Customer_Quesiton_Product

CREATE TABLE Wishlist(
    username VARCHAR(20),
    name VARCHAR(20) ,


    PRIMARY KEY(username, name),
    FOREIGN KEY(username) REFERENCES Customer ON DELETE no action ON UPDATE no action

);

--drop TABLE Wishlist

CREATE TABLE Wishlist_Product(
	customer_username VARCHAR(20),
    wish_name VARCHAR(20),
	serial_no INT,

    PRIMARY KEY(customer_username,wish_name, serial_no),
    FOREIGN KEY(serial_no) REFERENCES Product ON DELETE NO ACTION ON UPDATE  NO ACTION,
    FOREIGN KEY(customer_username, wish_name) REFERENCES Wishlist(username,name) ON DELETE NO ACTION ON UPDATE NO ACTION,

);
--drop TABLE Wishlist_Product

CREATE TABLE Admin_Customer_Giftcard(
    customer_name VARCHAR(20),
    code VARCHAR(10),
    admin_username VARCHAR(20),
    remaining_points INT,


    PRIMARY KEY(customer_name,admin_username, code),
    FOREIGN KEY(code) REFERENCES Giftcard ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(customer_name) REFERENCES Customer ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(admin_username) REFERENCES Admins ON DELETE no action ON UPDATE no action

);

--drop TABLE Admin_Customer_Giftcard
CREATE TABLE Admin_Delivery_Order(
    delivery_username VARCHAR(20),
    order_no INT,
    admin_username VARCHAR(20),
    delivery_window VARCHAR(50),

    PRIMARY KEY(delivery_username,admin_username, order_no),
    FOREIGN KEY(delivery_username) REFERENCES Delivery_Person ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(order_no) REFERENCES Orders ON DELETE no action ON UPDATE no action,
    FOREIGN KEY(admin_username) REFERENCES Admins ON DELETE no action ON UPDATE no action

);
--drop TABLE  Admin_Delivery_Order
CREATE TABLE Customer_CreditCard(
    customer_name VARCHAR(20),
    cc_number VARCHAR(20),

    PRIMARY KEY(customer_name,cc_number),
    FOREIGN KEY(customer_name) REFERENCES Customer ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(cc_number) REFERENCES Credit_Card ON DELETE CASCADE ON UPDATE CASCADE,

);
--drop TABLE	Customer_CreditCard
--------------------------------------------INSERTIONS-------------------------------------------------------------------
SELECT *
FROM Users

INSERT INTO Users
VALUES ('hana.aly','pass1','hana','aly','hana.aly@guc.edu.eg')

INSERT INTO Users
VALUES ('ammar.yasser','pass4','ammar','yasser','ammar.yasser@guc.edu.eg')

INSERT INTO Users
VALUES ('nada.sharaf','pass7','nada','sharaf','nada.sharaf@guc.edu.eg')

INSERT INTO Users
VALUES ('hadeel.adel','pass13','hadeel','adel','hadeel.adel@guc.edu.eg')

INSERT INTO Users
VALUES ('mohamed.tamer','pass16','mohamed','tamer','mohamed.tamer@guc.edu.eg')

INSERT INTO Admins
VALUES ('hana.aly')




INSERT INTO Admins
VALUES ('nada.sharaf')

INSERT INTO Customer
VALUES ('ammar.yasser', 15)

INSERT INTO Vendor
VALUES('hadeel.adel',1,'Dello', 47449349234 , 'hana.aly')



INSERT INTO Delivery_Person
VALUES('mohamed.tamer',1)

INSERT INTO User_Addresses
VALUES ('hana.aly','New Cairo')

INSERT INTO User_Addresses
VALUES ('hana.aly','Heliopolis')

INSERT INTO User_mobile_numbers
VALUES ('hana.aly','01111111111')

INSERT INTO User_mobile_numbers
VALUES ('hana.aly','1211555411')

INSERT INTO Credit_card
VALUES('4444-5555-6666-8888','2028-10-19','232')

INSERT INTO Delivery(type, time_duration, fees)
VALUES('pick-up',7,10)

INSERT INTO Delivery(type, time_duration, fees)
VALUES('regular',14,30)

INSERT INTO Delivery(type, time_duration, fees)
VALUES('speedy',1,50)

SET IDENTITY_INSERT Product ON; 

INSERT INTO Product(serial_no, product_name, category,
product_description,price, final_price, color, available, rate, vendor_username)
VALUES(1,'Bag','Fashion','backbag',100,100,'yellow','1',0,'hadeel.adel')

INSERT INTO Product(serial_no, product_name, category,
product_description,price, final_price, color, available, rate, vendor_username)
VALUES(3,'Blue pen','stationary','useful pen',10,10,'blue','1',0,'hadeel.adel')

INSERT INTO Product(serial_no, product_name, category,
product_description,price, final_price, color, available, rate, vendor_username)
VALUES(4,'Blue pen','stationary','useful pen',10,10,'blue','0',0,'hadeel.adel')

SET IDENTITY_INSERT Product OFF; 

INSERT INTO Todays_Deals(deal_amount, admin_username,expiry_date)
VALUES(30,'hana.aly','2019-11-30')

INSERT INTO Todays_Deals(deal_amount, admin_username,expiry_date)
VALUES(40,'hana.aly','2019-11-18' )


INSERT INTO Todays_Deals(deal_amount, admin_username,expiry_date)
VALUES(50,'hana.aly','2019-12-12' )


INSERT INTO Todays_Deals(deal_amount, admin_username,expiry_date)
VALUES(10,'nada.sharaf','2019-11-12' )



INSERT INTO Offer(offer_amount,expiry_date)
VALUES(10,'2019-11-30' )

/* INSERT INTO Offer(offer_amount,expiry_date)
VALUES(10,'2020-12-12' )
 */


INSERT INTO Wishlist
VALUES('ammar.yasser','fashion' )

INSERT INTO Wishlist_Product
VALUES('ammar.yasser','fashion',1)

--do later
--INSERT INTO Wishlist_Product
--VALUES('ammar.yasser','fashion',4 )




INSERT INTO Giftcard(code, expiry_date, deal_amount)
VALUES('G101','2019-11-18',100)


INSERT INTO Customer_CreditCard
VALUES('ammar.yasser','4444-5555-6666-8888')

INSERT INTO CustomerAddstoCartProduct
VALUES(1, 'ammar.yasser')

