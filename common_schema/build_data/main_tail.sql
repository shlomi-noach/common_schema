
-- doc_sql.placeholder

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
  attribute_value = ((@common_schema_innodb_plugin_installed > 0) AND (@common_schema_innodb_plugin_installed = @common_schema_innodb_plugin_expected))
WHERE 
  attribute_name = 'innodb_plugin_components_installed'
;

UPDATE 
  metadata
SET 
  attribute_value = ((@common_schema_percona_server_installed > 0) AND (@common_schema_percona_server_installed = @common_schema_percona_server_expected))
WHERE 
  attribute_name = 'percona_server_components_installed'
;

UPDATE 
  metadata
SET 
  attribute_value = ((@common_schema_tokudb_installed > 0) AND (@common_schema_tokudb_installed = @common_schema_tokudb_expected))
WHERE 
  attribute_name = 'tokudb_components_installed'
;

FLUSH TABLES mysql.db;
FLUSH TABLES mysql.proc;

set @notes_message := '';
SET @notes_message := CONCAT(@notes_message, 
  CASE
	WHEN @@global.thread_stack < 256*1024 THEN '\n- Please set ''thread_stack = 256K'' in your config file and apply, in order for QueryScript to run properly'
    ELSE ''	
  END
);
SET @notes_message := CONCAT(@notes_message, 
  CASE
	WHEN @@global.innodb_stats_on_metadata = 1 THEN '\n- Please set ''innodb_stats_on_metadata = 0'' for INFORMATION_SCHEMA related views to respond timely'
    ELSE ''	
  END
);

SET @message := '';
SET @message := CONCAT(@message, '\n- Base components: ', IF(TRUE, 'installed', 'not installed'));
SET @message := CONCAT(@message, '\n- InnoDB Plugin components: ', 
  CASE @common_schema_innodb_plugin_installed
	WHEN 0 THEN 'not installed'
	WHEN @common_schema_innodb_plugin_expected THEN 'installed'
    ELSE CONCAT('partial install: ', @common_schema_innodb_plugin_installed, '/', @common_schema_innodb_plugin_expected)	
  END
);
SET @message := CONCAT(@message, '\n- Percona Server components: ', 
  CASE @common_schema_percona_server_installed
	WHEN 0 THEN 'not installed'
	WHEN @common_schema_percona_server_expected THEN 'installed'
    ELSE CONCAT('partial install: ', @common_schema_percona_server_installed, '/', @common_schema_percona_server_expected)	
  END
);
SET @message := CONCAT(@message, '\n- TokuDB components: ', 
  CASE @common_schema_tokudb_installed
	WHEN 0 THEN 'not installed'
	WHEN @common_schema_tokudb_expected THEN 'installed'
    ELSE CONCAT('partial install: ', @common_schema_tokudb_installed, '/', @common_schema_tokudb_expected)	
  END
);
SET @message := CONCAT(@message, '\n');
SET @message := CONCAT(@message, '\nInstallation complete. Thank you for using common_schema!');

call prettify_message('notes', trim_wspace(@notes_message));
call prettify_message('complete', trim_wspace(@message));

set @@sql_mode := @current_sql_mode;

--
-- End of common_schema build file
--
