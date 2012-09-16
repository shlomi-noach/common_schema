set @s := 'the quick brown fox';
SELECT 
  starts_with(@s, 'the') = 3
  AND starts_with(@s, 'the quick brown fox')
  AND starts_with(@s, 't') = 1
;
