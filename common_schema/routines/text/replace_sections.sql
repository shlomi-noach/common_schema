-- 
-- Replace sections denoted by section_start & section_end with given replacement_text
-- Text is stripped of possibly multiple occurance of section_start...some..text...section_end
-- Each such appearance is replaced with replacement_text.
-- replacement_text may include the \0 backtrace, which resovled to the text being replaced, not including boundaries.
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS replace_sections $$
CREATE FUNCTION replace_sections(
  txt TEXT CHARSET utf8, 
  section_start TEXT charset utf8,
  section_end TEXT charset utf8,
  replacement_text TEXT CHARSET utf8) 
  RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Replace start-end sections with given text'

main_body: begin
  declare next_start_pos int unsigned default 1;
  declare next_end_pos int unsigned default 1;
  declare tmp_prefix, tmp_suffix, replaced_text text charset utf8;
  
  if txt is null then
    return null;
  end if;
  while true do
    set next_start_pos := LOCATE(section_start, txt, next_start_pos);
    if not next_start_pos then
      return txt;
    end if;
    set next_end_pos := LOCATE(section_end, txt, next_start_pos + char_length(section_start));
    if not next_end_pos then
      return txt;
    end if;
    set replaced_text := substring(txt, next_start_pos + char_length(section_start), (next_end_pos - next_start_pos) - char_length(section_start));
    set tmp_prefix := LEFT(txt, next_start_pos - 1);
    set tmp_suffix := SUBSTRING(txt, next_end_pos + CHAR_LENGTH(section_end));
    set txt := concat(tmp_prefix, replace(replacement_text, '\\0', replaced_text));
    set next_start_pos := char_length(txt);
    set txt := concat(txt, tmp_suffix);
  end while;
  return txt;
end $$

DELIMITER ;
