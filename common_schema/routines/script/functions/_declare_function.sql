--
--
--

delimiter //

drop procedure if exists _declare_function //

create procedure _declare_function(
    declare_function_name VARCHAR(65) CHARSET ascii,
    function_declaration_id INT UNSIGNED,
    function_arguments_declaration_id int unsigned,
    function_scope_start_id INT UNSIGNED,
    function_scope_end_id INT UNSIGNED,
    function_arguments_array_id int unsigned,
    throw_when_exists tinyint unsigned
)
comment 'Declares a function'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare imploded_function_arguments text charset utf8;
    declare local_count_function_arguments int unsigned default 0;
    
    call _get_array_size(function_arguments_array_id, local_count_function_arguments); 
    set imploded_function_arguments := _implode_nospace_array(function_arguments_array_id); 

    INSERT IGNORE INTO _qs_functions (server_id, session_id, function_name, declaration_id, arguments_declaration_id, scope_start_id, scope_end_id, count_function_arguments, function_arguments) 
      VALUES (_get_server_id(), CONNECTION_ID(), declare_function_name, function_declaration_id, function_arguments_declaration_id, function_scope_start_id, function_scope_end_id, local_count_function_arguments, imploded_function_arguments);

    if ROW_COUNT() = 0 and throw_when_exists then
      call _throw_script_error(function_declaration_id, CONCAT('Duplicate function name: ', declare_function_name));
    end if;
	update _qs_variables set scope_end_id = function_scope_end_id where declaration_id = function_arguments_declaration_id;
end;
//

delimiter ;
