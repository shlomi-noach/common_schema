SET @s := "

function h($a) {
  set $a := 6;
  set @result := @result + 1;
}

function g($a) {
  set $a := 17;
  set @result := @result + 1;
  invoke h($a);
}

function f($a) {
  set $a := 8;
  set @result := @result + 1;
  invoke g($a);
}

set @result := 0;

var $a := 23;
invoke f($a);
set @a := $a;

";

call run(@s);

select @result = 3 and @a = 23;
