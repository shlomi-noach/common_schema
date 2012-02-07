SET @s := '
  input $a, $b;

  set @x := $a;
  set @y := $b;
';
call run(@s);

select @x is null and @y is null;

