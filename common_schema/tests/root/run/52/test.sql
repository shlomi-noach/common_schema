SET @s := '
{
  set @x := 10;
  while (@x > 0)
  {
    throttle 1
    set @x := @x -1;
    do sleep(0.1);
  }
}
';
call run(@s);



