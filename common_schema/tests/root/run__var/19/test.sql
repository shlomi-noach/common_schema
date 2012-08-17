drop table if exists test_cs.test_19_expanded_variable;
SET @s := "
  set @res := 7;
  var $table_code := 19;
  create temporary table test_cs.test_:${table_code}_expanded_variable (id int);
  select count(*) from test_cs.test_19_expanded_variable into @res;
";
call run(@s);

select @res = 0;
