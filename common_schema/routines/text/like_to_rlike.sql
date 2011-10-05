-- 
-- Convert a LIKE expression to an RLIKE (REGEXP) expression
-- expression: a LIKE expression
--
-- example:
--
-- SELECT like_to_rlike('c_oun%')
-- Returns: '^c.oun.*$'
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS like_to_rlike $$
CREATE FUNCTION like_to_rlike(expression TEXT CHARSET utf8) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Convert a LIKE expression to an RLIKE expression'

begin
  set expression := REPLACE(expression, '.', '[.]');
  set expression := REPLACE(expression, '*', '[*]');
  set expression := REPLACE(expression, '_', '.');
  set expression := REPLACE(expression, '%', '.*');
  set expression := CONCAT('^', expression, '$');
  return expression;
end $$

DELIMITER ;
