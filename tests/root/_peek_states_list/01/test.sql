set @query_script_skip_cleanup := true;
set @query := 'INSERT IGNORE INTO';
call _interpret(@query, false);
call _peek_states_list(1, 10000, 'alpha,alpha,alpha', true, true, true, @tokens_array_id, @match_to);
call _get_array_element(@tokens_array_id, 1, @e1);
call _get_array_element(@tokens_array_id, 2, @e2);
call _get_array_element(@tokens_array_id, 3, @e3);

select (@e1, @e2, @e3) = ('INSERT', 'IGNORE', 'INTO');