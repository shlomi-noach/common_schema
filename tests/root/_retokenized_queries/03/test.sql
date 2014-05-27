SET @queries := 'select `1;` from dual; select '';2'', ";;3;", ''a";b'', "it''s;" from dual;';
SET @retokenized := _retokenized_queries(@queries); 
SELECT 
   @retokenized = CONCAT_WS(@common_schema_retokenized_delimiter,
    'select `1;` from dual', 'select '';2'', ";;3;", ''a";b'', "it''s;" from dual');
;
