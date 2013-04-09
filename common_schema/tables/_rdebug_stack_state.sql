
DROP TABLE IF EXISTS _rdebug_stack_state;

CREATE TABLE _rdebug_stack_state (
  worker_id bigint unsigned not null, 
  stack_level int unsigned not null,
  routine_schema varchar(64) not null, 
  routine_name varchar(64) not null, 
  statement_id int unsigned not null,
  entry_time timestamp default CURRENT_TIMESTAMP,
  PRIMARY KEY (worker_id, stack_level)
) ENGINE=MyISAM ;
