SET @s := '
set @res := 0;
foreach($i : 1:12)
{
  set @res := @res + 1;
}
var $i := 5;
set @res := @res + $i;
';
call run(@s);

select @res = 17;
