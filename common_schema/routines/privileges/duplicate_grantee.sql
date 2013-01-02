
--
-- Create a new account with same privileges as those of given grantee.
-- Initial password for new account is also duplicated from existing account.
--

DELIMITER $$

DROP PROCEDURE IF EXISTS duplicate_grantee $$
CREATE PROCEDURE duplicate_grantee(
    IN existing_grantee TINYTEXT CHARSET utf8,
    IN new_grantee TINYTEXT CHARSET utf8
  ) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Duplicate grantee''s privileges into new account'

begin
  declare sql_grants_statement TEXT charset utf8 default null;
    
  SELECT 
    MIN(REPLACE(sql_grants, _requalify_grantee_term(existing_grantee), _requalify_grantee_term(new_grantee)))
  FROM 
    sql_show_grants 
  WHERE 
    grantee = _requalify_grantee_term(existing_grantee)
  INTO
    sql_grants_statement;
  
  if sql_grants_statement is null then
    call throw(CONCAT('duplicate_grantee(): unknown grantee ', existing_grantee));
  end if;
  
  call exec(sql_grants_statement);
end $$

DELIMITER ;
