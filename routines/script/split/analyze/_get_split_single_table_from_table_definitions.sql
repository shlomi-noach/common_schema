--
--
--

delimiter //

drop procedure if exists _get_split_single_table_from_table_definitions //

create procedure _get_split_single_table_from_table_definitions (
   in  id_from      int unsigned,
   in  id_to      int unsigned,
   out tables_found enum ('none', 'single', 'multi'),
   out table_schema varchar(80) charset utf8, 
   out table_name varchar(80) charset utf8
)
comment 'Get table_schema, table_name from table definitions clause'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare statement_level int unsigned;
	declare multi_table_indicator_id int unsigned;
    declare tokens_array_id int unsigned;
    declare peek_match_to int unsigned;
     
    set table_schema := null;
    set table_name := null;
    set tables_found := 'none';
    
    select level from _sql_tokens where id = id_from into statement_level;
    -- Check for multiple tables indicator: a JOIN, a STRAIGHT_JOIN, a comma,
    -- parenthesis (may indicate subquery, a USE INDEX, ON, USING)
    -- Oh, yes -- index hints not allwed here.
    select MIN(id) from _sql_tokens where 
      (id between id_from and id_to) 
      and (
        ((state = 'comma') and (level = statement_level))
        or 
        ((state = 'alpha') and (LOWER(token) in ('join', 'straight_join')) and (level = statement_level))
        or 
        ((state = 'left parenthesis') and (level = statement_level + 1))
      )
      into multi_table_indicator_id;
      
    if multi_table_indicator_id is not null then
       set tables_found := 'multi';
       leave main_body;
    end if;
    -- Got here: there is one single table.
    -- It should be in the following format: [schema_name.]tbl_name [[AS] alias]
    -- (valid SQL)
    -- We expect it to be in 'schema_name.tbl_name [[AS] alias]' format
    -- An alias means we cannot automagically add our special split clause
    -- since table name will not match -- bummer. At this point we do not
    -- allow aliases, so we actually expect table_schema.table_name

    call _skip_tokens_and_spaces(id_from, id_to, 'ignore,low_priority');
    call _peek_states_list(id_from, id_to, 'alpha|alphanum|quoted identifier|expanded query_script variable,dot,alpha|alphanum|quoted identifier|expanded query_script variable', false, false, true, tokens_array_id, peek_match_to);
    if peek_match_to > 0 then
      call _get_array_element(tokens_array_id, '1', table_schema);		
      call _get_array_element(tokens_array_id, '3', table_name);
      set table_schema := unquote(table_schema);
      set table_name := unquote(table_name);
      set tables_found := 'single';
    end if;
    call _drop_array(tokens_array_id);
end;
//

delimiter ;
