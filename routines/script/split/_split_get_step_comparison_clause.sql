-- 
-- 
DELIMITER $$

DROP PROCEDURE IF EXISTS _split_get_step_comparison_clause $$
CREATE PROCEDURE _split_get_step_comparison_clause(
    out comparison_clause text charset utf8
  ) 
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

BEGIN	
  declare columns_count tinyint unsigned default _split_get_columns_count();
  declare range_start_comparison_clause text default _split_get_columns_comparison_clause('>', 'range_start', @_split_is_first_step_flag, columns_count);
  declare range_end_comparison_clause text default _split_get_columns_comparison_clause('<', 'range_end', true, columns_count);

  set comparison_clause := CONCAT(
  	'(', range_start_comparison_clause, ' AND ', range_end_comparison_clause, ')'
  );
END $$

DELIMITER ;
