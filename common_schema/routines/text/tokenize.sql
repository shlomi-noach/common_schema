-- 
-- Outputs ordered result set of tokens of given text
-- 
-- txt: input string
-- delimiter_text: char or text by which to split txt
--
-- example:
--
-- CALL tokenize('the quick brown fox', ' ');
-- +---+-------+
-- | n | token |
-- +---+-------+
-- | 1 | the   |
-- | 2 | quick |
-- | 3 | brown |
-- | 4 | fox   |
-- +---+-------+
--

DELIMITER $$

DROP PROCEDURE IF EXISTS tokenize $$
CREATE PROCEDURE tokenize(txt TEXT CHARSET utf8, delimiter_text VARCHAR(255) CHARSET utf8) 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare num_tokens INT UNSIGNED DEFAULT get_num_tokens(txt, delimiter_text);  
  SELECT n, split_token(txt, delimiter_text, n) AS token FROM numbers WHERE n BETWEEN 1 AND num_tokens;
end $$

DELIMITER ;
