-- 
-- Metadata: information about this project
-- 
DROP TABLE IF EXISTS metadata;

CREATE TABLE metadata (
  `attribute_name` VARCHAR(64) CHARSET ascii NOT NULL,
  `attribute_value` VARCHAR(2048) CHARSET utf8 NOT NULL,
  PRIMARY KEY (`attribute_name`)
) ENGINE=InnoDB
;

--
-- 
--
INSERT INTO metadata (attribute_name, attribute_value) VALUES
  ('author', 'Shlomi Noach'),
  ('author_url', 'http://code.openark.org/blog/shlomi-noach'),
  ('install_success', false),
  ('install_time', NOW()),
  ('install_sql_mode', @@sql_mode),
  ('install_mysql_version', VERSION()),
  ('base_components_installed', false),
  ('innodb_plugin_components_installed', false),
  ('percona_server_components_installed', false),
  ('tokudb_components_installed', false),
  ('license_type', 'MIT'),
  ('license', '

common_schema - DBA''s Framework for MySQL
Copyright (C) 2011-2019, Shlomi Noach

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

'),
  ('project_name', 'common_schema'),
  ('project_home', 'https://github.com/shlomi-noach/common_schema'),
  ('project_repository', 'https://github.com/shlomi-noach/common_schema.git'),
  ('project_repository_type', 'git'),
  ('revision', 'buildnumber.placeholder'),
  ('version', '2.3-snapshot')
;  
