-- 
-- Present a Hexadecimal table for given text's characters.
-- This routine will show a prettified table, laying out the given text's character
-- and their hexadecimal values side by side, 16 characters per row.
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS hexcode_text $$
CREATE PROCEDURE hexcode_text(
  in txt TEXT CHARSET utf8) 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Shows hex-table of given text'

main_body: begin
  declare title varchar(255) charset ascii default '';
  declare hex_text text charset utf8 default '';
  declare lpad_size tinyint unsigned default 2;
  declare current_chunk int unsigned default 1;
  declare count_chunks int unsigned default 0;
  declare current_index tinyint unsigned;
  
  if char_length(HEX(txt)) > 2*char_length(txt) then
    -- unicode characters found: at least one character
    -- requires more than 2 hex digits.
    set lpad_size := 4;
  end if;
  
  set count_chunks := ceil(char_length(txt)/16.0);
  while current_chunk <= count_chunks do
    set current_index := 1;
    while current_index <= 16 do
      set hex_text := concat(
          hex_text,
          lpad(
            hex(substring(txt, (current_chunk - 1)*16 + current_index, 1)), 
            if (current_index = 1, lpad_size, lpad_size + 1), 
            ' '
          )
        );
      if current_chunk = 1 then
        set title := concat(
          title, 
          lpad(
            lower(hex(current_index - 1)), 
            if (current_index = 1, lpad_size, lpad_size + 1), 
            ' '
          )
        );
      end if;
      set current_index := current_index + 1;
    end while;
    
    set hex_text := concat(hex_text, '  ');
    if current_chunk = 1 then
      set title := concat(title, '  ');
    end if;
    
    set current_index := 1;
    while current_index <= 16 do
      set hex_text := concat(
          hex_text,
          lpad(substring(txt, (current_chunk - 1)*16 + current_index, 1), 2, ' ')
        );
      if current_chunk = 1 then
        set title := concat(
          title, 
          lpad(
            lower(hex(current_index - 1)), 
            2,
            ' '
          )
        );
      end if;
      set current_index := current_index + 1;
    end while;
    set hex_text := concat(hex_text, '\n');
    set current_chunk := current_chunk + 1;
  end while;

  set hex_text := trim('\n' from hex_text);
  set title := concat('>', substring(title, 2));
  call prettify_message(title, hex_text);
end $$
DELIMITER ;
