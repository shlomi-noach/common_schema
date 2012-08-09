--
-- Kills connections based on grantee term.
-- The grantee term can be a full grantee declaration; a grantee user; a grantee host; a user; a hostname; a user@host combination.
-- SUPER and replication connections can be terminated as well.
-- At any case, thes procedure does not kill the current connection.
--

DELIMITER $$

DROP PROCEDURE IF EXISTS killall $$
CREATE PROCEDURE killall(IN grantee_term TINYTEXT CHARSET utf8) 
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Kills connections based on grantee term'

begin
  set grantee_term := _requalify_grantee_term(grantee_term);
  
  begin
    declare kill_process_id bigint unsigned default null;
    declare done tinyint default 0;
    declare killall_cursor cursor for 
      select 
        id 
      from 
        _processlist_grantees_exploded 
      where 
        grantee_term in (grantee, unqualified_grantee, grantee_host, grantee_user, qualified_user_host, unqualified_user_host, hostname, user)
        and id != CONNECTION_ID()
      ;
    declare continue handler for NOT FOUND set done = 1;
    declare continue handler for 1094 begin end; -- ERROR 1094 is "Unknown thread id"
  
    -- Two reason for opening a cursor and walking one by one instead of using existing constructs such as 'eval':
    -- 1. We wish to recover from error 1094 ("Unknown thread id") in case a connection has just been closed,
    -- and continue with killing of other connections.
    -- 2. We wish to be able to call this routine from with QueryScript, so no dynamic SQL allowed.
    open killall_cursor;
    read_loop: loop
      fetch killall_cursor into kill_process_id;
      if done then
        leave read_loop;
      end if;
      kill kill_process_id;
    end loop;

    close killall_cursor;
  end;
end $$

DELIMITER ;
