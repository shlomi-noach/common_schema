--
--
DELIMITER $$

DROP function IF EXISTS _split_get_columns_order_descending_clause $$
CREATE function _split_get_columns_order_descending_clause()
  returns TEXT CHARSET utf8
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

BEGIN
  declare return_value TEXT CHARSET utf8;

  select
      group_concat(column_name, ' DESC' order by column_order separator ', ')
    from
      _split_column_names_table
    into @_return_value
    ;
  set return_value=@_return_value;
  return return_value;
END $$

DELIMITER ;
