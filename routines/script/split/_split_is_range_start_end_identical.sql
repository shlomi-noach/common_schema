-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_is_range_start_end_identical $$
CREATE PROCEDURE _split_is_range_start_end_identical(out is_identical tinyint unsigned) 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare query text default NULL;

  declare range_start_variables_names text default _split_get_range_start_variables_names();
  declare range_end_variables_names text default _split_get_range_end_variables_names();

  set query := CONCAT(
    'select (', range_start_variables_names, ') = (', range_end_variables_names, ') into @_split_is_identical'
  );
  call exec_single(query);
  set is_identical := @_split_is_identical;
end $$

DELIMITER ;
