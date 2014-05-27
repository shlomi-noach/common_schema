USE test_cs;

drop table if exists test_table_rotate;
drop table if exists test_table_rotate__1;
drop table if exists test_table_rotate__2;
drop table if exists test_table_rotate__3;
drop table if exists test_table_rotate__4;

create table test_table_rotate 
  select 17 as id from DUAL
  ;
