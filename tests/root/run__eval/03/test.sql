
SET @s := '
  set @x := 3;
  eval (select "set @x := @x+1", "abc" from numbers where n between 1 and 5);
  ';
call run(@s);

select @x = 8;

