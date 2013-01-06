-- 
-- 
DELIMITER $$

DROP PROCEDURE IF EXISTS _split_set_step_clause_and_ranges_local_variables $$
CREATE PROCEDURE _split_set_step_clause_and_ranges_local_variables(
    in comparison_clause text charset utf8
  ) 
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

BEGIN
  declare columns_count tinyint unsigned default _split_get_columns_count();

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
  
  set @query_script_split_range_start_snapshot := TRIM(TRAILING ',' FROM CONCAT_WS(',',
  	IF(columns_count >= 1, QUOTE((SELECT @_split_column_variable_range_start_1)), ''),
  	IF(columns_count >= 2, QUOTE((SELECT @_split_column_variable_range_start_2)), ''),
  	IF(columns_count >= 3, QUOTE((SELECT @_split_column_variable_range_start_3)), ''),
  	IF(columns_count >= 4, QUOTE((SELECT @_split_column_variable_range_start_4)), ''),
  	IF(columns_count >= 5, QUOTE((SELECT @_split_column_variable_range_start_5)), ''),
  	IF(columns_count >= 6, QUOTE((SELECT @_split_column_variable_range_start_6)), ''),
  	IF(columns_count >= 7, QUOTE((SELECT @_split_column_variable_range_start_7)), ''),
  	IF(columns_count >= 8, QUOTE((SELECT @_split_column_variable_range_start_8)), ''),
  	IF(columns_count >= 9, QUOTE((SELECT @_split_column_variable_range_start_9)), '')
  ));
  set @query_script_split_range_end_snapshot := TRIM(TRAILING ',' FROM CONCAT_WS(',',
  	IF(columns_count >= 1, QUOTE((SELECT @_split_column_variable_range_end_1)), ''),
  	IF(columns_count >= 2, QUOTE((SELECT @_split_column_variable_range_end_2)), ''),
  	IF(columns_count >= 3, QUOTE((SELECT @_split_column_variable_range_end_3)), ''),
  	IF(columns_count >= 4, QUOTE((SELECT @_split_column_variable_range_end_4)), ''),
  	IF(columns_count >= 5, QUOTE((SELECT @_split_column_variable_range_end_5)), ''),
  	IF(columns_count >= 6, QUOTE((SELECT @_split_column_variable_range_end_6)), ''),
  	IF(columns_count >= 7, QUOTE((SELECT @_split_column_variable_range_end_7)), ''),
  	IF(columns_count >= 8, QUOTE((SELECT @_split_column_variable_range_end_8)), ''),
  	IF(columns_count >= 9, QUOTE((SELECT @_split_column_variable_range_end_9)), '')
  ));
END $$

DELIMITER ;
