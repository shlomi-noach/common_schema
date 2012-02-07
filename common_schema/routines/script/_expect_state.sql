--
-- Expect a given state, possible padded with whitespace, or raise an error.
--

delimiter //

drop procedure if exists _expect_state //

create procedure _expect_state(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   inout  consumed_to_id int unsigned,
   in   expected_states text charset utf8,
   out  matched_token text charset utf8
) 
comment 'Expects a state or raises error'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  declare state_has_matched tinyint unsigned default FALSE;

  call _consume_if_exists(id_from, id_to, consumed_to_id, NULL, expected_states, state_has_matched, matched_token);
  if not state_has_matched then
    call _throw_script_error(id_from, CONCAT('Expected ', REPLACE(expected_states, '|', '/')));
  end if;
end;
//

delimiter ;
