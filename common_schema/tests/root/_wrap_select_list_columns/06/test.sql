SET @query := 'SELECT rank, COUNT(*) AS num_winners, GROUP_CONCAT(name ORDER BY name) AS names FROM test_cs.test__wrap_select_list_columns GROUP BY rank ORDER BY rank ASC';
CALL _wrap_select_list_columns(@query, 3, @error);
CALL exec(@query);
