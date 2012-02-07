--
-- Called by _foreach, this routines executes a single step in iteration.
-- Execution is based on input, and the routine either dynamically executes given queries, or 
-- calls upon scripting to interpret statement.
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _run_foreach_step $$
CREATE PROCEDURE _run_foreach_step(
   execute_query TEXT CHARSET utf8,
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   expect_single tinyint unsigned,
   out  consumed_to_id int unsigned,
   in   variables_array_id int unsigned,
   in depth int unsigned,
   in should_execute_statement tinyint unsigned
)  
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Invoke queries/statement per foreach step'

main_body: begin
  if execute_query IS NOT NULL then
    call run(execute_query);
  elseif id_from IS NOT NULL then
    call _assign_input_local_variables(variables_array_id);
    call _consume_statement(id_from, id_to, expect_single, consumed_to_id, depth, should_execute_statement);
  else
    -- Panic. Should not get here.
    call throw('_run_foreach_step(): neither queries nor script position provided');
  end if;
end $$

DELIMITER ;
