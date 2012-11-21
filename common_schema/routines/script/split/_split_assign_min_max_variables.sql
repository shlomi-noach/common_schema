-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_assign_min_max_variables $$
CREATE PROCEDURE _split_assign_min_max_variables(
  id_from      int unsigned,
  split_table_schema varchar(128), 
  split_table_name varchar(128),
  split_options varchar(2048) charset utf8
  ) 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare query text default NULL;
  declare column_names text default _split_get_columns_names();
  declare columns_order_ascending_clause text default _split_get_columns_order_ascending_clause();
  declare min_variables_names text default _split_get_min_variables_names();
  declare columns_order_descending_clause text default _split_get_columns_order_descending_clause();
  declare max_variables_names text default _split_get_max_variables_names();

  set query := CONCAT(
    'select ', column_names, ' from ',
    mysql_qualify(split_table_schema), '.', mysql_qualify(split_table_name), 
    ' order by ', columns_order_ascending_clause,
    ' limit 1 ',
    ' into ', min_variables_names
  );
  call exec_single(query);

  set query := CONCAT(
    'select ', column_names, ' from ',
    mysql_qualify(split_table_schema), '.', mysql_qualify(split_table_name), 
    ' order by ', columns_order_descending_clause,
    ' limit 1 ',
    ' into ', max_variables_names
  );
  call exec_single(query);
  
  if get_option(split_options, 'start') is not null then
    if _split_get_columns_count() = 1 then
      set query := CONCAT(
        'set ', min_variables_names, ' := GREATEST(', min_variables_names, ', ', get_option(split_options, 'start'), ')'
      );
      call exec_single(query);
    else
      call _throw_script_error(id_from, 'Found ''start'' option, but this split uses multiple columns');
    end if;
  end if;
  if get_option(split_options, 'stop') is not null then
    if _split_get_columns_count() = 1 then
      set query := CONCAT(
        'set ', max_variables_names, ' := LEAST(', max_variables_names, ', ', get_option(split_options, 'stop'), ')'
      );
      call exec_single(query);
    else
      call _throw_script_error(id_from, 'Found ''stop'' option, but this split uses multiple columns');
    end if;
  end if;
end $$

DELIMITER ;
