USE test_cs;
DROP TABLE IF EXISTS test_foreach;
CREATE TABLE test_foreach (name VARCHAR(64) CHARSET ascii);

DROP DATABASE IF EXISTS test_cs_foreach;
CREATE DATABASE test_cs_foreach;
USE test_cs_foreach;
CREATE TABLE test_foreach_00 (id INT);
CREATE TABLE test_foreach_01 (id INT);
CREATE TABLE test_foreach_02 (id INT);
CREATE TABLE test_foreach_03 (id INT);
CREATE VIEW  test_foreach_04 AS SELECT * FROM  test_foreach_03;
