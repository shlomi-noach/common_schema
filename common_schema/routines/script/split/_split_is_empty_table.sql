-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_is_empty_table $$
CREATE PROCEDURE _split_is_empty_table(out is_empty_table tinyint unsigned) 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare query text default NULL;

  select 
    CONCAT(
      'SELECT (',
      GROUP_CONCAT(
        min_variable_name, ' IS NULL'
        separator ' AND '
      ),
      ') INTO @_split_is_empty_table_result'
      )
    from _split_column_names_table
    into query;

  call exec_single(query);
  set is_empty_table := @_split_is_empty_table_result;
end $$

DELIMITER ;
