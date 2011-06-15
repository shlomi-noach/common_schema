-- 
-- Return a 64 bit CRC of given input, as unsigned big integer.
-- 
-- This code is based on the idea presented in the book
-- High Performance MySQL, 2nd Edition, By Baron Schwartz et al., published by O'REILLY
-- 
-- Example:
--
-- SELECT crc64('mysql');
-- Returns: 9350511318824990686
--

DELIMITER $$

DROP FUNCTION IF EXISTS crc64 $$
CREATE FUNCTION crc64(data LONGTEXT CHARSET utf8) RETURNS BIGINT UNSIGNED 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return a 64 bit CRC of given input, as unsigned big integer'

BEGIN
  RETURN CONV(LEFT(MD5(data), 16), 16, 10);
END $$

DELIMITER ;
