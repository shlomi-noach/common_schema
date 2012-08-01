set @query := 'INSERT IGNORE 123';
call _interpret(@query, false);
call _peek_states_list(1, 10000, 'alpha,alpha,alpha', true, true, true, @tokens_array_id, @match_to);

select @match_to = 0;