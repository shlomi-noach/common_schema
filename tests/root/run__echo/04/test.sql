
SET @s := '
  var $x := 3;
  var $t := ''abc'';
  echo SELECT :$x, :$t FROM DUAL
  ';
call run(@s);

