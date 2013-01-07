-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS query_checksum $$
CREATE PROCEDURE query_checksum(in query TEXT CHARSET utf8) 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Checksum resultset of given query (max 9 columns)'

begin
  -- The following is now the constant 9.
  declare sql_query_num_columns TINYINT UNSIGNED DEFAULT 9;
  declare result_checksum CHAR(40) CHARSET ascii DEFAULT '';
  
  set @query_checksum_result := NULL;
  if not _is_select_query(query) then
    call throw('query_checksum input must be SELECT query');
  end if;

  DROP TEMPORARY TABLE IF EXISTS _tmp_query_checksum;
    
  call _wrap_select_list_columns(query, sql_query_num_columns, @common_schema_error);
  set @_common_schema_checkum_temporary_query := CONCAT('CREATE TEMPORARY TABLE _tmp_query_checksum ', query);

  PREPARE st FROM @_common_schema_checkum_temporary_query;
  EXECUTE st;
  DEALLOCATE PREPARE st;
    
  -- execute sql_query and iterate
  begin	
    declare col1, col2, col3, col4, col5, col6, col7, col8, col9 VARCHAR(4096) CHARSET utf8;
    declare done INT DEFAULT 0;
    declare query_cursor cursor for SELECT * FROM _tmp_query_checksum;
    declare continue handler for NOT FOUND set done = 1;
          
    open query_cursor;
    read_loop: loop
      fetch query_cursor into col1, col2, col3, col4, col5, col6, col7, col8, col9;
      if done then
        leave read_loop;
      end if;
      set result_checksum := MD5(CONCAT(result_checksum, '\0', IFNULL(col1, '\0')));
      set result_checksum := MD5(CONCAT(result_checksum, '\0', IFNULL(col2, '\0')));
      set result_checksum := MD5(CONCAT(result_checksum, '\0', IFNULL(col3, '\0')));
      set result_checksum := MD5(CONCAT(result_checksum, '\0', IFNULL(col4, '\0')));
      set result_checksum := MD5(CONCAT(result_checksum, '\0', IFNULL(col5, '\0')));
      set result_checksum := MD5(CONCAT(result_checksum, '\0', IFNULL(col6, '\0')));
      set result_checksum := MD5(CONCAT(result_checksum, '\0', IFNULL(col7, '\0')));
      set result_checksum := MD5(CONCAT(result_checksum, '\0', IFNULL(col8, '\0')));
      set result_checksum := MD5(CONCAT(result_checksum, '\0', IFNULL(col9, '\0')));
    end loop;
    close query_cursor;
  end; 
    
  DROP TEMPORARY TABLE IF EXISTS _tmp_query_checksum;
  
  SELECT (@query_checksum_result := result_checksum) AS `checksum`;
end $$

DELIMITER ;
