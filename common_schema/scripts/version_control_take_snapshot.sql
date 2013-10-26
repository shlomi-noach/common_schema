var $snapshot_id := prepare_snapshot('localhost', 'QueryScript snapshot');


function take_table_snapshot($schema1, $table1) {
  select $schema1, $table1;
}

function take_schema_snapshot($schema) {
  select 3, $schema;
  foreach($table: table in :$schema) {
    select 4;
    invoke take_table_snapshot($schema, $table);
  }
}

select 1;
foreach ($s: schema like %) {
  select 2, $s;
  invoke take_schema_snapshot($s);
}

/*
foreach ($schema: schema like %) {
  foreach($table: table in :$schema)
insert into 
  common_schema_version_control.vc_columns (
    vc_columns_id,
    vc_snapshot_id,
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    ORDINAL_POSITION,
    COLUMN_DEFAULT,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    CHARACTER_OCTET_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    CHARACTER_SET_NAME,
    COLLATION_NAME,
    COLUMN_TYPE,
    COLUMN_KEY,
    EXTRA,
    PRIVILEGES,
    COLUMN_COMMENT
  ) SELECT (
    NULL,
    $snapshot_id,
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    ORDINAL_POSITION,
    COLUMN_DEFAULT,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    CHARACTER_OCTET_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    CHARACTER_SET_NAME,
    COLLATION_NAME,
    COLUMN_TYPE,
    COLUMN_KEY,
    EXTRA,
    PRIVILEGES,
    COLUMN_COMMENT
  )
}
*/