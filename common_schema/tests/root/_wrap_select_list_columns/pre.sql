USE test_cs;
DROP TABLE IF EXISTS test__wrap_select_list_columns;
CREATE TABLE test__wrap_select_list_columns (
  id INT UNSIGNED, 
  name VARCHAR(10) CHARSET ascii,
  rank INT UNSIGNED
);
INSERT INTO test__wrap_select_list_columns VALUES (1, 'wallace', 2);
INSERT INTO test__wrap_select_list_columns VALUES (2, 'gromit', 1);
INSERT INTO test__wrap_select_list_columns VALUES (3, 'penguin', 1);
INSERT INTO test__wrap_select_list_columns VALUES (4, 'preston', 3);
INSERT INTO test__wrap_select_list_columns VALUES (5, 'shaun', 4);
INSERT INTO test__wrap_select_list_columns VALUES (6, 'fluffy', 4);
