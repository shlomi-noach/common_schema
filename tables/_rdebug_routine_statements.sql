
DROP TABLE IF EXISTS _rdebug_routine_statements;

CREATE TABLE _rdebug_routine_statements (
  routine_schema varchar(64) not null, 
  routine_name varchar(64) not null, 
  statement_id int unsigned not null not null,
  statement_start_pos int unsigned default 0, 
  statement_end_pos int unsigned default 0,
  PRIMARY KEY (routine_schema, routine_name, statement_id)
) ENGINE=MyISAM ;
