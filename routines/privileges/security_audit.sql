--
-- Generate a server's security audit report
--

DELIMITER $$

DROP PROCEDURE IF EXISTS security_audit $$
CREATE PROCEDURE security_audit() 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Kills connections based on grantee term'

begin
  call _run_named_script('security_audit');
end $$

DELIMITER ;
