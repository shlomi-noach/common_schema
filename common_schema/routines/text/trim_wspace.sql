-- 
-- Trim white space characters on both sides of text.
-- As opposed to the standard TRIM() function, which only trims
-- strict space characters (' '), trim_wspace() also trims new line, 
-- tab and backspace characters
--
-- example:
--
-- SELECT trim_wspace('\n a b c \n  ')
-- Returns: 'a b c'
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS trim_wspace $$
CREATE FUNCTION trim_wspace(txt TEXT CHARSET utf8) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Trim whitespace characters on both sides'

begin
  declare len INT UNSIGNED DEFAULT 0;
  declare done TINYINT UNSIGNED DEFAULT 0;

  while not done do
    set len := CHAR_LENGTH(txt);
    set txt = trim(' ' FROM txt);
    set txt = trim('\r' FROM txt);
    set txt = trim('\n' FROM txt);
    set txt = trim('\t' FROM txt);
    set txt = trim('\b' FROM txt);
    if CHAR_LENGTH(txt) = len then
      set done := 1;
    end if;
  end while;
  return txt;
end $$

DELIMITER ;
