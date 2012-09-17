
SET @s := '
  set @other := 17;
  foreach($tbl: table like _no_such_table_anywhere_33_)
  {
    set @other := 2;
  }
  otherwise 
  {
    set @other := 41;
  }
';
call run(@s);

SELECT @other = 41;

