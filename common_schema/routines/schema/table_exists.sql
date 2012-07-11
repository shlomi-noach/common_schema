-- 
-- A convenience function to determine whether a certain table exists.
-- This function reads from INFORMATION_SCHEMA and utilizes I_S optimizations.
-- The function returns true if a table or view by given name exist in given schema. There is
-- no check for temporary tables.
--

DELIMITER $$

DROP FUNCTION IF EXISTS table_exists $$
CREATE FUNCTION table_exists(lookup_table_schema varchar(64) charset utf8, lookup_table_name varchar(64) charset utf8) RETURNS TINYINT UNSIGNED
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Check if specified table exists'

BEGIN
  return (select count(*) from INFORMATION_SCHEMA.TABLES 
    where TABLE_SCHEMA = lookup_table_schema AND TABLE_NAME = lookup_table_name);
END $$

DELIMITER ;
