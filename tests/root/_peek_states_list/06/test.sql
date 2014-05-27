set @query_script_skip_cleanup := true;
set @query := 'INSERT IGNORE INTO some_table';
call _interpret(@query, false);
call _peek_states_list(1, 10000, 'alpha,alpha,alpha', true, false, true, @tokens_array_id, @match_to);

select @match_to = 0;