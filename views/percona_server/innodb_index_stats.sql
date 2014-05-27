-- 
-- Enhanced view of INNODB_INDEX_STATS: Estimated InnoDB depth & split factor of key's B+ Tree  
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW innodb_index_stats AS
  SELECT
    *,
    IFNULL(
      ROUND((index_total_pages - 1)/(index_total_pages - index_leaf_pages), 1),
      0
    ) AS split_factor,
    IFNULL(
      ROUND(1 + log(index_leaf_pages)/log((index_total_pages - 1)/(index_total_pages - index_leaf_pages)), 1),
      0
    ) AS index_depth
  FROM
    INFORMATION_SCHEMA.INNODB_INDEX_STATS
;
