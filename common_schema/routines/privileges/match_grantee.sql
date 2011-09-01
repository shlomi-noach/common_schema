-- 
-- Match an existing account based on user+host
--
-- Example:
--
-- SELECT match_grantee('apps', '192.128.0.1:12345');
-- Returns (text): 'apps'@'%', a closest matching account
-- 
DELIMITER $$

DROP FUNCTION IF EXISTS match_grantee $$
CREATE FUNCTION match_grantee(connection_user char(16) CHARSET utf8, connection_host char(70) CHARSET utf8) RETURNS VARCHAR(100) CHARSET utf8 
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Match an account based on user+host'

BEGIN
  DECLARE grantee_user char(16) CHARSET utf8 DEFAULT NULL;
  DECLARE grantee_host char(60) CHARSET utf8 DEFAULT NULL;

  SELECT
    MAX(user), MAX(host)
  FROM (
    SELECT
      user, host
    FROM
      mysql.user
    WHERE
      connection_user RLIKE
        CONCAT('^',
          REPLACE(
            user,
            '%', '.*'),
          '$')
      AND SUBSTRING_INDEX(connection_host, ':', 1) RLIKE
        CONCAT('^',
          REPLACE(
          REPLACE(
            host,
            '.', '\\.'),
            '%', '.*'),
          '$')
    ORDER BY
      CHAR_LENGTH(host) - CHAR_LENGTH(REPLACE(host, '%', '')) ASC,
      CHAR_LENGTH(host) - CHAR_LENGTH(REPLACE(host, '.', '')) DESC,
      host ASC,
      CHAR_LENGTH(user) - CHAR_LENGTH(REPLACE(user, '%', '')) ASC,
      user ASC
    LIMIT 1
  ) select_matching_account
  INTO 
    grantee_user, grantee_host;
    
    
  RETURN CONCAT('''', grantee_user, '''@''', grantee_host, '''');
END $$

DELIMITER ;
