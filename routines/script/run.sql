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
  if (LEFT(query_script, 1) in ('/', '\\')) and (LEFT(query_script, 2) != '/*') then
    begin
	  declare query_script_file_name text;  
      -- Assume filename
      set query_script_file_name := query_script;
      set query_script := LOAD_FILE(query_script_file_name);
      if query_script is null then
        call throw(CONCAT('Cannot load script file: ', query_script_file_name));
      end if;
    end;
  end if;
  call _interpret(query_script, TRUE);
end;

//

delimiter ;
