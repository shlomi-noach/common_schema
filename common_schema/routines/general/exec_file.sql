--
-- Executes queries from given file, residing on server
-- Given file is expected to contain SQL statements.
-- This procedure behaves in a similar manner to SOURCE; however it works on the server
-- whereas SOURCE is a client command and loads the file from the client's host.
--
-- Examples:
--
-- call exec_file('/tmp/tables_update.sql');
--

DELIMITER $$

DROP PROCEDURE IF EXISTS exec_file $$
CREATE PROCEDURE exec_file(IN file_name TEXT CHARSET utf8) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Executes queries from given file'

begin
  call exec(LOAD_FILE(file_name));	
end $$


DELIMITER ;
