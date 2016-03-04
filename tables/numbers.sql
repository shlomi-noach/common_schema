-- 
-- Utility table: unsigned integers, [0..4095]
-- 
DROP TABLE IF EXISTS numbers;

CREATE TABLE numbers (
  `n` smallint unsigned NOT NULL,
  PRIMARY KEY (`n`)
) ENGINE=InnoDB
;

--
-- Populate numbers table, values range [0...4095]
--
INSERT IGNORE INTO numbers (n) SELECT
  @counter := @counter+1 AS counter 
FROM
  (
    select NULL from
    (select 1 union select 2 union select 3 union select 4) a
    join (select 1 union select 2 union select 3 union select 4) b
    join (select 1 union select 2 union select 3 union select 4) c
  ) AS select1,
  (
    select NULL from
    (select 1 union select 2 union select 3 union select 4) a
    join (select 1 union select 2 union select 3 union select 4) b
    join (select 1 union select 2 union select 3 union select 4) c
  ) AS select2,
  (
    SELECT 
      @counter := -1
    FROM
      DUAL
  ) AS select_counter
;
