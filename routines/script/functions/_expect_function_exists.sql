--
-- Expect a given state, possible padded with whitespace, or raise an error.
--

delimiter //

drop procedure if exists _expect_function_exists //

create procedure _expect_function_exists(
	in	 id_from int unsigned,
    in   check_function_name text charset utf8
)
comment 'Expects existence of function by name'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  declare function_found tinyint unsigned default FALSE;

  select count(*) from _qs_functions where function_name = check_function_name into @_function_found;
	set function_found=@_function_found;

  if not function_found then
    call _throw_script_error(id_from, CONCAT('Cannot find function: ', check_function_name));
  end if;
end;
//

delimiter ;
