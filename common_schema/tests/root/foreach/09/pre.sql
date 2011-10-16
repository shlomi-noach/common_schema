USE test_cs;
DROP TABLE IF EXISTS test_foreach;
CREATE TABLE test_foreach (name VARCHAR(64) CHARSET ascii);

DROP DATABASE IF EXISTS test_cs_foreach_00;
CREATE DATABASE test_cs_foreach_00;
USE test_cs_foreach_00;
CREATE TABLE test_foreach_table_0a (id INT);
CREATE TABLE test_foreach_table_0b (id INT);

DROP DATABASE IF EXISTS test_cs_foreach_01;
CREATE DATABASE test_cs_foreach_01;
USE test_cs_foreach_01;
CREATE TABLE test_foreach_table_0c (id INT);
CREATE TABLE test_foreach_table_0d (id INT);
CREATE VIEW  test_foreach_0e AS SELECT * FROM  test_foreach_table_0d;
