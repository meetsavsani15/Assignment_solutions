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




