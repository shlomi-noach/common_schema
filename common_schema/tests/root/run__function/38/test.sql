SET @s := "
var $a := 17;

function f($a) {
  set @result := $a;
}

invoke f(16);
";

call run(@s);

select @result = 16;
