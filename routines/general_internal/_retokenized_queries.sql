-- 
-- Assume the given text is a list of queries: 
-- This function calls upon _retokenized_text to parse the queries based on a semicolor
-- delimiter and quoting characters as dictated by sql_mode server variable.
-- The function recognizes semicolons which may appear within quoted text, and ignores them.
--

DELIMITER $$

DROP FUNCTION IF EXISTS _retokenized_queries $$
CREATE FUNCTION _retokenized_queries(queries TEXT CHARSET utf8) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Retokenizes input queries with special token'

begin
  declare quoting_characters VARCHAR(5) CHARSET ascii DEFAULT '`''';

  if not find_in_set('ANSI_QUOTES', @@sql_mode) then
    set quoting_characters := CONCAT(quoting_characters, '"');
  end if;

  return _retokenized_text(queries, ';', quoting_characters, TRUE, 'skip');
end $$

DELIMITER ;
