--
-- Check if given states list apply.
-- Returned value: tokens_matched_to, the id of last matched token, or 0 on mismatch
--

delimiter //

drop procedure if exists _peek_states_list //

create procedure _peek_states_list(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   expected_states_list text charset utf8,
   in	allow_spaces tinyint unsigned,
   in	allow_trailing_states tinyint unsigned,
   in	return_tokens_array_id tinyint unsigned,
   out  tokens_array_id varchar(16) charset ascii,
   out	tokens_matched_to int unsigned
) 
comment 'Check if given states list apply'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  declare num_states int unsigned default 0;
  declare states_index int unsigned;
  declare expected_states text charset utf8;
  declare matched_token text charset utf8;
  declare token_has_matched tinyint unsigned default false;
  declare current_state tinytext charset utf8;
  declare states_matched tinyint unsigned default false;
  
  if return_tokens_array_id then
    call _create_array(tokens_array_id);
  end if;
  set tokens_matched_to := 0;
  
  -- allow for spaces before states
  call _skip_spaces(id_from, id_to);
  
  set num_states := get_num_tokens(expected_states_list, ',');
  set states_index := 1;
  while states_index <= num_states do
    set expected_states := split_token(expected_states_list, ',', states_index);
    select token, FIND_IN_SET(state, REPLACE(expected_states, '|', ',')) is true from _sql_tokens where id = id_from into matched_token, token_has_matched;
    if token_has_matched then
      set tokens_matched_to := id_from;
    else
      set tokens_matched_to := 0;
      leave main_body;
    end if;
    set id_from := id_from + 1;
    if allow_spaces then
      call _skip_spaces(id_from, id_to);
    end if;
    if return_tokens_array_id then
      call _push_array_element(tokens_array_id, matched_token);
    end if;
    set states_index := states_index + 1;
  end while;
  
  if allow_trailing_states then
    -- don't care about the rest
    leave main_body;
  end if;
 
  -- expect nothing more but spaces
  call _skip_spaces(id_from, id_to);
  if id_from <= id_to then
    set tokens_matched_to := 0;
    leave main_body;
  end if;
end;
//

delimiter ;
