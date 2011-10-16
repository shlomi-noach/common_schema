--
-- Invoke queries on each element of given collection.
--
-- This procedure will iterate a given collection. The collection is one of several
-- supported types as described below. For each element in the collection, the routine
-- invokes the given set (one or more) of queries.
--
-- Queries may relate to the particular element at hand, by using placeholders, in similar approach
-- to that used by regular expressions or the awk program.
-- 
-- foreach() supports the following collection types:
-- - Query: the collection is the rowset. An element is a single row.
-- - Numbers range: e.g. '1970:2038'
-- - Two dimentional numbers range: e.g. '-20:20,1970:2038'
-- - Constants set: e.g. '{red, green, blue}'
-- - 'schema': iterate all schemata
-- - 'schema like ...': iterate schemata whose name is like the given text
-- - 'schema ~ ...': iterate schemata whose name matches the given text
-- - 'table like ...': iterate tables whose name is like the given text
-- - 'table ~ ...': iterate tables whose name matches the given text
-- - 'table in schema_name': iterate tables in a given schema
-- 
-- Placeholders vary according to collection type:
-- - Query: ${1} - ${9}
-- - Numbers range: ${1}
-- - Two dimentional numbers range: ${1}, ${2}
-- - Constants set: ${1}
-- - 'schema': ${1} == ${schema}
-- - 'schema like ...': ${1} == ${schema}
-- - 'schema ~ ...': ${1} == ${schema}
-- - 'table like ...': ${1} == ${table}, ${2} == ${schema}
-- - 'table ~ ...': ${1} == ${table}, ${2} == ${schema}
-- - 'table in schema_name': ${1} == ${table}, ${2} == ${schema}
-- All types support the ${NR} placeholder (row number, similar to awk)
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS foreach $$
CREATE PROCEDURE foreach(collection TEXT CHARSET utf8, execute_query TEXT CHARSET utf8) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Invoke queries per element of given collection'

begin
  -- The following is now the constant 9.
  declare sql_query_num_columns TINYINT UNSIGNED DEFAULT 9;
  -- In any type of iteration, iteration_number indicates the 1-based number of iteration. It is similar to NR in awk.
  declare iteration_number INT UNSIGNED DEFAULT 0;
  
  
  set @__group_concat_max_len := @@group_concat_max_len;
  set @@group_concat_max_len := 32 * 1024 * 1024;
  
  -- Preprocessing: certain types of 'collection' are rewritten, to be handled later.
  if collection = 'schema' then
    set collection := 'schema ~ /.*/';
  end if;
  if collection RLIKE '^schema[ ]+like[ ]+[^ ]+[ ]*$' then
    begin
	  -- Rewrite as "~" regexp match
	  declare like_expression TEXT CHARSET utf8 DEFAULT unquote(trim_wspace(split_token(collection, ' like ', 2)));
	  set collection := CONCAT('schema ~ /', like_to_rlike(like_expression), '/');
    end;
  end if;
  if collection RLIKE '^schema[ ]*~[ ]*[^ ]+[ ]*$' then
    begin
	  --
	  -- Handle search for schema (filtered by regexp). rewrite as query, to be handled later.
	  --
	  declare re TEXT CHARSET utf8 DEFAULT unquote(trim_wspace(split_token(collection, '~', 2)));
	  set collection := CONCAT(
	    'SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME RLIKE ',
	    '\'', re, '\'');
      set execute_query := REPLACE(execute_query, '${schema}', '${1}');
	end;
  end if;
  if collection RLIKE '^table[ ]+in[ ]+[^ ]+[ ]*$' then
    begin
	  declare db TEXT CHARSET utf8 DEFAULT unquote(trim_wspace(split_token(collection, ' in ', 2)));
	  set collection := CONCAT(
	    'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=',
	    '\'', db, '\' AND TABLE_TYPE=\'BASE TABLE\'');
      set execute_query := REPLACE(execute_query, '${schema}', '${2}');
      set execute_query := REPLACE(execute_query, '${2}', db);
      set execute_query := REPLACE(execute_query, '${table}', '${1}');
	end;
  end if;
  if collection RLIKE '^table[ ]+like[ ]+[^ ]+[ ]*$' then
    begin
	  -- Rewrite as "~" regexp match
	  declare like_expression TEXT CHARSET utf8 DEFAULT unquote(trim_wspace(split_token(collection, ' like ', 2)));
	  set collection := CONCAT('table ~ /', like_to_rlike(like_expression), '/');
    end;
  end if;

  --
  -- Analyze the type of input. What kind of iteration is this?
  --
  if collection RLIKE '^table[ ]*~[ ]*[^ ]+[ ]*$' then
    begin
	  --
	  -- Handle search for table (filtered by regexp). 
      -- This does not get rewritten as query, since it will make for poor performance
      -- on INFORMATION_SCHEMA. Instead, we iterate each schema utilizing I_S optimizations.
	  --
      declare current_db TEXT CHARSET utf8 DEFAULT NULL;
      declare re TEXT CHARSET utf8 DEFAULT unquote(trim_wspace(split_token(collection, '~', 2)));
      declare count_tables SMALLINT UNSIGNED DEFAULT 0;
      declare table_name TEXT CHARSET utf8 DEFAULT NULL;
      declare done INT DEFAULT 0;
      declare table_counter INT UNSIGNED DEFAULT 1;
      declare db_cursor cursor for SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA;
      declare continue handler for NOT FOUND set done = 1;
	  
	  open db_cursor;
      db_loop: loop
        fetch db_cursor into current_db; 
        if done then
          leave db_loop;
        end if;

        set @_foreach_tables_query:= CONCAT(
          'SELECT GROUP_CONCAT(TABLE_NAME SEPARATOR \'\\n\') FROM INFORMATION_SCHEMA.TABLES ',
          'WHERE TABLE_SCHEMA = \'',current_db,'\' AND TABLE_NAME RLIKE \'',re,'\' AND TABLE_TYPE=\'BASE TABLE\' ',
          'INTO @_foreach_table_names');
        call exec(@_foreach_tables_query);

        set count_tables := get_num_tokens(@_foreach_table_names, '\n');
        set iteration_number := 1;
        while iteration_number <= count_tables do
          set table_name := split_token(@_foreach_table_names, '\n', iteration_number);
          set @_foreach_exec_query := execute_query;
          set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${table}', '${1}');
          set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${1}', table_name);
          set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${schema}', '${2}');
          set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${2}', current_db);
          set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${NR}', table_counter);

          call exec(@_foreach_exec_query);
          set iteration_number := iteration_number + 1;
          set table_counter := table_counter + 1;
        end while;
      end loop;
      close db_cursor;
	end;
  elseif _is_select_query(collection) then
    -- 
	-- input is query: need to execute the query and detect number of columns
	-- 
    DROP TEMPORARY TABLE IF EXISTS _tmp_foreach;
    
    set @_foreach_iterate_query := collection;
    call _wrap_select_list_columns(@_foreach_iterate_query, sql_query_num_columns, @common_schema_error);
    set @_foreach_iterate_query := CONCAT('CREATE TEMPORARY TABLE _tmp_foreach ', @_foreach_iterate_query);

    PREPARE st FROM @_foreach_iterate_query;
    EXECUTE st;
    DEALLOCATE PREPARE st;
    
    -- execute sql_query and iterate
    begin	
      declare foreach_col1, foreach_col2, foreach_col3, foreach_col4, foreach_col5, foreach_col6, foreach_col7, foreach_col8, foreach_col9 VARCHAR(4096) CHARSET utf8;
      declare done INT DEFAULT 0;
      declare query_cursor cursor for SELECT * FROM _tmp_foreach;
      declare continue handler for NOT FOUND set done = 1;
      
      set iteration_number := 1;
      open query_cursor;
      read_loop: loop
        fetch query_cursor into foreach_col1, foreach_col2, foreach_col3, foreach_col4, foreach_col5, foreach_col6, foreach_col7, foreach_col8, foreach_col9; 
        if done then
          leave read_loop;
        end if;
        -- Replace placeholders
        -- NULL values are allowed, and are translated to the literal 'NULL', or else the REPLACE method would return NULL.
        set @_foreach_exec_query := execute_query;
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${1}', IFNULL(foreach_col1, 'NULL'));
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${2}', IFNULL(foreach_col2, 'NULL'));
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${3}', IFNULL(foreach_col3, 'NULL'));
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${4}', IFNULL(foreach_col4, 'NULL'));
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${5}', IFNULL(foreach_col5, 'NULL'));
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${6}', IFNULL(foreach_col6, 'NULL'));
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${7}', IFNULL(foreach_col7, 'NULL'));
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${8}', IFNULL(foreach_col8, 'NULL'));
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${9}', IFNULL(foreach_col9, 'NULL'));
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${NR}', iteration_number);

        call exec(@_foreach_exec_query);
        
        set iteration_number := iteration_number + 1; 
      end loop;
      close query_cursor;
    end; 
    
    DROP TEMPORARY TABLE IF EXISTS _tmp_foreach;
  elseif collection RLIKE '^-?[0-9]+:-?[0-9]+,-?[0-9]+:-?[0-9]+$' then
    begin
	  --
      -- input is two dimentional integers range, both inclusive (e.g. '-10:55,1:17')
      --
      set @_foreach_first_range := split_token(collection, ',', 1);
      set @_foreach_second_range := split_token(collection, ',', 2);

      set @_foreach_first_start_index := CAST(split_token(@_foreach_first_range, ':', 1) AS SIGNED INTEGER);
      set @_foreach_first_end_index := CAST(split_token(@_foreach_first_range, ':', 2) AS SIGNED INTEGER);
      set @_foreach_second_start_index := CAST(split_token(@_foreach_second_range, ':', 1) AS SIGNED INTEGER);
      set @_foreach_second_end_index := CAST(split_token(@_foreach_second_range, ':', 2) AS SIGNED INTEGER);

      set iteration_number := 1;
      set @_foreach_first_loop_index := @_foreach_first_start_index;
      while @_foreach_first_loop_index <= @_foreach_first_end_index do
        set @_foreach_second_loop_index := @_foreach_second_start_index;
        while @_foreach_second_loop_index <= @_foreach_second_end_index do
          set @_foreach_exec_query := execute_query;
          set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${1}', @_foreach_first_loop_index);
          set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${2}', @_foreach_second_loop_index);
          set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${NR}', iteration_number);
        
          call exec(@_foreach_exec_query);

          set iteration_number := iteration_number + 1;
          set @_foreach_second_loop_index := @_foreach_second_loop_index + 1;
        end WHILE;
        set @_foreach_first_loop_index := @_foreach_first_loop_index + 1;
      end while;
    end;
  elseif collection RLIKE '^-?[0-9]+:-?[0-9]+$' then
    begin
	  --
      -- input is integers range, both inclusive (e.g. '-10:55')
      -- 
      declare _foreach_start_index INT SIGNED DEFAULT CAST(split_token(collection, ':', 1) AS SIGNED INTEGER);
      declare _foreach_end_index INT SIGNED DEFAULT CAST(split_token(collection, ':', 2) AS SIGNED INTEGER);
      declare _foreach_loop_index INT SIGNED DEFAULT NULL;
      
      set iteration_number := 1;
      set _foreach_loop_index := _foreach_start_index;
      while _foreach_loop_index <= _foreach_end_index do
        set @_foreach_exec_query := execute_query;
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${1}', _foreach_loop_index);
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${NR}', iteration_number);
      
        call exec(@_foreach_exec_query);

        set iteration_number := iteration_number + 1;
        set _foreach_loop_index := _foreach_loop_index + 1;
      end while;
    end;
  elseif collection RLIKE '^{.*}$' then
    begin
	  --
      -- input is constant tokens (e.g. 'read green blue'), space or comma delimited
      --
      declare _foreach_iterate_tokens TEXT CHARSET utf8 DEFAULT REPLACE(unwrap(collection), ',', ' ');
      declare _foreach_num_tokens INT UNSIGNED DEFAULT get_num_tokens(_foreach_iterate_tokens, ' ');
      declare _foreach_token TEXT CHARSET utf8;
      declare _foreach_row_number INT UNSIGNED DEFAULT 1;
      
      set iteration_number := 1;
      constant_tokens_loop: while iteration_number <= _foreach_num_tokens do
        set _foreach_token := split_token(_foreach_iterate_tokens, ' ', iteration_number);
        set iteration_number := iteration_number + 1;
        if CHAR_LENGTH(_foreach_token) = 0 then
          iterate constant_tokens_loop;
        end if;
        set @_foreach_exec_query := execute_query;
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${1}', _foreach_token);
        set @_foreach_exec_query := REPLACE(@_foreach_exec_query, '${NR}', _foreach_row_number);
      
        call exec(@_foreach_exec_query);

        set _foreach_row_number := _foreach_row_number + 1;
      end while;
    end;
  else
    set @common_schema_error := CONCAT('SELECT `foreach(): unrecognized collection format: \"', collection, '\"` FROM DUAL');
    call exec(@common_schema_error);
  end if;    
  set @@group_concat_max_len := @__group_concat_max_len;
end $$

DELIMITER ;
