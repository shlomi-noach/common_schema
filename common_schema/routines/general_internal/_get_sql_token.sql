delimiter //

set names utf8
//

drop procedure if exists _get_sql_token;
//

create procedure _get_sql_token(
    in      p_text      text charset utf8
,   inout   p_from      int unsigned
,   inout   p_level     int
,   out     p_token     text charset utf8
-- ,   inout   p_state     varchar(64)charset utf8
,   inout   p_state     enum(
                            'alpha'
                        ,   'alphanum'
                        ,   'and'
                        ,   'assign'
                        ,   'bitwise and'
                        ,   'bitwise or'
                        ,   'bitwise not'
                        ,   'bitwise xor'
                        ,   'colon'
                        ,   'comma'                        
                        ,   'conditional comment'
                        ,   'decimal'
                        ,   'delimiter'
                        ,   'divide'
                        ,   'dot'
                        ,   'equals'
                        ,   'error'
                        ,   'greater than'
                        ,   'greater than or equals'
                        ,   'integer'
                        ,   'left parenthesis'
                        ,   'left shift'
                        ,   'less than'
                        ,   'less than or equals'
                        ,   'minus'
                        ,   'modulo'
                        ,   'multi line comment'
                        ,   'multiply'
                        ,   'negate'
                        ,   'not equals'
                        ,   'null safe equals'
                        ,   'or'
                        ,   'plus'
                        ,   'quoted identifier'
                        ,   'right parenthesis'
                        ,   'right shift'
                        ,   'single line comment'
                        ,   'start'
                        ,   'statement delimiter'
                        ,   'string'
                        ,   'system variable'
                        ,   'user-defined variable'
                        ,   'whitespace'
                        ,   'not'
                        )               
)
comment 'Reads a token according to lexical rules for SQL'
language SQL
deterministic
no sql
sql security invoker
begin    
    declare v_length int unsigned default character_length(p_text);
    declare v_no_ansi_quotes        bool default find_in_set('ANSI_QUOTES', @@sql_mode) = FALSE;
    declare v_char, v_lookahead, v_quote_char    char(1) charset utf8;
    declare v_from int unsigned;

    if p_from is null then
        set p_from = 1;
    end if;
    if p_level is null then
        set p_level = 0;
    end if;
    if p_state = 'right parenthesis' then
        set p_level = p_level - 1;
    end if;
    set v_from = p_from;
    
    set p_token = ''
    ,   p_state = 'start';
    my_loop: while v_from <= v_length do
        set v_char = substr(p_text, v_from, 1)
        ,   v_lookahead = substr(p_text, v_from+1, 1)
        ;
        state_case: begin case p_state
            when 'error' then 
                set p_from = v_length;
                leave state_case;            
            when 'start' then
                case
                    when v_char between '0' and '9' then 
                        set p_state = 'integer';
                    when v_char between 'A' and 'Z' 
                    or   v_char between 'a' and 'z' 
                    or   v_char = '_' then
                        set p_state = 'alpha';                        
                    when v_char = ' ' then 
                        set p_state = 'whitespace'
                        ,   v_from = v_length - character_length(ltrim(substring(p_text, v_from)))
                        ;
                        leave state_case;
                    when v_char in ('\t', '\n', '\r') then 
                        set p_state = 'whitespace';
                    when v_char = '''' or v_no_ansi_quotes and v_char = '"' then
                        set p_state = 'string', v_quote_char = v_char;
                    when v_char = '`' or v_no_ansi_quotes = FALSE and v_char = '"' then
                        set p_state = 'quoted identifier', v_quote_char = v_char;
                    when v_char = '@' then
                        if v_lookahead = '@' then
                            set p_state = 'system variable', v_from = v_from + 1;
                        else
                            set p_state = 'user-defined variable';
                        end if;
                    when v_char = '.' then
                        if substr(p_text, v_from + 1, 1) between '0' and '9' then
                            set p_state = 'decimal', v_from = v_from + 1;
                        else
                            set p_state = 'dot', v_from = v_from + 1;
                            leave my_loop;
                        end if;
                    when v_char = ';' then
                        set p_state = 'statement delimiter', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = ',' then
                        set p_state = 'comma', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = '=' then
                        set p_state = 'equals', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = '*' then
                        set p_state = 'multiply', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = '%' then
                        set p_state = 'modulo', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = '/' then
                        if v_lookahead = '*' then
                            set v_from = locate('*/', p_text, p_from + 2);
                            if v_from then
                                set p_state = if (substr(p_text, p_from + 2, 1) = '!', 'conditional comment', 'multi line comment')
                                ,   v_from = v_from + 2
                                ;
                                leave my_loop;
                            else
                                set p_state = 'error';
                            end if;
                        else
                            set p_state = 'divide', v_from = v_from + 1;
                            leave my_loop;
                        end if;
                    when v_char = '-' then
                        case 
                            when v_lookahead = '-' and substr(p_text, v_from + 2, 1) = ' ' then
                                set p_state = 'single line comment'
                                ,   v_from = locate('\n', p_text, p_from)
                                ;
                                if not v_from then
                                    set v_from = v_length;
                                end if;
                                set v_from = v_from + 1;
                                leave my_loop;
                            else
                                set p_state = 'minus', v_from = v_from + 1;
                                leave my_loop;
                        end case;
                    when v_char = '#' then
                        set p_state = 'single line comment'
                        ,   v_from = locate('\n', p_text, p_from)
                        ;
                        if not v_from then
                            set v_from = v_length;
                        end if;
                        set v_from = v_from + 1;
                        leave my_loop;
                    when v_char = '+' then
                        set p_state = 'plus', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = '<' then 
                        set p_state = 'less than';
                    when v_char = '>' then 
                        set p_state = 'greater than';
                    when v_char = ':' then 
                        if v_lookahead = '=' then
                            set p_state = 'assign', v_from = v_from + 2;
                        else
                            set p_state = 'colon', v_from = v_from + 1;
                        end if;
                        leave my_loop;
                    when v_char = '(' then 
                        set p_state = 'left parenthesis', v_from = v_from + 1, p_level = p_level + 1;
                        leave my_loop;
                    when v_char = ')' then 
                        set p_state = 'right parenthesis', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = '^' then 
                        set p_state = 'bitwise xor', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = '~' then 
                        set p_state = 'bitwise not', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = '!' then
                        if v_lookahead = '=' then
                            set p_state = 'not equals', v_from = v_from + 2;
                        else
                            set p_state = 'not', v_from = v_from + 1;
                        end if;
                        leave my_loop;
                    when v_char = '|' then
                        if v_lookahead = '|' then
                            set p_state = 'or', v_from = v_from + 2;
                        else
                            set p_state = 'bitwise or', v_from = v_from + 1;
                        end if;
                        leave my_loop;
                    when v_char = '&' then
                        if v_lookahead = '&' then
                            set p_state = 'and', v_from = v_from + 2;
                        else
                            set p_state = 'bitwise and', v_from = v_from + 1;
                        end if;
                        leave my_loop;
                    else 
                        set p_state = 'error';
                end case;
            when 'less than' then
                case v_char 
                    when '=' then 
                        set p_state = 'less than or equals';
                        leave state_case;
                    when '>' then 
                        set p_state = 'not equals';
                    when '<' then 
                        set p_state = 'left shift';
                    else
                        do null;
                end case;
                leave my_loop;
            when 'less than or equals' then
                if v_char = '>' then 
                    set p_state = 'null safe equals'
                    ,   v_from = v_from + 1
                    ;
                end if;
                leave my_loop;
            when 'greater than' then
                case v_char 
                    when '=' then 
                        set p_state = 'greater than or equals';
                    when '>' then 
                        set p_state = 'right shift';
                    else
                        set p_state = 'error';
                end case;
                leave my_loop;
            when 'multi line comment' then
                if v_char = '*' and v_lookahead = '/' then
                    set v_from = v_from + 2;
                    leave my_loop;
                end if;
            when 'alpha' then 
                case
                    when v_char between 'A' and 'Z' 
                    or   v_char between 'a' and 'z' 
                    or   v_char = '_' then
                        leave state_case;
                    when v_char between '0' and '9' 
                    or   v_char = '$' then 
                        set p_state = 'alphanum';
                    else
                        leave my_loop;
                end case;
            when 'alphanum' then 
                case
                    when v_char between 'A' and 'Z' 
                    or   v_char between 'a' and 'z' 
                    or   v_char = '_'
                    or   v_char between '0' and '9' then 
                        leave state_case;
                    else
                        leave my_loop;
                end case;
            when 'integer' then
                case 
                    when v_char between '0' and '9' then 
                        leave state_case;
                    when v_char = '.' then 
                        set p_state = 'decimal';
                    else
                        leave my_loop;                        
                end case;
            when 'decimal' then
                case 
                    when v_char between '0' and '9' then 
                        leave state_case;
                    else
                        leave my_loop;
                end case;
            when 'whitespace' then
                if v_char not in ('\t', '\n', '\r') then
                    leave my_loop;                        
                end if;
            when 'string' then
                set v_from = locate(v_quote_char, p_text, v_from);
                if v_from then
                    if substr(p_text, v_from + 1, 1) = v_quote_char then
                        set v_from = v_from + 1;
                    elseif substr(p_text, v_from - 1, 1) != '\\' then
                        set v_from = v_from + 1;
                        leave my_loop;
                    end if;
                else
                    set p_state = 'error';
                    leave my_loop;
                end if;
            when 'quoted identifier' then
                if v_char != v_quote_char then 
                    leave state_case;
                else
                    set v_from = v_from + 1;
                    leave my_loop;                
                end if;
            when 'user-defined variable' then
                if v_char in (';', ',', ' ', '\t', '\n', '\r', '!', '~', '^', '%', '>', '<', ':', '=', '+', '-', '&', '*', '|', '(', ')') then
                    leave my_loop;
                end if;
            when 'system variable' then
                if v_char in (';', ',', ' ', '\t', '\n', '\r', '!', '~', '^', '%', '>', '<', ':', '=', '+', '-', '&', '*', '|', '(', ')') then
                    leave my_loop;
                end if;
            else
                leave my_loop;            
        end case; end state_case;
        set v_from = v_from + 1;
    end while my_loop;
    set p_token = substr(p_text, p_from, v_from - p_from) collate utf8_general_ci;
    set p_from = v_from;
end;
//

delimiter ;