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
  declare is_horizontal_ruler tinyint unsigned default 0;
  
  if not @_common_schema_script_report_used then
    drop temporary table if exists _script_report_data;
    create temporary table _script_report_data (
      id int unsigned AUTO_INCREMENT,
      info text charset utf8,
      PRIMARY KEY (id)
    ) engine=MyISAM;
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
  elseif (@_common_schema_script_report_prefix_len := starts_with(report_params, 'hr ')) then
    set is_horizontal_ruler := 1;
  end if;
  set report_params := substring(report_params, @_common_schema_script_report_prefix_len + 1);
  
  set report_query := CONCAT('set @_query_script_report_line := CONCAT_WS(@_common_schema_script_report_delimiter, ', report_params, ')');
  call exec_single(report_query);
  
  set @_query_script_report_line := trim_wspace(@_query_script_report_line);
  set @_query_script_report_line := case @_query_script_report_line
    when '<h1>' then ' '
    when '<p>' then ' '
    when '<br>' then ' '
    else @_query_script_report_line
  end;
--  insert into 
--    _script_report_data (info) values (@_query_script_report_line);
  if is_header then
    set @_query_script_report_line := CONCAT('\n', @_query_script_report_line,
      '\n', REPEAT('=', CHAR_LENGTH(@_query_script_report_line)));
  end if;
  if is_bullet then
    set @_query_script_report_line := CONCAT('- ', @_query_script_report_line);
  end if;
  if is_paragraph then
    set @_query_script_report_line := CONCAT('\n', @_query_script_report_line);
  end if;
  if is_horizontal_ruler then
    set @_query_script_report_line := CONCAT('---\n', @_query_script_report_line);
  end if;
  
  insert into 
    _script_report_data (info) 
  SELECT 
    split_token(@_query_script_report_line, '\n', n)
  FROM
    numbers
  WHERE 
    numbers.n BETWEEN 1 AND get_num_tokens(@_query_script_report_line, '\n')
  ORDER BY 
    n ASC;

  set @_query_script_report_line := NULL;
end $$

DELIMITER ;
