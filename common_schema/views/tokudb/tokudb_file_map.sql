-- 
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _tokudb_table_breakdown_map AS
  SELECT 
    *,
    split_token(dictionary_name, '/', 2) as table_schema,
    split_token(LEFT(dictionary_name, CHAR_LENGTH(dictionary_name)-CHAR_LENGTH('-main')), '/', 3) as table_name
  FROM
    INFORMATION_SCHEMA.TokuDB_file_map
  WHERE
    dictionary_name like './%-main'
;

-- 
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _tokudb_table_p_filenames_map AS
  SELECT 
    table_schema, 
    table_name, 
    count(*) as count_files,
    group_concat(tokudb_file_map.internal_file_name order by tokudb_file_map.internal_file_name) as files
  FROM
    _tokudb_table_breakdown_map
    JOIN information_schema.tokudb_file_map ON (tokudb_file_map.dictionary_name LIKE CONCAT('./', table_schema, '/', table_name, '-%'))
  GROUP BY
    table_schema, table_name
;

-- 
-- 
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _tokudb_table_filenames_map AS
  SELECT 
    table_schema, 
    substring_index(table_name, '#P#', 1) as table_name,
    SUM(count_files) as count_files,
    group_concat(files order by table_name) as files
  FROM
    _tokudb_table_p_filenames_map
  GROUP BY
    1, 2
;

-- 
-- map TokuDB tables to files and common shell commands
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW tokudb_file_map AS
  SELECT 
    table_schema,
    table_name,
    count_files,
    files,
    concat('ls -l ', replace(files, ',', ' ')) as bash_ls,
    concat('du -ch ', replace(files, ',', ' '), ' | tail -n 1') as bash_du
  FROM
    _tokudb_table_filenames_map
;
