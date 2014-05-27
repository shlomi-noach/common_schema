SET @s := 'quick, "nice, happy" dog is `way faster` than \'foxy foxed\' fox';
SET @result := _retokenized_text(@s, ' ,', '"`\'', FALSE, 'skip');

SELECT @result = 
    CONCAT_WS(@common_schema_retokenized_delimiter, 
      'quick', '"nice, happy"', 'dog', 'is', '`way faster`', 'than', '\'foxy foxed\'', 'fox')
;
