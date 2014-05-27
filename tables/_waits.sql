
DROP TABLE IF EXISTS _waits;

CREATE TABLE _waits (
  wait_name varchar(128) character set ascii collate ascii_bin NOT NULL,
  wait_value bigint unsigned not null,
  first_entry_time timestamp default CURRENT_TIMESTAMP,
  last_entry_time timestamp null default null,
  PRIMARY KEY (wait_name),
  KEY (last_entry_time)
) ENGINE=InnoDB ;

--