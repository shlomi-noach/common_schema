SET @s := '
{
  set @x := 1;
  throttle 1;
}
';
call run(@s);

select @x = 1;


