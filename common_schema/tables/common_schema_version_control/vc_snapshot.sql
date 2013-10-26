
CREATE TABLE IF NOT EXISTS common_schema_version_control.vc_snapshot (
  vc_snapshot_id BIGINT UNSIGNED AUTO_INCREMENT,
  host_name VARCHAR(128) CHARSET ascii,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  comment VARCHAR(128) CHARSET utf8,
  PRIMARY KEY (vc_snapshot_id),
  KEY host_created_idx (host_name, created_at),
  KEY created_idx (created_at)
) ENGINE=InnoDB 
;
