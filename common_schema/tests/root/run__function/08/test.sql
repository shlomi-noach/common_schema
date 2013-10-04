SET @s := "
function f($a) {
}

function f($b) {
}
";
call run(@s);

select 1;
