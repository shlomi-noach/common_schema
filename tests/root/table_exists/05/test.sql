CREATE TABLE test_cs.existing_table (id int) engine=MyISAM;
SELECT 
  table_exists('test_cs', 'existing_table')
;

