/*The following queries were executed using the NORTHWIND database.*/



1) SQL SELECT -

SELECT * FROM customers;


2) SQL SELECT DISTINCT -

SELECT DISTINCT contact_title FROM customers;


3) SQL WHERE -

SELECT * FROM PRODUCTS
WHERE units_in_stock > 50;


4) SQL AND, OR, NOT -

SELECT * FROM PRODUCTS
WHERE units_in_stock > 50 AND unit_price < 20;

SELECT * FROM PRODUCTS
WHERE units_in_stock > 50 OR unit_price > 20;

SELECT * FROM PRODUCTS
WHERE units_in_stock > 50 OR unit_price > 20;


5) SQL ORDER BY -

SELECT * FROM suppliers
ORDER BY contact_title;


6) SQL INSERT INTO -

INSERT INTO accounts(id, name, balance)
VALUES(5, 'Manoj', 10000);


7) SQL NULL VALUES -

INSERT INTO trial(id, name, age)
VALUES(1, null, null);


8) SQL UPDATE -

UPDATE trial
SET name = 'Meet'
WHERE id = 5;


9) SQL DELETE - 

DELETE FROM trial;


10) SQL SELECT TOP -

/* The TOP function is only valid for SQL server/MS access. For PostgreSQL we have LIMIT function. */

SELECT * FROM CUSTOMERS
LIMIT 10;


11) SQL MIN , MAX -

SELECT MIN(unit_price) FROM products;
SELECT MAX(unit_price) FROM products;


12) SQL COUNT, AVG, SUM -

SELECT COUNT(unit_price) FROM products;
SELECT AVG(unit_price) FROM products;
SELECT SUM(unit_price) FROM products;


13) SQL LIKE -

SELECT * FROM products
WHERE product_name LIKE 'C%';


14) SQL WILDCARDS -

SELECT * FROM products
WHERE product_name LIKE '_a%';

SELECT * FROM suppliers
WHERE city LIKE '_ondon';

SELECT * FROM suppliers
WHERE city LIKE '%by%';


15) SQL IN -

SELECT * FROM suppliers
WHERE country IN('USA', 'UK', 'INDIA');


16) SQL BETWEEN -

SELECT * FROM products
WHERE unit_price BETWEEN 60 AND 70;


17) SQL AS -

SELECT units_in_stock AS stocks
FROM products;


18) SQL JOIN -

SELECT orders.order_id, customers.contact_name, orders.order_date
FROM orders
JOIN customers 
ON orders.customer_id = customers.customer_id;


19) SQL INNER JOIN -

SELECT orders.order_id, customers.contact_name, orders.order_date
FROM orders
INNER JOIN customers 
ON orders.customer_id = customers.customer_id;


20) SQL LEFT JOIN -

SELECT orders.order_id, customers.contact_name, orders.order_date
FROM orders
LEFT JOIN customers 
ON orders.customer_id = customers.customer_id;


21) SQL RIGHT JOIN -

SELECT order_details.product_id, products.product_name, products.unit_price
FROM order_details
RIGHT JOIN products
ON order_details.product_id = products.product_id;


22) SQL FULL JOIN -

SELECT *
FROM order_details
FULL JOIN products
ON order_details.product_id = products.product_id
ORDER BY product_name;


23) SQL SELF JOIN -

SELECT A.contact_name AS CustomerName1, B.contact_name AS CustomerName2, A.city
FROM Customers A, Customers B
WHERE A.customer_id <> B.customer_id
AND A.city = B.city
ORDER BY A.city;


24) SQL UNION -

SELECT city FROM employees
UNION
SELECT city FROM suppliers;


25) SQL GROUP BY -

SELECT COUNT(employee_id), city
FROM employees
GROUP BY city;


26) SQL HAVING -

SELECT COUNT(customer_id), city
FROM customers
GROUP BY city
HAVING COUNT(customer_id) < 5
ORDER BY city;


27) SQL EXISTS -

SELECT contact_name
FROM suppliers
WHERE EXISTS (SELECT product_name 
	      FROM products
	      WHERE products.supplier_id = suppliers.supplier_id
	      AND unit_price > 20);
			 
28) SQL ANY, ALL -

SELECT product_name
FROM products
WHERE product_id = ANY (SELECT product_id
			 FROM order_details
			 WHERE quantity > 100);
					   
SELECT product_name
FROM products
WHERE product_id = ALL (SELECT product_id
 			 FROM order_details
  			 WHERE quantity = 10);
  			 
 
29) SQL SELECT INTO -

SELECT customer_id, contact_name INTO customers_AND_contact
FROM customers;


30) SQL INSERT INTO -

INSERT INTO customers (contact_name, city, country)
SELECT contact_name, city, country FROM suppliers;


31) SQL CASE -

SELECT order_id, quantity,
CASE
	WHEN quantity > 30 THEN 'The quantity is greater than 30.'
	WHEN quantity = 30 THEN 'The quantity is 30.'
	ELSE 'The quantity is less than 30.'
END AS quantity_details
FROM order_details;


32) SQL NULL FUNCTIONS -

SELECT product_name, unit_price * (units_in_stock + IFNULL(units_on_order, 0))
FROM products;

SELECT product_name, unit_price * (units_in_stock + COALESCE(units_on_order, 0))
FROM products;

SELECT product_name, unit_price * (units_in_stock + ISNULL(units_on_order, 0))
FROM products;


33) SQL STORED PROCEDURES -

-- STORED PROCEDURE DEMONSTRATION
-- ref: https://www.postgresqltutorial.com/postgresql-create-procedure/

-- First of all create a table

CREATE TABLE accounts (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DEC(15,2) NOT NULL
);

INSERT INTO accounts(id, name, balance)
VALUES(01, 'Meet', 100000);

INSERT INTO accounts(id, name,balance)
VALUES(02, 'Hobbit', 1000);

-- looking at the data

SELECT * FROM accounts;

-- creating a procedure names transfer

CREATE PROCEDURE transfer
(
	sender INT,
	receiver INT,
	amount DEC
)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE accounts
	SET balance = balance - amount
	WHERE id = sender;
	
	UPDATE accounts
	SET balance = balance + amount
	WHERE id = receiver;

COMMIT;
END $$;

-- Calling the procedure

CALL transfer(01, 02, 999);

-- looking at the updated data

SELECT * FROM accounts



Readings -->

1	"Meet"	       99001.00
2	"Hobbit"	1999.00



34) SQL COMMENT

Single Line Comment -- Select * from products;
Multi Line comment /* select * from products
			where product_name = "Chai"; */
			

35) SQL OPERATORS

Arithmetic Operator -

	SELECT 30 + 20;
	SELECT 20 - 10;
	SELECT 10 * 20;
	SELECT 20 / 10;
	SELECT 20 % 5;

Comparison Operator -

	SELECT * FROM products
	WHERE unit_price = 18;

	SELECT * FROM products
	WHERE unit_price > 18;

	SELECT * FROM products
	WHERE unit_price < 18;

	SELECT * FROM products
	WHERE unit_price >= 18;

	SELECT * FROM products
	WHERE unit_price <= 18;

	SELECT * FROM products
	WHERE unit_price <> 18;
	
/* Logical Operators are covered in the above SQL Queries - ANY, ALL, AND, OR, NOT
   BETWEEN, EXISTS, IN, LIKE. */
   

36) SQL CREATE DATABASE

CREATE DATABASE practice;


37) SQL DROP DATABASE

DROP DATABASE practice;


38) SQL BACKUP DATABASE

BACKUP DATABASE exercise
TO DISK = '/home/meetsavsani';


39) SQL CREATE TABLE

CREATE TABLE accounts (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DEC(15,2) NOT NULL
);


40) SQL DROP TABLE

DROP TABLE accounts;


41) SQL ALTER TABLE

ALTER TABLE customers
ADD email VARCHAR(100);


42) SQL CONSTRAINTS 

/* Constraints covered - PRIMARY KEY, 
			  NOT NULL, 
			  FORIEGN KEY,
			  REFERENCE, 
			  UNIQUE, 
			  CHECK,
			  DEFAULT,
			  AUTO INCREMENT. */

CREATE TABLE students
(
	roll_no INT AUTO_INCREMENT,
	firstname VARCHAR(50) NOT NULL,
	lastname VARCHAR(50) NOT NULL,
	class_section TEXT NOT NULL 
	age INT CHECK (age <= 20)
	marks_received_on DEFAULT GETDATE(),
	PRIMARY KEY(roll_no)
);

CREATE TABLE marks
(
	roll_no INT PRIMARY KEY REFERENCES students(roll_no),
	physics DEC(3,2) NOT NULL,
	chemistry DEC(3,2) NOT NULL,
	mathematics DEC(3,2) NOT NULL,
	english DEC(3,2) NOT NULL,
	informatics_practices DEC(3,2) NOT NULL
);


43) SQL INDEX 

CREATE INDEX find_unit_price
ON unit_price(products);


44) SQL DATE

/* Date Format - YYYY-MM-DD
   Date Time - YYYY-MM-DD HH:MM:SS
   Timestamp - YYYY-MM-DD HH:MM:SS
   Year - YYYY
   */
   
 SELECT * FROM orders 
 WHERE order_date='2008-11-11';
 
 
45) SQL VIEW
 
CREATE VIEW [Brazil Customers] AS
SELECT contact_name
FROM customers
WHERE country = 'Brazil';



















































































