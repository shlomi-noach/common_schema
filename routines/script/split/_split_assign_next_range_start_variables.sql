-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_assign_next_range_start_variables $$
CREATE PROCEDURE _split_assign_next_range_start_variables() 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare queries text default NULL;

  select 
    GROUP_CONCAT(
      'set ', range_start_variable_name, ' := ', range_end_variable_name, ';'
      separator ''
    )
    from _split_column_names_table
    into queries;
    
  call exec(queries);
end $$

DELIMITER ;
