--
--
--

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_assign_initial_range_start_variables $$
CREATE PROCEDURE _split_assign_initial_range_start_variables()
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare queries text default NULL;

  select
    GROUP_CONCAT(
      'set ', range_start_variable_name, ' := ', min_variable_name, ';'
      separator ''
    )
    from _split_column_names_table
    into @_queries;
  set queries=@_queries;
  
  call exec(queries);

  set @_split_column_variable_range_end_1 := NULL;
end $$

DELIMITER ;
