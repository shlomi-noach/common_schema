SET @s := "
var $a := 17;

function f($a)
{
}

invoke f(4);
";
call run(@s);

select 1;
