SET @s := 'a b c d';
SELECT split_token(@s, '-', 3) = @s;
