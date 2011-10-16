USE test_cs;
DROP TABLE IF EXISTS test_foreach;
CREATE TABLE test_foreach (id INT UNSIGNED, name VARCHAR(10) CHARSET ascii);
INSERT INTO test_foreach VALUES (1, 'first');
INSERT INTO test_foreach VALUES (2, 'second');
INSERT INTO test_foreach VALUES (3, 'third');
