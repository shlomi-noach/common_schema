-- 
-- Replaces characters in a given text with a given replace-text.
-- txt: input text
-- from_characters: a text consisting of characters to replace.
-- to_str: a string to plant in place of each occurance of a character from from_characters.
--   Can be of any length.
--
-- example:
--
-- SELECT replace_all('red, green, blue;', '; ,', '-') 
-- Returns: 'red--green--blue-'
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS replace_all $$
CREATE FUNCTION replace_all(txt TEXT CHARSET utf8, from_characters VARCHAR(1024) CHARSET utf8, to_str TEXT CHARSET utf8) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Replace any char in from_characters with to_str '

begin
  declare counter SMALLINT UNSIGNED DEFAULT 1;

  while counter <= CHAR_LENGTH(from_characters) do
    set txt := REPLACE(txt, SUBSTRING(from_characters, counter, 1), to_str);
    set counter := counter + 1;
  end while;
  return txt;
end $$

DELIMITER ;
