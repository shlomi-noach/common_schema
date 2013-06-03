-- 
-- Stores text message to be verbosed at end of script.
--

DELIMITER $$

DROP procedure IF EXISTS _script_report $$
CREATE procedure _script_report(report_params TEXT CHARSET utf8)
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare report_query text charset utf8;
  
  declare is_header tinyint unsigned default 0;
  declare is_paragraph tinyint unsigned default 0;
  declare is_bullet tinyint unsigned default 0;
  declare is_code tinyint unsigned default 0;
  declare is_horizontal_ruler tinyint unsigned default 0;
  
  if not @_common_schema_script_report_used then
    -- First report in this script. Make sure to clean up first.
    delete from _script_report_data;
    set @_common_schema_script_report_used := true;
  end if;
  
  set report_params := trim_wspace(report_params);
  set @_common_schema_script_report_prefix_len := 0;
  if (@_common_schema_script_report_prefix_len := starts_with(report_params, 'h1 ')) then
    set is_header := 1;
  elseif (@_common_schema_script_report_prefix_len := starts_with(report_params, 'p ')) then
    set is_paragraph := 1;
  elseif (@_common_schema_script_report_prefix_len := starts_with(report_params, 'li ')) then
    set is_bullet := 1;
  elseif (@_common_schema_script_report_prefix_len := starts_with(report_params, 'code ')) then
    set is_code := 1;
  elseif (@_common_schema_script_report_prefix_len := starts_with(report_params, 'hr ')) then
    set is_horizontal_ruler := 1;
  end if;
  set report_params := substring(report_params, @_common_schema_script_report_prefix_len + 1);
  
  set report_query := CONCAT('set @_query_script_report_line := CONCAT_WS(@_common_schema_script_report_delimiter, ', report_params, ')');
  call exec_single(report_query);
  
  set @_query_script_report_line := trim_wspace(@_query_script_report_line);
--  insert into 
--    _script_report_data (info) values (@_query_script_report_line);
  if is_header then
    set @_query_script_report_line := CONCAT('\n', @_query_script_report_line,
      '\n', REPEAT('=', CHAR_LENGTH(@_query_script_report_line)));
  end if;
  if is_bullet then
    set @_query_script_report_line := CONCAT('- ', @_query_script_report_line);
  end if;
  if is_code then
    set @_query_script_report_line := CONCAT('> ', @_query_script_report_line);
  end if;
  if is_paragraph then
    set @_query_script_report_line := CONCAT('\n', @_query_script_report_line);
  end if;
  if is_horizontal_ruler then
    set @_query_script_report_line := CONCAT('---\n', @_query_script_report_line);
  end if;
  
  insert into 
    _script_report_data (session_id, info) 
  SELECT 
    CONNECTION_ID(), split_token(@_query_script_report_line, '\n', n)
  FROM
    numbers
  WHERE 
    numbers.n BETWEEN 1 AND get_num_tokens(@_query_script_report_line, '\n')
  ORDER BY 
    n ASC;

  set @_query_script_report_line := NULL;
end $$

DELIMITER ;
