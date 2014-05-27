SELECT 
  sql_add_next_partition 
FROM 
  sql_range_partitions 
WHERE 
  table_name='test_sql_range_partitions_quarter_no_maxvalue'
;
