SET @s := '
create temporary table test_found_rows (
  id int
);

insert into test_found_rows select n from numbers where n between 1 and 7;

set @res := $found_rows;
';

call run(@s);

select @res = 7;
