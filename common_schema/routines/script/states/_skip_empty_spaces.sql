--
-- Skips empty spaces (the '' tokens)
-- Required be case of hack converting the :${t} expanded variable format
-- from multiple tokens into a singe token, emptying the rest of the tokens.
--

delimiter //

drop procedure if exists _skip_empty_spaces //

create procedure _skip_empty_spaces(
   inout   id_from      int unsigned,
   in   id_to      int unsigned
)
comment 'Skips empty whitespace tokens'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    select min(id) from _sql_tokens 
      where id >= id_from and id <= id_to 
      and (state, CHAR_LENGTH(token)) != ('whitespace', 0) 
    into id_from;
    if id_from is null then
      set id_from := id_to + 1;
    end if;
end;
//

delimiter ;
