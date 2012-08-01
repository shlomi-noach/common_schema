set @query := 'select some_schema.`some_table`';
call _interpret(@query, false);
call _peek_states_list(1, 10000, 'alpha,alpha|alphanum|quoted identifier,dot,alpha|alphanum|quoted identifier', true, true, true, @tokens_array_id, @match_to);
call _get_array_element(@tokens_array_id, 1, @e1);
call _get_array_element(@tokens_array_id, 2, @e2);
call _get_array_element(@tokens_array_id, 3, @e3);
call _get_array_element(@tokens_array_id, 4, @e4);

select (@e1, @e2, @e3, @e4) = ('select', 'some_schema', '.', '`some_table`');
