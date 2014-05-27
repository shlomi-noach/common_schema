SET @s := '{
  set @x := 4;
  if (@x % 2 = 1)
    set @r := ''odd'';
  else if (@x % 2 = 0)
    set @r := ''even'';
  else if (@x is null)
    set @r := ''none'';
}
';

call run(@s);

SELECT @r = 'even';

