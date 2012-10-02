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
-- bash$ mysql < '/path/to/common_schema.sql'
-- 
-- - Use your favorite MySQL GUI editor, copy+paste file content, execute.
-- 
-- To verify install, execute:
-- SHOW DATABASES LIKE 'common_schema';
-- SELECT * FROM common_schema.status;
--

--
-- LICENSE
-- =======================================
-- Released under the BSD license
--
-- Copyright (c) 2011 - 2012, Shlomi Noach
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
--
--     * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
--     * Neither the name of the organization nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--


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
