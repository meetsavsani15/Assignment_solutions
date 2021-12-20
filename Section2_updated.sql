
-- 1) CREATE TABLE


CREATE TABLE products
(
	product_id INT PRIMARY KEY,
	product_name VARCHAR(50) NOT NULL,
	product_type VARCHAR(50) NOT NULL,
	product_unit_price INT NOT NULL	
);


CREATE TABLE orders
(
	order_id INT PRIMARY KEY REFERENCES products(product_id),
	order_date DATE NOT NULL,
	order_receipient_name VARCHAR(50) NOT NULL,
	order_delivered_to VARCHAR(50) NOT NULL,
	order_dispatched_from VARCHAR(50) NOT NULL,
	order_quantity INT
);

-- 2) INSERT INTO

INSERT INTO products(product_id, product_name, product_type, product_unit_price)
VALUES (10245, 'Florence Tea bag', 'Food', 150),
	   (10100, 'Luffos Grenade Toy Pack of 4', 'Toys', 45),
	   (10330, 'Markwell Perfumes', 'Beauty Care', 1000),
	   (10450, 'Dubios XR-504ARC', 'Sports', 6045),
	   (10555, 'Lutris Fabluent Ink pen', 'Accessories', 400),
	   (10889, 'Potra Pot Plant', 'Decoration', 1520),
	   (10565, 'Benevolent Pakced Meat', 'Food', 450),
	   (10323, 'HyperX Gaming Keyboard', 'Gaming', 3500),
	   (10456, 'Nvidia GeForce RTX 3070', 'Gaming', 35000),
	   (10455, 'AMD Ryzen 5700 Processor', 'Gaming', 34000);

INSERT INTO orders(order_id, order_date, order_receipient_name, order_delivered_to, order_dispatched_from, order_quantity)
VALUES (10245, '2021-11-10', 'Sartaj Sharma', 'Ranchi', 'Ahmedabad', 5),
       (10100, '2021-10-09', 'Mahol Mohram', 'Jammu', 'Mumbai', 3),
	   (10330, '2021-09-10', 'Alex Albon', 'Surat', 'Banglore', 1),
	   (10450, '2021-08-20', 'Max Verstappen', 'Udaipur', 'Delhi', 2),
	   (10555, '2021-10-21', 'Jason Darula', 'Mohali', 'Rajkot', 5),
	   (10889, '2021-11-21', 'Kinjal Dave', 'Ahmedabad', 'Mumbai', 2),
	   (10565, '2021-12-16', 'Rihan Parag', 'Ahmedabad', 'Chennai', 1),
	   (10323, '2021-12-15', 'Rohan Muley', 'Jamnagar', 'Banglore', 1),
	   (10456, '2021-12-20', 'Meet Savsani', 'Jamnagar', 'Mumbai', 10),
	   (10455, '2021-12-20', 'Meet Savsani', 'Jamnagar', 'Mumbai', 10);

-- 3) SELECT FROM

SELECT * FROM orders;
SELECT * FROM products;

-- 4) DISTINCT

SELECT DISTINCT product_type FROM products;

-- 5) WHERE

SELECT order_receipient_name FROM orders
WHERE order_id = 10565;

-- 6) AND, OR, NOT

SELECT * FROM products
WHERE product_unit_price > 20 AND product_type = 'Toys';

SELECT * FROM orders
WHERE order_date > '2021-11-01' OR order_date < '2021-12-20';

SELECT * FROM orders
WHERE order_quantity <> 1;

-- 7) ORDER BY

SELECT * FROM products
ORDER BY product_type;

-- 8) UPDATE

UPDATE orders
SET order_quantity = 10
WHERE order_id = 10323;

-- 9) LIMIT/TOP

SELECT * FROM products
LIMIT 5;

-- 10) MIN, MAX

SELECT MIN(product_unit_price) FROM products;
SELECT MAX(order_date) FROM orders;

-- 11) COUNT, AVG, SUM

SELECT COUNT(product_type) FROM products;
SELECT ROUND(AVG(order_quantity)) FROM orders;
SELECT SUM(product_unit_price) FROM products;

-- 12) LIKE/WILDCARDS

SELECT * FROM orders
WHERE order_receipient_name LIKE '%M%';

SELECT * FROM products
WHERE product_name LIKE '%Pack%';

-- 13) IN

SELECT * FROM orders
where order_delivered_to IN('Ahmedabad' , 'Rajkot');

-- 14) BETWEEN

SELECT * FROM orders
WHERE order_date BETWEEN '2021-12-01' AND '2021-12-20';

-- 15) AS

SELECT o.order_receipient_name, o.order_quantity * p.product_unit_price
AS total_cost
FROM orders o, products p
WHERE o.order_id = p.product_id;

-- 16) JOIN

SELECT *
FROM orders o
JOIN products p
ON o.order_id = p.product_id;

-- 17) INNER JOIN

SELECT *
FROM orders o
INNER JOIN products p
ON o.order_id = p.product_id;

-- 18) OUTER JOIN

SELECT o.order_date, p.*
FROM orders o
FULL JOIN products p
ON o.order_id = p.product_id;

-- 19) LEFT JOIN

SELECT o.order_receipient_name, p.*
FROM orders o
LEFT JOIN products p
ON o.order_id = p.product_id;

-- 20) RIGHT JOIN

SELECT p.product_type, o.order_date, o.order_quantity
FROM products p
RIGHT JOIN orders o
ON o.order_id = p.product_id;

-- 21) UNION

SELECT order_delivered_to FROM orders
UNION
SELECT product_type FROM products;

-- 22) GROUP BY

SELECT order_delivered_to, count(order_id) FROM orders
WHERE order_quantity > 1
GROUP BY order_delivered_to;

-- 23) HAVING

SELECT order_delivered_to, count(order_id) FROM orders
GROUP BY order_delivered_to
HAVING count(order_id) < 10
ORDER BY count(order_id);

-- 24) EXISTS

SELECT product_name
FROM products
WHERE EXISTS (SELECT order_date FROM orders
			 WHERE order_date > '2021-12-01'
			 AND orders.order_id = products.product_id);

-- 25) CASE

SELECT p.product_name, o.order_date,
CASE
	WHEN o.order_date BETWEEN '2021-12-01' AND '2021-12-31' THEN 'Orders are placed in month of December.'
	WHEN o.order_date BETWEEN '2021-11-01' AND '2021-11-20' THEN 'Orders are placed before December'
	ELSE 'Orders are placed before December and November.'
END AS order_month_details
FROM orders o, products p
WHERE o.order_id = p.product_id;

-- 26) STORED PROCEDURE

CREATE PROCEDURE return_order
(
	id INT,
	name VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
	DELETE FROM orders
	WHERE order_id = id;
COMMIT;
END $$;

CALL return_order(10450, 'Max Verstappen');

SELECT * FROM orders;

-- 27) INDEX

CREATE INDEX product_price
ON products (product_unit_price);

EXPLAIN ANALYZE SELECT product_unit_price FROM products;

-- 28) VIEW

CREATE VIEW Ahmedabad_Customers AS
SELECT order_receipient_name
FROM orders
WHERE order_delivered_to = 'Ahmedabad';

SELECT * FROM Ahmedabad_Customers;

-- 29) ALTER 

ALTER TABLE products
ADD product_wishlist VARCHAR(50);

-- 30) DROP

DROP TABLE products;
DROP TABLE orders;



