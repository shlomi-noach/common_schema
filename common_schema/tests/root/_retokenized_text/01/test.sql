SET @s := 'the quick brown fox';
SET @result := _retokenized_text(@s, ' ', '', FALSE, 'allow');

SELECT @result = 
    CONCAT_WS(@common_schema_retokenized_delimiter, 'the', 'quick', 'brown', 'fox')
    AND @common_schema_retokenized_count = 4
;
