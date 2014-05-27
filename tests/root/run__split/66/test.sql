-- since PK is textual, starting with 900 only ends up with ten rows.
SET @s := '
  set @counter := 0;
  update test_cs.test_split_text set nval = 1;
  split({start: 900}: update test_cs.test_split_text set nval = nval + 1)
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

select @counter = 1;

