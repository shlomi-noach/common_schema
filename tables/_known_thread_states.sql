
DROP TABLE IF EXISTS _known_thread_states;

CREATE TABLE _known_thread_states (
  state varchar(128) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  state_type enum('replication_sql_thread', 'replication_io_thread', 'unknown') DEFAULT NULL,
  PRIMARY KEY (state),
  KEY (state_type)
) ENGINE=InnoDB ;

--
-- The 'Waiting for slave mutex on exit' state appears on both SQL and I/O states,
-- and signifies waiting for slave mutex while stopping replication.
-- We will simply consider both to indicate "no replication", so we don't list the
-- state in our known replication states.
--

--
-- Replication SQL thread states
--
INSERT INTO _known_thread_states VALUES ('Waiting for the next event in relay log', 'replication_sql_thread');
INSERT INTO _known_thread_states VALUES ('Reading event from the relay log', 'replication_sql_thread');
INSERT INTO _known_thread_states VALUES ('Making temp file', 'replication_sql_thread');
INSERT INTO _known_thread_states VALUES ('Slave has read all relay log; waiting for the slave I/O thread to update it', 'replication_sql_thread');
INSERT INTO _known_thread_states VALUES ('Waiting until MASTER_DELAY seconds after master executed event', 'replication_sql_thread');
INSERT INTO _known_thread_states VALUES ('Has read all relay log; waiting for the slave I/O thread to update it', 'replication_sql_thread');

--
-- Replication I/O thread states
--
INSERT INTO _known_thread_states VALUES ('Waiting for an event from Coordinator', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Waiting for master update', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Connecting to master ', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Checking master version', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Registering slave on master', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Requesting binlog dump', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Waiting to reconnect after a failed binlog dump request', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Reconnecting after a failed binlog dump request', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Waiting for master to send event', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Queueing master event to the relay log', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Waiting to reconnect after a failed master event read', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Reconnecting after a failed master event read', 'replication_io_thread');
INSERT INTO _known_thread_states VALUES ('Waiting for the slave SQL thread to free enough relay log space', 'replication_io_thread');
