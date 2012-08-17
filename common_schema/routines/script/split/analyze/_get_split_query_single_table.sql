--
--
--

delimiter //

drop procedure if exists _get_split_query_single_table //

create procedure _get_split_query_single_table (
   in  id_from      int unsigned,
   in  id_to      int unsigned,
   out query_type_supported tinyint unsigned,
   out tables_found enum ('none', 'single', 'multi'),
   out table_schema varchar(80) charset utf8, 
   out table_name varchar(80) charset utf8
)
comment ''
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
	declare split_query_type varchar(32) charset ascii;
    declare table_definitions_found tinyint unsigned;
    declare table_definitions_id_from int unsigned;
    declare table_definitions_id_to int unsigned;
    
    set table_schema := null;
    set table_name := null;

    -- Analyze query type
    call _get_split_query_type(id_from, id_to, split_query_type, @_common_schema_dummy, @_common_schema_dummy);
    if split_query_type = 'unsupported' then
      set query_type_supported := false;
      leave main_body;
    end if;
    set query_type_supported := true;

    -- Try to isolate table definitions clause
    call _get_split_query_table_definitions_clause(id_from, id_to, split_query_type, 
      table_definitions_found, table_definitions_id_from, table_definitions_id_to);
    if not table_definitions_found then
      set tables_found := 'none';
      leave main_body;
    end if;
    
    -- Finally, get table_schema & table_name, if possible:
    call _get_split_single_table_from_table_definitions(
      table_definitions_id_from,
      table_definitions_id_to,
      tables_found,
      table_schema,
      table_name
      );
end;
//

delimiter ;
