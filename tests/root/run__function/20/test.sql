SET @s := "
function f()
{
}

function g() {
  invoke f();
}

invoke g();
";
call run(@s);

select 1;
