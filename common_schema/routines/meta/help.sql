--
-- Search and read common_schema documentation.
--
-- help() accepts a search term, and presents a single documentation page
-- which best fits the term. The term may appear within the documentation's title
-- or description. It could be the name or part of name of one of 
-- common_schema's components (routines, views, ...), or it could be any
-- keyword appearing within the documentation.
-- The output is MySQL-friendly, in that it breaks the documentation into rows of
-- text, thereby presenting the result in a nicely formatted table.
--

DELIMITER $$

DROP PROCEDURE IF EXISTS help $$
CREATE PROCEDURE help(expression TINYTEXT CHARSET utf8) 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inline help'

begin
  set expression := REPLACE(expression, '()', '');
  set expression := REPLACE(expression, ';', '');
  set expression := trim_wspace(expression);
  set expression := trim_wspace(expression);
  SELECT 
    split_token(help_message, '\n', n) AS help
  FROM (
    SELECT help_message FROM (
      SELECT 1 AS order_column, help_message FROM help_content WHERE topic LIKE CONCAT('%', expression, '%')
      UNION ALL
      SELECT 2, help_message FROM help_content WHERE help_message LIKE CONCAT('%', expression, '%')
      UNION ALL
      SELECT 3, CONCAT('No help topics found for "', expression, '".')
    ) select_all 
    ORDER BY order_column ASC 
    LIMIT 1
  ) select_single,
  numbers
  WHERE 
    numbers.n BETWEEN 1 AND get_num_tokens(help_message, '\n')
  ORDER BY n ASC;
end $$

DELIMITER ;
