SET @_query_script_input_col1 := 3;
SET @_query_script_input_col2 := 'abc';

SET @s := '
  input $a, $b;

  set @x := $a;
  set @y := $b;
';
call run(@s);

select @x = 3 and @y = 'abc';

