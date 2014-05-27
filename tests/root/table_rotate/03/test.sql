call table_rotate('test_cs', 'test_table_rotate', 3);
call table_rotate('test_cs', 'test_table_rotate', 3);
call table_rotate('test_cs', 'test_table_rotate', 3);
SELECT 
  table_exists('test_cs', 'test_table_rotate__3') 
  and
  not table_exists('test_cs', 'test_table_rotate__4') 
;
