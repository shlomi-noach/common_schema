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
  ('license_type', 'GPL'),
  ('license', '

common_schema - DBA''s Framework for MySQL
Copyright (C) 2011-2013, Shlomi Noach

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is available at
<http://www.gnu.org/licenses/>; or type ''man gpl'' on a unix system.
'),
  ('project_name', 'common_schema'),
  ('project_home', 'http://code.google.com/p/common-schema/'),
  ('project_repository', 'https://common-schema.googlecode.com/svn/trunk/'),
  ('project_repository_type', 'svn'),
  ('revision', 'revision.placeholder'),
  ('version', '2.0.0')
;  
