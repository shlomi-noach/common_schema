--
-- A private case for _Expect_state, which is all too common
--

delimiter //

drop procedure if exists _expect_statement_delimiter //

create procedure _expect_statement_delimiter(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   out  consumed_to_id int unsigned
) 
comment 'Expects ";" or raises error'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  call _expect_state(id_from, id_to, 'statement delimiter', true, consumed_to_id, @_common_schema_dummy);
end;
//

delimiter ;
