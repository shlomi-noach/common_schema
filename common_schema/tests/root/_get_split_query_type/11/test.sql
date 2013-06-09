set @query_script_skip_cleanup := true;
set @query := 'INSERT INTO test_cs.some_table VALUES (1, 2, 3)';
call _interpret(@query, false);
call _get_split_query_type(1,10000, @query_type, @split_query_id_from, @split_query_following_select_id);

select @query_type = 'unsupported';
