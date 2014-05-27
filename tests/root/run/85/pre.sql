USE test_cs;
DROP TABLE IF EXISTS test_script_expansion;
CREATE TABLE test_script_expansion (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(10) CHARSET ascii);
INSERT INTO test_script_expansion VALUES (1, 'first');
INSERT INTO test_script_expansion VALUES (2, 'second');
INSERT INTO test_script_expansion VALUES (3, 'third');


