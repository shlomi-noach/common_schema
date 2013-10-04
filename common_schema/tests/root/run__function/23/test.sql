SET @s := "
function f($a)
{
}

invoke f();
";
call run(@s);

select 1;
