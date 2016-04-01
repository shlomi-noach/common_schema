--
--
--

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_assign_min_max_variables $$
CREATE PROCEDURE _split_assign_min_max_variables(
  id_from      int unsigned,
  split_table_schema varchar(128),
  split_table_name varchar(128),
  split_options varchar(2048) charset utf8,
  out is_empty_range tinyint unsigned
  )
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare query text default NULL;
  declare manual_min_max_params_used tinyint unsigned default false;
  declare column_names text default _split_get_columns_names();
  declare columns_order_ascending_clause text default _split_get_columns_order_ascending_clause();
  declare min_variables_names text default _split_get_min_variables_names();
  declare columns_order_descending_clause text default _split_get_columns_order_descending_clause();
  declare max_variables_names text default _split_get_max_variables_names();
  declare columns_count tinyint unsigned default _split_get_columns_count();
  declare start_values text default get_option(split_options, 'start');
  declare stop_values text default get_option(split_options, 'stop');

  set is_empty_range := false;

  set query := CONCAT(
    'select ', column_names, ' from ',
    mysql_qualify(split_table_schema), '.', mysql_qualify(split_table_name),
    ' order by ', columns_order_ascending_clause,
    ' limit 1 ',
    ' into ', min_variables_names
  );
  call exec_single(query);

  set query := CONCAT(
    'select ', column_names, ' from ',
    mysql_qualify(split_table_schema), '.', mysql_qualify(split_table_name),
    ' order by ', columns_order_descending_clause,
    ' limit 1 ',
    ' into ', max_variables_names
  );
  call exec_single(query);

  if start_values is not null then
    if columns_count = get_num_tokens(start_values, ',') then
      select
          group_concat('set ', min_variable_name, ' := ', QUOTE(split_token(start_values, ',', column_order)), ';' order by column_order separator '')
        from
          _split_column_names_table
        into @_query;
      set query=@_query;
      call exec(query);
      set manual_min_max_params_used := true;
    else
      call _throw_script_error(id_from, CONCAT(get_num_tokens(start_values, ','), ' ''start'' value[s] provided; chosen index has ', columns_count, ' columns'));
    end if;
  end if;
  if stop_values is not null then
    if columns_count = get_num_tokens(stop_values, ',') then
      select
          group_concat('set ', max_variable_name, ' := ', QUOTE(split_token(stop_values, ',', column_order)), ';' order by column_order separator '')
        from
          _split_column_names_table
        into @_query;
      set query=@_query;
      call exec(query);
      set manual_min_max_params_used := true;
    else
      call _throw_script_error(id_from, CONCAT(get_num_tokens(stop_values, ','), ' ''stop'' value[s] provided; chosen index has ', columns_count, ' columns'));
    end if;
  end if;
  if manual_min_max_params_used then

    -- Due to manual intervention, we need to verify boundaries.
    -- We know for certain there is one column in splitting key (due to above checks)
    set @_query=null;
    select
      CONCAT(
        'SELECT (',
          GROUP_CONCAT(min_variable_name order by column_order), ') > (', GROUP_CONCAT(max_variable_name order by column_order),
        ') INTO @_split_is_empty_range_result'
        )
      from _split_column_names_table
      into @_query;
    set query=@_query;

    call exec_single(query);

    if @_split_is_empty_range_result then
      set is_empty_range := true;
    end if;

  end if;

  -- Check if range is empty
  set @_query=null;
  select
    CONCAT(
      'SELECT (',
      GROUP_CONCAT(
        min_variable_name, ' IS NULL'
        separator ' AND '
      ),
      ') INTO @_split_is_empty_range_result'
      )
    from _split_column_names_table
    into @_query;
  set query=@_query;

  call exec_single(query);
  if @_split_is_empty_range_result then
    set is_empty_range := true;
  end if;


  set @_query_script_split_min := TRIM(TRAILING ',' FROM CONCAT_WS(',',
  	IF(columns_count >= 1, QUOTE((SELECT @_split_column_variable_min_1)), ''),
  	IF(columns_count >= 2, QUOTE((SELECT @_split_column_variable_min_2)), ''),
  	IF(columns_count >= 3, QUOTE((SELECT @_split_column_variable_min_3)), ''),
  	IF(columns_count >= 4, QUOTE((SELECT @_split_column_variable_min_4)), ''),
  	IF(columns_count >= 5, QUOTE((SELECT @_split_column_variable_min_5)), ''),
  	IF(columns_count >= 6, QUOTE((SELECT @_split_column_variable_min_6)), ''),
  	IF(columns_count >= 7, QUOTE((SELECT @_split_column_variable_min_7)), ''),
  	IF(columns_count >= 8, QUOTE((SELECT @_split_column_variable_min_8)), ''),
  	IF(columns_count >= 9, QUOTE((SELECT @_split_column_variable_min_9)), '')
  ));
  set @_query_script_split_max := TRIM(TRAILING ',' FROM CONCAT_WS(',',
  	IF(columns_count >= 1, QUOTE((SELECT @_split_column_variable_max_1)), ''),
  	IF(columns_count >= 2, QUOTE((SELECT @_split_column_variable_max_2)), ''),
  	IF(columns_count >= 3, QUOTE((SELECT @_split_column_variable_max_3)), ''),
  	IF(columns_count >= 4, QUOTE((SELECT @_split_column_variable_max_4)), ''),
  	IF(columns_count >= 5, QUOTE((SELECT @_split_column_variable_max_5)), ''),
  	IF(columns_count >= 6, QUOTE((SELECT @_split_column_variable_max_6)), ''),
  	IF(columns_count >= 7, QUOTE((SELECT @_split_column_variable_max_7)), ''),
  	IF(columns_count >= 8, QUOTE((SELECT @_split_column_variable_max_8)), ''),
  	IF(columns_count >= 9, QUOTE((SELECT @_split_column_variable_max_9)), '')
  ));

end $$

DELIMITER ;
