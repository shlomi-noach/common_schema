SET @s := "
var $a := 17;

function f($b) {
  set @r1 := $a;
  set @r2 := $b;
}

invoke f(16);

";

call run(@s);

select @r1 = 17 and @r2 = 16;
