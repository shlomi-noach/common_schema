--
--
--

delimiter //

drop procedure if exists _get_split_query_type //

create procedure _get_split_query_type(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   out  split_query_type enum (
     'unsupported', 'delete', 'update', 'select', 'insert_select', 'replace_select'),
   out  split_query_id_from int unsigned,
   out  split_query_following_select_id int unsigned
)
comment 'Get type of query supported by split() statement'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare statement_level int unsigned;
    declare statement_type tinytext charset utf8 default null;
    
    set split_query_type := 'unsupported';
    set split_query_following_select_id := null;
    
    call _skip_spaces(id_from, id_to);
    SELECT id, level, LOWER(token) FROM _sql_tokens WHERE id = id_from AND state = 'alpha' INTO split_query_id_from, statement_level, statement_type;
    
	if statement_type in ('insert', 'replace') then
      SELECT MIN(id) FROM _sql_tokens WHERE id > id_from AND id <= id_to AND level = statement_level AND state = 'alpha' AND LOWER(token) = 'select' INTO split_query_following_select_id;
    end if;
    
    if statement_type = 'delete' then
      set split_query_type := 'delete';
    elseif statement_type = 'update' then
      set split_query_type := 'update';
    elseif statement_type = 'select' then
      set split_query_type := 'select';
    elseif statement_type = 'insert' and split_query_following_select_id is not null then
      set split_query_type := 'insert_select';
    elseif statement_type = 'replace' and split_query_following_select_id is not null then
      set split_query_type := 'replace_select';
    end if;
end;
//

delimiter ;
