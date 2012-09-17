USE test_cs;
DROP TABLE IF EXISTS test_script_foreach;
CREATE TABLE test_script_foreach (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(10) CHARSET ascii);
INSERT INTO test_script_foreach VALUES (1, 'first');
INSERT INTO test_script_foreach VALUES (2, 'second');
INSERT INTO test_script_foreach VALUES (3, 'third');

ALTER TABLE test_script_foreach ADD COLUMN extra VARCHAR(10) CHARSET ascii;

