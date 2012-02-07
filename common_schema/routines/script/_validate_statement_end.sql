--
-- Expects and validates that stament ends with delimiter or end of block, returning 
-- position of end of statement
--

delimiter //

drop procedure if exists _validate_statement_end //

create procedure _validate_statement_end(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   out  id_end_statement int unsigned
) 
comment 'Validates delimiter or end of block'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  declare state_end_statement text charset utf8 default NULL;
  
  set id_end_statement := NULL;
  -- id_to limits scope of this statement until end of block or end of script.
  -- it is possible that a new block starts within these bounds, or multiple statements appear, or any combination of the above.
  SELECT id, state FROM _sql_tokens WHERE id > id_from AND id <= id_to AND state IN ('statement delimiter', 'left braces') ORDER BY id ASC LIMIT 1 INTO id_end_statement, state_end_statement;
  if state_end_statement = 'left braces' then
    call _throw_script_error(id_from, 'Missing '';'' statement delimiter');
  end if; 
  if id_end_statement IS NULL then
    -- Last query in script or block is allowed not to be terminated by ';'
    set id_end_statement := id_to;
  end if;
end;
//

delimiter ;
