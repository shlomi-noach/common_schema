SET @repeat_counter := 0;
CALL repeat_exec(0.01, 'SET @repeat_counter := @repeat_counter + 1; UPDATE test.test_repeat_exec SET name = LEFT(name, CHAR_LENGTH(name)-1);', '0');
SELECT GROUP_CONCAT(name SEPARATOR ',') = ',,' AND @repeat_counter = 7 FROM test.test_repeat_exec;

