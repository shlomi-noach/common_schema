-- 
-- Return number of tokens in delimited text
-- txt: input string
-- delimiter: char or text by which to split txt
--
-- example:
--
-- SELECT get_num_tokens('the quick brown fox', ' ') AS num_token;
-- Returns: 4
-- 
DELIMITER $$

DROP FUNCTION IF EXISTS get_num_tokens $$
CREATE FUNCTION get_num_tokens(txt TEXT CHARSET utf8, delimiter VARCHAR(255) CHARSET utf8) RETURNS INT UNSIGNED 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return number of tokens in delimited text'

BEGIN
  RETURN (CHAR_LENGTH(txt) - CHAR_LENGTH(REPLACE(txt, delimiter, '')))/CHAR_LENGTH(delimiter) + 1;
END $$

DELIMITER ;
