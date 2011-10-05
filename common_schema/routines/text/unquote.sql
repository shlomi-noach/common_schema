-- 
-- Unquotes a given text.
-- Removes leading and trailing quoting characters (one of: "'/)
-- Unquoting works only if both leading and trailing character are identical.
-- There is no nesting or sub-unquoting.
--
-- example:
--
-- SELECT unquote('\"saying\"') 
-- Returns: 'saying'
--

DELIMITER $$

DROP FUNCTION IF EXISTS unquote $$
CREATE FUNCTION unquote(txt TEXT CHARSET utf8) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Unquotes a given text'

begin
  if CHAR_LENGTH(txt) < 2 then
    return txt;
  end if;
  if LEFT(txt, 1) = '/' AND RIGHT(txt, 1) = '/' then
    return SUBSTRING(txt, 2, CHAR_LENGTH(txt) - 2);
  end if;
  if LEFT(txt, 1) = '\'' AND RIGHT(txt, 1) = '\'' then
    return SUBSTRING(txt, 2, CHAR_LENGTH(txt) - 2);
  end if;
  if LEFT(txt, 1) = '\"' AND RIGHT(txt, 1) = '\"' then
    return SUBSTRING(txt, 2, CHAR_LENGTH(txt) - 2);
  end if;
  return txt;
end $$

DELIMITER ;
