--
--
--

delimiter //

drop procedure if exists _interpret//

create procedure _interpret(
  in query_script text,
  in should_execute_statement tinyint unsigned
)
comment '...'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare id_from int unsigned;
  declare id_to int unsigned;
  declare end_level int;
  declare negative_level_id int unsigned;
  
  set @@max_sp_recursion_depth := 127;
  
  call _get_sql_tokens(query_script);
  SELECT MIN(id), MAX(id) FROM _sql_tokens INTO id_from, id_to;
  SELECT MIN(id) FROM _sql_tokens WHERE level < 0 INTO negative_level_id;
  if negative_level_id IS NOT NULL then
    call throw(CONCAT('Negative nesting level detected at id ', negative_level_id));
  end if;
  SELECT level FROM _sql_tokens WHERE id = id_to INTO end_level;
  if end_level != 0 then
    call throw('Invalid nesting level detected at end of script');
  end if;

  drop temporary table if exists _qs_variables;
  create temporary table _qs_variables(
      variable_name VARCHAR(65) CHARSET ascii NOT NULL,
      mapped_user_defined_variable_name  VARCHAR(65) CHARSET ascii NOT NULL,
      declaration_depth INT UNSIGNED NOT NULL,
      declaration_id INT UNSIGNED NOT NULL,
      value_snapshot TEXT DEFAULT NULL,
      PRIMARY KEY(variable_name),
      KEY(declaration_depth),
      KEY(declaration_id)
  );
  
  set @_common_schema_script_break_type := NULL;
  set @_common_schema_script_loop_nesting_level := 0;
  set @_common_schema_script_throttle_chunk_start := NULL;
  set @_common_schema_script_start_timestamp := NOW();
    
  -- First, do syntax validation: go through the code, but execute nothing:
  call _consume_statement(id_from, id_to, FALSE, id_to, 0, FALSE);
  -- Now, if need be, execute it:
  if should_execute_statement then
    call _consume_statement(id_from, id_to, FALSE, id_to, 0, TRUE);
  end if;
end;
//

delimiter ;
