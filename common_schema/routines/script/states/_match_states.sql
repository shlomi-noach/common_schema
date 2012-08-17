--
-- Given a state (or optional states), expect a dynamic length comma 
-- delimited list where each element is given state(s).
--

delimiter //

drop procedure if exists _match_states //

create procedure _match_states(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   expected_states_list text charset utf8,
   in	allow_spaces_between_states tinyint unsigned,
   in	allow_trailing_states tinyint unsigned,
   in   repeat_count int unsigned,
   in   repeat_delimiter_state text charset utf8,
   in	return_tokens_array_id tinyint unsigned,
   in   throw_on_mismatch tinyint unsigned,
   out  states_have_matched tinyint unsigned,
   out  tokens_array_id VARCHAR(16) charset ascii,
   out  single_matched_token text charset utf8,
   out	consumed_to_id int unsigned
) 
comment 'Expects a state or raises error'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  declare state_has_matched tinyint unsigned default FALSE;
  declare num_states int unsigned default 0;
  declare states_index int unsigned;
  declare repeat_index int unsigned;
  declare expected_states text charset utf8;
  
  if return_tokens_array_id then
    call _create_array(tokens_array_id);
  end if;

  set num_states := get_num_tokens(expected_states_list, ',');
  if num_states = 0 then
    call _throw_script_error(id_from, 'Internal error: num_states = 0 in _match_states');
  end if;
  
  -- repeat_count = 0 means undefined length, dynamic.
  set states_have_matched := true;
  set repeat_index := 1;
  repeat_loop: while (repeat_index <= repeat_count) or (repeat_count = 0) do
    call _skip_spaces(id_from, id_to);
    set states_index := 1;

    while states_index <= num_states do
      -- Read a single state, one of current expected states.
      if allow_spaces_between_states then
        call _skip_spaces(id_from, id_to);
      end if;
      set expected_states := split_token(expected_states_list, ',', states_index);

      select token, FIND_IN_SET(state, REPLACE(expected_states, '|', ',')) is true from _sql_tokens where id = id_from into single_matched_token, state_has_matched;
      if state_has_matched then
        set consumed_to_id := id_from;
        if return_tokens_array_id then
          call _push_array_element(tokens_array_id, single_matched_token);
        end if;
      else
        set states_have_matched := false;
        leave repeat_loop;
      end if;
      set id_from := id_from + 1;
      
      set states_index := states_index + 1;
    end while;
    -- End reading single-occurence of expected states.
    -- We now expect delimiters, if appliccable (NULL delimiter means no delimiter expected)
    if repeat_delimiter_state != 'whitespace' then
      -- If expected delimiter is whitespace, well, we want to consume it,
      -- not skip it... 
      call _skip_spaces(id_from, id_to);
    end if;
    if repeat_delimiter_state is not null then
      select token, (state = repeat_delimiter_state) from _sql_tokens where id = id_from into @_common_schema_dummy, state_has_matched;
      if not state_has_matched then
        -- Could not find dilimiter.
        -- This is fine for last repeat-step, or when there is
        -- a dynamic repeat_count (== 0); and it just means we're
        -- through with repeats. Otherwise this means no match.
        if (repeat_index < repeat_count) then
          set states_have_matched := false;
        end if;
        leave repeat_loop;
      end if;
      set id_from := id_from + 1;
    end if;
    -- Phew, got here: this means a delimiter is matched.
    set repeat_index := repeat_index + 1; 
  end while;

  if states_have_matched then
    -- wrap up the match
    if allow_trailing_states then
      -- don't care about the rest
      leave main_body;
    end if;
 
    -- Do not allow trailing states: expect nothing more but spaces or statement delimiter
    call _skip_spaces(id_from, id_to);
    call _skip_end_of_statement(id_from, id_to);
    if id_from <= id_to then
      set states_have_matched := false;
    end if;
  end if;
  
  if not states_have_matched then
    -- This entire routine fails: there is no match
    if throw_on_mismatch then
      call _throw_script_error(id_from, CONCAT('Expected ', REPLACE(expected_states, '|', '/')));
    else
      leave main_body;
    end if;
  end if;

end;
//

delimiter ;
