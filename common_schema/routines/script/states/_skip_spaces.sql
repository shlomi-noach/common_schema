--
--
--

delimiter //

drop procedure if exists _skip_spaces //

create procedure _skip_spaces(
   inout   id_from      int unsigned,
   in   id_to      int unsigned
)
comment 'Skips whitespace tokens'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    call _skip_tokens_and_spaces(id_from, id_to, null);
end;
//

delimiter ;
