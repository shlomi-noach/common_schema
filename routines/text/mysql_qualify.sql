-- 
-- Return a qualified MySQL name (e.g. database name, table name, column name, ...) from given text.
-- 
-- Can be used for dynamic query generation by INFORMATION_SCHEMA, where names are unqualified.
--
-- Example:
--
-- SELECT mysql_qualify('film_actor') AS qualified;
-- Returns: '`film_actor`'
-- 
DELIMITER $$

DROP FUNCTION IF EXISTS mysql_qualify $$
CREATE FUNCTION mysql_qualify(name TINYTEXT CHARSET utf8) RETURNS TINYTEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return a qualified MySQL name from given text'

begin
  if name RLIKE '^`[^`]*`$' then
    return name;
  end if;
  return CONCAT('`', REPLACE(name, '`', '``'), '`');
end $$

DELIMITER ;
