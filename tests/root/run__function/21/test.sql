SET @s := "
set @result := 17;

function f($a)
{
  set @result := $a;
}

function g($b) {
  invoke f($b);
}

invoke g(23);
";
call run(@s);

select @result = 23;
