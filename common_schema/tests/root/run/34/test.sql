SET @s := '{
  set @x := 3;
  while (@x > 0)
  {
    set @y := 3;
    while (@y > 0)
    {
      if (@y = 1)
        break;
      INSERT INTO test_cs.test_run VALUES (NULL, @x, @y);
      set @y := @y - 1;
    }
    set @x := @x - 1;
  }
  set @z := 11;
}
';

call run(@s);

SELECT x, y FROM test_cs.test_run ORDER BY id;

