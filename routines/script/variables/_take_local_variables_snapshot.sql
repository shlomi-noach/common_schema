--
-- Assign input values into local variables
--

delimiter //

drop procedure if exists _take_local_variables_snapshot //

create procedure _take_local_variables_snapshot(
   expanded_variables text charset utf8
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
  declare snapshot_query text charset ascii;

  set num_variables := get_num_tokens(expanded_variables, ',');
  set variable_index := 1;
  while variable_index <= num_variables do
    set local_variable := split_token(expanded_variables, ',', variable_index);
    set @_user_defined_variable_name=null;
    SELECT
        mapped_user_defined_variable_name
      FROM
        _qs_variables
      WHERE
        variable_name = local_variable
        and function_scope IN ('', _get_current_variables_function_scope())
      ORDER BY
        function_scope DESC
      LIMIT 1
      INTO
        @_user_defined_variable_name;
    set user_defined_variable_name=@_user_defined_variable_name;

    set snapshot_query := CONCAT('UPDATE _qs_variables SET value_snapshot = ', user_defined_variable_name, ' WHERE variable_name = ', QUOTE(local_variable));
    call exec_single(snapshot_query);

    set variable_index := variable_index + 1;
  end while;
end;

//

delimiter ;
