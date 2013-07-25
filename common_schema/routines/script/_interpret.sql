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
  declare expanded_variables_ids text charset ascii;
  declare num_expanded_variables_ids int unsigned;
  declare expanded_variable_index int unsigned;
  declare current_expanded_variable_id int unsigned;
  /*!50500
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
      call _cleanup_script_tables();
      RESIGNAL;
    END;
   */
  
  set @@max_sp_recursion_depth := 127;
  set @__script_group_concat_max_len := @@group_concat_max_len;
  set @@group_concat_max_len := GREATEST(@@group_concat_max_len, 32 * 1024 * 1024);
  
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

  delete from _qs_variables;
  
  -- Identify ${my_var} expanded variables. These are initially not identified as a state.
  -- We hack the _sql_tokens table to make these in their own state, combining multiple rows into one,
  -- leaving previously occupied rows as empty strings.
  select group_concat(id order by id) from _sql_tokens where state='expanded query_script variable' and token=':$' into expanded_variables_ids;
  if expanded_variables_ids then
    set num_expanded_variables_ids := get_num_tokens(expanded_variables_ids, ',');
    set expanded_variable_index := 1;
    while expanded_variable_index <= num_expanded_variables_ids do
      set current_expanded_variable_id := split_token(expanded_variables_ids, ',', expanded_variable_index);
      select 
          GROUP_CONCAT(token ORDER BY id SEPARATOR '') AS expanded_variable_tokens, 
          (
            GROUP_CONCAT(state ORDER BY id) = 'left braces,alpha,right braces' OR
            GROUP_CONCAT(state ORDER BY id) = 'left braces,alphanum,right braces' 
          ) AS expanded_variable_match
        from _sql_tokens where id between current_expanded_variable_id+1 and current_expanded_variable_id+3
        into @_expanded_variable_tokens, @_expanded_variable_match;

      if @_expanded_variable_match then
        -- set @_expanded_variable_tokens := replace_all(@_expanded_variable_tokens, '${}', '');
        -- set @_expanded_variable_tokens := CONCAT(':$',@_expanded_variable_tokens);
        update _sql_tokens set token = CONCAT(':$', @_expanded_variable_tokens) where id = current_expanded_variable_id;
        update _sql_tokens set token = '', state = 'whitespace', level = level - 1 where id between current_expanded_variable_id+1 and current_expanded_variable_id+3;
      end if;
      
      set expanded_variable_index := expanded_variable_index + 1;
    end while;    
  end if;
  
  set @_common_schema_script_break_type := NULL;
  set @_common_schema_script_loop_nesting_level := 0;
  set @_common_schema_script_throttle_chunk_start := NULL;
  set @_common_schema_script_start_timestamp := NOW();
  set @_common_schema_script_report_used := false;
  set @_common_schema_script_report_delimiter := '';

  -- We happen to know tokens in _sql_tokens begin at "1". So "0" is a safe 
  -- place not to step on anyone's toes.
  call _declare_local_variable(0, 0, id_to, 0, '$rowcount', '@query_script_rowcount', FALSE);
  call _declare_local_variable(0, 0, id_to, 0, '$found_rows', '@query_script_found_rows', FALSE);
  
  -- First, do syntax validation: go through the code, but execute nothing:
  call _consume_statement(id_from, id_to, FALSE, id_to, 0, FALSE);
  -- Now, if need be, execute it:
  if should_execute_statement then
    -- delete from _qs_variables;
    call _consume_statement(id_from, id_to, FALSE, id_to, 0, TRUE);
  end if;
  
  if @_common_schema_script_report_used then
    call _script_report_finalize();
  end if;
  
  set @@group_concat_max_len := @__script_group_concat_max_len;
  call _cleanup_script_tables();
end;
//

delimiter ;
