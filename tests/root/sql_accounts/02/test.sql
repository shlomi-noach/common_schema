SELECT 
  sql_block_account = "SET PASSWORD FOR 'cs_test_user'@'localhost' = '752AA50E562A6B40DE87DF0FA69FACADD908EA32*'"
FROM 
  sql_accounts
WHERE 
  user = 'cs_test_user'
;
