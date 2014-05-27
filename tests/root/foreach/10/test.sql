SET @num_schemata := 0;
CALL foreach('schema', 'SET @num_schemata := @num_schemata + 1');
SELECT @num_schemata > 2;