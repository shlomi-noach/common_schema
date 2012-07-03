--
--
--
set @script := "
try {
component.placeholder
}
catch {
  set @common_schema_innodb_plugin_installed := false;
}
";

call run(@script);

