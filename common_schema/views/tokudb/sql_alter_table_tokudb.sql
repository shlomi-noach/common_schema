
--
-- Generate an ALTER TABLE statement for converting tables to TokuDB
--

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW _sql_alter_table_tokudb_internal AS
  SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    ENGINE,
    concat(
      sql_drop_keys, ', ', sql_add_keys, 
      ', engine=tokudb row_format=tokudb_small key_block_size=0;') as alter_fast_clause,
    concat(
      sql_drop_keys, ', ', sql_add_keys, 
      ', engine=tokudb row_format=tokudb_small key_block_size=0;') as alter_small_clause
  FROM 
    sql_alter_table
;


CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW sql_alter_table_tokudb AS
  SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    ENGINE,
    alter_fast_clause,
    concat(
      'alter table ', mysql_qualify(table_schema), '.', mysql_qualify(table_name), ' ', alter_fast_clause) as sql_alter_fast,
    alter_small_clause,
    concat(
      'alter table ', mysql_qualify(table_schema), '.', mysql_qualify(table_name), ' ', alter_small_clause) as sql_alter_small
  FROM 
    _sql_alter_table_tokudb_internal
;

