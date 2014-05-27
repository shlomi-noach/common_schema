SET @s := 'quick,brown,,dogs';
SET @result := _retokenized_text(@s, ',', '', FALSE, 'error');

SELECT @result IS NULL;

