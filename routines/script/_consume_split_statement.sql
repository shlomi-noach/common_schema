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
   out	split_options varchar(2048) charset utf8,
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
    declare query_type_supported tinyint unsigned;
    declare tables_found varchar(32) charset ascii;
    declare colon_exists tinyint unsigned default false;
    declare found_explicit_table tinyint unsigned;
    declare found_any_params tinyint unsigned;
    declare found_possible_statement tinyint unsigned;

    call _skip_spaces(id_from, id_to);
    set @_expression_level=null, @_first_state=null;
    SELECT level, state FROM _sql_tokens WHERE id = id_from INTO @_expression_level, @_first_state;
    set expression_level=@_expression_level;
    set first_state=@_first_state;

    -- Validate syntax:
    if (first_state != 'left parenthesis') then
      call _throw_script_error(id_from, 'Expected "(" on split expression');
    end if;

    SELECT MIN(id) FROM _sql_tokens WHERE id > id_from AND state = 'right parenthesis' AND level = expression_level INTO @_id_end_action_statement;
    set id_end_action_statement=@_id_end_action_statement;
  	if id_end_action_statement IS NULL then
	  call _throw_script_error(id_from, 'Unmatched "(" parenthesis');
	end if;

	-- Detect the separator:
    SELECT MIN(id) FROM _sql_tokens WHERE id > id_from AND state = 'colon' AND level = expression_level INTO @_id_end_split_table_declaration;
    set id_end_split_table_declaration=@_id_end_split_table_declaration;
    set colon_exists := (id_end_split_table_declaration IS NOT NULL);
  	if id_end_split_table_declaration IS NULL then
  	  set id_end_split_table_declaration := id_end_action_statement;
	end if;

    set id_from := id_from + 1;

    set split_injected_text := '[:_query_script_split_injected_placeholder:]';

    set found_possible_statement := true;
    if colon_exists then
      call _consume_split_statement_params(id_from, id_end_split_table_declaration-1, should_execute_statement, split_table_schema, split_table_name, split_options, found_explicit_table, found_any_params);
      if not found_any_params then
        call _throw_script_error(id_from, 'split: must indicate table or options before colon; otherwise drop colon');
      end if;

      -- Get the action statement clause:
      set id_from := id_end_split_table_declaration + 1;
      call _skip_spaces(id_from, id_to);
    else
      -- colon does not exist
      call _consume_split_statement_params(id_from, id_end_split_table_declaration-1, should_execute_statement, split_table_schema, split_table_name, split_options, found_explicit_table, found_any_params);
      if found_any_params then
        -- no statement
        set found_possible_statement := false;
      end if;
    end if;

    if not (found_possible_statement or found_explicit_table) then
      call _throw_script_error(id_from, 'split: no statement nor table provided. Provide at least either one');
    end if;

    if found_possible_statement then
      if not found_explicit_table then
        call _skip_spaces(id_from, id_end_action_statement - 1);
        call _get_split_query_single_table(id_from, id_end_action_statement - 1, query_type_supported, tables_found, split_table_schema, split_table_name);
        call _expand_single_variable(id_from, id_end_action_statement - 1, split_table_schema, should_execute_statement);
        call _expand_single_variable(id_from, id_end_action_statement - 1, split_table_name, should_execute_statement);
        if should_execute_statement and ((split_table_schema is null) or (split_table_name is null)) then
          -- Can't get single table name. Either multi table or using hints or subquery...
          call _throw_script_error(id_from, 'split() cannot deduce split table name. Please specify explicitly');
        end if;
      end if;
      call _inject_split_where_token(id_from, id_end_action_statement - 1, split_injected_text, should_execute_statement, split_injected_action_statement);
    else
      set split_injected_action_statement := CONCAT('SELECT COUNT(NULL) FROM ', mysql_qualify(split_table_schema), '.', mysql_qualify(split_table_name), ' WHERE ', split_injected_text, ' INTO @_common_schema_dummy');
    end if;

    set consumed_to_id := id_end_action_statement;
end;
//

delimiter ;
