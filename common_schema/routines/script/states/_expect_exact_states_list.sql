--
-- Expects an exact list of states.
-- spaces are only allowed before and after list of states, but not between states.
--

delimiter //

drop procedure if exists _expect_exact_states_list //

create procedure _expect_exact_states_list(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   expected_states_list text charset utf8,
   out  tokens_array_id VARCHAR(16) charset ascii
) 
comment 'Expects states or raises error'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  call _match_states(id_from, id_to, expected_states_list, false, false, 1, null, true, true, @_common_schema_dummy, tokens_array_id, @_common_schema_dummy, @_common_schema_dummy);
end;
//

delimiter ;
