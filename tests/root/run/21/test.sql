SET @s := '{
  set @x := 3;
  if (@x % 2 = 1)
    set @r := ''odd'';
  else
    set @r := ''even'';

  if (@x < 0)
    set @y := ''negative'';
  else
    set @y := ''positive'';
}
';

call run(@s);

SELECT @r = 'odd' and @y = 'positive';

