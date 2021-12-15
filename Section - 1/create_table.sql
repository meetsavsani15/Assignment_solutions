CREATE TABLE students
(
	roll_no INT PRIMARY KEY,
	firstname VARCHAR(50) NOT NULL,
	lastname VARCHAR(50) NOT NULL,
	class_section TEXT NOT NULL 
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







CREATE TABLE

Query returned successfully in 56 msec.
