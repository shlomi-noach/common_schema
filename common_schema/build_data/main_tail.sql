--
-- Check up on installation success:
--
UPDATE 
  metadata
SET 
  attribute_value = '1'
WHERE 
  attribute_name = 'install_success'
;

UPDATE 
  metadata
SET 
  attribute_value = '1'
WHERE 
  attribute_name = 'base_components_installed'
;

UPDATE 
  metadata
SET 
  attribute_value = (@common_schema_innodb_plugin_installed IS TRUE)
WHERE 
  attribute_name = 'innodb_plugin_components_installed'
;

UPDATE 
  metadata
SET 
  attribute_value = (@common_schema_percona_server_installed IS TRUE)
WHERE 
  attribute_name = 'percona_server_components_installed'
;

FLUSH TABLES mysql.db;
FLUSH TABLES mysql.proc;

SET @message := '';
SET @message := CONCAT(@message, '\n- Base components: ', IF(TRUE, 'installed', 'not installed'));
SET @message := CONCAT(@message, '\n- InnoDB Plugin components: ', IF(@common_schema_innodb_plugin_installed, 'installed', 'not installed'));
SET @message := CONCAT(@message, '\n- Percona Server components: ', IF(@common_schema_percona_server_installed, 'installed', 'not installed'));
SET @message := CONCAT(@message, '\n');
SET @message := CONCAT(@message, '\nInstallation complete. Thank you for using common_schema!');

CALL prettify_message('complete', trim_wspace(@message));

--
-- End of common_schema build file
--
