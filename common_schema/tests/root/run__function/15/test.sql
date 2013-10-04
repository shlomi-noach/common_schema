SET @s := "
function f()
{
}

invoke f();
";
call run(@s);

select 1;
