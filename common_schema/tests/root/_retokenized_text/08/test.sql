SET @s := 'quick,brown,   ,dogs';
SET @result := _retokenized_text(@s, ',', '', TRUE, 'error');

SELECT @result IS NULL;

