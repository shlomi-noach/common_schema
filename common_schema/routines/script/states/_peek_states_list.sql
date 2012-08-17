--
-- Check if given states list apply.
-- Returned value: tokens_matched_to, the id of last matched token, or 0 on mismatch
--

delimiter //

drop procedure if exists _peek_states_list //

create procedure _peek_states_list(
   in   id_from					int unsigned,
   in   id_to					int unsigned,
   in   expected_states_list	text charset utf8,
   in	allow_spaces			tinyint unsigned,
   in	allow_trailing_states	tinyint unsigned,
   in	return_tokens_array_id	tinyint unsigned,
   out  tokens_array_id			varchar(16) charset ascii,
   out	tokens_matched_to		int unsigned
) 
comment 'Check if given states list apply'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  declare states_have_matched tinyint unsigned default false;

  call _match_states(id_from, id_to, expected_states_list, allow_spaces, allow_trailing_states, 1, null, return_tokens_array_id, false, states_have_matched, tokens_array_id, @_common_schema_dummy, tokens_matched_to);
  if not states_have_matched then
    set tokens_matched_to := 0;
  end if;
end;
//

delimiter ;
