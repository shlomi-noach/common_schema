SET @s := '{
  set @x := FALSE;
  if (UPDATE test_cs.test_run SET value = ''new val'' WHERE id >= 1)
  {
    set @x := TRUE;
  }
}
';

call run(@s);

SELECT @x IS TRUE;

