--
--


DELIMITER $$

DROP PROCEDURE IF EXISTS foreach $$
CREATE PROCEDURE foreach(iterate_data TEXT CHARSET utf8, execute_query TEXT CHARSET utf8) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  -- The following is now the constant 9.
  declare sql_query_num_columns TINYINT UNSIGNED DEFAULT 9;
  -- In any type of iteration, iteration_number indicates the 1-based number of iteration. It is similar to NR in awk.
  declare iteration_number INT UNSIGNED DEFAULT 0;
  
  -- First, analyze 'iterate_data' input. What kind of input is it?
  if _is_select_query(iterate_data) then
    -- 
	-- input is query: need to execute the query and detect number of columns
	-- 
    DROP TEMPORARY TABLE IF EXISTS _tmp_foreach;
    
    set @_foreach_iterate_query := iterate_data;
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
  elseif iterate_data RLIKE '^-?[0-9]+:-?[0-9]+,-?[0-9]+:-?[0-9]+$' then
    begin
	  --
      -- input is two dimentional integers range, both inclusive (e.g. '-10:55,1:17')
      --
      set @_foreach_first_range := split_token(iterate_data, ',', 1);
      set @_foreach_second_range := split_token(iterate_data, ',', 2);

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
  elseif iterate_data RLIKE '^-?[0-9]+:-?[0-9]+$' then
    begin
	  --
      -- input is integers range, both inclusive (e.g. '-10:55')
      -- 
      declare _foreach_start_index INT SIGNED DEFAULT CAST(split_token(iterate_data, ':', 1) AS SIGNED INTEGER);
      declare _foreach_end_index INT SIGNED DEFAULT CAST(split_token(iterate_data, ':', 2) AS SIGNED INTEGER);
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
  else
    begin
	  --
      -- input is constant tokens (e.g. 'read green blue')
      --
      declare _foreach_num_tokens INT UNSIGNED DEFAULT get_num_tokens(iterate_data, ' ');
      declare _foreach_token TEXT CHARSET utf8;
      declare _foreach_row_number INT UNSIGNED DEFAULT 1;
      
      set iteration_number := 1;
      constant_tokens_loop: while iteration_number <= _foreach_num_tokens do
        set _foreach_token := split_token(iterate_data, ' ', iteration_number);
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
  end if;    
end $$

DELIMITER ;
