
DROP TABLE IF EXISTS _rdebug_routine_variables;

CREATE TABLE _rdebug_routine_variables (
  routine_schema varchar(64) not null, 
  routine_name varchar(64) not null, 
  variable_name varchar(128) not null,
  variable_scope_id_start int unsigned not null default 0, 
  variable_scope_id_end int unsigned default 0,
  variable_type enum('param', 'local', 'user_defined') not null,
  PRIMARY KEY (routine_schema, routine_name, variable_name, variable_scope_id_start)
) ENGINE=MyISAM ;
