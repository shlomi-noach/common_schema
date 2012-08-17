--
--
--

delimiter //

drop procedure if exists _skip_tokens_and_spaces //

create procedure _skip_tokens_and_spaces(
   inout   id_from      int unsigned,
   in   id_to      int unsigned,
   in	tokens_list text charset utf8
)
comment 'Skips whitespace and given tokens'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    call _skip_states(id_from, id_to, 'whitespace,single line comment,multi line comment,start', tokens_list);
end;
//

delimiter ;
