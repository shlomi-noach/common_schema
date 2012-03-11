SET @s := 'The quick brown fox';
SELECT 
  strip_urls(@s) = @s
;

