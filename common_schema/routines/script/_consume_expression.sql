--
--
--

delimiter //

drop procedure if exists _consume_expression //

create procedure _consume_expression(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   require_parenthesis tinyint unsigned,
   out  consumed_to_id int unsigned,
   out  expression text charset utf8,
   out  expression_statement text charset utf8
)
comment 'Reads expression'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare first_state text;
    declare expression_level int unsigned;
    declare id_end_expression int unsigned; 
    
    set expression_statement := NULL ;
    
    call _skip_spaces(id_from, id_to);
    SELECT level, state FROM _sql_tokens WHERE id = id_from INTO expression_level, first_state;

    if (first_state = 'left parenthesis') then
      SELECT MIN(id) FROM _sql_tokens WHERE id > id_from AND state = 'right parenthesis' AND level = expression_level INTO id_end_expression;
  	  if id_end_expression IS NULL then
	    call _throw_script_error(id_from, 'Unmatched "(" parenthesis');
	  end if;
	  set id_from := id_from + 1;
      call _skip_spaces(id_from, id_to);
      SELECT GROUP_CONCAT(token ORDER BY id SEPARATOR '') FROM _sql_tokens WHERE id BETWEEN id_from AND id_end_expression-1 INTO expression;
      -- Note down the statement (if any) of the expression:
      SELECT token FROM _sql_tokens WHERE id = id_from AND state = 'alpha' INTO expression_statement;
      if expression is NULL then
        call _throw_script_error(id_from, 'Found empty expression');
      end if;
      -- ~~~ select expression, expression_statement;
      set consumed_to_id := id_end_expression;
    else
      if require_parenthesis then
        call _throw_script_error(id_from, 'Expected "(" on expression');
      end if;
    end if;
end;
//

delimiter ;
