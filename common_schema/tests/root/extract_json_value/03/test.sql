select json_text from test_cs.json_data where id = 1 into @s;

SELECT 
  extract_json_value(@s, 'count(//GlossSeeAlso)') = '2'
;

