delimiter //

drop procedure if exists _wrap_select_list_columns
//

create procedure _wrap_select_list_columns(
    inout p_text text
,   out p_error  text
)
begin
    declare v_from, v_old_from int unsigned;
    declare v_token text;
    declare v_level int unsigned;
    declare v_state varchar(32);
    declare v_select bool default false;
    declare v_whitespace varchar(1) default '';
    declare v_done bool default FALSE;
    declare v_statement text;
    declare v_expression text default '';
    declare v_column_number int unsigned default 1;

    -- part one: find the SELECT keyword.
    my_loop: repeat 
        set v_old_from = v_from;
        call _get_sql_token(p_text, v_from, v_level, v_token, v_state);
        case 
            when v_state in ('whitespace', 'single line comment', 'multi line comment') then
                iterate my_loop;
            when v_select = false and v_state = 'alpha' and v_token = 'select' then
                set v_select = true;
            else leave my_loop;
        end case;
    until 
        v_select
    or  v_old_from = v_from
    end repeat;
    
    if v_select = false then
        set p_error = 'no SELECT keyword found';
    end if;

    set v_statement = substr(p_text, 1, v_from);
    -- part two: rewrite columns
    my_loop: repeat 
        set v_old_from = v_from;
        call _get_sql_token(p_text, v_from, v_level, v_token, v_state);         
        if v_level = 0 and v_token in ('from', ',') then
            set v_statement = concat(
                    v_statement
                ,   '(select '
                ,   v_expression
                ,   ') as col'
                ,   v_column_number
                ,   ' '
                ,   v_token
                )
            ;
            if v_token = 'from' then
                set v_statement = concat(
                        v_statement
                    ,   substr(p_text, v_from)
                    );
                leave my_loop;
            else
                set v_column_number = v_column_number + 1
                ,   v_expression = ''
                ;
            end if;
        else
            set v_expression = concat(v_expression, v_token);
        end if;
    until 
        v_old_from = v_from
    end repeat;
    set p_text = v_statement;
end;
//

delimiter ;
