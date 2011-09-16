delimiter //

set names utf8
//

drop procedure if exists get_sql_dependencies
//

create procedure get_sql_dependencies(
    in  p_sql               text charset utf8
,   in  p_default_schema    varchar(64) charset utf8
)
my_main: begin
    declare v_from, v_old_from int unsigned;
    declare v_token text charset utf8;
    declare v_level int unsigned default 0;
    declare v_state varchar(32) charset utf8;
    declare v_scan_state varchar(32) charset utf8 default 'start';
    declare v_schema_name, v_object_name, v_object_type, v_definer, v_action varchar(64) charset utf8 default null;
    declare v_error_message text charset utf8 default '';

    set @old_autocommit = @@autocommit
    ,   autocommit = off
    ;
  my_error: begin
    
    declare exit handler for 1339
        set v_error_message = concat('case not defined for state: "', v_scan_state, '" ("', v_state, '")');
    declare exit handler for 1265
        set v_error_message = concat('not valid for enum ', v_token);
    
    drop temporary table if exists _sql_dependencies;
    create temporary table if not exists _sql_dependencies(
        id              int unsigned auto_increment primary key
    ,   start           int unsigned
    ,   action          enum('alter', 'call', 'create', 'delete', 'drop', 'insert', 'replace', 'select', 'truncate', 'update')
    ,   object_type     enum('event', 'function', 'index', 'procedure', 'table', 'trigger', 'view')
    ,   schema_name     varchar(64)
    ,   object_name     varchar(64)
    );
    
    my_loop: repeat 
        set v_old_from = v_from;
        call _get_sql_token(p_sql, v_from, v_level, v_token, v_state);
        set v_token = v_token collate utf8_general_ci;
        if v_state in ('whitespace', 'single line comment', 'multi line comment') then
            iterate my_loop;
        elseif v_state = 'statement delimiter' then
            if v_scan_state = 'expect dot' then
                insert 
                into _sql_dependencies (start, schema_name, object_name, object_type, action) 
                values (v_from, v_schema_name, v_object_name, v_object_type, v_action);
            end if;
            set v_scan_state = 'start'
            ,   v_action = null;
        end if;
        if @debug_get_sql_dependencies then
            select v_scan_state, v_from, v_token, v_state;
        end if;
        case v_scan_state
            when 'start' then
                set v_schema_name = p_default_schema, v_object_name = null, v_object_type = null, v_definer = null;
                if v_state = 'alpha' then
                    if v_token in ('alter', 'call', 'create', 'delete', 'drop', 'insert', 'replace', 'select', 'truncate', 'update') then
                        set v_action = lower(v_token) collate utf8_general_ci
                        ,   v_scan_state = v_action
                        ;
                    elseif v_token in ('join', 'from') then
                        set v_scan_state = 'expect table';
                    end if;
                end if;
            when 'select' then
                set v_scan_state = 'expect from';
            when 'insert' then
                set v_scan_state = 'expect table';
            when 'expect from' then
                if v_state = 'alpha' and v_token = 'from' then
                    set v_scan_state = 'expect table';
                end if;
            when 'call' then
                set v_object_type = 'procedure'
                ,   v_object_name = v_token
                ,   v_scan_state = 'expect dot'
                ;
            when 'alter' then
                if v_state = 'alpha' then
                    if v_token in ('database', 'event', 'function', 'procedure', 'schema', 'server', 'table', 'tablespace', 'view') then
                        set v_object_type = v_token
                        ,   v_scan_state = 'expect identifier1';
                    elseif v_token = 'logfile' then
                        set v_scan_state = 'expect logfile group';
                    elseif v_token in ('online', 'offline', 'ignore') then
                        set v_scan_state = 'expect object type';
                    elseif v_token = 'definer' then
                        set v_scan_state = 'definer';
                    else 
                        set v_error_message = concat('"', v_token, '" is not a valid object type for alter ', v_scan_state);
                        leave my_error;
                    end if;
                else
                    set v_error_message = concat('expected alpha ', v_scan_state);
                    leave my_error;
                end if;
            when 'create' then
                if v_state = 'alpha' then
                    if v_token in ('database', 'event', 'function', 'procedure', 'schema', 'server', 'table', 'tablespace', 'view') then
                        set v_object_type = v_token
                        ,   v_scan_state = 'expect identifier1';
                    end if;
                else
                    set v_error_message = concat('expected alpha ', v_scan_state);
                    leave my_error;
                end if;
            when 'drop' then
                if v_state = 'alpha' then
                    if v_token in ('database', 'event', 'function', 'procedure', 'schema', 'server', 'table', 'tablespace', 'view') then
                        set v_object_type = v_token
                        ,   v_scan_state = 'expect identifier1';
                    end if;
                else
                    set v_error_message = concat('expected alpha ', v_scan_state);
                    leave my_error;
                end if;
            when 'expect logfile group' then
                if v_state = 'alpha' and v_token = 'group' then
                    set v_object_type = 'logfile group'
                    ,   v_scan_state = 'expect identifier2';
                else 
                    set v_error_message = concat('expected group keyword');
                    leave my_error;
                end if;
            when 'expect definer user' then
                if v_state in ('alpha') and v_token = 'CURRENT_USER' then 
                    set v_scan_state = 'expect object type';
                elseif v_state = 'string'  then
                    set v_scan_state = 'expect definer host';
                else
                    set v_error_message = concat('expected alpha or alphanum', v_scan_state);
                    leave my_error;
                end if;
            when 'expect definer host' then
                if v_state = 'user-defined variable' then
                    set v_scan_state = 'expect object type';
                else
                    set v_error_message = concat('expected hostname, not ', v_state);
                    leave my_error;
                end if;
            when 'definer' then
                if v_state = 'equals' then
                    set v_scan_state = 'expect definer user';
                else
                    set v_error_message = concat('expected equals in state', v_scan_state);
                    leave my_error;
                end if;            
            when 'expect create or replace' then
                if v_state = 'alpha' and v_token = 'replace' then
                    set v_scan_state = 'expect object type';
                else
                    set v_error_message = concat('expected replace in state', v_scan_state);
                    leave my_error;
                end if;
            when 'expect object type' then
                if  v_state = 'alpha' then
                    if v_token in ('event', 'function', 'index', 'procedure', 'schema', 'table', 'trigger', 'view') then
                        set v_object_type = v_token
                        ,   v_scan_state = 'expect identifier1'
                        ;                    
                    elseif v_token = 'definer' then
                        set v_scan_state = 'definer';
                    elseif v_token = 'or' then
                        set v_scan_state = 'expect create or replace';
                    elseif v_token = 'temporary' then
                        set v_scan_state = 'expect object type';
                    else
                        set v_error_message = concat('invalid object type ', v_token);
                        leave my_error;
                    end if;
                else
                    set v_error_message = concat('expected alpha in state ', v_scan_state);
                    leave my_error;
                end if;
            when 'expect identifier1' then
                if v_state = 'quoted identifier' then
                    set v_object_name = substr(v_token, 2, character_length(v_token) - 2);                    
                elseif v_state in ('alpha', 'alphanum') then
                    if v_token not in ('if', 'not', 'exists') then
                        set v_object_name = v_token;
                        set v_scan_state = 'expect dot';
                    end if;
                else
                    set v_error_message = concat('expected identifier ', v_scan_state);
                    leave my_error;
                end if;
            when 'expect identifier2' then
                if v_state in ('quoted identifier', 'alpha', 'alphanum') then
                    set v_schema_name = v_object_name;
                    if v_state = 'quoted identifier' then
                        set v_object_name = substr(v_token, 2, character_length(v_token) - 2)
                        ;
                    elseif v_state in ('alpha', 'alphanum') then
                        set v_object_name = v_token;
                    end if;
                    
                    insert 
                    into _sql_dependencies (start, schema_name, object_name, object_type, action) 
                    values (v_from, v_schema_name, v_object_name, v_object_type, v_action);

                    if v_object_type = 'table' then 
                        set v_scan_state = 'expect join';
                    else 
                        set v_scan_state = 'start';
                    end if;
                else
                    set v_error_message = concat('expected identifier ', v_scan_state);
                    leave my_error;
                end if;
            when 'expect dot' then
                if v_state = 'dot' then
                    set v_scan_state = 'expect identifier2';
                else
                    insert 
                    into _sql_dependencies (start, schema_name, object_name, object_type, action) 
                    values (v_from,v_schema_name, v_object_name, v_object_type, v_action);
                    
                    if v_object_type = 'table' then 
                        if  (v_state = 'alpha' and v_token in ('into', 'where', 'group', 'having', 'order', 'limit'))
                        or  v_action != 'select'
                        then
                            set v_scan_state = 'start';
                        elseif v_state = 'comma' then
                            set v_scan_state = 'expect table';
                        else
                            set v_scan_state = 'expect join';
                        end if;
                    else 
                        set v_scan_state = 'start';
                    end if;
                end if;
            when 'expect join' then
                if v_state = 'alpha' then
                    if v_token = 'join' then
                        set v_scan_state = 'expect table';
                    elseif v_token = 'on' then
                        set v_scan_state = 'expect join';
                    elseif v_token = 'select' then
                        set v_scan_state = 'select';
                    elseif v_token in ('into', 'where', 'group', 'having', 'order', 'limit') then
                        set v_scan_state = 'start';
                    end if;
                elseif v_state = 'comma' then 
                    set v_scan_state = 'expect table';
                end if;
            when 'expect table' then
                set v_object_type = 'table';
                case 
                    when v_state = 'quoted identifier' then
                        set v_object_name = substr(v_token, 2, character_length(v_token) - 2)
                        ,   v_scan_state = 'expect dot'
                        ;
                    when v_state = 'alpha' and v_token in ('low_priority', 'delayed', 'high_priority', 'ignore', 'into') 
                    or   v_token = '(' 
                    then
                        do null;
                    when v_state = 'alpha' and v_token = 'select' then 
                        set v_scan_state = 'select';
                    when v_state in ('alpha', 'alphanum') then
                        set v_object_name = v_token
                        ,   v_scan_state = 'expect dot'
                        ;
                    else
                        set v_error_message = concat('unexpected state ', v_scan_state, ' (', v_state,')');
                        do null;
                end case;
            when 'expect identifier' then
                if v_state in ('quoted identifier', 'alpha', 'alphanum') then
                    set v_schema_name = v_object_name;
                    if v_state = 'quoted identifier' then
                        set v_object_name = substr(v_token, 2, character_length(v_token) - 2);
                    else
                        set v_object_name = v_token;
                    end if;
                    insert 
                    into _sql_dependencies (start, schema_name, object_name, object_type, action) 
                    values (v_from, v_schema_name, v_object_name, v_object_type, v_action) 
                    ;
                end if;
                set v_scan_state = 'start';
            else 
                set v_error_message = concat('unexpected state ', v_scan_state);
                leave my_error;
        end case;
    until 
        v_old_from = v_from
    end repeat;

    commit;
    set autocommit = @old_autocommit;
    
    select distinct schema_name, object_name, object_type, action
    from _sql_dependencies
    order by schema_name, object_name, object_type, action
    ;
    leave my_main;
  end;
  select concat('Error: ', v_error_message) error;
end;
//

delimiter ;

