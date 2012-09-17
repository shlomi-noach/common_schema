-- 
-- Verbose all reported messages
--
DELIMITER $$

DROP procedure IF EXISTS _script_report_finalize $$
CREATE procedure _script_report_finalize()
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  call _script_report(
    CONCAT('hr ', QUOTE('Report generated on '), QUOTE(NOW()))
  );

  select info as `report` from _script_report_data order by id;
end $$

DELIMITER ;
