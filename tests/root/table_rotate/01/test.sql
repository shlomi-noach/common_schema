call table_rotate('test_cs', 'test_table_rotate', 3);
SELECT 
  table_exists('test_cs', 'test_table_rotate') 
  and
  table_exists('test_cs', 'test_table_rotate__1') 
;

