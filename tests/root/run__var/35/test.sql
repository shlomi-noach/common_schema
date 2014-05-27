SET @s := '
create temporary table test_rowcount (
  id int
);

insert into test_rowcount values (1), (2), (3), (5), (8);

set @res := $rowcount;
';

call run(@s);

select @res = 5;
