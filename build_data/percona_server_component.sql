--
--
--
set @script := "
try {
  set @common_schema_percona_server_expected := @common_schema_percona_server_expected + 1; 
component.placeholder
  set @common_schema_percona_server_installed := @common_schema_percona_server_installed + 1;
}
catch {
}
";

call run(@script);

