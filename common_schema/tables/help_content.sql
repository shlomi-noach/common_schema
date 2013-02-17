-- 
-- Metadata: information about this project
-- 
DROP TABLE IF EXISTS help_content;

CREATE TABLE help_content (
  topic VARCHAR(32) CHARSET ascii NOT NULL,
  help_message TEXT CHARSET utf8 NOT NULL,
  PRIMARY KEY (topic)
) ENGINE=InnoDB
;
