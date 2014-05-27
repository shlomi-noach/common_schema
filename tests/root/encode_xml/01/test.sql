SET @s := 'The quick brown fox';
SELECT 
  encode_xml(@s) = @s
;

