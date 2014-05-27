
DROP TABLE IF EXISTS _rdebug_breakpoint_hints;

CREATE TABLE _rdebug_breakpoint_hints (
  worker_id bigint unsigned not null, 
  routine_schema varchar(64) default null, 
  routine_name varchar(64) default null, 
  statement_id int unsigned default null,
  conditional_expression text default null,
  PRIMARY KEY (worker_id, routine_schema, routine_name, statement_id)
) ENGINE=MyISAM ;
