--
--
--
set @script := "
try {
  set @common_schema_innodb_plugin_expected := @common_schema_innodb_plugin_expected + 1; 
component.placeholder
  set @common_schema_innodb_plugin_installed := @common_schema_innodb_plugin_installed + 1;
}
catch {
}
";

call run(@script);

