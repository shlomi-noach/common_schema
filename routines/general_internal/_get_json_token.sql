delimiter //

set names utf8
//

drop procedure if exists _get_json_token;
//

create procedure _get_json_token(
    in      p_text      text charset utf8
,   inout   p_from      int unsigned
,   inout   p_level     int
,   out     p_token     text charset utf8
,   in      allow_script_tokens int
,   inout   p_state     enum(
                            'alpha'
                        ,   'alphanum'
                        ,   'colon'
                        ,   'comma'                        
                        ,   'decimal'
                        ,   'error'
                        ,   'integer'
                        ,   'number'
                        ,   'minus'
                        ,   'object_begin'
                        ,   'object_end'
                        ,   'array_begin'
                        ,   'array_end'
                        ,   'start'
                        ,   'string'
                        ,   'whitespace'
                        )               
)
comment 'Reads a token according to lexical rules for JSON'
language SQL
deterministic
no sql
sql security invoker
begin    
    declare v_length int unsigned default character_length(p_text);
    declare v_char, v_lookahead, v_quote_char    varchar(1) charset utf8;
    declare v_from int unsigned;
    declare negative_number bool default false;

    if p_from is null then
        set p_from = 1;
    end if;
    if p_level is null then
        set p_level = 0;
    end if;
    if p_state = 'object_end' then
        set p_level = p_level - 1;
    end if;
    if p_state = 'array_end' and allow_script_tokens then
        set p_level = p_level - 1;
    end if;
    set v_from = p_from;
    
    set p_token = ''
    ,   p_state = 'start';
    my_loop: while v_from <= v_length do
        set v_char = substr(p_text, v_from, 1)
        ,   v_lookahead = substr(p_text, v_from+1, 1)
        ;
        if v_char = '-' then
            set negative_number := true, v_from = v_from + 1;
            iterate my_loop;
        end if;
        state_case: begin case p_state
            when 'error' then 
                set p_from = v_length;
                leave state_case;            
            when 'start' then
                case
                    when v_char = '-' then
                        set p_state = 'minus', v_from = v_from + 1;
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
                    when v_char = '"' then
                        set p_state = 'string', v_quote_char = v_char;
                    when v_char = '.' then
                        if substr(p_text, v_from + 1, 1) between '0' and '9' then
                            set p_state = 'decimal', v_from = v_from + 1;
                        else
                            set p_state = 'error';
                            leave my_loop;
                        end if;
                    when v_char = ',' then
                        set p_state = 'comma', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = ':' then 
                        set p_state = 'colon', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = '{' then 
                        set p_state = 'object_begin', v_from = v_from + 1, p_level = p_level + 1;
                        leave my_loop;
                    when v_char = '}' then
                        set p_state = 'object_end', v_from = v_from + 1;
                        leave my_loop;
                    when v_char = '[' then 
                        set p_state = 'array_begin', v_from = v_from + 1, p_level = p_level + 1;
                        leave my_loop;
                    when v_char = ']' then 
                        set p_state = 'array_end', v_from = v_from + 1;
                        leave my_loop;
                    else 
                        set p_state = 'error';
                end case;
            when 'alpha' then 
                case
                    when v_char between 'A' and 'Z' 
                    or   v_char between 'a' and 'z' 
                    or   v_char = '_' then
                        leave state_case;
                    when v_char between '0' and '9' then 
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
            else
                leave my_loop;            
        end case; end state_case;
        set v_from = v_from + 1;
    end while my_loop;
    set p_token = substr(p_text, p_from, v_from - p_from) collate utf8_general_ci;
    set p_from = v_from;
    if p_state in ('decimal', 'integer') then
      set p_state := 'number';
    end if;
    if p_state = 'alphanum' then
      set p_state := 'alpha';
    end if;
    if negative_number and (p_state != 'number') then
    	set p_token := NULL;
    end if;
end;
//

delimiter ;
