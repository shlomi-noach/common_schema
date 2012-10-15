--
--
--

delimiter //

drop procedure if exists _get_sql_tokens//

create procedure _get_sql_tokens(
    in p_text text
)
comment 'Reads tokens according to lexical rules for SQL'
language SQL
deterministic
modifies sql data
sql security invoker
begin
    declare v_from, v_old_from int unsigned;
    declare v_token text;
    declare v_level int;
    declare v_state varchar(32);
    declare _sql_tokens_id int unsigned default 0;
    
    drop temporary table if exists _sql_tokens;
    create temporary table _sql_tokens(
        id int unsigned primary key
    ,   start int unsigned  not null
    ,   level int not null
    ,   token text          
    ,   state text           not null
    ) engine=MyISAM;
    
    repeat 
        set v_old_from = v_from;
        call _get_sql_token(p_text, v_from, v_level, v_token, 1, v_state);
        set _sql_tokens_id := _sql_tokens_id + 1;
        insert into _sql_tokens(id,start,level,token,state) 
        values (_sql_tokens_id, v_from, v_level, v_token, v_state);
    until 
        v_old_from = v_from
    end repeat;
    
    if @common_schema_debug then
      select * 
      from _sql_tokens
      order by id;
    end if;
end;
//

delimiter ;
