SET @s := "
function f($a)
{
}

invoke f 7, 8, 9;
";
call run(@s);

select 1;
