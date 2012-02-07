SET @s := '{
  set @x := 0;
  while (DELETE FROM test_cs.test_run ORDER BY id LIMIT 1)
  {
    set @x := @x + 1;
  }
}
';

call run(@s);

SELECT @x = 3;

