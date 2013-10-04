SET @s := "
set @result := 17;

function f($a)
{
  set @result := $a;
}
var $x := 23;
invoke f($x);

";
call run(@s);

select @result = 23;
