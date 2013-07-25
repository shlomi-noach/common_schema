delimiter //

set names utf8
//

drop procedure if exists throw;
//

create procedure throw(error_message VARCHAR(1024) CHARSET utf8)
comment 'Raise an error'
language SQL
deterministic
no sql
sql security invoker
main_body: begin
  declare error_statement VARCHAR(1500) CHARSET utf8;

  set @common_schema_error := error_message;
  /*!50500
  SIGNAL SQLSTATE VALUE '91100' SET MESSAGE_TEXT = @common_schema_error;
   */
  -- MySQL 5.1 does not support SIGNAL. Fallback:
  set error_statement := CONCAT('SELECT error FROM error.`', error_message, '`');
  call exec_single(error_statement);
end;
//

delimiter ;
