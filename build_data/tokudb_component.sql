--
--
--
set @script := "
try {
  set @common_schema_tokudb_expected := @common_schema_tokudb_expected + 1; 
component.placeholder
  set @common_schema_tokudb_installed := @common_schema_tokudb_installed + 1;
}
catch {
}
";

call run(@script);

