USE test_cs;
DROP TABLE IF EXISTS test_run;
CREATE TABLE test_run (
  id INT UNSIGNED NOT NULL, 
  value VARCHAR(64),
  PRIMARY KEY (id)
);
INSERT INTO test_run VALUES (1, 'first');

