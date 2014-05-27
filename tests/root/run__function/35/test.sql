SET @s := "

function h($a) {
  set @result := @result + $a;
}

function g($a) {
  set @result := @result + $a;
  set $a := $a + 1;
  invoke h($a);
}

function f($a) {
  set @result := @result + $a;
  set $a := $a + 1;
  invoke g($a);
}

set @result := 0;

var $a := 7;
invoke f($a);

";

call run(@s);

select @result = 24;
