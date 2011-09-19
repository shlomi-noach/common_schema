SET @common_schema_dryrun := 1;
SET @val := 0;
CALL repeat_exec(0.01, 'SELECT @val := @val + ${NR}', '5');
