SET @s := "
function f($a, 3, '')
{
}
";
call run(@s);

select 1;
