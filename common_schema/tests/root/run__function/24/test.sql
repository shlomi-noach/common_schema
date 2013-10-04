SET @s := "
function f($a, $b)
{
}

invoke f(17 18);
";
call run(@s);

select 1;
