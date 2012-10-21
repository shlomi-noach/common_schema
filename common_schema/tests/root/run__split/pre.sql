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
  select id, CONCAT('name_', id), TIMESTAMP('2000-01-01') + interval 1 second, CONCAT('textval_', id)
  from test_split;
