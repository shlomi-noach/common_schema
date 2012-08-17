-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_generate_dependency_tables $$
CREATE PROCEDURE _split_generate_dependency_tables(split_table_schema varchar(128), split_table_name varchar(128)) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'split values by columns...'

begin
  declare split_column_names varchar(2048) default NULL;
  declare split_num_column tinyint unsigned;
  
  drop temporary table if exists _split_unique_keys;
  create temporary table _split_unique_keys
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
    WHERE
      TABLE_SCHEMA = split_table_schema
      AND TABLE_NAME = split_table_name
      AND NON_UNIQUE=0
    GROUP BY TABLE_SCHEMA, TABLE_NAME, INDEX_NAME
  ;
  
  drop temporary table if exists _split_i_s_columns;
  create temporary table _split_i_s_columns
   SELECT
      TABLE_SCHEMA,
      TABLE_NAME,
      COLUMN_NAME,
      DATA_TYPE,
      CHARACTER_SET_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      TABLE_SCHEMA = split_table_schema
      AND TABLE_NAME = split_table_name
  ;
  
  drop temporary table if exists _split_candidate_keys;
  create temporary table _split_candidate_keys
    SELECT
      _split_i_s_columns.TABLE_SCHEMA AS table_schema,
      _split_i_s_columns.TABLE_NAME AS table_name,
      _split_unique_keys.INDEX_NAME AS index_name,
      _split_unique_keys.has_nullable AS has_nullable,
      _split_unique_keys.is_primary AS is_primary,
      _split_unique_keys.COLUMN_NAMES AS column_names,
      _split_unique_keys.COUNT_COLUMN_IN_INDEX AS count_column_in_index,
      _split_i_s_columns.DATA_TYPE AS data_type,
      _split_i_s_columns.CHARACTER_SET_NAME AS character_set_name,
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
      _split_i_s_columns
      INNER JOIN _split_unique_keys ON (
        _split_i_s_columns.TABLE_SCHEMA = _split_unique_keys.TABLE_SCHEMA AND
        _split_i_s_columns.TABLE_NAME = _split_unique_keys.TABLE_NAME AND
        _split_i_s_columns.COLUMN_NAME = _split_unique_keys.FIRST_COLUMN_NAME
      )
    ORDER BY   
      _split_i_s_columns.TABLE_SCHEMA, _split_i_s_columns.TABLE_NAME, candidate_key_rank_in_table
  ;
  
  drop temporary table if exists _split_candidate_keys_recommended;
  create temporary table _split_candidate_keys_recommended
    SELECT
      table_schema,
      table_name,	
      SUBSTRING_INDEX(GROUP_CONCAT(index_name ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS recommended_index_name,
      CAST(SUBSTRING_INDEX(GROUP_CONCAT(has_nullable ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS UNSIGNED INTEGER) AS has_nullable,
      CAST(SUBSTRING_INDEX(GROUP_CONCAT(is_primary ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS UNSIGNED INTEGER) AS is_primary,
      CAST(SUBSTRING_INDEX(GROUP_CONCAT(count_column_in_index ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS UNSIGNED INTEGER) AS count_column_in_index,
      SUBSTRING_INDEX(GROUP_CONCAT(column_names ORDER BY candidate_key_rank_in_table ASC SEPARATOR '\n'), '\n', 1) AS column_names
    FROM 
      _split_candidate_keys
    GROUP BY
      table_schema, table_name
    ORDER BY   
      table_schema, table_name
    ;
  
end $$

DELIMITER ;
