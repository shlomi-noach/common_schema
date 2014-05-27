--
--
--

delimiter //

drop procedure if exists _get_split_query_table_definitions_clause //

create procedure _get_split_query_table_definitions_clause(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   split_query_type enum (
     'unsupported', 'delete', 'update', 'select', 'insert_select', 'replace_select'),
   out	table_definitions_found tinyint unsigned,
   out	table_definitions_id_from int unsigned,
   out	table_definitions_id_to   int unsigned
)
comment 'Get type of query supported by split() statement'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare statement_level int unsigned;

    declare starting_id int unsigned;
    declare terminating_id int unsigned;
    declare following_select_id int unsigned;
    
    set table_definitions_found := false;
    set table_definitions_id_from := null;
    set table_definitions_id_to := null;
    
    if split_query_type = 'unsupported' then
      leave main_body;
    end if;
    
    select level from _sql_tokens where id = id_from into statement_level;

    if split_query_type = 'update' then
      select MIN(id) from _sql_tokens where (id between id_from and id_to) and level = statement_level and state = 'alpha' and LOWER(token) = 'set' into terminating_id;
      if terminating_id is not null then
        set table_definitions_found := true;
        set table_definitions_id_from := id_from + 1;
        set table_definitions_id_to := terminating_id - 1;
      end if;
      leave main_body;    
    end if;

    if split_query_type = 'delete' then
      -- find FROM
      select MIN(id) from _sql_tokens where (id between id_from and id_to) and level = statement_level and state = 'alpha' and LOWER(token) = 'from' into starting_id;
      if starting_id is not null then
        set table_definitions_found := true;
        set table_definitions_id_from := starting_id + 1;
        -- But if there's USING, then override:
        select MIN(id) from _sql_tokens where (id between table_definitions_id_from and id_to) and level = statement_level and state = 'alpha' and LOWER(token) = 'using' into starting_id;
        if starting_id is not null then
          set table_definitions_id_from := starting_id + 1;
        end if;
        -- now find the terminating token: WHERE, ORDER or LIMIT (or end of line)
        select MIN(id) from _sql_tokens where (id between table_definitions_id_from and id_to) and level = statement_level and state = 'alpha' and LOWER(token) in ('where', 'order', 'limit') into terminating_id;
        if terminating_id is not null then
          set table_definitions_id_to := terminating_id - 1;
        else
          set table_definitions_id_to := id_to;
        end if;
      end if;
      leave main_body;    
    end if;

    if split_query_type in ('insert_select', 'replace_select') then
      -- We know for sure the 'INSERT' or 'REPLACE' are followed by a 'SELECT'. 
      -- It just so happens that there's nothing special about it: we can parse the query 
      -- as if it were a SELECT query: we just look for the FROM clause.
      set split_query_type := 'select';
    end if;

    if split_query_type = 'select' then
      -- find FROM
      select MIN(id) from _sql_tokens where (id between id_from and id_to) and level = statement_level and state = 'alpha' and LOWER(token) = 'from' into starting_id;
      if starting_id is not null then
        set table_definitions_found := true;
        set table_definitions_id_from := starting_id + 1;
        -- now find the terminating token: WHERE, ORDER or LIMIT (or end of line)
        select MIN(id) from _sql_tokens where (id between table_definitions_id_from and id_to) and level = statement_level and state = 'alpha' and LOWER(token) in ('partition', 'where', 'group', 'having', 'order', 'limit', 'procedure', 'into', 'for', 'lock') into terminating_id;
        if terminating_id is not null then
          set table_definitions_id_to := terminating_id - 1;
        else
          set table_definitions_id_to := id_to;
        end if;
      end if;
      leave main_body;    
    end if;
end;
//

delimiter ;
