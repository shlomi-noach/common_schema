--
-- common_schema: DBA's framework for MySQL
--

--
-- HOW TO INSTALL
-- =======================================
-- This file is a SQL source file. To install it, you should execute it on your MySQL server.
--
-- Choose either:
-- 
-- - Within MySQL, issue:
-- mysql> SOURCE '/path/to/common_schema.sql';
-- 
-- - From shell, execute:
-- bash$ mysql < /path/to/common_schema.sql
-- 
-- - Use your favorite MySQL GUI editor, copy+paste file content, execute.
-- 
-- To verify install, execute:
-- SHOW DATABASES LIKE 'common_schema';
-- SELECT * FROM common_schema.status;
--

-- 
-- REQUIREMENTS
-- =======================================
-- 
-- On some MySQL versions a stack size of 256K is required (though may work for 192K as well).
-- 256K is the default stack size as of 5.5.
-- You should review/edit the following in your MySQL config file; change will only take
-- place after MySQL restart
--
-- [mysqld]
-- thread_stack = 256K
--
--

-- LICENSE
-- =======================================

-- common_schema - DBA's Framework for MySQL
-- Copyright (C) 2011-2013, Shlomi Noach

-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2, or (at your option)
-- any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- A copy of the GNU General Public License is available at
-- <http://www.gnu.org/licenses/>; or type 'man gpl' on a unix system.


--
-- Generate schema
--

-- Uncomment if you want a clean build:
-- DROP DATABASE IF EXISTS common_schema;

CREATE DATABASE IF NOT EXISTS common_schema;
ALTER DATABASE common_schema DEFAULT CHARACTER SET 'utf8' DEFAULT COLLATE 'utf8_general_ci';

USE common_schema;

set @@group_concat_max_len = 1048576;
set @current_sql_mode := @@sql_mode;
set @@sql_mode = REPLACE(REPLACE(@@sql_mode, 'ANSI_QUOTES', ''), ',,', ',');

-- To be updated during installation process:
set @common_schema_innodb_plugin_expected := 0;
set @common_schema_innodb_plugin_installed := 0;
set @common_schema_percona_server_expected := 0;
set @common_schema_percona_server_installed := 0;
