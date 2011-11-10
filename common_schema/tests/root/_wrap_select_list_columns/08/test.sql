SET @query := "SELECT id the_id , CONCAT(name, '_', rank), CONCAT('it''s: ',rank) AS the_rank FROM test_cs.test__wrap_select_list_columns ORDER BY id";
CALL _wrap_select_list_columns(@query, 3, @error);
CALL exec(@query);
