--
-- Assign input values into local variables
--

delimiter //

drop procedure if exists _assign_input_local_variables //

create procedure _assign_input_local_variables(
   variables_array_id int unsigned
)
comment 'Declares local variables'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare num_variables int unsigned;
  declare variable_index int unsigned default 0;
  declare local_variable varchar(65) charset ascii;
  declare user_defined_variable_name varchar(65) charset ascii;
  declare reset_query text charset ascii;
  
  call _get_array_size(variables_array_id, num_variables);
  set variable_index := 1;
  while variable_index <= num_variables do
    call _get_array_element(variables_array_id, variable_index, local_variable);
    SELECT mapped_user_defined_variable_name FROM _qs_variables WHERE variable_name = local_variable INTO user_defined_variable_name;
    
    set reset_query := CONCAT('SET ', user_defined_variable_name, ' := @_query_script_input_col', variable_index);
    call exec_single(reset_query);
    
    set variable_index := variable_index + 1;
  end while;
end;
//

delimiter ;
