USE test_cs;
DROP TABLE IF EXISTS test_script_foreach;
CREATE TABLE test_script_foreach (tbl VARCHAR(64) CHARSET ascii, scm VARCHAR(64) CHARSET ascii, engine VARCHAR(64) CHARSET ascii, create_options VARCHAR(1024) CHARSET ascii);

DROP DATABASE IF EXISTS test_cs_script_foreach_00;
CREATE DATABASE test_cs_script_foreach_00;
USE test_cs_script_foreach_00;
CREATE TABLE test_script_foreach_table_0a (id INT) ENGINE=InnoDB;
CREATE TABLE test_script_foreach_table_0b (id INT) ENGINE=MyISAM;

DROP DATABASE IF EXISTS test_cs_script_foreach_01;
CREATE DATABASE test_cs_script_foreach_01;
USE test_cs_script_foreach_01;
CREATE TABLE test_script_foreach_table_0c (id INT) ENGINE=MEMORY;
CREATE TABLE test_script_foreach_table_0d (id INT) ENGINE=InnoDB;
CREATE VIEW  test_script_foreach_0e AS SELECT * FROM  test_script_foreach_table_0d;

