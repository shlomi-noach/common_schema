use test_cs;
truncate test_split_complex_unique;
insert into test_split_complex_unique
  select id, CONCAT('name_', id), TIMESTAMP('2000-01-01') + interval id second, CONCAT('textval_', id)
  from test_split;
