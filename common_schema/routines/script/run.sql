--
-- Run a given QueryScript code
--

delimiter //

drop procedure if exists run //

create procedure run(
  in query_script text
)
comment 'Run given QueryScript text'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  call _interpret(query_script, TRUE);
end;

//

delimiter ;
