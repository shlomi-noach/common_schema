-- 
-- Checks whether given text starts with given prefix.
-- Returns length of prefix if indeed text starts with it
-- Returns 0 when text does not start with prefix
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS starts_with $$
CREATE FUNCTION starts_with(txt TEXT CHARSET utf8, prefix TEXT CHARSET utf8)
RETURNS INT UNSIGNED
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return substring by index in delimited text'

begin
  if left(txt, CHAR_LENGTH(prefix)) = prefix then
    return CHAR_LENGTH(prefix);
  end if;
  return 0;
end $$

DELIMITER ;
