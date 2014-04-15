/* Конфигурация плагина */
/* -------------------- */

CREATE TABLE config (
   config_name varchar(255) NOT NULL,
   config_value varchar(255) NOT NULL,
   CONSTRAINT imhistory_config_pkey PRIMARY KEY (config_name)
);

INSERT INTO config (config_name, config_value) VALUES ('config_id','1');
INSERT INTO config (config_name, config_value) VALUES ('system_disable','0');
INSERT INTO config (config_name, config_value) VALUES ('icq_version','2.6');
INSERT INTO config (config_name, config_value) VALUES ('rnq_version','2.6');
INSERT INTO config (config_name, config_value) VALUES ('qip_version','2.6');
INSERT INTO config (config_name, config_value) VALUES ('miranda_version','2.6');
INSERT INTO config (config_name, config_value) VALUES ('skype_version','2.6');

/* Базовая таблица пользователя с сообщениями: */
/* ------------------------------------------- */

CREATE SEQUENCE uin_username_id_seq;

CREATE TABLE uin_username (
  id integer not null default nextval('uin_username_id_seq'),
  proto_name int2 default 0 not null,
  my_nick varchar(128) default null,
  my_uin varchar(128) default null,
  nick varchar(128) default null,
  uin varchar(128) default null,
  msg_direction int2 default 0 not null,
  msg_time timestamp not null,
  msg_text text,
  md5hash varchar(32) not null,
  key_id int2 default null,
  PRIMARY KEY (id),
  CONSTRAINT username_hash UNIQUE (md5hash)
);

/* Базовая таблица пользователя с чат-сообщениями: */
/* ----------------------------------------------- */

CREATE SEQUENCE uin_chat_username_id_seq;

CREATE TABLE uin_chat_username (
  id integer not null default nextval('uin_chat_username_id_seq'),
  msg_type int2 default 0 not null,
  msg_time timestamp not null,
  chat_caption varchar(255) default 0 not null,
  proto_acc varchar(255) default null,
  nick_name varchar(255) default null,
  is_private int2 default 0 not null,
  is_simple int2 default 1 not null,
  is_irc int2 default 0 not null,
  msg_text text,
  md5hash varchar(32) not null,
  key_id int2 default null,
  PRIMARY KEY (id),
  CONSTRAINT chat_username_hash UNIQUE (md5hash)
);

/* Таблица ключей: */
/* --------------- */

CREATE SEQUENCE key_username_id_seq;

CREATE TABLE key_username (
  id integer not null default nextval('key_username_id_seq'),
  status_key int2 not null,
  encryption_method int2 default 0,
  encryption_key text,
  PRIMARY KEY (id)
);

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

CREATE OR REPLACE FUNCTION key_username_trigger_before() RETURNS trigger AS '
BEGIN
NEW.id=nextval(''key_username_id_seq'');
return NEW;
END;
' LANGUAGE plpgsql;

CREATE TRIGGER uin_username_trigger
BEFORE INSERT ON uin_username FOR EACH ROW
EXECUTE PROCEDURE uin_username_trigger_before ();

CREATE TRIGGER uin_chat_username_trigger
BEFORE INSERT ON uin_chat_username FOR EACH ROW
EXECUTE PROCEDURE uin_chat_username_trigger_before ();

CREATE TRIGGER key_username_trigger
BEFORE INSERT ON key_username FOR EACH ROW
EXECUTE PROCEDURE key_username_trigger_before ();
