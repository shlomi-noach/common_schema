SET @s := "
function f()
{
}

invoke f(17);
";
call run(@s);

select 1;
