
set @script := "
foreach ($i: 1:4) {
  eval SELECT 
      sql_add_next_partition 
    FROM 
      sql_range_partitions 
    WHERE 
      table_name='test_sql_range_partitions_weekly'
}";

SELECT 
  sql_add_next_partition 
FROM 
  sql_range_partitions 
WHERE 
  table_name='test_sql_range_partitions_weekly'
;
