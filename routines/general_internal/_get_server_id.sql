-- 
-- return the @@server_id (to be used from within views)
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS _get_server_id $$
CREATE FUNCTION _get_server_id() RETURNS INT UNSIGNED 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Return current server id'

BEGIN
  RETURN @@global.server_id;
END $$

DELIMITER ;
