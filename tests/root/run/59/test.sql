SET @s := '{
  set @y := 4; 
  break;
  set @y := 17;
}
';

call run(@s);

SELECT 1;

