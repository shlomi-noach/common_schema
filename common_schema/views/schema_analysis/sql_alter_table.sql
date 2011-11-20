-- 
-- Generate ALTER TABLE statements per table, with engine and create options
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW sql_alter_table AS
  SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    ENGINE,
    CONCAT(
      'ALTER TABLE `', TABLE_SCHEMA, '`.`', TABLE_NAME, 
      '` ENGINE=', ENGINE, ' ',
      IF(CREATE_OPTIONS='partitioned', '', CREATE_OPTIONS)
    ) AS alter_statement
  FROM 
    INFORMATION_SCHEMA.TABLES
  WHERE
    TABLE_SCHEMA NOT IN ('mysql', 'INFORMATION_SCHEMA', 'performance_schema')
    AND ENGINE IS NOT NULL
;

