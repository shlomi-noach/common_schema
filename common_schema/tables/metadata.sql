-- 
-- Metadata: information about this project
-- 
DROP TABLE IF EXISTS metadata;

CREATE TABLE metadata (
  `attribute_name` VARCHAR(32) CHARSET ascii NOT NULL,
  `attribute_value` VARCHAR(255) CHARSET utf8 NOT NULL,
  PRIMARY KEY (`attribute_name`)
)
;

--
-- Populate numbers table, values range [0...4095]
--
INSERT 
  INTO metadata (attribute_name, attribute_value)
VALUES
  ('author', 'Shlomi Noach'),
  ('author_url', 'http://code.openark.org/blog/shlomi-noach'),
  ('license', 'New BSD'),
  ('project_name', 'common_schema'),
  ('project_home', 'http://code.google.com/p/common-schema/'),
  ('project_repository', 'https://common-schema.googlecode.com/svn/trunk/'),
  ('project_repository_type', 'svn'),
  ('revision', 'revision.placeholder')
;  
