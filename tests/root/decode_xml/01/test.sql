SET @s := 'The quick brown fox';
SELECT 
  decode_xml(@s) = @s
;

