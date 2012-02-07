--
-- Given a state (or optional states), expect a comma delimited list where
-- each element is given state(s).
-- This differs from _expect_states_list() where a specific number of elements, each
-- of specific type are expected.
--

delimiter //

drop procedure if exists _expect_dynamic_states_list //

create procedure _expect_dynamic_states_list(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   expected_states text charset utf8,
   out  tokens_array_id VARCHAR(16) charset ascii
) 
comment 'Expects a state or raises error'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  declare matched_token text charset utf8;
  declare consumed_to_id int unsigned default NULL;
  declare state_has_matched tinyint unsigned default FALSE;
  
  call _create_array(tokens_array_id);

  consume_loop: repeat
    call _expect_state(id_from, id_to, consumed_to_id, expected_states, matched_token);
    call _push_array_element(tokens_array_id, matched_token);
    set id_from := consumed_to_id + 1;

    call _consume_if_exists(id_from, id_to, consumed_to_id, NULL, 'comma', state_has_matched, @_common_schema_dummy);
    if not state_has_matched then
      leave consume_loop;
    end if;
    set id_from := consumed_to_id + 1;
  until false
  end repeat;
  call _expect_nothing(id_from, id_to);
end;
//

delimiter ;
