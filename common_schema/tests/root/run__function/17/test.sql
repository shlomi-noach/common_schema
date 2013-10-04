SET @s := "

function f($a)
{
}

var $x := 23;
invoke f($x);

";
call run(@s);

select 1;
