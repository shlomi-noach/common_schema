-- 
-- Encode (escape_ given text for XML
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS encode_xml $$
CREATE FUNCTION encode_xml(txt TEXT CHARSET utf8) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Encode (escape) given text for XML'

begin
  set txt := REPLACE(txt, '&', '&amp;');
  set txt := REPLACE(txt, '<', '&lt;');
  set txt := REPLACE(txt, '>', '&gt;');
  set txt := REPLACE(txt, '"', '&quot;');
  set txt := REPLACE(txt, '''', '&apos;');
  
  return txt;
end $$

DELIMITER ;
