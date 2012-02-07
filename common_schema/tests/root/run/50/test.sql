SET @s := '
{
  set @x := 3;
  set @y := 41
}
{
  set @y := @y + 1;
  set @x := @x + 1
}
{set @y := @y + 1}
{set @x := @x + 1}
';

call run(@s);

select @x = 5 and @y = 43;
