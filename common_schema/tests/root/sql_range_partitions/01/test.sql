SELECT 
  sql_drop_first_partition
FROM 
  sql_range_partitions 
WHERE 
  table_name='test_sql_range_partitions_quarter_maxvalue'
;
