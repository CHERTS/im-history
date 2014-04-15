/* Конфигурация плагина */
/* -------------------- */

CREATE TABLE config (
	config_name varchar(255) NOT NULL,
	config_value varchar(255) NOT NULL
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
  id integer not null,
  proto_name integer default 0 not null,
  my_nick varchar(128) default null,
  my_uin varchar(128) default null,
  nick varchar(128) default null,
  uin varchar(128) default null,
  msg_direction integer default 0 not null,
  msg_time timestamp not null,
  msg_text blob sub_type text,
  md5hash varchar(32) not null,
  key_id integer default null,
  primary key (id),
  constraint username_hash unique (md5hash)
);

/* Базовая таблица пользователя с чат-сообщениями: */
/* ----------------------------------------------- */

CREATE SEQUENCE uin_chat_username_id_seq;

CREATE TABLE uin_chat_username (
  id integer not null,
  msg_type integer default 0 not null,
  msg_time timestamp not null,
  chat_caption varchar(255) default 0 not null,
  proto_acc varchar(255) default null,
  nick_name varchar(255) default null,
  is_private integer default 0 not null,
  is_simple integer default 1 not null,
  is_irc integer default 0 not null,
  msg_text blob sub_type text,
  md5hash varchar(32) not null,
  key_id integer default null,
  primary key (id),
  constraint chat_username_hash unique (md5hash)
);

/* Таблица ключей: */
/* --------------- */

CREATE SEQUENCE key_username_id_seq;

CREATE TABLE key_username (
  id integer not null,
  status_key integer not null,
  encryption_method integer default 0,
  encryption_key blob sub_type text,
  PRIMARY KEY (id)
);

SET TERM !!! ;
CREATE OR ALTER TRIGGER uin_username_set_id FOR uin_username
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(uin_username_id_seq, 1);
END
!!!
SET TERM ; !!!

SET TERM !!! ;
CREATE OR ALTER TRIGGER uin_chat_username_set_id FOR uin_chat_username
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(uin_chat_username_id_seq, 1);
END
!!!
SET TERM ; !!!

SET TERM !!! ;
CREATE OR ALTER TRIGGER key_username_set_id FOR key_username
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(key_username_id_seq, 1);
END
!!!
SET TERM ; !!!
