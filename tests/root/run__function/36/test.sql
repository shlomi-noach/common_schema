SET @s := "

function h($arg) {
  var $a := 2;
  set @result := @result + $arg + $a;
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

select @result = 26;
