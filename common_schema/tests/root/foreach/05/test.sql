SET @common_schema_dryrun := 1; 
CALL foreach('-2:2', 'SELECT ${1} FROM DUAL');
