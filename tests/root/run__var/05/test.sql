SET @s := '
  {
    var $a;
    set $a := 3;
  }
  set @x := $a;
';
call run(@s);


