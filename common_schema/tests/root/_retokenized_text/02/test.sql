SET @s := 'quick, nice, happy dog';
SET @result := _retokenized_text(@s, ' ,', '', FALSE, 'allow');

SELECT @result = 
    CONCAT_WS(@common_schema_retokenized_delimiter, 'quick', '', 'nice', '', 'happy', 'dog')
    AND @common_schema_retokenized_count = 6
;
