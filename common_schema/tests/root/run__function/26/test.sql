SET @s := "
function f()
{
  function g() {
  }
}

";
call run(@s);

select 1;
