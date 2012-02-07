SET @s := '{
  set @x := FALSE;
  if (DELETE FROM test_cs.test_run WHERE id = 17)
  {
    set @x := TRUE;
  }
}
';

call run(@s);

SELECT @x IS FALSE;

