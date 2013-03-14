UPDATE config SET config_value = '1' WHERE config_name = 'system_disable';
UPDATE config SET config_value = '2.0' where config_name = 'icq_version';
UPDATE config SET config_value = '2.0' where config_name = 'qip_version';
UPDATE config SET config_value = '2.0' where config_name = 'rnq_version';
UPDATE config SET config_value = '2.0' where config_name = 'miranda_version';
ALTER TABLE uin_username ADD my_nick varchar(128) default null;
ALTER TABLE uin_username ADD my_uin varchar(128) default null;
ALTER TABLE uin_username RENAME COLUMN direction TO msg_direction;
ALTER TABLE uin_username RENAME COLUMN time TO msg_time;
ALTER TABLE uin_username RENAME COLUMN msg TO msg_text;
CREATE TABLE uin_username_temp (
  id int2 not null,
  proto_name int2 default 0,
  my_nick varchar(128) default null,
  my_uin varchar(128) default null,
  nick varchar(128) default null,
  uin varchar(128) default null,
  msg_direction int2 not null,
  msg_time timestamp not null,
  msg_text text,
  PRIMARY KEY (id)
);
INSERT INTO uin_username_temp SELECT id, proto_name, my_nick, my_uin, nick, uin, msg_direction, msg_time, msg_text FROM uin_username;
DROP TABLE uin_username;
ALTER TABLE uin_username_temp RENAME TO uin_username;
ALTER TABLE uin_username ALTER COLUMN id SET default nextval('uin_username_id_seq');
ALTER TABLE uin_username ADD md5hash varchar(32) not null;
ALTER TABLE uin_username ADD CONSTRAINT username_hash UNIQUE(md5hash);
ALTER TABLE uin_chat_username ADD md5hash varchar(32) not null;
ALTER TABLE uin_chat_username ADD CONSTRAINT chat_username_hash UNIQUE(md5hash);
ALTER TABLE uin_username ALTER COLUMN id TYPE integer;
ALTER TABLE uin_chat_username ALTER COLUMN id TYPE integer;
ALTER TABLE uin_username ADD key_id int2 default null;
ALTER TABLE uin_chat_username ADD key_id int2 default null;
CREATE SEQUENCE key_username_id_seq;

CREATE TABLE key_username (
  id integer not null default nextval('key_username_id_seq'),
  status_key int2 not null,
  encryption_method int2 default 0,
  encryption_key text,
  PRIMARY KEY (id)
);

CREATE OR REPLACE FUNCTION key_username_trigger_before() RETURNS trigger AS '
BEGIN
NEW.id=nextval(''key_username_id_seq'');
return NEW;
END;
' LANGUAGE plpgsql;

CREATE TRIGGER key_username_trigger
BEFORE INSERT ON key_username FOR EACH ROW
EXECUTE PROCEDURE key_username_trigger_before ();

CREATE OR REPLACE FUNCTION uin_username_trigger_before() RETURNS trigger AS '
BEGIN
NEW.id=nextval(''uin_username_id_seq'');
return NEW;
END;
' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION uin_chat_username_trigger_before() RETURNS trigger AS '
BEGIN
NEW.id=nextval(''uin_chat_username_id_seq'');
return NEW;
END;
' LANGUAGE plpgsql;

CREATE TRIGGER uin_username_trigger
BEFORE INSERT ON uin_username FOR EACH ROW
EXECUTE PROCEDURE uin_username_trigger_before ();

CREATE TRIGGER uin_chat_username_trigger
BEFORE INSERT ON uin_chat_username FOR EACH ROW
EXECUTE PROCEDURE uin_chat_username_trigger_before ();

UPDATE config SET config_value = '0' WHERE config_name = 'system_disable';
