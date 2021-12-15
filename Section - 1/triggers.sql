/*
	DEMONSTRATION OF TRIGGERS
	ref: https://www.postgresqltutorial.com/creating-first-trigger-postgresql/
*/ 

-- create sample tables

CREATE TABLE employees
(
   id INT GENERATED ALWAYS AS IDENTITY,
   first_name VARCHAR(40) NOT NULL,
   last_name VARCHAR(40) NOT NULL,
   PRIMARY KEY(id)
);

-- employee_audit table save the changes made to employee table 

CREATE TABLE employee_audits 
(
   id INT GENERATED ALWAYS AS IDENTITY,
   employee_id INT NOT NULL,
   last_name VARCHAR(40) NOT NULL,
   changed_on TIMESTAMP(6) NOT NULL
);


-- creating a function to keep track of all the changes made 

CREATE OR REPLACE FUNCTION log_last_name_changes()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
	IF NEW.last_name <> OLD.last_name THEN
		 INSERT INTO employee_audits(employee_id,last_name,changed_on)
		 VALUES(OLD.id,OLD.last_name,now());
	END IF;

	RETURN NEW;
END;
$$

-- creating a trigger function and integrating it with the function made earlier
-- and the table employees.

CREATE TRIGGER last_name_changes
  BEFORE UPDATE
  ON employees
  FOR EACH ROW
  EXECUTE PROCEDURE log_last_name_changes();
  
-- Populating the table employees for demo  

INSERT INTO employees (first_name, last_name)
VALUES ('Meet', 'Savsani');

INSERT INTO employees (first_name, last_name)
VALUES ('Umesh', 'Rathod');


-- updating the data in employees

UPDATE employees
SET last_name = 'Zalaria'
WHERE ID = 2;

SELECT * FROM employees;
1	"Meet"	"Savsani"
2	"Umesh"	"Zalaria"

SELECT * FROM employee_audits;
1	2	"Rathod"	"2021-12-15 18:21:33.360856"
