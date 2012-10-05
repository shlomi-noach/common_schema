call eval("
  SELECT 
    sql_block_account
  FROM 
    sql_accounts
  WHERE 
    user = 'cs_test_user'
  ");

SELECT 
  sql_release_account = "SET PASSWORD FOR 'cs_test_user'@'localhost' = '*23AE809DDACAF96AF0FD78ED04B6A265E05AA257'"
FROM 
  sql_accounts
WHERE 
  user = 'cs_test_user'
;
