delimiter //

drop procedure if exists _wrap_select_list_columns
//

create procedure _wrap_select_list_columns(
    inout p_text        text    -- select statement text
,   in p_column_count   int     -- number of select-list column expressions to rewrite
,   out p_error         text    -- error message text output (to be inspected by the caller)
)
my_proc: begin
    declare v_from, v_old_from int unsigned;
    declare v_token text charset utf8;
    declare v_level int unsigned;
    declare v_state varchar(32);
    declare v_whitespace varchar(1) default '';
    declare v_done bool default FALSE;
    declare v_statement text;
    declare v_expression text default '';
    declare v_column_number int unsigned default 0;
    declare v_prev_tokens text default '';
    declare v_token_separator char(1) default '~';
    declare v_token_separator_esc char(1) default '_';
    declare v_handle text;
    declare v_substr_length int unsigned default 0;
    set @_wrap_select_num_original_columns := 0;
    
    my_main: begin
    -- part one: find the SELECT keyword.
    my_loop: repeat 
        set v_old_from = v_from;
        call _get_sql_token(p_text, v_from, v_level, v_token, FALSE, v_state);
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
    columns_loop: repeat 
        set v_old_from = v_from;
        call _get_sql_token(p_text, v_from, v_level, v_token, FALSE, v_state);
        if v_state = 'error' then
            set p_error = 'Tokenizer returned error state';
            leave my_main;
        elseif (v_column_number = 0) and ((v_state, v_token) = ('alpha', 'distinct')) then
            set v_statement = concat(v_statement, 'distinct ');
        elseif (v_column_number < p_column_count) or (p_column_count = 0)  then
            if  v_level = 0 and (
                (v_state, v_token) in (
                    ('alpha', 'from')
                ,   ('comma', ',')
                ) 
                or v_old_from = v_from
            ) then
                -- if we ran into the from clause and there is whitespace (or comments) between the last column expression and the from keyword,
                -- then v_prev_tokens will end with a v_token_separator. We remove that here to not mess up finding the handle
                if v_token = 'from' 
                and substr(v_prev_tokens, character_length(v_prev_tokens) + 1 - character_length(v_token_separator)) = v_token_separator then
                    set v_prev_tokens = substr(v_prev_tokens, 1, character_length(v_prev_tokens) - character_length(v_token_separator));
                end if;
                -- check if we have multiple separated tokens
                if character_length(v_prev_tokens) - character_length(replace(v_prev_tokens, v_token_separator, '')) > 1 then
                    -- store the 2nd last token in v_handle
                    set v_handle = substring_index(substring_index(v_prev_tokens, v_token_separator, -2), v_token_separator, 1)
                    -- get the max length of the column expression
                    ,   v_substr_length = character_length(v_expression)
                    -- substract length that makes up the alias (and AS keyword if applicable)
                    ,   v_substr_length = v_substr_length - case 
                            when UPPER(v_handle) = 'AS' then    -- handle indicates an explicit alias.
                                2 + character_length(substring_index(v_expression, v_handle, -1))
                            when coalesce(v_handle, '') not in (  -- if the handle is not a keyword then the last token must be an alias. chop it off 
                                '', 'AND', 'BINARY', 'COLLATE', 'DIV', 'ESCAPE', 'IS', 'LIKE', 'MOD', 'NOT', 'OR', 'REGEXP', 'RLIKE', 'XOR'
                            ,   '+', '-', '/', '*', '%'
                            ,   '||', '&&', '!' 
                            ,   '<', '<=', '=>', '>', '<=>', '=', '!=', ':='
                            ,   '|', '&', '~', '^', '<<', '>>'
                            ,   '.'
                            ) and not (   -- what also counts as a keyword is a character set specifier. consider moving this into the tokenizer.
                                    v_handle = '_bin' 
                                or  v_handle LIKE '_%'
                                and exists (
                                    select  null 
                                    from    information_schema.character_sets 
                                    where   character_set_name = substring(v_handle, 2)
                                )
                            ) then
                                1+character_length(substring_index(v_prev_tokens, v_token_separator, -1))
                            else 0
                        end
                    -- chop off the alias.
                    ,   v_expression = substring(v_expression, 1, v_substr_length)
                    ;
                end if;
                
                set v_statement = concat(
                        v_statement
                    ,   if (v_column_number, ', ', '')
                    ,   TRIM(v_expression)
                    ,   ' AS col', v_column_number + 1  
                    )
                ,   v_column_number = v_column_number + 1
                ,   v_expression = ''
                ,   v_prev_tokens = ''
                ;
            else
                set v_expression = concat(v_expression, v_token);
                set v_prev_tokens = concat(
                    v_prev_tokens
                ,   if( v_level != 0
                    or  v_state not in (
                            'whitespace'
                        ,   'multi line comment'
                        ,   'single line comment'
                        )
                    ,   concat(
                            if(v_level, '', v_token_separator)
                        ,   replace(v_token, v_token_separator, v_token_separator_esc)
                        )
                    ,   ''
                    )
                );
            end if;            
        end if;
    until 
        v_old_from = v_from or v_token = 'from'
    end repeat;

    -- part three: pad null columns
    set @_wrap_select_num_original_columns := v_column_number;
    while v_column_number < p_column_count do
        set v_column_number = v_column_number + 1
        ,   v_statement = concat(v_statement, ', NULL as col', v_column_number)
        ;
    end while;

    end my_main;
    
    set p_text= concat(
                    v_statement
                ,   if(v_token = 'from', ' from', '')
                ,   substr(p_text, v_from)
                );
end;
//

delimiter ;
