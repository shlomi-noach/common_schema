USE test_cs;

SET @@auto_increment_increment := 1;

drop table if exists test_split;
create table test_split(
  id int auto_increment primary key, 
  nval int unsigned, 
  textval varchar(32)
) engine=myisam;
insert into test_split (id) values (null);
-- Generate 4096 records:
call common_schema.run('
  foreach ($i: 1:12)
    insert into test_cs.test_split (id) select null from test_cs.test_split;
  ');

create table test_split_text(
  id varchar(12) primary key, 
  nval int unsigned, 
  textval varchar(32)
) engine=myisam;
insert into test_split_text (id, nval, textval) select id, nval, textval from test_split;

drop table if exists test_split_sparse;
create table test_split_sparse(
  id int auto_increment primary key, 
  nval int unsigned, 
  textval varchar(32)
) engine=myisam;

call common_schema.run('
  foreach ($i: 1:100)
    insert into test_cs.test_split_sparse (id) values ($i*40);
  ');
  
  
  
drop table if exists test_split_complex_unique;
create table test_split_complex_unique(
  counter int unsigned, 
  name varchar(10), 
  ts timestamp, 
  textval varchar(32), 
  PRIMARY KEY(counter, name, ts)
) engine=innodb;

insert into test_split_complex_unique
  select id, CONCAT('name_', id), TIMESTAMP('2000-01-01') + interval id second, CONCAT('textval_', id)
  from test_split;

  
drop table if exists test_split_multiple_unique;
create table test_split_multiple_unique(
  id int auto_increment,
  small_val smallint,
  name varchar(10), 
  ts timestamp, 
  textval varchar(32), 
  PRIMARY KEY(id),
  UNIQUE KEY `id` (id),
  UNIQUE KEY `small` (small_val, name),
  UNIQUE KEY `name` (name, ts, small_val),
  UNIQUE KEY `ts` (ts, small_val),
  UNIQUE KEY `textval` (textval),
  KEY `non_unique_idx` (name, small_val)
) engine=innodb;

insert into test_split_multiple_unique
  values (1, 2, 'brown', '2000-01-01 00:00:00', '6ff47afa5dc7daa42cc705a03fca8a9b')
  ;
