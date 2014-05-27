SET @s := '
  var $a := 3;
  var $b := $a + 1;
  set @res := $b;
';
call run(@s);

select @res = 4;
