--
--
--

delimiter //

drop procedure if exists _consume_split_statement //

create procedure _consume_split_statement(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   out  consumed_to_id int unsigned,
   in   depth int unsigned,
   out  split_table_schema tinytext charset utf8,
   out  split_table_name tinytext charset utf8,
   out  split_injected_action_statement text charset utf8,
   out  split_injected_text tinytext charset utf8,
   in should_execute_statement tinyint unsigned
)
comment 'Reads split() expression'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare first_state text;
    declare expression_level int unsigned;
    declare id_end_action_statement int unsigned default NULL; 
    declare id_end_split_table_declaration int unsigned default NULL; 
    declare peek_match_to int unsigned default NULL; 
    declare table_array_id varchar(16);
    declare colon_exists tinyint unsigned default false;
    declare explicit_table_exists tinyint unsigned default false;
    declare split_statement_exists tinyint unsigned default false;
    
    call _skip_spaces(id_from, id_to);
    SELECT level, state FROM _sql_tokens WHERE id = id_from INTO expression_level, first_state;

    -- Validate syntax:
    if (first_state != 'left parenthesis') then
      call _throw_script_error(id_from, 'Expected "(" on split expression');
    end if;
    
    SELECT MIN(id) FROM _sql_tokens WHERE id > id_from AND state = 'right parenthesis' AND level = expression_level INTO id_end_action_statement;
  	if id_end_action_statement IS NULL then
	  call _throw_script_error(id_from, 'Unmatched "(" parenthesis');
	end if;
	
	-- Detect the separator:
    SELECT MIN(id) FROM _sql_tokens WHERE id > id_from AND state = 'colon' AND level = expression_level INTO id_end_split_table_declaration;
    set colon_exists := (id_end_split_table_declaration IS NOT NULL);
  	if id_end_split_table_declaration IS NULL then
  	  set id_end_split_table_declaration := id_end_action_statement;
	end if;
	
    set id_from := id_from + 1;
	
	-- Expect schema.table:
	-- call _peek_states_list(id_from, id_end_split_table_declaration-1, 'alpha|alphanum|quoted identifier,dot,alpha|alphanum|quoted identifier', true, @peek_result);
	-- select @peek_result;
    set split_injected_text := '[:_query_script_split_injected_placeholder:]';
	
    if colon_exists then
      -- expect table_schema.table_name : statement
      call _expect_exact_states_list(id_from, id_end_split_table_declaration-1, 'alpha|alphanum|quoted identifier,dot,alpha|alphanum|quoted identifier', table_array_id);
      call _get_array_element(table_array_id, '1', split_table_schema);		
      call _get_array_element(table_array_id, '3', split_table_name);
      set split_table_schema := unquote(split_table_schema);
      set split_table_name := unquote(split_table_name);
      call _drop_array(table_array_id);

      -- Get the action statement clause:
      set id_from := id_end_split_table_declaration + 1;
      call _skip_spaces(id_from, id_to);

      call _inject_split_where_token(id_from, id_end_action_statement - 1, split_injected_text, split_injected_action_statement);
      
      set explicit_table_exists := true;
      set split_statement_exists := true;
    else
      begin
        -- expect table_schema.table_name
        -- OR statement
        declare query_type_supported tinyint unsigned;
        declare tables_found varchar(32) charset ascii;

        call _create_array(table_array_id);
        call _peek_states_list(id_from, id_end_split_table_declaration-1, 'alpha|alphanum|quoted identifier,dot,alpha|alphanum|quoted identifier', false, false, true, table_array_id, peek_match_to);
        if peek_match_to > 0 then
          -- we have table_schema.table_name, and no statement
          call _get_array_element(table_array_id, '1', split_table_schema);		
          call _get_array_element(table_array_id, '3', split_table_name);
          set split_table_schema := unquote(split_table_schema);
          set split_table_name := unquote(split_table_name);
          set split_injected_action_statement := CONCAT('SELECT COUNT(NULL) FROM ', mysql_qualify(split_table_schema), '.', mysql_qualify(split_table_name), ' WHERE ', split_injected_text, ' INTO @_common_schema_dummy');
          set explicit_table_exists := true;
        else
          -- Try and get a statement and extract table_schema.table_name
          call _skip_spaces(id_from, id_end_action_statement - 1);
          call _get_split_query_single_table(id_from, id_end_action_statement - 1, query_type_supported, tables_found, split_table_schema, split_table_name);
          if split_table_schema is not null and split_table_name is not null then
            -- Got it!
            call _inject_split_where_token(id_from, id_end_action_statement - 1, split_injected_text, split_injected_action_statement);
          else
            -- Can't get single table name. Either multi table or using hints or subquery...
            call _throw_script_error(id_from, 'split() cannot deduce split table name. Please specify explicitly');
          end if;
        end if;
        call _drop_array(table_array_id);
      end;
    end if;
    
    set consumed_to_id := id_end_action_statement;
end;
//

delimiter ;
