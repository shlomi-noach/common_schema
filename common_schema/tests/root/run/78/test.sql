
SET @s := '
  SET @num_schemata := 0;
  foreach($scm: schema)
  {
    SET @num_schemata := @num_schemata + 1
  }
';
call run(@s);

SELECT @num_schemata > 2;

