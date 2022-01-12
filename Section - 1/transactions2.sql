-- Scenario 2

/*
For suppose, Radha wants to book a ticket from IRCTC portal to Varanasi for 2500 rupees and she is short of 1000 rupees
so she asks his father Ramesh to transfer the money to her account so she can book the tickets.

For this, we have T1 --> amount transfer from ramesh to radha
				  T2 --> amount transfer from radha to irctc
*/

-- Let's start with creating tables

CREATE TABLE ramesh_account(
	id INT PRIMARY KEY,
	total_amount_transferred DEC(15,2) NOT NULL,
	current_balance DEC(15,2)
);

CREATE TABLE radha_account(
	id INT PRIMARY KEY,
	total_amount_transferred DEC(15,2) NOT NULL,
	current_balance DEC(15,2)
);

CREATE TABLE irctc(
	id INT PRIMARY KEY,
	name_of_passenger VARCHAR(50) NOT NULL,
	destination VARCHAR(50) NOT NULL,
	amount_transferred DEC(15,2)
);

INSERT INTO ramesh_account
VALUES(1, 0.00, 20000.00);

INSERT INTO radha_account
VALUES(1, 0.00, 1500.00);

SELECT * FROM ramesh_account;
SELECT * FROM radha_account;
SELECT * FROM irctc;

DELETE FROM radha_account;
DELETE FROM ramesh_account;
DELETE FROM irctc;

-- Transaction 1

-- Tranfer of 1000 from ramesh to radha

BEGIN;

INSERT INTO ramesh_account
VALUES('2', 1000.00, 20000.00);

UPDATE ramesh_account
SET current_balance = current_balance - 1000.00
WHERE id = 2;


INSERT INTO radha_account
VALUES('2', 1000.00, 1500.00);

UPDATE radha_account
SET current_balance = current_balance + 1000.00
where id = 2;

SAVEPOINT transaction1;

SELECT * FROM radha_account;
SELECT * FROM ramesh_account;

ROLLBACK;

COMMIT;

-- TRANSACTION 2 --> Transfer of 2500 from radha to irctc.

BEGIN;

INSERT INTO irctc
VALUES('1', 'Radha', 'Varanasi', 2500.00);

UPDATE radha_account
SET current_balance = current_balance - 2500.00
WHERE id = 2;

SAVEPOINT update1;

SELECT * FROM irctc;
SELECT * FROM radha_account;

ROLLBACK;
COMMIT;




