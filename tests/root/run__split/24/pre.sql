USE test_cs;
drop table if exists test_split_twin;
create table test_split_twin like test_split ;

insert into test_split_twin select * from test_split;
