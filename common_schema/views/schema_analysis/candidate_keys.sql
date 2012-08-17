-- 
-- Unique keys: listing of all unique keys aith aggregated column names and additional data
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _unique_keys AS
  SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    INDEX_NAME,
    COUNT(*) AS COUNT_COLUMN_IN_INDEX,
    IF(SUM(NULLABLE = 'YES') > 0, 1, 0) AS has_nullable,
    IF(INDEX_NAME = 'PRIMARY', 1, 0) AS is_primary,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX ASC) AS COLUMN_NAMES,
    SUBSTRING_INDEX(GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX ASC), ',', 1) AS FIRST_COLUMN_NAME
  FROM INFORMATION_SCHEMA.STATISTICS
  WHERE NON_UNIQUE=0
  GROUP BY TABLE_SCHEMA, TABLE_NAME, INDEX_NAME
;

-- 
-- Candidate keys: listing of prioritized candidate keys: keys which are UNIQUE, by order of best-use. 
-- 

CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW candidate_keys AS
SELECT
  COLUMNS.TABLE_SCHEMA AS table_schema,
  COLUMNS.TABLE_NAME AS table_name,
  _unique_keys.INDEX_NAME AS index_name,
  _unique_keys.has_nullable AS has_nullable,
  _unique_keys.is_primary AS is_primary,
  _unique_keys.COLUMN_NAMES AS column_names,
  _unique_keys.COUNT_COLUMN_IN_INDEX AS count_column_in_index,
  COLUMNS.DATA_TYPE AS data_type,
  COLUMNS.CHARACTER_SET_NAME AS character_set_name,
  (CASE IFNULL(CHARACTER_SET_NAME, '')
      WHEN '' THEN 0
      ELSE 1
  END << 20
  )
  + (CASE LOWER(DATA_TYPE)
    WHEN 'tinyint' THEN 0
    WHEN 'smallint' THEN 1
    WHEN 'int' THEN 2
    WHEN 'timestamp' THEN 3
    WHEN 'bigint' THEN 4
    WHEN 'datetime' THEN 5
    ELSE 9
  END << 16
  ) + (COUNT_COLUMN_IN_INDEX << 0
  ) AS candidate_key_rank_in_table  
FROM 
  INFORMATION_SCHEMA.COLUMNS 
  INNER JOIN _unique_keys ON (
    COLUMNS.TABLE_SCHEMA = _unique_keys.TABLE_SCHEMA AND
    COLUMNS.TABLE_NAME = _unique_keys.TABLE_NAME AND
    COLUMNS.COLUMN_NAME = _unique_keys.FIRST_COLUMN_NAME
  )
ORDER BY   
  COLUMNS.TABLE_SCHEMA, COLUMNS.TABLE_NAME, candidate_key_rank_in_table
;


-- 
-- Candidate keys: listing of prioritized candidate keys: keys which are UNIQUE, by order of best-use. 
-- 

CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW candidate_keys_recommended AS
SELECT
  table_schema,
  table_name,
  SUBSTRING_INDEX(GROUP_CONCAT(index_name ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS recommended_index_name,
  CAST(SUBSTRING_INDEX(GROUP_CONCAT(has_nullable ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS UNSIGNED INTEGER) AS has_nullable,
  CAST(SUBSTRING_INDEX(GROUP_CONCAT(is_primary ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS UNSIGNED INTEGER) AS is_primary,
  CAST(SUBSTRING_INDEX(GROUP_CONCAT(count_column_in_index ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS UNSIGNED INTEGER) AS count_column_in_index,
  SUBSTRING_INDEX(GROUP_CONCAT(column_names ORDER BY candidate_key_rank_in_table ASC SEPARATOR '\n'), '\n', 1) AS column_names
FROM 
  candidate_keys
GROUP BY
  table_schema, table_name
ORDER BY   
  table_schema, table_name
;
