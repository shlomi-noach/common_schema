call table_rotate('test_cs', 'test_table_rotate', 3);
SELECT 
  max(id) from test_cs.test_table_rotate into @id
  ;
SELECT 
  max(id) from test_cs.test_table_rotate__2 into @id__2
  ;

SELECT
  @id IS NULL and @id__2 = 17
  ;