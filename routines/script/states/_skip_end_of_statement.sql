--
--
--

delimiter //

drop procedure if exists _skip_end_of_statement //

create procedure _skip_end_of_statement(
   inout   id_from      int unsigned,
   in   id_to      int unsigned
)
comment 'Skips enf of statement state'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
	call _skip_states(id_from, id_to, 'statement delimiter,start', null);
end;
//

delimiter ;
