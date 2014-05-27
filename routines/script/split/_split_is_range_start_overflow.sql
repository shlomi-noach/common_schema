-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_is_range_start_overflow $$
CREATE PROCEDURE _split_is_range_start_overflow(out is_overflow tinyint unsigned) 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare query text default NULL;

  declare range_start_variables_names text default _split_get_range_start_variables_names();
  declare max_variables_names text default _split_get_max_variables_names();

  set query := CONCAT(
    'select (', range_start_variables_names, ') >= (', max_variables_names, ') into @_split_is_overflow'
  );
  call exec_single(query);
  set is_overflow := @_split_is_overflow;
end $$

DELIMITER ;
