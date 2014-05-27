--
-- Given a state (or optional states), expect a dynamic length comma 
-- delimited list where each element is given state(s).
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
  call _match_states(id_from, id_to, expected_states, false, false, 0, 'comma', true, true, @_common_schema_dummy, tokens_array_id, @_common_schema_dummy, @_common_schema_dummy);
end;
//

delimiter ;
