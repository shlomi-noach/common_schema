-- 
-- Enhanced view of INNODB_INDEX_STATS
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW innodb_index_stats AS
  SELECT
    *,
    IFNULL(
      ROUND((index_size - 1)/(index_size - leaf_pages), 1),
      0
    ) AS split_factor,
    IFNULL(
      ROUND(1 + log(leaf_pages)/log((index_size - 1)/(index_size - leaf_pages)), 1),
      0
    ) AS index_depth
  FROM
    INFORMATION_SCHEMA.INNODB_INDEX_STATS
;
