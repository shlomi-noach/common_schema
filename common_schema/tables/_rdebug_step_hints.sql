
DROP TABLE IF EXISTS _rdebug_step_hints;

CREATE TABLE _rdebug_step_hints (
  worker_id bigint unsigned not null, 
  hint_type enum ('step_into', 'step_over', 'step_out', 'run') not null default 'step_into',
  stack_level int unsigned default null,
  is_consumed tinyint unsigned default 0,
  PRIMARY KEY (worker_id)
) ENGINE=MyISAM ;
