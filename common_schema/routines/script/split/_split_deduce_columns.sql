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

  call _split_generate_dependency_tables(split_table_schema, split_table_name);
  
  SELECT 
      column_names, count_column_in_index, index_name
    FROM 
      _split_candidate_keys_recommended 
    WHERE 
      table_schema = split_table_schema AND table_name = split_table_name 
    INTO split_column_names, split_num_column, @_query_script_split_index_name
  ;
    
  call _split_cleanup_dependency_tables();

  if split_column_names is null then
    call throw(CONCAT('split: no key or definition found for: ', split_table_schema, '.', split_table_name));
  end if;

  -- There can't be nested "split" operations. Therefore there can't be two "instances"
  -- of "split" for this session.
  delete from _split_column_names_table;
  insert into _split_column_names_table
    select
      CONNECTION_ID(),
      n,
      split_table_name,
      @_query_script_split_index_name,
      split_token(split_column_names, ',', n),
      CONCAT('@_split_column_variable_min_', n),
      CONCAT('@_split_column_variable_max_', n),
      CONCAT('@_split_column_variable_range_start_', n),
      CONCAT('@_split_column_variable_range_end_', n)
    from
      numbers
    where 
      n between 1 and split_num_column
  ;
  
  select
    group_concat(mysql_qualify(column_name) order by column_order)
  from
    _split_column_names_table
  into
    @_query_script_split_columns;    
end $$

DELIMITER ;
