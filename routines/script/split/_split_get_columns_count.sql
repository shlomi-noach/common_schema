--
--
DELIMITER $$

DROP function IF EXISTS _split_get_columns_count $$
CREATE function _split_get_columns_count()
  returns TINYINT UNSIGNED
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

BEGIN
  declare return_value TINYINT UNSIGNED;

  select
      count(*)
    from
      _split_column_names_table
    into @_return_value
    ;
  set return_value=@_return_value;
  return return_value;
END $$

DELIMITER ;
