-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_deduce_columns $$
CREATE PROCEDURE _split_deduce_columns(split_table_schema varchar(128), split_table_name varchar(128)) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'split values by columns...'

begin
  declare split_column_names varchar(2048) default NULL;
  declare split_num_column tinyint unsigned;
  
  SELECT 
      column_names, count_column_in_index
    FROM 
      _split_candidate_keys_recommended 
    WHERE 
      table_schema = split_table_schema AND table_name = split_table_name 
    INTO split_column_names, split_num_column;
  if split_column_names is null then
    call throw(CONCAT('split: no key or definition found for: ', split_table_schema, '.', split_table_name));
  end if;
  
  drop temporary table if exists _split_column_names_table;
  create temporary table _split_column_names_table (
    column_order TINYINT UNSIGNED,
    split_table_name varchar(128) charset utf8,
    column_name VARCHAR(128) charset utf8,
    min_variable_name VARCHAR(128) charset utf8,
    max_variable_name VARCHAR(128) charset utf8,
    range_start_variable_name VARCHAR(128) charset utf8,
    range_end_variable_name VARCHAR(128) charset utf8
  );
  insert into _split_column_names_table
    select
      n,
      split_table_name,
      split_token(split_column_names, ',', n),
      CONCAT('@_split_column_variable_min_', n),
      CONCAT('@_split_column_variable_max_', n),
      CONCAT('@_split_column_variable_range_start_', n),
      CONCAT('@_split_column_variable_range_end_', n)
    from
      numbers
    where 
      n between 1 and split_num_column;
  select
    group_concat(mysql_qualify(column_name) order by column_order)
  from
    _split_column_names_table
  into
    @_query_script_split_columns;
end $$

DELIMITER ;
