USE test_cs;
DROP TABLE IF EXISTS test_eval;
CREATE TABLE test_eval (id INT UNSIGNED, name VARCHAR(10) CHARSET ascii);
INSERT INTO test_eval VALUES (7, 'first');
INSERT INTO test_eval VALUES (8, 'second');
INSERT INTO test_eval VALUES (9, 'third');
