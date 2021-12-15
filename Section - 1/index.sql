/*
	DEMONSTRATION OF TRIGGERS
	ref: https://www.postgresqltutorial.com/postgresql-indexes/postgresql-create-index/
*/ 

EXPLAIN ANALYZE SELECT * from marks
WHERE roll_no = 10521;

"Seq Scan on marks  (cost=0.00..1.12 rows=1 width=24) (actual time=0.010..0.011 rows=1 loops=1)"
"  Filter: (roll_no = 10521)"
"  Rows Removed by Filter: 9"
"Planning Time: 0.122 ms"
"Execution Time: 0.028 ms"



CREATE INDEX idx_marks
ON marks(roll_no);




EXPLAIN ANALYZE SELECT * from marks
WHERE roll_no = 10521;

"Seq Scan on marks  (cost=0.00..1.12 rows=1 width=24) (actual time=0.010..0.011 rows=1 loops=1)"
"  Filter: (roll_no = 10521)"
"  Rows Removed by Filter: 9"
"Planning Time: 0.062 ms"
"Execution Time: 0.024 ms"
