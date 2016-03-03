
DROP TABLE IF EXISTS _rdebug_stats;

CREATE TABLE _rdebug_stats (
  worker_id bigint unsigned not null, 
  routine_schema varchar(64) not null, 
  routine_name varchar(64) not null, 
  statement_id int unsigned not null,
  count_visits bigint unsigned not null,
  PRIMARY KEY (worker_id, routine_schema, routine_name, statement_id)
) ENGINE=MyISAM ;
