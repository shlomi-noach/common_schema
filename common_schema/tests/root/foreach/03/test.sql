SET @common_schema_dryrun := 1; 
CALL foreach('0:3,10:12', 'ALTER TABLE test_cs.t_${1} ADD COLUMN col_${2} INT');
