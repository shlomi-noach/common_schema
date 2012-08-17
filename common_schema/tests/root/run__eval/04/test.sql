
SET @s := '
  set @x := 3;
  var $condition := "n between 1 and 5";
  eval select "set @x := @x+1" from numbers where :${condition};
  ';
call run(@s);

select @x = 8;

