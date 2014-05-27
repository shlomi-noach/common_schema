-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_generate_dependency_tables $$
CREATE PROCEDURE _split_generate_dependency_tables(split_table_schema varchar(128), split_table_name varchar(128), requested_index_name varchar(128)) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'analyze recommended keys'

begin
  declare split_column_names varchar(2048) default NULL;
  declare split_num_column tinyint unsigned;
  
  drop temporary table if exists _split_unique_key_columns;
  create temporary table _split_unique_key_columns engine=MyISAM
   SELECT
      TABLE_SCHEMA,
      TABLE_NAME,
      INDEX_NAME,
      COLUMN_NAME,
      SEQ_IN_INDEX,
      (NULLABLE = 'YES') AS has_nullable,
      (INDEX_NAME = 'PRIMARY') AS is_primary
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE
      TABLE_SCHEMA = split_table_schema
      AND TABLE_NAME = split_table_name
      AND NON_UNIQUE=0
  ;
  
  drop temporary table if exists _split_i_s_columns;
  create temporary table _split_i_s_columns engine=MyISAM
   SELECT
      TABLE_SCHEMA,
      TABLE_NAME,
      COLUMN_NAME,
      CASE LOWER(DATA_TYPE)
          WHEN 'tinyint' THEN 1
          WHEN 'smallint' THEN 2
          WHEN 'mediumint' THEN 4
          WHEN 'int' THEN 4
          WHEN 'bigint' THEN 8
          WHEN 'timestamp' THEN 4
          WHEN 'time' THEN 4
          WHEN 'date' THEN 4
          WHEN 'datetime' THEN 8
          WHEN 'float' THEN 4
          WHEN 'double' THEN 8
          WHEN 'decimal' THEN CEILING(NUMERIC_PRECISION/2)
          WHEN 'bit' THEN CEILING(NUMERIC_PRECISION/8)
          WHEN 'set' THEN 8
          WHEN 'enum' THEN 8
          WHEN 'year' THEN 2
          WHEN 'char' THEN CHARACTER_OCTET_LENGTH
          WHEN 'varchar' THEN CHARACTER_OCTET_LENGTH
          WHEN 'binary' THEN CHARACTER_OCTET_LENGTH
          WHEN 'varbinary' THEN CHARACTER_OCTET_LENGTH
          WHEN 'tinytext' THEN CHARACTER_OCTET_LENGTH
          WHEN 'text' THEN CHARACTER_OCTET_LENGTH
          WHEN 'mediumtext' THEN CHARACTER_OCTET_LENGTH
          WHEN 'longtext' THEN CHARACTER_OCTET_LENGTH
          WHEN 'tinyblob' THEN CHARACTER_OCTET_LENGTH
          WHEN 'blob' THEN CHARACTER_OCTET_LENGTH
          WHEN 'mediumblob' THEN CHARACTER_OCTET_LENGTH
          WHEN 'longblob' THEN CHARACTER_OCTET_LENGTH
          ELSE 255
        END AS column_type_length
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      TABLE_SCHEMA = split_table_schema
      AND TABLE_NAME = split_table_name
  ;
  
  drop temporary table if exists _split_candidate_keys;
  create temporary table _split_candidate_keys engine=MyISAM
   SELECT
      TABLE_SCHEMA,
      TABLE_NAME,
      INDEX_NAME,
      MAX(has_nullable) AS has_nullable,
      MAX(is_primary) AS is_primary,
      COUNT(*) AS count_column_in_index,
      GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX ASC) AS COLUMN_NAMES,
      SUM(column_type_length) AS covered_columns_length
    FROM 
      _split_unique_key_columns
      JOIN _split_i_s_columns USING(TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME)
    GROUP BY TABLE_SCHEMA, TABLE_NAME, INDEX_NAME
  ;

  drop temporary table if exists _split_candidate_keys_recommended;
  create temporary table _split_candidate_keys_recommended engine=MyISAM
    SELECT
      *
    FROM 
      _split_candidate_keys
    ORDER BY   
      (INDEX_NAME = requested_index_name) IS TRUE DESC,
      has_nullable ASC, covered_columns_length ASC, is_primary DESC
    LIMIT 1
  ;
  
end $$

DELIMITER ;
