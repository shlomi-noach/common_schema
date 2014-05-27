SET @s := '{
  set @x := FALSE;
  if (SELECT COUNT(*) > 0 FROM test_cs.test_run)
  {
    set @x := TRUE;
  }
}
';

call run(@s);

SELECT @x IS TRUE;

