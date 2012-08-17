-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_assign_range_end_variables $$
CREATE PROCEDURE _split_assign_range_end_variables(split_table_schema varchar(128), split_table_name varchar(128)) 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare query text default NULL;
  declare column_names text default _split_get_columns_names();
  
  declare columns_order_ascending_clause text default _split_get_columns_order_ascending_clause();
  declare range_end_variables_names text default _split_get_range_end_variables_names();
  
  declare columns_order_descending_clause text default _split_get_columns_order_descending_clause();
  declare max_variables_names text default _split_get_max_variables_names();
  
  declare columns_count tinyint unsigned default _split_get_columns_count();
  
  declare as_of_range_start_comparison_clause text default _split_get_columns_comparison_clause('>', 'range_start', _split_is_first_step(), columns_count);
  declare limit_by_max_comparison_clause text default _split_get_columns_comparison_clause('<', 'max', true, columns_count);

  set query := CONCAT(
    'select ', column_names, ' from (',
      'select ', column_names, ' from ',
      mysql_qualify(split_table_schema), '.', mysql_qualify(split_table_name), 
      ' where ', as_of_range_start_comparison_clause,
      ' and ', limit_by_max_comparison_clause,
      ' order by ', columns_order_ascending_clause,
      ' limit 1000 ',
    ') sel_split_range ',
    ' order by ', columns_order_descending_clause,
    ' limit 1 ',
    ' into ', range_end_variables_names
  );
  call exec_single(query);
end $$

DELIMITER ;
