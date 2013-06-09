-- 
-- Match an existing account based on user+host
--
-- Example:
--
-- SELECT match_grantee('apps', '192.128.0.1:12345');
-- Returns (text): 'apps'@'%', a closest matching account
-- 
DELIMITER $$

DROP procedure IF EXISTS test_cs.dbg_iterate_numbers $$
CREATE procedure test_cs.dbg_iterate_numbers()
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER

main_body: BEGIN
  declare done bool default false;
  declare current_value int unsigned default null;
  declare numbers_cursor cursor for select n from test.numbers where n between 1 and 10;
  declare continue handler for not found set done := true;
  
  open numbers_cursor;
  cursor_loop: while not done do
    fetch numbers_cursor into current_value;
    if done then
      leave cursor_loop;
    end if;
    select current_value;
  end while;
  close numbers_cursor;
END


$$

DELIMITER ;
