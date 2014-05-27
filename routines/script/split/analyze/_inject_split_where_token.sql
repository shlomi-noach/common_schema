--
--
--

delimiter //

drop procedure if exists _inject_split_where_token //

create procedure _inject_split_where_token(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   split_injected_text tinytext charset utf8,
   in   should_execute_statement tinyint unsigned,
   out  split_injected_action_statement text charset utf8
)
comment 'Injects a magical token into the WHERE statement'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare statement_level int unsigned;
    declare id_where_clause int unsigned default NULL; 
    declare id_where_clause_end int unsigned default NULL; 
    declare id_end_split_table_declaration int unsigned default NULL;
    declare query_part_prefix text charset utf8 default '';
    declare query_part_where_clause text charset utf8 default '';
    declare query_part_suffix text charset utf8 default '';
 	declare split_query_type varchar(32) charset ascii;
 	declare split_query_id_from int unsigned;
    declare split_query_following_select_id int unsigned;
   
    call _skip_spaces(id_from, id_to);
    SELECT level FROM _sql_tokens WHERE id = id_from INTO statement_level;
    
    -- Analyze query type
    call _get_split_query_type(id_from, id_to, split_query_type, split_query_id_from, split_query_following_select_id);
    
    if split_query_type = 'unsupported' then
      call _throw_script_error(id_from, 'split(): unsupported query type');
    end if;

    SELECT 
      MIN(id) FROM _sql_tokens 
      WHERE 
        level = statement_level AND state = 'alpha' and LOWER(token) = 'where' 
        AND id between id_from and id_to
      INTO id_where_clause;
    if id_where_clause is NULL then
      -- No "WHERE" clause.
      -- Attempt to find a clause which appears after the WHERE clause

      -- "INTO" is such a pain: is appears both in "INSERT INTO ... SELECT" (irrelevant to our injection)
      -- as well as in "SELECT ... INTO ..." (relevant to our injection)
      -- There's a lot of fuss to make sure to stop at the right "INTO".
      SELECT 
        MIN(id) FROM _sql_tokens 
        WHERE 
          level = statement_level 
          AND state = 'alpha' and LOWER(token) IN ('group', 'having', 'order', 'limit', 'into') 
          AND id between GREATEST(id_from, split_query_id_from, IFNULL(split_query_following_select_id, split_query_id_from)) and id_to
        INTO id_where_clause_end;
      if id_where_clause_end is NULL then
        -- No "WHERE", no following clause... Just invent a new "WHERE" clause...
        call _expand_statement_variables(id_from, id_to, query_part_prefix, @common_schema_dummy, should_execute_statement);
      else
        -- No "WHERE", but we found a following clause. Invent a new "WHERE"
        -- clause before that clause...
        call _expand_statement_variables(id_from, id_where_clause_end - 1, query_part_prefix, @common_schema_dummy, should_execute_statement);
        call _expand_statement_variables(id_where_clause_end, id_to, query_part_suffix, @common_schema_dummy, should_execute_statement);
      end if;
      -- Must invent/inject a "WHERE" clause
      set split_injected_action_statement := CONCAT(
          query_part_prefix, ' WHERE ', split_injected_text, ' ', query_part_suffix
        );
    else
      -- "WHERE" clause found.
      call _expand_statement_variables(id_from, id_where_clause, query_part_prefix, @common_schema_dummy, should_execute_statement);
      -- Search for end of "WHERE" clause
      SELECT 
        MIN(id) FROM _sql_tokens 
        WHERE 
          level = statement_level 
          AND state = 'alpha' and LOWER(token) IN ('group', 'having', 'order', 'limit', 'into') 
          AND id between id_from and id_to
          AND id > id_where_clause
        INTO id_where_clause_end;
      if id_where_clause_end is NULL then
        -- Nothing after the "WHERE" clause. So the "WHERE" clause 
        -- terminates at id_to
        call _expand_statement_variables(id_where_clause + 1, id_to, query_part_where_clause, @common_schema_dummy, should_execute_statement);
      else
        call _expand_statement_variables(id_where_clause + 1, id_where_clause_end - 1, query_part_where_clause, @common_schema_dummy, should_execute_statement);
        call _expand_statement_variables(id_where_clause_end, id_to, query_part_suffix, @common_schema_dummy, should_execute_statement);
      end if;
      -- inject text in exsiting WHERE clause
      set split_injected_action_statement := CONCAT(
          query_part_prefix, ' (', query_part_where_clause, ') AND ', split_injected_text, ' ', query_part_suffix
        );
    end if;
end;
//

delimiter ;
