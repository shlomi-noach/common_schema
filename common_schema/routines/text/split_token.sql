-- 
-- Return substring by index in delimited text
-- txt: input string
-- delimiter: char or text by which to split txt
-- token_index: 1-based index of token in split string
--
-- example:
--
-- SELECT split_token('the quick brown fox', ' ', 3) AS token;
-- Returns: 'brown'
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS split_token $$
CREATE FUNCTION split_token(txt TEXT CHARSET utf8, delimiter VARCHAR(255) CHARSET utf8, token_index INT UNSIGNED) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return substring by index in delimited text'

begin
  if CHAR_LENGTH(delimiter) = '' then
    return SUBSTRING(txt, token_index, 1);
  else
    return SUBSTRING_INDEX(SUBSTRING_INDEX(txt, delimiter, token_index), delimiter, -1);
  end if;
end $$

DELIMITER ;
