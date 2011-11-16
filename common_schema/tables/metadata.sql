-- 
-- Metadata: information about this project
-- 
DROP TABLE IF EXISTS metadata;

CREATE TABLE metadata (
  `attribute_name` VARCHAR(32) CHARSET ascii NOT NULL,
  `attribute_value` VARCHAR(2048) CHARSET utf8 NOT NULL,
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
  ('license_type', 'New BSD'),
  ('license', '
Copyright (c) 2011, Shlomi Noach
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the organization nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

'),
  ('project_name', 'common_schema'),
  ('project_home', 'http://code.google.com/p/common-schema/'),
  ('project_repository', 'https://common-schema.googlecode.com/svn/trunk/'),
  ('project_repository_type', 'svn'),
  ('revision', 'revision.placeholder')
;  
