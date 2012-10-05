call eval("
  SELECT 
    sql_block_account
  FROM 
    sql_accounts
  WHERE 
    user = 'cs_test_user'
  ");

SELECT 
  password RLIKE '[0-9A-F]{40}[*]'
FROM 
  sql_accounts
WHERE 
  user = 'cs_test_user'
;
