SET @repeat_counter := 0;
CALL repeat_exec(0.01, 'SET @repeat_counter := @repeat_counter + 1', 'invalid');
SELECT @repeat_counter = 0 AND @common_schema_error = 'repeat_exec: invalid stop_condition';
