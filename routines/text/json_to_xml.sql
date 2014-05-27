--
--
--

delimiter //

drop function if exists json_to_xml//

create function json_to_xml(
    json_text text charset utf8
) returns text charset utf8
comment 'Transforms JSON to XML'
language SQL
deterministic
modifies sql data
sql security invoker
begin
    declare v_from, v_old_from int unsigned;
    declare v_token text;
    declare v_level int;
    declare v_state, expect_state varchar(255);
    declare _json_tokens_id int unsigned default 0;
    declare is_lvalue, is_rvalue tinyint unsigned;
    declare scope_stack text charset ascii;
    declare xml text charset utf8;
    declare xml_nodes, xml_node text charset utf8;
    
    set json_text := trim_wspace(json_text);
    
    set expect_state := 'object_begin';
    set is_lvalue := true;
    set is_rvalue := false;
    set scope_stack := '';
    set xml_nodes := '';
    set xml_node := '';
    set xml := '';
    get_token_loop: repeat 
        set v_old_from = v_from;
        call _get_json_token(json_text, v_from, v_level, v_token, 1, v_state);
        set _json_tokens_id := _json_tokens_id + 1;
        if v_state = 'whitespace' then
          iterate get_token_loop;
        end if;
        if v_level < 0 then
          return null;
          -- call throw('Negative nesting level found in _get_json_tokens');
        end if;
        if v_state = 'start' and scope_stack = '' then
          leave get_token_loop;
        end if;
        if FIND_IN_SET(v_state, expect_state) = 0 then
          return null;
          -- call throw(CONCAT('Expected ', expect_state, '. Got ', v_state));
        end if;
        if v_state = 'array_end' and left(scope_stack, 1) = 'o' then
          return null;
          -- call throw(CONCAT('Missing "}". Found ', v_state));
        end if;
        if v_state = 'object_end' and left(scope_stack, 1) = 'a' then
          return null;
          -- call throw(CONCAT('Missing "]". Found ', v_state));
        end if;
        if v_state = 'alpha' and lower(v_token) not in ('true', 'false', 'null') then
          return null;
          -- call throw(CONCAT('Unsupported literal: ', v_token));
        end if;
        set is_rvalue := false;
        case 
          when v_state = 'object_begin' then set expect_state := 'string', scope_stack := concat('o', scope_stack), is_lvalue := true;
          when v_state = 'array_begin' then set expect_state := 'string,object_begin', scope_stack := concat('a', scope_stack), is_lvalue := false;
          when v_state = 'string' and is_lvalue then set expect_state := 'colon', xml_node := v_token;
          when v_state = 'colon' then set expect_state := 'string,number,alpha,object_begin,array_begin', is_lvalue := false;
          when FIND_IN_SET(v_state, 'string,number,alpha') and not is_lvalue then set expect_state := 'comma,object_end,array_end', is_rvalue := true;
          when v_state = 'object_end' then set expect_state := 'comma,object_end,array_end', scope_stack := substring(scope_stack, 2);
          when v_state = 'array_end' then set expect_state := 'comma,object_end,array_end', scope_stack := substring(scope_stack, 2);
          when v_state = 'comma' and left(scope_stack, 1) = 'o' then set expect_state := 'string', is_lvalue := true;
          when v_state = 'comma' and left(scope_stack, 1) = 'a' then set expect_state := 'string,object_begin', is_lvalue := false;
        end case;
        set xml_node := unquote(xml_node);
        if v_state = 'object_begin' then 
          if substring_index(xml_nodes, ',', 1) != '' then
            set xml := concat(xml, '<', substring_index(xml_nodes, ',', 1), '>');
          end if;
          set xml_nodes := concat(',', xml_nodes);
        end if;
        if v_state = 'string' and is_lvalue then
          if left(xml_nodes, 1) = ',' then
            set xml_nodes := concat(xml_node, xml_nodes);
          else
            set xml_nodes := concat(xml_node, substring(xml_nodes, locate(',', xml_nodes)));
          end if;
        end if;
        if is_rvalue then
          set xml := concat(xml, '<', xml_node, '>', encode_xml(unquote(v_token)), '</', xml_node, '>');
        end if;
        if v_state = 'object_end' then 
          set xml_nodes := substring(xml_nodes, locate(',', xml_nodes) + 1);
          if substring_index(xml_nodes, ',', 1) != '' then
            set xml := concat(xml, '</', substring_index(xml_nodes, ',', 1), '>');
          end if;
        end if;
    until 
        v_old_from = v_from
    end repeat;
    return xml;
end;
//

delimiter ;
