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
  set @y := 4;
}
';

call run(@s);

SELECT @r = 'even' and @y = 4;

