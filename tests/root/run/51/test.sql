SET @s := '
{
  set @x := 3;
  set @y := 41
  {
    set @y := @y + 37;
    set @x := @x + 1
  }
}
';
call run(@s);

