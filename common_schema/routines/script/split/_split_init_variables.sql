-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_init_variables $$
CREATE PROCEDURE _split_init_variables() 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare queries text default NULL;

  select 
    GROUP_CONCAT(
      'set ', min_variable_name, ' := NULL; ',
      'set ', max_variable_name, ' := NULL; ',
      'set ', range_start_variable_name, ' := NULL; ',
      'set ', range_end_variable_name, ' := NULL; '
      separator ''
    )
    from _split_column_names_table
    into queries;
    
  call exec(queries);
end $$

DELIMITER ;
