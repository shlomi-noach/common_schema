USE test_cs;
DROP TABLE IF EXISTS test_repeat_exec;
CREATE TABLE test_repeat_exec (id INT UNSIGNED, name VARCHAR(10) CHARSET ascii);
INSERT INTO test_repeat_exec VALUES (7, 'first');
INSERT INTO test_repeat_exec VALUES (8, 'second');
INSERT INTO test_repeat_exec VALUES (9, 'third');
