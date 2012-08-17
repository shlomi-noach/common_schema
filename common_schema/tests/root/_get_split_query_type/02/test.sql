set @query := '/* update this comment */ SELECT * FROM /* consusing insert */ test_cs.some_table';
call _interpret(@query, false);
call _get_split_query_type(1,10000, @query_type, @split_query_id_from, @split_query_following_select_id);

select @query_type = 'select';


