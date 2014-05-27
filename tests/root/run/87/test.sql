SET @s := '{
  set @y := 4; 
  exit;
  set @y := 17;
}
';

call run(@s);

SELECT @y = 4;

