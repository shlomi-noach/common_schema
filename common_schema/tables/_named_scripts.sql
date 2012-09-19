
DROP TABLE IF EXISTS _named_scripts;

CREATE TABLE _named_scripts (
  script_name varchar(64) CHARACTER SET ascii NOT NULL,
  script_text text charset utf8 DEFAULT NULL,
  PRIMARY KEY (script_name)
) ENGINE=InnoDB ;
