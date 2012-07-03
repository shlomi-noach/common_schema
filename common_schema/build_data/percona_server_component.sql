--
--
--
set @script := "
try {
component.placeholder
}
catch {
  set @common_schema_percona_server_installed := false;
}
";

call run(@script);

