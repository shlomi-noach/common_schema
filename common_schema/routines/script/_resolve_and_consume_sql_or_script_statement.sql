--
--
--

delimiter //

drop procedure if exists _resolve_and_consume_sql_or_script_statement //

create procedure _resolve_and_consume_sql_or_script_statement(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   statement_id_from      int unsigned,
   in   statement_id_to      int unsigned,
   in   depth int unsigned,
   in   statement_token text charset utf8,
   in   should_execute_statement tinyint unsigned
)
comment 'Reads script statement'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare resolve_statement_type text charset utf8;
  declare token_has_matched tinyint unsigned default FALSE;
  
  select statement_type from _script_statements where statement = statement_token into resolve_statement_type;
  
  case resolve_statement_type
    when 'sql' then begin
	    call _consume_sql_statement(id_from, statement_id_to, should_execute_statement);
	  end;
    when 'script' then begin
	    call _consume_script_statement(id_from, id_to, statement_id_from, statement_id_to, depth, statement_token, should_execute_statement);
	  end;
    when 'script,sql' then begin
        if statement_token = 'start' then
          -- can be script ("start transaction") or sql ("start slave" or anything else)
          call _consume_if_exists(statement_id_from, statement_id_to, @_common_schema_dummy, 'transaction', NULL, token_has_matched, @_common_schema_dummy);
          if token_has_matched then
            call _consume_script_statement(id_from, id_to, statement_id_from, statement_id_to, depth, statement_token, should_execute_statement);
          else
            call _consume_sql_statement(id_from, statement_id_to, should_execute_statement);
          end if;
        end if;
	  end;
  end case;
end;
//

delimiter ;
