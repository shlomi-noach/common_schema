--
--
--

delimiter //

drop procedure if exists _skip_states //

create procedure _skip_states(
   inout   id_from      int unsigned,
   in   id_to      int unsigned,
   in	states_list text charset utf8,
   in	tokens_list text charset utf8
)
comment 'Skips given states'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
	set states_list := IFNULL(states_list, '');
	set tokens_list := LOWER(IFNULL(tokens_list, ''));
    select min(id) from _sql_tokens 
      where id >= id_from and id <= id_to 
      and FIND_IN_SET(state, states_list) = 0 
      and FIND_IN_SET(LOWER(token), tokens_list) = 0 
    into id_from;
    if id_from is null then
      set id_from := id_to + 1;
    end if;
end;
//

delimiter ;
