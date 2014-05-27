-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- 

DELIMITER $$

DROP procedure IF EXISTS rdebug_compile_routine $$
CREATE procedure rdebug_compile_routine(
  in rdebug_routine_schema varchar(128) charset utf8,
  in rdebug_routine_name   varchar(128) charset utf8,
  in debug_info     bool
  )
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

BEGIN
  declare quoting_characters VARCHAR(5) CHARSET ascii DEFAULT '`''';
  declare compiled_body, compiled_body_utf8 longblob;
  declare debug_code text charset utf8 default '';
  declare first_statement_debug_code text charset utf8;
  declare first_valid_for_breakpoint_debug_code text charset utf8;
  declare first_valid_for_breakpoint_id int unsigned default null;
  declare debug_code_start varchar(64) charset utf8 default _rdebug_get_debug_code_start();
  declare debug_code_end varchar(64) charset utf8 default _rdebug_get_debug_code_end();
  declare routine_param_list blob default null;

  set @__debug_group_concat_max_len := @@group_concat_max_len;
  set @@group_concat_max_len := GREATEST(@@group_concat_max_len, 32 * 1024 * 1024);
  
  if not find_in_set('ANSI_QUOTES', @@sql_mode) then
    set quoting_characters := CONCAT(quoting_characters, '"');
  end if;

  -- Get current routine body:
  set compiled_body := null;
  select body, body_utf8, param_list from mysql.proc where db = rdebug_routine_schema and name = rdebug_routine_name into compiled_body, compiled_body_utf8, routine_param_list;
  if compiled_body is null then
    call throw(CONCAT('Unknown routine: ', mysql_qualify(rdebug_routine_schema), '.', mysql_qualify(rdebug_routine_name)));
  end if;
  
  -- Remove any existing debug code
  set compiled_body := replace_sections(compiled_body, debug_code_start, debug_code_end, '');
  set compiled_body_utf8 := replace_sections(compiled_body_utf8, debug_code_start, debug_code_end, '');

  begin
    declare v_from, v_old_from int unsigned;
    declare v_token text;
    declare v_level int;
    declare v_state varchar(32);
    declare _sql_tokens_id int unsigned default 0;
    
    drop temporary table if exists _routine_tokens;
    create temporary table _routine_tokens(
        id int unsigned primary key
    ,   start int unsigned  not null
    ,   level int not null
    ,   token text          
    ,   state text           not null
    ,   nesting_level int unsigned default 0
    ,   is_valid_for_breakpoint tinyint unsigned default 0
    ,   is_declare_variables_statement tinyint unsigned default 0
    ,   is_first_statement tinyint unsigned default 0
    ) engine=MyISAM;
    
    repeat 
      set v_old_from = v_from;
      call _get_sql_token(compiled_body, v_from, v_level, v_token, 'routine', v_state);
      set _sql_tokens_id := _sql_tokens_id + 1;
      insert into _routine_tokens(id,start,level,token,state) 
      values (_sql_tokens_id, v_from - char_length(v_token), v_level, v_token, v_state);
    until 
      v_old_from = v_from
    end repeat;
  end;
  
  if debug_info then
    set debug_code := '';
    set debug_code := concat(debug_code, '_RDEBUG_RESTORE_STACK_LEVEL');
    set debug_code := concat(debug_code, '_RDEBUG_EXPORT_VARIABLES');
    set debug_code := concat(debug_code, 'call ', database(), '._rdebug_on_breakpoint(_RDEBUG_BREAKPOINT_ID,', QUOTE(rdebug_routine_schema), ',', QUOTE(rdebug_routine_name),');');
    set debug_code := concat(debug_code, '_RDEBUG_IMPORT_VARIABLES');
    set debug_code := concat(debug_code_start, _rdebug_get_debug_code_breakpoint_hint_start(), '_RDEBUG_BREAKPOINT_ID', _rdebug_get_debug_code_breakpoint_hint_end(), debug_code, debug_code_end);
    
    set first_statement_debug_code := concat('declare _rdebug_stack_level_ int unsigned default (@_rdebug_stack_level_ := ', database(), '._rdebug_get_next_stack_level());');
    set first_statement_debug_code := concat(debug_code_start, first_statement_debug_code, debug_code_end);
    
    set first_valid_for_breakpoint_debug_code := concat('call ', database(), '._rdebug_on_routine_entry(', QUOTE(rdebug_routine_schema), ',', QUOTE(rdebug_routine_name), ');');
    set first_valid_for_breakpoint_debug_code := concat(debug_code_start, first_valid_for_breakpoint_debug_code, debug_code_end);
    
    call _rdebug_analyze_routine(rdebug_routine_schema, rdebug_routine_name);
    call _rdebug_analyze_routine_params(rdebug_routine_schema, rdebug_routine_name, routine_param_list, quoting_characters);
    call _rdebug_analyze_routine_variables_scope(rdebug_routine_schema, rdebug_routine_name);

    select id from _routine_tokens where is_valid_for_breakpoint order by id limit 1 into first_valid_for_breakpoint_id;
    -- Rebuild routine body, with debug info:
    select 
        group_concat(
          if(is_first_statement, first_statement_debug_code, ''),
          if(id = first_valid_for_breakpoint_id, first_valid_for_breakpoint_debug_code, ''),
          if(
            is_valid_for_breakpoint, 
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
              debug_code, 
                '_RDEBUG_BREAKPOINT_ID', id ), 
                '_RDEBUG_EXPORT_VARIABLES', IF(export_variables is not null, CONCAT('set ', export_variables, ';'), '') ),
                '_RDEBUG_IMPORT_VARIABLES', IF(import_variables is not null, CONCAT('set ', import_variables, ';'), '') ),
                '_RDEBUG_RESTORE_STACK_LEVEL', 'set @_rdebug_stack_level_ := _rdebug_stack_level_;' ),
            '' -- not valid for breakpoint -- we pad nothing prior to token
          ), token 
          order by id separator '' 
        ) 
      from (
        select 
          _routine_tokens.*, 
          group_concat(variable_name order by variable_name) as variable_names,
          group_concat(if(variable_type in ('local', 'param'), concat(variable_name,':= ', '@$_$',variable_name), NULL) order by variable_name) as import_variables,
          group_concat(if(variable_type in ('local', 'param'), concat('@$_$',variable_name,':= ', variable_name), NULL) order by variable_name) as export_variables
        from 
          _routine_tokens
          left join _rdebug_routine_variables on (
            _routine_tokens.id between _rdebug_routine_variables.variable_scope_id_start and _rdebug_routine_variables.variable_scope_id_end
            and routine_schema = rdebug_routine_schema and routine_name = rdebug_routine_name
          )
        group by 
          _routine_tokens.id,
          _routine_tokens.start,
          _routine_tokens.level,
          _routine_tokens.token,
          _routine_tokens.state,
          _routine_tokens.nesting_level,
          _routine_tokens.is_valid_for_breakpoint,
          _routine_tokens.is_declare_variables_statement,
          _routine_tokens.is_first_statement
        ) select_tokens_variables
      into 
        compiled_body;
    set compiled_body_utf8 := compiled_body;
  end if;
  
  update mysql.proc set body = compiled_body, body_utf8 = compiled_body_utf8 where db = rdebug_routine_schema and name = rdebug_routine_name;
  -- select compiled_body;

  call _rdebug_invalidate_routine_cache();
  
  set @@group_concat_max_len := @__debug_group_concat_max_len;  
END $$

DELIMITER ;
