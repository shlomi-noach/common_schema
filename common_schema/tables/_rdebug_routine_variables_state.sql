
DROP TABLE IF EXISTS _rdebug_routine_variables_state;

CREATE TABLE _rdebug_routine_variables_state (
  worker_id bigint unsigned not null, 
  stack_level int unsigned not null,
  routine_schema varchar(64) not null, 
  routine_name varchar(64) not null, 
  variable_name varchar(128) not null,
  variable_value blob default null,
  modify_time timestamp,
  PRIMARY KEY (worker_id, stack_level, routine_schema, routine_name, variable_name)
) ENGINE=MyISAM ;
