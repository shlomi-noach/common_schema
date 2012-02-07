SET @s := '{
  set @x := FALSE;
  if (UPDATE test_cs.test_run SET value = ''failure'' WHERE id >= 2)
  {
    set @x := TRUE;
  }
}
';

call run(@s);

SELECT @x IS FALSE;

