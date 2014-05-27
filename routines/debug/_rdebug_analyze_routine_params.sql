-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Analyze the parameters for a given routine; write down their names
-- 

DELIMITER $$

DROP procedure IF EXISTS _rdebug_analyze_routine_params $$
CREATE procedure _rdebug_analyze_routine_params(
  in rdebug_routine_schema varchar(128) charset utf8,
  in rdebug_routine_name   varchar(128) charset utf8,
  in variables_routine_param_list blob,
  in quoting_characters VARCHAR(5)
)
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

main_body: BEGIN
  begin
    -- param list
    declare param_index int unsigned default 1;
    declare param_text text charset utf8;
  
    set variables_routine_param_list := replace_sections(variables_routine_param_list, '(', ')', '');
    set variables_routine_param_list := common_schema._retokenized_text(variables_routine_param_list, ',', quoting_characters, true, 'skip');
  
    while param_index <= ifnull(@common_schema_retokenized_count, 0) do
      set param_text := split_token(variables_routine_param_list, @common_schema_retokenized_delimiter, param_index);
      set param_text := replace_all(param_text, ' \n\r\b\t', ' ');
      if (locate('in ', lower(param_text)) = 1) or (locate('out ', lower(param_text)) = 1) or (locate('inout ', lower(param_text)) = 1) then
        set param_text = trim(substring(param_text, locate(' ', param_text)));
      end if;
      set param_text = trim(left(param_text, locate(' ', param_text)));
      insert into 
        _rdebug_routine_variables (routine_schema, routine_name, variable_name, variable_scope_id_start, variable_scope_id_end, variable_type)
        values (rdebug_routine_schema, rdebug_routine_name, param_text, 0, NULL, 'param');
      set param_index := param_index + 1;
    end while;
  end;
END $$

DELIMITER ;
