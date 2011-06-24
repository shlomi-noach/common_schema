--
-- common_schema: utility schema, views, tables & routines for MySQL
--
-- Released under the BSD license
--
-- Copyright (c) 2011, Shlomi Noach
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
--
--     * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
--     * Neither the name of the organization nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--

--
-- Generate schema
--

CREATE DATABASE IF NOT EXISTS common_schema;

USE common_schema;
-- 
-- Utility table: unsigned integers, [0..4095]
-- 
DROP TABLE IF EXISTS numbers;

CREATE TABLE numbers (
  `n` smallint unsigned NOT NULL,
  PRIMARY KEY (`n`)
)
;

--
-- Populate numbers table, values range [0...4095]
--
INSERT IGNORE
  INTO numbers (n)
SELECT
  @counter := @counter+1 AS counter 
FROM
  (
    SELECT 
      NULL
    FROM
      INFORMATION_SCHEMA.SESSION_VARIABLES
    LIMIT 64
  ) AS select1,
  (
    SELECT 
      NULL
    FROM
      INFORMATION_SCHEMA.SESSION_VARIABLES
    LIMIT 64
  ) AS select2,
  (
    SELECT 
      @counter := -1
    FROM
      DUAL
  ) AS select_counter
;
-- 
-- Return a 64 bit CRC of given input, as unsigned big integer.
-- 
-- This code is based on the idea presented in the book
-- High Performance MySQL, 2nd Edition, By Baron Schwartz et al., published by O'REILLY
-- 
-- Example:
--
-- SELECT crc64('mysql');
-- Returns: 9350511318824990686
--

DELIMITER $$

DROP FUNCTION IF EXISTS crc64 $$
CREATE FUNCTION crc64(data LONGTEXT CHARSET utf8) RETURNS BIGINT UNSIGNED 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return a 64 bit CRC of given input, as unsigned big integer'

BEGIN
  RETURN CONV(LEFT(MD5(data), 16), 16, 10);
END $$

DELIMITER ;
-- 
-- Return number of tokens in delimited text
-- txt: input string
-- delimiter: char or text by which to split txt
--
-- example:
--
-- SELECT get_num_tokens('the quick brown fox', ' ') AS num_token;
-- Returns: 4
-- 
DELIMITER $$

DROP FUNCTION IF EXISTS get_num_tokens $$
CREATE FUNCTION get_num_tokens(txt TEXT CHARSET utf8, delimiter VARCHAR(255) CHARSET utf8) RETURNS INT UNSIGNED 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return number of tokens in delimited text'

BEGIN
  RETURN CHAR_LENGTH(txt) - CHAR_LENGTH(REPLACE(txt, delimiter, '')) + 1;
END $$

DELIMITER ;
-- 
-- Return a qualified MySQL name (e.g. database name, table name, column name, ...) from given text.
-- 
-- Can be used for dynamic query generation by INFORMATION_SCHEMA, where names are unqualified.
--
-- Example:
--
-- SELECT mysql_qualify('film_actor') AS qualified;
-- Returns: '`film_actor`'
-- 
DELIMITER $$

DROP FUNCTION IF EXISTS mysql_qualify $$
CREATE FUNCTION mysql_qualify(name TINYTEXT CHARSET utf8) RETURNS TINYTEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return a qualified MySQL name from given text'

BEGIN
  RETURN CONCAT('`', name, '`');
END $$

DELIMITER ;
-- 
-- Return substring by index in delimited text
-- txt: input string
-- delimiter: char or text by which to split txt
-- token_index: 1-based index of token in split string
--
-- example:
--
-- SELECT split_token('the quick brown fox', ' ', 3) AS token;
-- Returns: 'brown'
-- 
DELIMITER $$

DROP FUNCTION IF EXISTS split_token $$
CREATE FUNCTION split_token(txt TEXT CHARSET utf8, delimiter VARCHAR(255) CHARSET utf8, token_index INT UNSIGNED) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return substring by index in delimited text'

BEGIN
  RETURN SUBSTRING_INDEX(SUBSTRING_INDEX(txt, delimiter, token_index), delimiter, -1);
END $$

DELIMITER ;
-- 
-- Returns DATETIME of beginning of round hour of given DATETIME.
-- 
-- Example:
--
-- SELECT start_of_hour('2011-03-24 11:17:08');
-- Returns: '2011-03-24 11:00:00' (as DATETIME)
--

DELIMITER $$

DROP FUNCTION IF EXISTS start_of_hour $$
CREATE FUNCTION start_of_hour(dt DATETIME) RETURNS DATETIME
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns DATETIME of beginning of round hour of given DATETIME.'

BEGIN
  RETURN dt - INTERVAL MINUTE(dt) MINUTE - INTERVAL SECOND(dt) SECOND;
END $$

DELIMITER ;
-- 
-- Returns first day of month of given datetime, as DATE object
-- 
-- Example:
--
-- SELECT start_of_month('2011-03-24 11:13:42');
-- Returns: '2011-03-01' (as DATE)
--

DELIMITER $$

DROP FUNCTION IF EXISTS start_of_month $$
CREATE FUNCTION start_of_month(dt DATETIME) RETURNS DATE 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns first day of month of given datetime, as DATE object'

BEGIN
  RETURN DATE(dt) - INTERVAL (DAYOFMONTH(dt) - 1) DAY;
END $$

DELIMITER ;
-- 
-- Returns first day of year of given datetime, as DATE object
-- 
-- Example:
--
-- SELECT start_of_year('2011-03-24 11:13:42');
-- Returns: '2011-01-01' (as DATE)
--

DELIMITER $$

DROP FUNCTION IF EXISTS start_of_year $$
CREATE FUNCTION start_of_year(dt DATETIME) RETURNS DATE 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns first day of month of given datetime, as DATE object'

BEGIN
  RETURN DATE(dt) - INTERVAL (MONTH(dt) -1) MONTH - INTERVAL (DAYOFMONTH(dt) - 1) DAY;
END $$

DELIMITER ;
-- 
-- Returns first day of week of given datetime (i.e. start of Monday), as DATE object
-- 
-- Example:
--
-- SELECT start_of_week('2011-03-24 11:13:42');
-- Returns: '2011-03-21' (which is Monday, as DATE)
--

DELIMITER $$

DROP FUNCTION IF EXISTS start_of_week $$
CREATE FUNCTION start_of_week(dt DATETIME) RETURNS DATE 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns Monday-based first day of week of given datetime'

BEGIN
  RETURN DATE(dt) - INTERVAL WEEKDAY(dt) DAY;
END $$

DELIMITER ;
-- 
-- Returns first day of week, Sunday based, of given datetime, as DATE object
-- 
-- Example:
--
-- SELECT start_of_week_sunday('2011-03-24 11:13:42');
-- Returns: '2011-03-20' (which is Sunday, as DATE)
--

DELIMITER $$

DROP FUNCTION IF EXISTS start_of_week_sunday $$
CREATE FUNCTION start_of_week_sunday(dt DATETIME) RETURNS DATE 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns Sunday-based first day of week of given datetime'

BEGIN
  RETURN DATE(dt) - INTERVAL (WEEKDAY(dt) + 1) DAY;
END $$

DELIMITER ;


-- 
-- Returns first day of quarter of given datetime, as DATE object
-- 
-- Example:
--
-- SELECT start_of_quarter('2010-08-24 11:13:42');
-- Returns: '2010-07-01' (as DATE)
--

DELIMITER $$

DROP FUNCTION IF EXISTS start_of_quarter $$
CREATE FUNCTION start_of_quarter(dt DATETIME) RETURNS DATE 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns first day of quarter of given datetime, as DATE object'

BEGIN
  RETURN DATE(dt) - INTERVAL (MONTH(dt) -1) MONTH - INTERVAL (DAYOFMONTH(dt) - 1) DAY + INTERVAL (QUARTER(dt) - 1) QUARTER;
END $$

DELIMITER ;
-- 
-- Tables' charsets and collations
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW table_charset AS
  SELECT 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    CHARACTER_SET_NAME, 
    TABLE_COLLATION
  FROM 
    INFORMATION_SCHEMA.TABLES
    INNER JOIN INFORMATION_SCHEMA.COLLATION_CHARACTER_SET_APPLICABILITY 
      ON (TABLES.TABLE_COLLATION = COLLATION_CHARACTER_SET_APPLICABILITY.COLLATION_NAME)
  WHERE 
    TABLE_SCHEMA NOT IN ('mysql', 'INFORMATION_SCHEMA', 'performance_schema')
;
-- 
-- Textual columns charsets & collations
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW text_columns AS
  SELECT 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    COLUMN_NAME, 
    COLUMN_TYPE,
    CHARACTER_SET_NAME, 
    COLLATION_NAME
  FROM 
    INFORMATION_SCHEMA.COLUMNS
  WHERE 
    TABLE_SCHEMA NOT IN ('mysql', 'INFORMATION_SCHEMA', 'performance_schema')
    AND CHARACTER_SET_NAME IS NOT NULL
    AND DATA_TYPE != 'enum'
;
-- 
-- AUTO_INCREMENT columns and their capacity
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW auto_increment_columns AS
  SELECT 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE,
    COLUMN_TYPE,
    IF(
      LOCATE('unsigned', COLUMN_TYPE) > 0,
      1,
      0
    ) AS IS_UNSIGNED,
    (
      CASE DATA_TYPE
        WHEN 'tinyint' THEN 255
        WHEN 'smallint' THEN 65535
        WHEN 'mediumint' THEN 16777215
        WHEN 'int' THEN 4294967295
        WHEN 'bigint' THEN 18446744073709551615
      END >> IF(LOCATE('unsigned', COLUMN_TYPE) > 0, 0, 1)
    ) AS MAX_VALUE,
    AUTO_INCREMENT,
    AUTO_INCREMENT / (
      CASE DATA_TYPE
        WHEN 'tinyint' THEN 255
        WHEN 'smallint' THEN 65535
        WHEN 'mediumint' THEN 16777215
        WHEN 'int' THEN 4294967295
        WHEN 'bigint' THEN 18446744073709551615
      END >> IF(LOCATE('unsigned', COLUMN_TYPE) > 0, 0, 1)
    ) AS AUTO_INCREMENT_RATIO
  FROM 
    INFORMATION_SCHEMA.COLUMNS
    INNER JOIN INFORMATION_SCHEMA.TABLES USING (TABLE_SCHEMA, TABLE_NAME)
  WHERE 
    TABLE_SCHEMA NOT IN ('mysql', 'INFORMATION_SCHEMA', 'performance_schema')
    AND EXTRA='auto_increment'
;
-- 
-- Dataset size per engine
-- 
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW data_size_per_engine AS
  SELECT 
    ENGINE, 
    COUNT(*) AS count_tables,
    SUM(DATA_LENGTH) AS data_size,
    SUM(INDEX_LENGTH) AS index_size,
    SUM(DATA_LENGTH+INDEX_LENGTH) AS total_size,
    SUBSTRING_INDEX(GROUP_CONCAT(CONCAT(TABLE_SCHEMA, '.', TABLE_NAME) ORDER BY DATA_LENGTH+INDEX_LENGTH DESC), ',', 1) AS largest_table,
    MAX(DATA_LENGTH+INDEX_LENGTH) AS largest_table_size
  FROM 
    INFORMATION_SCHEMA.TABLES
  WHERE 
    TABLE_SCHEMA NOT IN ('mysql', 'INFORMATION_SCHEMA', 'performance_schema')
    AND ENGINE IS NOT NULL
  GROUP BY 
    ENGINE
;
-- 
-- Dataset size per schema
-- 
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW data_size_per_schema AS
  SELECT 
    TABLE_SCHEMA, 
    SUM(TABLE_TYPE = 'BASE TABLE') AS count_tables,
    SUM(TABLE_TYPE = 'VIEW') AS count_views,
    COUNT(DISTINCT ENGINE) AS distinct_engines,
    SUM(DATA_LENGTH) AS data_size,
    SUM(INDEX_LENGTH) AS index_size,
    SUM(DATA_LENGTH+INDEX_LENGTH) AS total_size,
    SUBSTRING_INDEX(GROUP_CONCAT(IF(TABLE_TYPE = 'BASE TABLE', TABLE_NAME, NULL) ORDER BY DATA_LENGTH+INDEX_LENGTH DESC), ',', 1) AS largest_table,
    MAX(DATA_LENGTH+INDEX_LENGTH) AS largest_table_size
  FROM 
    INFORMATION_SCHEMA.TABLES
  WHERE 
    TABLE_SCHEMA NOT IN ('mysql', 'INFORMATION_SCHEMA', 'performance_schema')
  GROUP BY 
    TABLE_SCHEMA
;
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

-- 
-- Generate 'ALTER TABLE ... ADD CONSTRAINT ... FOREIGN KEY ... / DROP FOREIGN KEY' statement pairs
-- 
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW sql_foreign_keys AS
  SELECT 
    KEY_COLUMN_USAGE.TABLE_SCHEMA,
    KEY_COLUMN_USAGE.TABLE_NAME,
    KEY_COLUMN_USAGE.CONSTRAINT_NAME,
    CONCAT(
      'ALTER TABLE `', KEY_COLUMN_USAGE.TABLE_SCHEMA, '`.`', KEY_COLUMN_USAGE.TABLE_NAME, 
      '` DROP FOREIGN KEY `', KEY_COLUMN_USAGE.CONSTRAINT_NAME, '`'
    ) AS drop_statement,
    CONCAT(
      'ALTER TABLE `', KEY_COLUMN_USAGE.TABLE_SCHEMA, '`.`', KEY_COLUMN_USAGE.TABLE_NAME, 
      '` ADD CONSTRAINT `', KEY_COLUMN_USAGE.CONSTRAINT_NAME, 
      '` FOREIGN KEY (', GROUP_CONCAT(CONCAT('`', KEY_COLUMN_USAGE.COLUMN_NAME, '`')), ')', 
      ' REFERENCES `', KEY_COLUMN_USAGE.REFERENCED_TABLE_SCHEMA, '`.`', KEY_COLUMN_USAGE.REFERENCED_TABLE_NAME, 
      '` (', GROUP_CONCAT(CONCAT('`', KEY_COLUMN_USAGE.REFERENCED_COLUMN_NAME, '`')), ')',
      ' ON DELETE ', REFERENTIAL_CONSTRAINTS.DELETE_RULE, 
      ' ON UPDATE ', REFERENTIAL_CONSTRAINTS.UPDATE_RULE
    ) AS create_statement
  FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
    INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS USING(CONSTRAINT_SCHEMA, CONSTRAINT_NAME)
  WHERE 
    KEY_COLUMN_USAGE.REFERENCED_TABLE_SCHEMA IS NOT NULL
  GROUP BY
    KEY_COLUMN_USAGE.TABLE_SCHEMA, KEY_COLUMN_USAGE.TABLE_NAME, KEY_COLUMN_USAGE.CONSTRAINT_NAME, KEY_COLUMN_USAGE.REFERENCED_TABLE_SCHEMA, KEY_COLUMN_USAGE.REFERENCED_TABLE_NAME
;

-- 
-- InnoDB tables where no PRIMARY KEY is defined
-- 
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW no_pk_innodb_tables AS
  SELECT 
    TABLES.TABLE_SCHEMA,
    TABLES.TABLE_NAME,
    TABLES.ENGINE
  FROM 
    INFORMATION_SCHEMA.TABLES 
    LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS USING(TABLE_SCHEMA, TABLE_NAME)
  WHERE 
    TABLES.ENGINE='InnoDB'
  GROUP BY
    TABLES.TABLE_SCHEMA,
    TABLES.TABLE_NAME
  HAVING
    IFNULL(
      SUM(CONSTRAINT_TYPE='PRIMARY KEY'),
      0
    ) = 0
;

-- 
-- Redundant indexes: indexes which are made redundant (or duplicate) by other (dominant) keys. 
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _flattened_keys AS
  SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    INDEX_NAME,
    MAX(NON_UNIQUE) AS non_unique,
    MAX(IF(SUB_PART IS NULL, 0, 1)) AS subpart_exists,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS index_columns
  FROM `information_schema`.`STATISTICS`
  WHERE
    INDEX_TYPE='BTREE'
    AND TABLE_SCHEMA NOT IN ('mysql', 'INFORMATION_SCHEMA', 'PERFORMANCE_SCHEMA')
  GROUP BY
    TABLE_SCHEMA, TABLE_NAME, INDEX_NAME
;



-- 
-- Redundant indexes: indexes which are made redundant (or duplicate) by other (dominant) keys. 
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW redundant_keys AS
  SELECT
    redundant_keys.table_schema,
    redundant_keys.table_name,
    redundant_keys.index_name AS redundant_index_name,
    redundant_keys.index_columns AS redundant_index_columns,
    redundant_keys.non_unique AS redundant_index_non_unique,
    dominant_keys.index_name AS dominant_index_name,
    dominant_keys.index_columns AS dominant_index_columns,
    dominant_keys.non_unique AS dominant_index_non_unique,
    IF(redundant_keys.subpart_exists OR dominant_keys.subpart_exists, 1 ,0) AS subpart_exists
  FROM
    _flattened_keys AS redundant_keys
    INNER JOIN _flattened_keys AS dominant_keys
    USING (TABLE_SCHEMA, TABLE_NAME)
  WHERE
    redundant_keys.index_name != dominant_keys.index_name
    AND (
      ( 
        /* Identical columns */
        (redundant_keys.index_columns = dominant_keys.index_columns)
        AND (
          (redundant_keys.non_unique > dominant_keys.non_unique)
          OR (redundant_keys.non_unique = dominant_keys.non_unique AND redundant_keys.index_name > dominant_keys.index_name)
        )
      )
      OR
      ( 
        /* Non-unique prefix columns */
        LOCATE(CONCAT(redundant_keys.index_columns, ','), dominant_keys.index_columns) = 1
        AND redundant_keys.non_unique = 1
      )
      OR
      ( 
        /* Unique prefix columns */
        LOCATE(CONCAT(dominant_keys.index_columns, ','), redundant_keys.index_columns) = 1
        AND dominant_keys.non_unique = 0
      )
    )
;
-- 
-- INFORMATION_SCHEMA-like privileges on routines    
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW routine_privileges AS
  SELECT
    CONCAT('\'', User, '\'@\'', Host, '\'') AS GRANTEE,
    NULL AS ROUTINE_CATALOG,
    Db AS ROUTINE_SCHEMA,
    Routine_name AS ROUTINE_NAME,
    Routine_type AS ROUTINE_TYPE,
    UPPER(SUBSTRING_INDEX(SUBSTRING_INDEX(Proc_priv, ',', n+1), ',', -1)) AS PRIVILEGE_TYPE,
    IF(find_in_set('Grant', Proc_priv) > 0, 'YES', 'NO') AS IS_GRANTABLE
  FROM
    mysql.procs_priv
    CROSS JOIN numbers
  WHERE
    numbers.n BETWEEN 0 AND CHAR_LENGTH(Proc_priv) - CHAR_LENGTH(REPLACE(Proc_priv, ',', ''))
    AND UPPER(SUBSTRING_INDEX(SUBSTRING_INDEX(Proc_priv, ',', n+1), ',', -1)) != 'GRANT'
;
-- 
-- (Internal use): privileges set on columns   
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _columns_privileges AS
  SELECT
    GRANTEE,
    TABLE_SCHEMA,
    TABLE_NAME,
    MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
    CONCAT(
      PRIVILEGE_TYPE,
      ' (', GROUP_CONCAT(COLUMN_NAME ORDER BY COLUMN_NAME SEPARATOR ', '), ')'
      ) AS column_privileges    
  FROM
    INFORMATION_SCHEMA.COLUMN_PRIVILEGES
  GROUP BY
    GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE_TYPE
;

-- 
-- (Internal use): GRANTs, account details, privileges details   
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _sql_grants_components AS
  (
    SELECT 
      GRANTEE,
      '*.*' AS priv_level,
      'user' AS priv_level_name,
      'USAGE' AS current_privileges,
      MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
      1 AS result_order
    FROM
      INFORMATION_SCHEMA.USER_PRIVILEGES
    GROUP BY
      GRANTEE
  )
  UNION ALL
  (
    SELECT 
      GRANTEE,
      '*.*' AS priv_level,
      'user' AS priv_level_name,
      GROUP_CONCAT(PRIVILEGE_TYPE ORDER BY PRIVILEGE_TYPE SEPARATOR ', ') AS current_privileges,
      MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
      2 AS result_order
    FROM
      INFORMATION_SCHEMA.USER_PRIVILEGES
    GROUP BY
      GRANTEE
    HAVING
      GROUP_CONCAT(PRIVILEGE_TYPE ORDER BY PRIVILEGE_TYPE) != 'USAGE'
  )
  UNION ALL
  (
    SELECT
      GRANTEE,
      CONCAT('`', TABLE_SCHEMA, '`.*') AS priv_level,
      'schema' AS priv_level_name,
      GROUP_CONCAT(PRIVILEGE_TYPE ORDER BY PRIVILEGE_TYPE SEPARATOR ', ') AS current_privileges,
      MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
      3 AS result_order
    FROM 
      INFORMATION_SCHEMA.SCHEMA_PRIVILEGES
    GROUP BY
      GRANTEE, TABLE_SCHEMA
  )
  UNION ALL
  (
    SELECT
      GRANTEE,
      CONCAT('`', TABLE_SCHEMA, '`.`', TABLE_NAME, '`') AS priv_level,
      'table' AS priv_level_name,
      GROUP_CONCAT(PRIVILEGE_TYPE ORDER BY PRIVILEGE_TYPE SEPARATOR ', ') AS current_privileges,
      MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
      4 AS result_order
    FROM 
      INFORMATION_SCHEMA.TABLE_PRIVILEGES
    GROUP BY
      GRANTEE, TABLE_SCHEMA, TABLE_NAME
  )
  UNION ALL
  (
    SELECT
      GRANTEE,
      CONCAT('`', TABLE_SCHEMA, '`.`', TABLE_NAME, '`') AS priv_level,
      'column' AS priv_level_name,
      GROUP_CONCAT(column_privileges ORDER BY column_privileges SEPARATOR ', ') AS current_privileges,
      MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
      5 AS result_order
    FROM 
      _columns_privileges
    GROUP BY
      GRANTEE, TABLE_SCHEMA, TABLE_NAME
  )
;

-- 
-- Current grantee privileges and additional info breakdown, generated GRANT and REVOKE sql statements  
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW sql_grants AS
  SELECT 
    GRANTEE, 
    user.user,
    user.host,
    priv_level,
    priv_level_name,
    current_privileges,
    IS_GRANTABLE,
    CONCAT(
      'GRANT ', current_privileges, 
      ' ON ', priv_level, 
      ' TO ', GRANTEE,
      IF(priv_level = '*.*' AND current_privileges = 'USAGE', 
        CONCAT(' IDENTIFIED BY PASSWORD ''', user.password, ''''), ''),
      IF(IS_GRANTABLE = 'YES', 
        ' WITH GRANT OPTION', '')
      ) AS sql_grant,
    CASE
      WHEN current_privileges = 'USAGE' AND priv_level = '*.*' THEN ''
      ELSE
        CONCAT(
          'REVOKE ', current_privileges, 
          IF(IS_GRANTABLE = 'YES', 
            ', GRANT OPTION', ''),
          ' ON ', priv_level, 
          ' FROM ', GRANTEE
          )      
    END AS sql_revoke,
    CONCAT(
      'DROP USER ', GRANTEE
      ) AS sql_drop_user
  FROM 
    _sql_grants_components
    JOIN mysql.user ON (GRANTEE = CONCAT('''', user.user, '''@''', user.host, ''''))
  ORDER BY 
    GRANTEE, result_order
;


-- 
-- SHOW GRANTS like output, for all accounts  
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW sql_show_grants AS
  SELECT
    GRANTEE,
    user,
    host,
    GROUP_CONCAT(
      CONCAT(sql_grant, ';')
      SEPARATOR '\n'
      ) AS sql_grants
  FROM
    sql_grants
  GROUP BY
    GRANTEE, user, host
;
-- 
-- State of processes per user/host: connected, executing, average execution time
-- 
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW processlist_per_userhost AS
  SELECT 
    USER AS user,
    SUBSTRING_INDEX(HOST, ':', 1) AS host,
    COUNT(*) AS count_processes,
    SUM(COMMAND != 'Sleep') AS active_processes,
    AVG(IF(COMMAND != 'Sleep', TIME, NULL)) AS average_active_time
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  WHERE 
    id != CONNECTION_ID()
  GROUP BY
    USER, SUBSTRING_INDEX(HOST, ':', 1)
;
-- 
-- Replication processes only (both Master & Slave)
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW processlist_repl AS
  SELECT 
    * 
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  WHERE 
    USER = 'system user'
    OR COMMAND = 'Binlog Dump'
;
-- 
-- Active processes sorted by current query runtime, desc (longest first). Exclude current connection.
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW processlist_top AS
  SELECT 
    * 
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  WHERE 
    COMMAND != 'Sleep'
    AND id != CONNECTION_ID()
  ORDER BY
    TIME DESC
;
-- 
-- (Internal use): sample of GLOBAL_STATUS with time delay
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _global_status_sleep AS
  (
    SELECT 
      VARIABLE_NAME,
      VARIABLE_VALUE 
    FROM 
      INFORMATION_SCHEMA.GLOBAL_STATUS
  )
  UNION ALL
  (
    SELECT 
      '', 
      SLEEP(10) 
    FROM DUAL
  )
;


-- 
-- Status variables difference over time, with interpolation and extrapolation per time unit  
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW global_status_diff AS
  SELECT 
    LOWER(gs0.VARIABLE_NAME) AS variable_name,
    gs0.VARIABLE_VALUE AS variable_value_0,
    gs1.VARIABLE_VALUE AS variable_value_1,
    (gs1.VARIABLE_VALUE - gs0.VARIABLE_VALUE) AS variable_value_diff,
    (gs1.VARIABLE_VALUE - gs0.VARIABLE_VALUE) / 10 AS variable_value_psec,
    (gs1.VARIABLE_VALUE - gs0.VARIABLE_VALUE) * 60 / 10 AS variable_value_pminute
  FROM
    _global_status_sleep AS gs0
    JOIN INFORMATION_SCHEMA.GLOBAL_STATUS gs1 USING (VARIABLE_NAME)
;

-- 
-- Status variables difference over time, with spaces where zero diff encountered  
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW global_status_diff_clean AS
  SELECT 
    variable_name,
    variable_value_0,
    variable_value_1,
    IF(variable_value_diff = 0, '', variable_value_diff) AS variable_value_diff,
    IF(variable_value_diff = 0, '', variable_value_psec) AS variable_value_psec,
    IF(variable_value_diff = 0, '', variable_value_pminute) AS variable_value_pminute
  FROM
    global_status_diff
;

-- 
-- Status variables difference over time, only nonzero findings listed
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW global_status_diff_nonzero AS
  SELECT 
    *
  FROM
    global_status_diff
  WHERE
    variable_value_diff != 0
;
