SET @s := "
function f($a)
{
}

var $a := 17;
";
call run(@s);

select 1;
