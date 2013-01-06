
DROP TABLE IF EXISTS _script_statements;

CREATE TABLE _script_statements (
  statement varchar(16) CHARACTER SET ascii NOT NULL,
  statement_type enum('sql', 'script', 'script,sql', 'unknown') DEFAULT NULL,
  PRIMARY KEY (statement)
) ENGINE=InnoDB ;

--
-- SQL statements
--
INSERT INTO _script_statements VALUES ('alter', 'sql');
INSERT INTO _script_statements VALUES ('analyze', 'sql');
INSERT INTO _script_statements VALUES ('binlog', 'sql');
INSERT INTO _script_statements VALUES ('cache', 'sql');
INSERT INTO _script_statements VALUES ('call', 'sql');
INSERT INTO _script_statements VALUES ('change', 'sql');
INSERT INTO _script_statements VALUES ('check', 'sql');
INSERT INTO _script_statements VALUES ('checksum', 'sql');
INSERT INTO _script_statements VALUES ('create ', 'sql');
INSERT INTO _script_statements VALUES ('delete', 'sql');
INSERT INTO _script_statements VALUES ('do', 'sql');
INSERT INTO _script_statements VALUES ('drop', 'sql');
INSERT INTO _script_statements VALUES ('drop user', 'sql');
INSERT INTO _script_statements VALUES ('flush', 'sql');
INSERT INTO _script_statements VALUES ('grant', 'sql');
INSERT INTO _script_statements VALUES ('handler', 'sql');
INSERT INTO _script_statements VALUES ('insert', 'sql');
INSERT INTO _script_statements VALUES ('kill', 'sql');
INSERT INTO _script_statements VALUES ('load', 'sql');
INSERT INTO _script_statements VALUES ('lock', 'sql');
INSERT INTO _script_statements VALUES ('optimize', 'sql');
INSERT INTO _script_statements VALUES ('purge', 'sql');
INSERT INTO _script_statements VALUES ('rename', 'sql');
INSERT INTO _script_statements VALUES ('repair', 'sql');
INSERT INTO _script_statements VALUES ('replace', 'sql');
INSERT INTO _script_statements VALUES ('reset', 'sql');
INSERT INTO _script_statements VALUES ('revoke', 'sql');
INSERT INTO _script_statements VALUES ('savepoint', 'sql');
INSERT INTO _script_statements VALUES ('select', 'sql');
INSERT INTO _script_statements VALUES ('set', 'sql');
INSERT INTO _script_statements VALUES ('show', 'sql');
INSERT INTO _script_statements VALUES ('stop ', 'sql');
INSERT INTO _script_statements VALUES ('truncate', 'sql');
INSERT INTO _script_statements VALUES ('unlock', 'sql');
INSERT INTO _script_statements VALUES ('update', 'sql');

--
-- Script statements
--
INSERT INTO _script_statements VALUES ('echo', 'script');
INSERT INTO _script_statements VALUES ('eval', 'script');
INSERT INTO _script_statements VALUES ('pass', 'script');
INSERT INTO _script_statements VALUES ('sleep', 'script');
INSERT INTO _script_statements VALUES ('throttle', 'script');
INSERT INTO _script_statements VALUES ('throw', 'script');
INSERT INTO _script_statements VALUES ('var', 'script');
INSERT INTO _script_statements VALUES ('input', 'script');
INSERT INTO _script_statements VALUES ('report', 'script');
INSERT INTO _script_statements VALUES ('begin', 'script');
INSERT INTO _script_statements VALUES ('commit', 'script');
INSERT INTO _script_statements VALUES ('rollback', 'script');

--
-- Both SQL and Script statements (ambiguous resolve)
--
INSERT INTO _script_statements VALUES ('start', 'script,sql');
