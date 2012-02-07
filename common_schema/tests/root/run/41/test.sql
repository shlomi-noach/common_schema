SET @s := '{
  set @x := FALSE;
  if (INSERT IGNORE INTO test_cs.test_run VALUES (2, ''second''))
  {
    set @x := TRUE;
  }
}
';

call run(@s);

SELECT @x IS TRUE;

