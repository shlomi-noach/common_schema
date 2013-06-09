-- 
-- Generate ALTER TABLE statements per table, with keys, engine and create options
-- 


CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _sql_table_keys AS
  SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    INDEX_NAME,
    CONCAT(
      IF(MIN(NON_UNIQUE) = 0, IF(INDEX_NAME='PRIMARY', 'PRIMARY ', 'UNIQUE '), ''),
      'KEY ', 
      IF(INDEX_NAME='PRIMARY', '', mysql_qualify(INDEX_NAME)), '(',
        GROUP_CONCAT(
          mysql_qualify(COLUMN_NAME),
          IFNULL(
            CONCAT('(', SUB_PART,')'),
            ''
            )
          ORDER BY SEQ_IN_INDEX
        ),
      ')'
      ) as sql_index_definition
  FROM 
    INFORMATION_SCHEMA.STATISTICS
  WHERE
    TABLE_SCHEMA NOT IN ('mysql', 'INFORMATION_SCHEMA', 'performance_schema')
  GROUP BY
    TABLE_SCHEMA, TABLE_NAME, INDEX_NAME
;


CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW sql_table_keys AS
  SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    INDEX_NAME,
    IF(
      INDEX_NAME='PRIMARY',
      'DROP PRIMARY KEY',
      CONCAT('DROP KEY ', mysql_qualify(INDEX_NAME))
    ) as sql_drop_key,
    CONCAT('ADD ', sql_index_definition) as sql_add_key
  FROM 
    _sql_table_keys
;



CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW sql_alter_table AS
  SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    ENGINE,
    GROUP_CONCAT(sql_drop_key SEPARATOR ', ' ORDER BY INDEX_NAME) AS sql_drop_keys,
    GROUP_CONCAT(sql_add_key  SEPARATOR ', ' ORDER BY INDEX_NAME) AS sql_add_keys,
    CONCAT(
      'ENGINE=', ENGINE, ' ',
      IF(CREATE_OPTIONS='partitioned', '', CREATE_OPTIONS)
    ) AS table_options,
    CONCAT(
      'ALTER TABLE ', mysql_qualify(TABLE_SCHEMA), '.', mysql_qualify(TABLE_NAME), 
      ' ENGINE=', ENGINE, ' ',
      IF(CREATE_OPTIONS='partitioned', '', CREATE_OPTIONS)
    ) AS alter_statement
  FROM 
    INFORMATION_SCHEMA.TABLES
    JOIN sql_table_keys USING (TABLE_SCHEMA, TABLE_NAME)
  WHERE
    TABLE_SCHEMA NOT IN ('mysql', 'INFORMATION_SCHEMA', 'performance_schema')
    AND ENGINE IS NOT NULL
  GROUP BY
    TABLE_SCHEMA, TABLE_NAME, ENGINE, CREATE_OPTIONS
;

