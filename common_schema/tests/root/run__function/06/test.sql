SET @s := "
function f($a) {
}

function g($a) {
}
";
call run(@s);

select 1;
