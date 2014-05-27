-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- 

DELIMITER $$

DROP procedure IF EXISTS _rdebug_analyze_routine $$
CREATE procedure _rdebug_analyze_routine(
  in rdebug_routine_schema varchar(128) charset utf8,
  in rdebug_routine_name   varchar(128) charset utf8
)
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

main_body: BEGIN
  declare current_id int unsigned;
  declare current_pos int unsigned;
  declare current_token text charset utf8;
  declare current_state varchar(32);
  declare is_beginning_of_statement tinyint unsigned default false;
  declare is_labeled_statement tinyint unsigned default false;
  declare expected_token varchar(32) charset ascii default null;
  declare next_nesting_block_id int unsigned default 0;
  declare declare_variables_statement_id int unsigned default null;
  declare valid_breakpoint_statement_id int unsigned default null;
  declare valid_breakpoint_statement_pos int unsigned default null;
  declare first_begin_id int unsigned default null;
  declare first_statement_id int unsigned default null;
  
  declare cursor_done tinyint unsigned default false;
  declare tokens_cursor cursor for select id, start, token, state from _routine_tokens;
  declare continue handler for not found set cursor_done := true;

  update _routine_tokens set nesting_level = 0, is_valid_for_breakpoint = 0, is_declare_variables_statement = 0, is_first_statement = 0;
  delete from _rdebug_routine_statements where routine_schema = rdebug_routine_schema and routine_name = rdebug_routine_name;
  delete from _rdebug_routine_variables where routine_schema = rdebug_routine_schema and routine_name = rdebug_routine_name;
  delete from _rdebug_routine_variables_state where routine_schema = rdebug_routine_schema and routine_name = rdebug_routine_name;
  delete from _rdebug_breakpoint_hints where routine_schema = rdebug_routine_schema and routine_name = rdebug_routine_name;

  open tokens_cursor;
  tokens_cursor_loop: loop
    fetch tokens_cursor into current_id, current_pos, current_token, current_state; 
    if cursor_done then
      leave tokens_cursor_loop;
    end if;
    set current_token := lower(current_token);
    if current_state in ('whitespace', 'single line comment', 'multi line comment') then
      iterate tokens_cursor_loop;
    end if;
    if current_state in ('colon') and first_begin_id is not null then
      -- This is a label. However, we completely ignore the label for the BEGIN statement 
      -- of the routine (hecne check for first_begin_id), since it has nothing to do with statements...
      set is_beginning_of_statement := true;
      set is_labeled_statement := true;
      set expected_token := '';
      iterate tokens_cursor_loop;
    end if;
    if (current_state, current_token) = ('alpha', 'begin') then
      if first_begin_id is null then
        set first_begin_id := current_id;
      end if;
      update _routine_tokens set nesting_level = nesting_level + 1 where id >= current_id;
      set next_nesting_block_id := next_nesting_block_id + 1;
    end if;
    
    if current_state = 'user-defined variable' then
      insert ignore into 
        _rdebug_routine_variables (routine_schema, routine_name, variable_name, variable_scope_id_start, variable_scope_id_end, variable_type)
        values (rdebug_routine_schema, rdebug_routine_name, current_token, 0, NULL, 'user_defined');
    end if;
    
    if (current_state, current_token) = ('alpha', 'begin') or (current_state in ('statement delimiter', 'start')) then
      set is_beginning_of_statement := true;
      if declare_variables_statement_id is not null then
        -- We are now terminating a "declare [var]" statement.
        update _routine_tokens set is_declare_variables_statement = 1 where id = declare_variables_statement_id;
        -- This is a good place to analyze variable names!
        call _rdebug_analyze_routine_declare_statement(rdebug_routine_schema, rdebug_routine_name, declare_variables_statement_id, current_id);
        set declare_variables_statement_id := null;
      end if;
      if valid_breakpoint_statement_id is not null then
        -- this is end of statement. Note!
        insert into 
          _rdebug_routine_statements (routine_schema, routine_name, statement_id, statement_start_pos, statement_end_pos)
        values
          (rdebug_routine_schema, rdebug_routine_name, valid_breakpoint_statement_id, valid_breakpoint_statement_pos, current_pos);
        set valid_breakpoint_statement_id := null;
      end if;
      iterate tokens_cursor_loop;
    end if;
    if expected_token = '' then
      set expected_token := null;
    end if;
    if expected_token is not null and expected_token != current_token then
      iterate tokens_cursor_loop;
    end if;
    if expected_token = current_token then
      -- Found the "expected". But we do not consume it -- we skip it.
      set expected_token := null;

      -- And for some statements (like IF-THEN)
      if valid_breakpoint_statement_id is not null then
        -- this is end of statement. Note!
        insert into 
          _rdebug_routine_statements (routine_schema, routine_name, statement_id, statement_start_pos, statement_end_pos)
        values
          (rdebug_routine_schema, rdebug_routine_name, valid_breakpoint_statement_id, valid_breakpoint_statement_pos, current_pos);
        set valid_breakpoint_statement_id := null;
      end if;
      
      iterate tokens_cursor_loop;
    end if;
    if declare_variables_statement_id is not null and current_token in ('cursor', 'handler', 'condition') then
      -- Not a variable declaration
      set declare_variables_statement_id := null;
    end if;
    
    -- Beginning of a statement:
    if is_beginning_of_statement then
      if first_statement_id is null then
        update _routine_tokens set is_first_statement = 1 where id = current_id;    
        set first_statement_id := current_id;
      end if;
      case current_token 
        when 'if' then set expected_token := 'then';
        when 'else' then set expected_token := '';
        when 'while' then set expected_token := 'do';
        when 'loop' then set expected_token := '';
        when 'repeat' then set expected_token := '';
        when 'when' then set expected_token := 'then';
        else begin end;
      end case;
      if current_token in ('if', 'while', 'repeat', 'loop', 'case') then
        update _routine_tokens set nesting_level = nesting_level + 1 where id >= current_id;
        set next_nesting_block_id := next_nesting_block_id + 1;
      end if;
      if current_token = 'end' then
        update _routine_tokens set nesting_level = nesting_level - 1 where id > current_id;
      end if;
      if (current_token = 'declare') then
        set declare_variables_statement_id := current_id;
      elseif (expected_token is null) or (current_token in ('if', 'while', 'loop', 'repeat')) then
        if not is_labeled_statement then
          -- a labeled statement is one such that is preceeded by a label.
          -- The label position makes for the actual "valid for breakpoint"
          -- but the statement itself is of importance as we ened to figure out how
          -- to handle it (if it's a "WHILE", look for "DO")
          update _routine_tokens set is_valid_for_breakpoint = 1 where id = current_id;
          set valid_breakpoint_statement_id := current_id;
          set valid_breakpoint_statement_pos := current_pos;
        end if;
      end if;
      set is_labeled_statement := false;
      if expected_token is not null then
        iterate tokens_cursor_loop;
      end if;
      set is_beginning_of_statement := false;
    end if;
  end loop;
  close tokens_cursor;
END $$

DELIMITER ;
