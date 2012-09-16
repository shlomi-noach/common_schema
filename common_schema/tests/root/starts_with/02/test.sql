set @s := 'the quick brown fox';
SELECT 
  not starts_with(@s, 'what')
  AND not starts_with(@s, 'thy')
  AND not starts_with(@s, '')
;
