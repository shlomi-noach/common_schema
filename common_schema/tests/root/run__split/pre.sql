USE test_cs;
drop table if exists test_split;
create table test_split(id int auto_increment primary key, nval int unsigned, textval tinytext);
insert into test_split (id) values (null);
-- Generate 4096 records:
call common_schema.run('
  foreach ($i: 1:12)
    insert into test_cs.test_split (id) select null from test_cs.test_split;
  ');

drop table if exists test_split_no_uniques;
create table test_split_no_uniques(counter int unsigned, name varchar(10), key(counter), key(name));
