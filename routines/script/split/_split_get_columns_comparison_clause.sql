--
--
DELIMITER $$

DROP function IF EXISTS _split_get_columns_comparison_clause $$
CREATE function _split_get_columns_comparison_clause(
    comparison_operator VARCHAR(3),
    split_variable_type enum('range_start', 'range_end', 'max'),
    comparison_includes_equals TINYINT UNSIGNED,
    num_split_columns TINYINT UNSIGNED)
  returns TEXT CHARSET utf8
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

BEGIN
  declare return_value TEXT CHARSET utf8;

  select
    group_concat('(', partial_comparison, ')' order by n separator ' OR ') as comparison
  from (
    select
      n,
      group_concat('(', column_name, ' ', if(is_last, comparison_operator, '='), ' ', variable_name, ')' order by column_order separator ' AND ') as partial_comparison
    from (
      select
        n, CONCAT(mysql_qualify(split_table_name), '.', mysql_qualify(column_name)) AS column_name,
        case split_variable_type
          when 'range_start' then range_start_variable_name
          when 'range_end' then range_end_variable_name
          when 'max' then max_variable_name
        end as variable_name,
        _split_column_names_table.column_order, _split_column_names_table.column_order = n as is_last
      from
        numbers, _split_column_names_table
      where
        n between _split_column_names_table.column_order and num_split_columns
      order by n, _split_column_names_table.column_order
    ) s1
    group by n
  ) s2
  into @_return_value
  ;
  set return_value=@_return_value;

  if comparison_includes_equals then
    set @_return_value=null;
    select
      CONCAT(
        return_value, ' OR (',
        GROUP_CONCAT(
          '(', CONCAT(mysql_qualify(split_table_name), '.', mysql_qualify(column_name)), ' = ',
          case split_variable_type
            when 'range_start' then range_start_variable_name
            when 'range_end' then range_end_variable_name
            when 'max' then max_variable_name
          end,
          ')' order by column_order separator ' AND '),
        ')'
      )
    from
      _split_column_names_table
    into @_return_value
    ;
    set return_value=@_return_value;
  end if;
  set return_value := CONCAT('(', return_value, ')');

  return return_value;
END $$

DELIMITER ;
