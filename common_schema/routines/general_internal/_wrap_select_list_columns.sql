delimiter //

drop procedure if exists _wrap_select_list_columns
//

create procedure _wrap_select_list_columns(
    inout p_text text
,   in p_column_count int
,   out p_error  text
)
my_proc: begin
    declare v_from, v_old_from int unsigned;
    declare v_token text;
    declare v_level int unsigned;
    declare v_state varchar(32);
    declare v_whitespace varchar(1) default '';
    declare v_done bool default FALSE;
    declare v_statement text;
    declare v_expression text default '';
    declare v_column_number int unsigned default 0;

my_main: begin
    -- part one: find the SELECT keyword.
    my_loop: repeat 
        set v_old_from = v_from;
        call _get_sql_token(p_text, v_from, v_level, v_token, v_state);
        case 
            when v_state in ('whitespace', 'single line comment', 'multi line comment', 'conditional comment') then
                iterate my_loop;
            when v_state = 'alpha' and v_token = 'select' then
                set v_statement = substr(p_text, 1, v_from);
                leave my_loop;
            else 
                set p_error = 'No Select found';
                leave my_proc;
        end case;
    until 
        v_old_from = v_from
    end repeat;
    
    -- part two: rewrite columns
    my_loop: repeat 
        set v_old_from = v_from;
        call _get_sql_token(p_text, v_from, v_level, v_token, v_state);
        if v_column_number < p_column_count then
            if  v_level = 0 and (
                (v_state, v_token) in (('alpha', 'from'), ('comma', ',')) 
            or  v_old_from = v_from
            )
            then
                set v_statement = concat(
                        v_statement
                    ,   if (v_column_number, ', ', '')
                    ,   '(select '
                    ,   v_expression
                    ,   ') as col'
                    ,   (v_column_number + 1)
                    )
                ,   v_column_number = v_column_number + 1
                ,   v_expression = ''
                ;
            else
                set v_expression = concat(v_expression, v_token);
            end if;
        end if;
    until 
        v_old_from = v_from or v_token = 'from'
    end repeat;

    -- part three: pad null columns
    while v_column_number < p_column_count do
        set v_column_number = v_column_number + 1
        ,   v_statement = concat(v_statement, ', null as col', v_column_number)
        ;
    end while;

    end;
    
    set p_text= concat(
                    v_statement
                ,   if(v_token = 'from', ' from', '')
                ,   substr(p_text, v_from)
                );
end;
//

delimiter ;