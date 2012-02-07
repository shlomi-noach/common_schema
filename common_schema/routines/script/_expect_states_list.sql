--
-- Expects a comma delimited list of states
--

delimiter //

drop procedure if exists _expect_states_list //

create procedure _expect_states_list(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   expected_states_list text charset utf8,
   out  tokens_array_id VARCHAR(16) charset ascii
) 
comment 'Expects a state or raises error'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  declare num_states int unsigned default 0;
  declare states_index int unsigned default 0;
  declare expected_states text charset utf8;
  declare matched_token text charset utf8;
  declare consumed_to_id int unsigned default NULL;
  
  call _create_array(tokens_array_id);
  
  set num_states := get_num_tokens(expected_states_list, ',');
  set states_index := 1;
  while states_index <= num_states do
    set expected_states := split_token(expected_states_list, ',', states_index);
    call _expect_state(id_from, id_to, consumed_to_id, expected_states, matched_token);
    call _push_array_element(tokens_array_id, matched_token);
    set id_from := consumed_to_id + 1;
    if states_index < num_states then
      call _expect_state(id_from, id_to, consumed_to_id, 'comma', @_common_schema_dummy);
      set id_from := consumed_to_id + 1;
    end if;
    set states_index := states_index + 1;
  end while;
  -- If we got here that means all states have matched.
  call _expect_nothing(id_from, id_to);
end;
//

delimiter ;
