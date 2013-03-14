UPDATE config SET config_value = '1' WHERE config_name = 'system_disable';
UPDATE config SET config_value = '2.0' where config_name = 'icq_version';
UPDATE config SET config_value = '2.0' where config_name = 'qip_version';
UPDATE config SET config_value = '2.0' where config_name = 'rnq_version';
UPDATE config SET config_value = '2.0' where config_name = 'miranda_version';
BEGIN TRANSACTION;
CREATE TEMPORARY TABLE uin_username_temp (
  id integer primary key autoincrement not null unique,
  proto_name int(2) default 0,
  nick varchar(128) default null,
  uin varchar(128) default null,
  direction int(1) not null,
  time timestamp(14) not null,
  msg text
);
INSERT INTO uin_username_temp SELECT id, proto_name, nick, uin, direction, time, msg FROM uin_username;
DROP TABLE uin_username;
CREATE TABLE uin_username (
  id integer primary key autoincrement not null unique,
  proto_name int(2) default 0,
  my_nick varchar(128) default null,
  my_uin varchar(128) default null,
  nick varchar(128) default null,
  uin varchar(128) default null,
  msg_direction int(1) not null,
  msg_time timestamp(14) not null,
  msg_text text
);
INSERT INTO uin_username SELECT id, proto_name, null, null, nick, uin, direction, time, msg FROM uin_username_temp;
DROP TABLE uin_username_temp;
COMMIT;

ALTER TABLE uin_username ADD md5hash varchar(32) default 0 not null;
CREATE UNIQUE INDEX username_hash ON uin_username(md5hash);
ALTER TABLE uin_chat_username ADD md5hash varchar(32) default 0 not null;
CREATE UNIQUE INDEX chat_username_hash ON uin_chat_username(md5hash);

ALTER TABLE uin_username ADD key_id integer default null;
ALTER TABLE uin_chat_username ADD key_id integer default null;

CREATE TABLE key_username (
  id integer primary key autoincrement not null unique,
  status_key int(2) not null,
  encryption_method int(2) default 0,
  encryption_key text
);

UPDATE config SET config_value = '0' WHERE config_name = 'system_disable';
