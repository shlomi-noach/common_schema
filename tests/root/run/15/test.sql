SET @s := '{
  set @x := 4;
  if  (@x % 2 = 1)
  {
    set @r := ''odd'';
  }
  else
  {
    set @r := ''even'';
  }
}
';

call run(@s);

SELECT @r = 'even';

