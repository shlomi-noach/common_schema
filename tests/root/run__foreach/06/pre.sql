USE test_cs;
DROP TABLE IF EXISTS test_script_foreach;
CREATE TABLE test_script_foreach (tbl VARCHAR(64) CHARSET ascii, scm VARCHAR(64) CHARSET ascii, engine VARCHAR(64) CHARSET ascii, create_options VARCHAR(1024) CHARSET ascii);

DROP DATABASE IF EXISTS test_cs_script_foreach;
CREATE DATABASE test_cs_script_foreach;
USE test_cs_script_foreach;
CREATE TABLE test_script_foreach_00 (id INT) ENGINE=InnoDB;
CREATE TABLE test_script_foreach_01 (id INT) ENGINE=InnoDB;
CREATE TABLE test_script_foreach_02 (id INT) ENGINE=InnoDB;
CREATE TABLE test_script_foreach_03 (id INT) ENGINE=MyISAM;
CREATE VIEW  test_script_foreach_04 AS SELECT * FROM test_script_foreach_03;

