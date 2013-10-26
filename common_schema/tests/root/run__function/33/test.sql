SET @s := "

function f($a) {
  set $a := 8;
}

var $a := 3;
invoke f($a);
set @result := $a;

";

call run(@s);

select @result = 3;
