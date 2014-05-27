
--
-- Rotate a table logrotate-style: version current table and move aside,
-- pushing older versions further down the line, 
--

DELIMITER $$

DROP PROCEDURE IF EXISTS table_rotate $$
CREATE PROCEDURE table_rotate(
    IN table_schema varchar(64) charset utf8, 
    IN table_name varchar(64) charset utf8,
    IN rotate_limit smallint unsigned
  ) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Rotate a table logrotate-style'

begin
  declare rotate_index smallint unsigned;
  declare rotate_statement TEXT charset utf8 default null;
    
  if not table_exists(table_schema, table_name) then
    call throw(concat('Cannot rotate non-existing table: ', mysql_qualify(table_schema), '.', mysql_qualify(table_name)));
  end if;
 
  if IFNULL(rotate_limit, 0) > 0 then
    -- drop oldest:
    set rotate_statement := concat(
        'DROP TABLE IF EXISTS ', 
        mysql_qualify(table_schema), '.', mysql_qualify(concat(table_name, '__', rotate_limit))
    );  
    call exec(rotate_statement);
  end if;
  
  -- create empty table:
  set rotate_statement := concat(
      'CREATE TABLE ', 
      mysql_qualify(table_schema), '.', mysql_qualify(concat(table_name, '__0')), ' LIKE ',
      mysql_qualify(table_schema), '.', mysql_qualify(table_name)
  );  
  call exec(rotate_statement);
 
  -- rotate all tables:
  set rotate_statement := '';
  set rotate_index := 1;
  while table_exists(table_schema, concat(table_name, '__', rotate_index)) do
    set rotate_statement := concat(
        mysql_qualify(table_schema), '.', mysql_qualify(concat(table_name, '__', rotate_index)),
          ' TO ', mysql_qualify(table_schema), '.', mysql_qualify(concat(table_name, '__', rotate_index+1)),
        ', ', rotate_statement
      );
    set rotate_index := rotate_index + 1;
  end while;
  set rotate_statement := concat(
      'RENAME TABLE ', rotate_statement, 
      mysql_qualify(table_schema), '.', mysql_qualify(table_name),
        ' TO ', mysql_qualify(table_schema), '.', mysql_qualify(concat(table_name, '__', 1)),
      ', ',
      mysql_qualify(table_schema), '.', mysql_qualify(concat(table_name, '__0')),
        ' TO ', mysql_qualify(table_schema), '.', mysql_qualify(table_name)
    );
  
  call exec(rotate_statement);
end $$

DELIMITER ;
