SELECT 
  count_past_partitions = 6 and count_future_partitions = 0
FROM 
  sql_range_partitions 
WHERE 
  table_name='test_sql_range_partitions_quarter_maxvalue'
;
