-- 
-- Strips URLs from given text, replacing them with an empty string.
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS strip_urls $$
CREATE FUNCTION strip_urls(txt TEXT CHARSET utf8) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Strips URLs from given text'

begin
  declare end_pos INT UNSIGNED DEFAULT 0;
  declare done TINYINT UNSIGNED DEFAULT 0;
  
  while ((@_strip_urls_url_pos := LOCATE('http://', txt)) > 0) do
    set end_pos := @_strip_urls_url_pos;
    while (SUBSTRING(txt, end_pos, 1) not in (' ', '\n', '\r', '<', '')) do
      set end_pos := end_pos + 1;
    end while;
    set txt := CONCAT(LEFT(txt, @_strip_urls_url_pos - 1), SUBSTRING(txt, end_pos));
  end while;
  while ((@_strip_urls_url_pos := LOCATE('https://', txt)) > 0) do
    set end_pos := @_strip_urls_url_pos;
    while (SUBSTRING(txt, end_pos, 1) not in (' ', '\n', '\r', '<', '')) do
      set end_pos := end_pos + 1;
    end while;
    set txt := CONCAT(LEFT(txt, @_strip_urls_url_pos - 1), SUBSTRING(txt, end_pos));
  end while;
  return txt;
end $$

DELIMITER ;
