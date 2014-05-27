SET @s := "
function f($a) {
}

function g() {
}

function h($v) {
}
";
call run(@s);

select 1;
