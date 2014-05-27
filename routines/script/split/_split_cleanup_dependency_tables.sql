-- 
-- 
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS _split_cleanup_dependency_tables $$
CREATE PROCEDURE _split_cleanup_dependency_tables() 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'drop temporary tables'

begin
  drop temporary table if exists _split_unique_key_columns;
  drop temporary table if exists _split_i_s_columns;
  drop temporary table if exists _split_candidate_keys;
  drop temporary table if exists _split_candidate_keys_recommended;
end $$

DELIMITER ;
