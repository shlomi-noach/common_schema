SET @s := '
set @res := 0;
{
  var $x := 3;
  set @res := @res + $x;
}
{
  var $x := 17;
  set @res := @res + $x;
}
';
call run(@s);

select @res = 20;
