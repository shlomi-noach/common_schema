-- Outputs a prettified text message, one row per line in text
--

DELIMITER $$

DROP PROCEDURE IF EXISTS prettify_message $$
CREATE PROCEDURE prettify_message(title TINYTEXT CHARSET utf8, msg MEDIUMTEXT CHARSET utf8) 
NO SQL
SQL SECURITY INVOKER
COMMENT 'Outputs a prettified text message, one row per line in text'

begin
  declare query text charset utf8;
  
  set @_prettify_message_text := msg;
  set @_prettify_message_num_rows := get_num_tokens(msg, '\n');
  set query := CONCAT('
    SELECT 
        split_token(@_prettify_message_text, \'\\n\', n) AS ', mysql_qualify(title), '
      FROM 
        numbers
      WHERE 
        numbers.n BETWEEN 1 AND @_prettify_message_num_rows
      ORDER BY n ASC;
    ');
  call exec_single(query);
  set @_prettify_message_text := NULL;
  set @_prettify_message_num_rows := NULL;
end $$

DELIMITER ;
