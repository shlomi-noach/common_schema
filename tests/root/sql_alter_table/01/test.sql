SELECT 
  LOWER(table_options) = LOWER('ENGINE=MyISAM row_format=DYNAMIC')
FROM 
  sql_alter_table 
WHERE 
  table_schema='test_cs' 
  AND table_name='test_sql_alter_table'
;
