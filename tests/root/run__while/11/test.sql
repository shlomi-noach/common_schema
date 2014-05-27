create temporary table test_cs.test_while_otherwise (
  id int
) engine=MyISAM;

SET @s := '{
  set @other := 17;
  while (DELETE FROM test_cs.test_while_otherwise)
  {
    set @other := 9;
  }
  otherwise {
    set @other := 41;
  }
}
';

call run(@s);

SELECT @other = 41;

