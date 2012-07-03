-- 
-- General metadata/status of common_schema
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW status AS
  select 
    max(if(attribute_name = 'project_name', attribute_value, null)) as project_name,
    max(if(attribute_name = 'version', attribute_value, null)) as version,
    max(if(attribute_name = 'revision', attribute_value, null)) as revision,
    max(if(attribute_name = 'install_time', attribute_value, null)) as install_time,
    max(if(attribute_name = 'install_success', attribute_value, null)) as install_success,    
    max(if(attribute_name = 'base_components_installed', attribute_value, null)) as base_components_installed,    
    max(if(attribute_name = 'innodb_plugin_components_installed', attribute_value, null)) as innodb_plugin_components_installed,    
    max(if(attribute_name = 'percona_server_components_installed', attribute_value, null)) as percona_server_components_installed,    
    max(if(attribute_name = 'install_mysql_version', attribute_value, null)) as install_mysql_version,
    max(if(attribute_name = 'install_sql_mode', attribute_value, null)) as install_sql_mode
  from
    metadata;
;
