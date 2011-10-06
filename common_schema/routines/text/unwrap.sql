-- 
-- Unwraps a given text from braces
-- Removes leading and trailing braces (round, square, curly)
-- Unwraps works only if both leading and trailing character are matching.
-- There is no nesting or sub-unwrapping.
--
-- example:
--
-- SELECT unwrap('{set}') 
-- Returns: 'set'
--

DELIMITER $$

DROP FUNCTION IF EXISTS unwrap $$
CREATE FUNCTION unwrap(txt TEXT CHARSET utf8) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Unwraps a given text from braces'

begin
  if CHAR_LENGTH(txt) < 2 then
    return txt;
  end if;
  if LEFT(txt, 1) = '{' AND RIGHT(txt, 1) = '}' then
    return SUBSTRING(txt, 2, CHAR_LENGTH(txt) - 2);
  end if;
  if LEFT(txt, 1) = '[' AND RIGHT(txt, 1) = ']' then
    return SUBSTRING(txt, 2, CHAR_LENGTH(txt) - 2);
  end if;
  if LEFT(txt, 1) = '(' AND RIGHT(txt, 1) = ')' then
    return SUBSTRING(txt, 2, CHAR_LENGTH(txt) - 2);
  end if;
  return txt;
end $$

DELIMITER ;
