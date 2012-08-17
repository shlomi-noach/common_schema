-- 
-- 
DELIMITER $$

DROP PROCEDURE IF EXISTS _split_set_local_variable_step_comparison_clause $$
CREATE PROCEDURE _split_set_local_variable_step_comparison_clause(
    in comparison_clause text charset utf8
  ) 
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

BEGIN	
  set @query_script_split_comparison_clause := comparison_clause;
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_start_1', QUOTE((SELECT @_split_column_variable_range_start_1)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_start_2', QUOTE((SELECT @_split_column_variable_range_start_2)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_start_3', QUOTE((SELECT @_split_column_variable_range_start_3)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_start_4', QUOTE((SELECT @_split_column_variable_range_start_4)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_start_5', QUOTE((SELECT @_split_column_variable_range_start_5)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_start_6', QUOTE((SELECT @_split_column_variable_range_start_6)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_start_7', QUOTE((SELECT @_split_column_variable_range_start_7)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_start_8', QUOTE((SELECT @_split_column_variable_range_start_8)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_start_9', QUOTE((SELECT @_split_column_variable_range_start_9)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_end_1', QUOTE((SELECT @_split_column_variable_range_end_1)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_end_2', QUOTE((SELECT @_split_column_variable_range_end_2)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_end_3', QUOTE((SELECT @_split_column_variable_range_end_3)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_end_4', QUOTE((SELECT @_split_column_variable_range_end_4)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_end_5', QUOTE((SELECT @_split_column_variable_range_end_5)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_end_6', QUOTE((SELECT @_split_column_variable_range_end_6)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_end_7', QUOTE((SELECT @_split_column_variable_range_end_7)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_end_8', QUOTE((SELECT @_split_column_variable_range_end_8)));
  set @query_script_split_comparison_clause := REPLACE(@query_script_split_comparison_clause, '@_split_column_variable_range_end_9', QUOTE((SELECT @_split_column_variable_range_end_9)));
END $$

DELIMITER ;
