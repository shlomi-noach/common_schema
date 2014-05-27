--
-- 
-- A synonym for the foreach() routine
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS `$` $$
CREATE PROCEDURE `$`(collection TEXT CHARSET utf8, execute_queries TEXT CHARSET utf8) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Invoke queries per element of given collection'

begin
  call foreach(collection, execute_queries);
end $$

DELIMITER ;
