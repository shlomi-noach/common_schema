--
--


DELIMITER $$

DROP PROCEDURE IF EXISTS foreach $$
CREATE PROCEDURE foreach(iterate_data TEXT CHARSET utf8, execute_query TEXT CHARSET utf8) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

BEGIN
  DECLARE sql_query_num_columns TINYINT UNSIGNED DEFAULT 1;
  -- In any type of iteration, iteration_number indicates the 1-based number of iteration. It is similar to NR in awk.
  DECLARE iteration_number INT UNSIGNED DEFAULT 0;
  
  -- First, analyze 'iterate_data' input. What kind of input is it?
  IF LOCATE('select', LOWER(LTRIM(iterate_data))) = 1 THEN
	-- input is query: need to execute the query and detect number of columns
    DROP TEMPORARY TABLE IF EXISTS _tmp_foreach;
    SET @q := CONCAT('CREATE TEMPORARY TABLE _tmp_foreach ', iterate_data);  
    PREPARE st FROM @q;
    EXECUTE st;
    DEALLOCATE PREPARE st;
  
    -- Will now detect the number of columns resulting from the input query.
    -- Ugly hack. But that's what we're here for!
    BEGIN
	  DECLARE _tmp_file VARCHAR(4096) CHARSET utf8 DEFAULT NULL;
      SET _tmp_file := CONCAT(@@global.tmpdir, '/tmp_foreach_', CONNECTION_ID(), '_', UNIX_TIMESTAMP(NOW()), '_', LEFT(MD5(RAND()), 10), '.csv');

      -- Write 1 row into temporary file
      SET @q := CONCAT('SELECT * FROM _tmp_foreach LIMIT 1 INTO OUTFILE \'', _tmp_file, '\' FIELDS TERMINATED BY \'\\t|\\t\'');
      PREPARE st FROM @q;
      EXECUTE st;
      DEALLOCATE PREPARE st;
    
      -- Parse temporary file as text and get the number of columns
      SELECT LOAD_FILE(_tmp_file) INTO @_csv_file_firstline;
      SELECT get_num_tokens(@_csv_file_firstline, '\t|\t') INTO sql_query_num_columns;
      SET @_csv_file_firstline := NULL;
    END;
    
    -- execute sql_query and iterate
    BEGIN	
  	DECLARE foreach_c1, foreach_c2, foreach_c3, foreach_c4, foreach_c5, foreach_c6, foreach_c7, foreach_c8, foreach_c9 VARCHAR(4096) CHARSET utf8;
      DECLARE done INT DEFAULT 0;
      DECLARE query_cursor CURSOR FOR SELECT * FROM _tmp_foreach;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
      
      SET iteration_number := 1;
      OPEN query_cursor;
      read_loop: LOOP
        -- for each row / piece of data:
        CASE sql_query_num_columns
          WHEN 1 THEN FETCH query_cursor INTO foreach_c1; 
          WHEN 2 THEN FETCH query_cursor INTO foreach_c1, foreach_c2; 
          WHEN 3 THEN FETCH query_cursor INTO foreach_c1, foreach_c2, foreach_c3; 
          WHEN 4 THEN FETCH query_cursor INTO foreach_c1, foreach_c2, foreach_c3, foreach_c4; 
          WHEN 5 THEN FETCH query_cursor INTO foreach_c1, foreach_c2, foreach_c3, foreach_c4, foreach_c5; 
          WHEN 6 THEN FETCH query_cursor INTO foreach_c1, foreach_c2, foreach_c3, foreach_c4, foreach_c5, foreach_c6; 
          WHEN 7 THEN FETCH query_cursor INTO foreach_c1, foreach_c2, foreach_c3, foreach_c4, foreach_c5, foreach_c6, foreach_c7; 
          WHEN 8 THEN FETCH query_cursor INTO foreach_c1, foreach_c2, foreach_c3, foreach_c4, foreach_c5, foreach_c6, foreach_c7, foreach_c8; 
          WHEN 9 THEN FETCH query_cursor INTO foreach_c1, foreach_c2, foreach_c3, foreach_c4, foreach_c5, foreach_c6, foreach_c7, foreach_c8, foreach_c9; 
        END CASE;
        IF done THEN
          LEAVE read_loop;
        END IF;
        -- Replace placeholders
        -- A placeholder identifying a position greater than num columns is not replaced.
        -- NULL values are allowed, and are translated to the literal 'NULL', otherwise the REPLACE method returns NULL.
        SET @exec_query := execute_query;
        SET @exec_query := REPLACE(@exec_query, '${1}', IF(sql_query_num_columns >= 1, IFNULL(foreach_c1, 'NULL'), '${1}'));
        SET @exec_query := REPLACE(@exec_query, '${2}', IF(sql_query_num_columns >= 2, IFNULL(foreach_c2, 'NULL'), '${2}'));
        SET @exec_query := REPLACE(@exec_query, '${3}', IF(sql_query_num_columns >= 3, IFNULL(foreach_c3, 'NULL'), '${3}'));
        SET @exec_query := REPLACE(@exec_query, '${4}', IF(sql_query_num_columns >= 4, IFNULL(foreach_c4, 'NULL'), '${4}'));
        SET @exec_query := REPLACE(@exec_query, '${5}', IF(sql_query_num_columns >= 5, IFNULL(foreach_c5, 'NULL'), '${5}'));
        SET @exec_query := REPLACE(@exec_query, '${6}', IF(sql_query_num_columns >= 6, IFNULL(foreach_c6, 'NULL'), '${6}'));
        SET @exec_query := REPLACE(@exec_query, '${7}', IF(sql_query_num_columns >= 7, IFNULL(foreach_c7, 'NULL'), '${7}'));
        SET @exec_query := REPLACE(@exec_query, '${8}', IF(sql_query_num_columns >= 8, IFNULL(foreach_c8, 'NULL'), '${8}'));
        SET @exec_query := REPLACE(@exec_query, '${9}', IF(sql_query_num_columns >= 9, IFNULL(foreach_c9, 'NULL'), '${9}'));
        SET @exec_query := REPLACE(@exec_query, '${NR}', iteration_number);

        call exec(@exec_query);
        
        SET iteration_number := iteration_number + 1; 
      END LOOP;
      CLOSE query_cursor;
    END;    
    
    DROP TEMPORARY TABLE IF EXISTS _tmp_foreach;
  ELSEIF iterate_data RLIKE '^-?[0-9]+:-?[0-9]+,-?[0-9]+:-?[0-9]+$' THEN
    BEGIN
      -- input is integers range, both inclusive (e.g. '-10:55')
      SET @first_range := split_token(iterate_data, ',', 1);
      SET @second_range := split_token(iterate_data, ',', 2);

      SET @first_start_index := CAST(split_token(@first_range, ':', 1) AS SIGNED INTEGER);
      SET @first_end_index := CAST(split_token(@first_range, ':', 2) AS SIGNED INTEGER);
      SET @second_start_index := CAST(split_token(@second_range, ':', 1) AS SIGNED INTEGER);
      SET @second_end_index := CAST(split_token(@second_range, ':', 2) AS SIGNED INTEGER);

      SET iteration_number := 1;
      SET @first_loop_index := @first_start_index;
      WHILE @first_loop_index <= @first_end_index DO
        SET @second_loop_index := @second_start_index;
        WHILE @second_loop_index <= @second_end_index DO
          SET @exec_query := execute_query;
          SET @exec_query := REPLACE(@exec_query, '${1}', @first_loop_index);
          SET @exec_query := REPLACE(@exec_query, '${2}', @second_loop_index);
          SET @exec_query := REPLACE(@exec_query, '${NR}', iteration_number);
        
          call exec(@exec_query);

          SET iteration_number := iteration_number + 1;
          SET @second_loop_index := @second_loop_index + 1;
        END WHILE;
        SET @first_loop_index := @first_loop_index + 1;
      END WHILE;
    END;
  ELSEIF iterate_data RLIKE '^-?[0-9]+:-?[0-9]+$' THEN
    BEGIN
      -- input is integers range, both inclusive (e.g. '-10:55')
      SET @start_index := CAST(split_token(iterate_data, ':', 1) AS SIGNED INTEGER);
      SET @end_index := CAST(split_token(iterate_data, ':', 2) AS SIGNED INTEGER);

      SET iteration_number := 1;
      SET @loop_index := @start_index;
      WHILE @loop_index <= @end_index DO
        SET @exec_query := execute_query;
        SET @exec_query := REPLACE(@exec_query, '${1}', @loop_index);
        SET @exec_query := REPLACE(@exec_query, '${NR}', iteration_number);
      
        call exec(@exec_query);

        SET iteration_number := iteration_number + 1;
        SET @loop_index := @loop_index + 1;
      END WHILE;
    END;
  ELSE
    BEGIN
      -- input is constant tokens (e.g. 'read green blue')
      SET @num_tokens := get_num_tokens(iterate_data, ' ');
      SET iteration_number := 1;
      WHILE iteration_number <= @num_tokens DO
        SET @exec_query := execute_query;
        SET @exec_query := REPLACE(@exec_query, '${1}', split_token(iterate_data, ' ', iteration_number));
        SET @exec_query := REPLACE(@exec_query, '${NR}', iteration_number);
      
        call exec(@exec_query);

        SET iteration_number := iteration_number + 1;
      END WHILE;
    END;
  END IF;    
END $$

DELIMITER ;
