--
--
--

delimiter //

drop procedure if exists _consume_try_statement //

create procedure _consume_try_statement(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   expect_single tinyint unsigned,
   out  consumed_to_id int unsigned,
   in depth int unsigned,
   in should_execute_statement tinyint unsigned,
   out try_statement_error_found int unsigned
)
comment 'Invokes statement in try{} block'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  -- declare continue handler for 1052 set try_statement_error_found = 1051;
  -- declare continue handler for 1146 set try_statement_error_found = 1146;
  declare continue handler for SQLEXCEPTION set try_statement_error_found = true;
  
  set try_statement_error_found := false;
  call _consume_statement(id_from, id_to, expect_single, consumed_to_id, depth, false, should_execute_statement);
  -- select try_statement_error_found;
end;
//

delimiter ;
