SELECT 
  has_maxvalue = 1
FROM 
  sql_range_partitions 
WHERE 
  table_name='test_sql_range_partitions_quarter_maxvalue'
;
