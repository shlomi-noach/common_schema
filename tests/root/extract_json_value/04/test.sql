select json_text from test_cs.json_data where id = 2 into @s;

SELECT 
  extract_json_value(@s, 'count(//menuitem)') = '3'
  and extract_json_value(@s, 'count(//onclick)') = '3'
;

