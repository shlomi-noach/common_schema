SET @s := "
set @result := 17;

function f($a, $b, $c)
{
  set @result := $a + $b + $c;
}
var $x := 100;
invoke f($x, 20, (1+2));

";
call run(@s);

select @result = 123;
