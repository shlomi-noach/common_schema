
DROP TABLE IF EXISTS _global_sql_tokens;

CREATE TABLE _global_sql_tokens (
    server_id int unsigned not null
  , session_id int unsigned
  , id int unsigned
  , start int unsigned  not null
  , level int not null
  , token text          
  , state text not null
  , PRIMARY KEY(server_id, session_id, id)
) ENGINE=InnoDB ;
