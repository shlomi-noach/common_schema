SET @query := 'SELECT CONCAT(\'UPDATE test_cs.test_eval SET name=UPPER(name)\') FROM DUAL';
CALL eval(@query);
SELECT GROUP_CONCAT(name ORDER BY id)='FIRST,SECOND,THIRD' FROM test_cs.test_eval;
