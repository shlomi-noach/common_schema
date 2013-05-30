
--
-- Grant SELECT & EXECUTE to all grantees on common_schema
--

DELIMITER $$

DROP PROCEDURE IF EXISTS grant_access $$
CREATE PROCEDURE grant_access() 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Grant SELECT & EXECUTE to all on common_schema'

begin
  declare grant_query TEXT charset utf8 default null;
  
  set grant_query := '
    select 
      concat(''GRANT SELECT, EXECUTE ON '', 
        mysql_qualify(DATABASE()), ''.* TO '', GRANTEE) AS grant_query
      from
        sql_show_grants'
  ;
  
  call eval(grant_query);
end $$

DELIMITER ;
