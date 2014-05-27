call eval("
  SELECT 
    sql_add_next_partition 
  FROM 
    sql_range_partitions 
  WHERE 
    table_name='tmp_test_sql_range_partitions_quarter_maxvalue'
");

SELECT 
  sql_add_next_partition 
FROM 
  sql_range_partitions 
WHERE 
  table_name='tmp_test_sql_range_partitions_quarter_maxvalue'
;
