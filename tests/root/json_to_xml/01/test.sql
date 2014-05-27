select json_text from test_cs.json_data where id = 1 into @s;

SELECT 
  json_to_xml(@s)
;

