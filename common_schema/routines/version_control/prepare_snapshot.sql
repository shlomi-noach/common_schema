-- 
-- 
-- 
--

DELIMITER $$

DROP FUNCTION IF EXISTS prepare_snapshot $$
CREATE FUNCTION prepare_snapshot(
  snapshot_host_name VARCHAR(128) CHARSET ascii,
  snapshot_comment VARCHAR(128) CHARSET utf8
  ) RETURNS BIGINT UNSIGNED 
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Creates a snapshot entry'

begin
	insert into common_schema_version_control.vc_snapshot (
	  vc_snapshot_id, host_name, created_at, comment) VALUES (
	  NULL, snapshot_host_name, NOW(), snapshot_comment);
	return LAST_INSERT_ID();
end $$

DELIMITER ;
