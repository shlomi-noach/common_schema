--
-- Read split() parameters
--

delimiter //

drop procedure if exists _consume_split_statement_params //

create procedure _consume_split_statement_params(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   should_execute_statement tinyint unsigned,
   out  split_table_schema tinytext charset utf8,
   out  split_table_name tinytext charset utf8,
   out  split_options varchar(2048) charset utf8,
   out  found_explicit_table tinyint unsigned,
   out  found_any_params tinyint unsigned
)
comment 'Reads split() parameters'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare expanded_statement mediumtext charset utf8;
    declare options_value mediumtext charset utf8;
    
    call _skip_spaces(id_from, id_to);

    set split_table_schema := null;
    set split_table_name := null;
    set split_options := null;
    set found_explicit_table := false;

    call _expand_statement_variables(id_from, id_to, expanded_statement, @_common_schema_dummy, should_execute_statement);
    -- select GROUP_CONCAT(token order by id separator '') from _sql_tokens where id between id_from AND id_to into split_options;
    if _is_options_format(expanded_statement) then
      set split_options := expanded_statement;
      set options_value := get_option(split_options, 'table');
      if options_value is not null then
        if get_num_tokens(options_value, '.') = 2 then
          set split_table_schema := unquote(split_token(options_value, '.', 1));
          set split_table_name := unquote(split_token(options_value, '.', 2));
          set found_explicit_table := true;
        else
          call _throw_script_error(id_from, '''table'' option in split(): expected format schema_name.table_name');
        end if;
      end if;
    else
      begin
        -- watch out for table_schema.table_name
        declare peek_match_to int unsigned default NULL; 
        declare table_array_id varchar(16);
        
        call _create_array(table_array_id);
        call _peek_states_list(id_from, id_to, 'alpha|alphanum|quoted identifier|expanded query_script variable,dot,alpha|alphanum|quoted identifier|expanded query_script variable', false, false, true, table_array_id, peek_match_to);
        if peek_match_to > 0 then
          -- we have table_schema.table_name, and no statement
          call _get_array_element(table_array_id, '1', split_table_schema);		
          call _get_array_element(table_array_id, '3', split_table_name);
          call _expand_single_variable(id_from, id_to, split_table_schema, should_execute_statement);
          call _expand_single_variable(id_from, id_to, split_table_name, should_execute_statement);
          set split_table_schema := unquote(split_table_schema);
          set split_table_name := unquote(split_table_name);

          set found_explicit_table := true;
        end if;
        call _drop_array(table_array_id);
      end;
    end if;
    set found_any_params := (split_options is not null) or (found_explicit_table);
end;
//

delimiter ;
