-- 
-- Utility table: unsigned integers, [0..4095]
-- 
DROP TABLE IF EXISTS numbers;

CREATE TABLE numbers (
  `n` smallint unsigned NOT NULL,
  PRIMARY KEY (`n`)
)
;

--
-- Populate numbers table, values range [0...4095]
--
INSERT IGNORE
  INTO numbers (n)
SELECT
  @counter := @counter+1 AS counter 
FROM
  (
    SELECT 
      NULL
    FROM
      INFORMATION_SCHEMA.SESSION_VARIABLES
    LIMIT 64
  ) AS select1,
  (
    SELECT 
      NULL
    FROM
      INFORMATION_SCHEMA.SESSION_VARIABLES
    LIMIT 64
  ) AS select2,
  (
    SELECT 
      @counter := -1
    FROM
      DUAL
  ) AS select_counter
;
