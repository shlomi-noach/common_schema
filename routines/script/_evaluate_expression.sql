--
--
--

delimiter //

drop procedure if exists _evaluate_expression //

create procedure _evaluate_expression(
   in  expression text charset utf8,
   in  expression_statement text charset utf8,
   out expression_result tinyint unsigned
)
comment 'Evaluates expression, returns boolean value'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare read_row_count tinyint unsigned default FALSE; 
  
  case
    when expression_statement IN ('insert', 'replace', 'update', 'delete') then begin
	    set read_row_count := TRUE;
	  end;    
    else begin
	    set expression := CONCAT('SELECT ((', expression, ') IS TRUE) INTO @_common_schema_script_expression_result'); 
	  end;
  end case;
  call exec_single(expression);
  set @query_script_rowcount := @common_schema_rowcount;
  if read_row_count then
    set expression_result := ((@query_script_rowcount > 0) IS TRUE);
  else
    set expression_result := @_common_schema_script_expression_result;
  end if;
end;
//

delimiter ;
