-- 
-- Decode escaped XML text
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS decode_xml $$
CREATE FUNCTION decode_xml(txt TEXT CHARSET utf8) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Decode escaped XML'

begin
  set txt := REPLACE(txt, '&apos;', '''');
  set txt := REPLACE(txt, '&quot;', '"');
  set txt := REPLACE(txt, '&gt;', '>');
  set txt := REPLACE(txt, '&lt;', '<');
  set txt := REPLACE(txt, '&amp;', '&');
  
  return txt;
end $$

DELIMITER ;
