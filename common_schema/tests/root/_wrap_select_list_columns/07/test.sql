SET @query := 'SELECT id, name, rank FROM test_cs.test__wrap_select_list_columns ORDER BY id';
CALL _wrap_select_list_columns(@query, 3, @error);
CALL exec(@query);
