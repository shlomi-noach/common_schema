--
--
--

delimiter //

drop procedure if exists _consume_if_exists //

create procedure _consume_if_exists(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   inout  consumed_to_id int unsigned,
   in   expected_token text charset utf8,
   in   expected_states text charset utf8,
   out  token_has_matched tinyint unsigned,
   out  matched_token text charset utf8
) 
comment 'Consumes token or state if indeed exist'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  call _skip_spaces(id_from, id_to);
  set token_has_matched := FALSE;
  SELECT token, ((token = expected_token) OR FIND_IN_SET(state, REPLACE(expected_states, '|', ','))) IS TRUE FROM _sql_tokens WHERE id = id_from INTO matched_token, token_has_matched;
  if token_has_matched then
    set consumed_to_id = id_from;
  end if;
end;
//

delimiter ;
