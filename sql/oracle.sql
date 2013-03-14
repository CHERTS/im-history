/* Конфигурация плагина */
/* -------------------- */

CREATE TABLE config (
   config_name varchar(255) NOT NULL,
   config_value varchar(255) NOT NULL,
   CONSTRAINT imhistory_config_pkey PRIMARY KEY (config_name)
);

INSERT INTO config (config_name, config_value) VALUES ('config_id','1');
INSERT INTO config (config_name, config_value) VALUES ('system_disable','0');
INSERT INTO config (config_name, config_value) VALUES ('icq_version','2.5');
INSERT INTO config (config_name, config_value) VALUES ('rnq_version','2.5');
INSERT INTO config (config_name, config_value) VALUES ('qip_version','2.5');
INSERT INTO config (config_name, config_value) VALUES ('miranda_version','2.5');
INSERT INTO config (config_name, config_value) VALUES ('skype_version','2.5');

/* Базовая таблица пользователя с сообщениями: */
/* ------------------------------------------- */

CREATE SEQUENCE uin_username_id_seq;

CREATE TABLE uin_username (
  id number(10,0) not null,
  proto_name number(3,0) default 0 not null,
  my_nick varchar2(128) default null,
  my_uin varchar2(128) default null,
  nick varchar2(128) default null,
  uin varchar2(128) default null,
  msg_direction number(3,0) default 0 not null,
  msg_time date default to_date('01.01.0001 01:00:00', 'dd.mm.yyyy hh24:mi:ss') not null,
  msg_text clob,
  md5hash varchar2(32) not null,
  key_id number(10,0) default null,
  PRIMARY KEY (id),
  CONSTRAINT username_hash UNIQUE (md5hash)
);

/* Базовая таблица пользователя с чат-сообщениями: */
/* ----------------------------------------------- */

CREATE SEQUENCE uin_chat_username_id_seq;

CREATE TABLE uin_chat_username (
  id number(10,0) not null,
  msg_type number(3,0) default 0 not null,
  msg_time date default to_date('01.01.0001 01:00:00', 'dd.mm.yyyy hh24:mi:ss') not null,
  chat_caption varchar2(255) default 0 not null,
  proto_acc varchar2(255) default null,
  nick_name varchar2(255) default null,
  is_private number(3,0) default 0 not null,
  is_simple number(3,0) default 1 not null,
  is_irc number(3,0) default 0 not null,
  msg_text clob,
  md5hash varchar2(32) not null,
  key_id number(10,0) default null,
  PRIMARY KEY (id),
  CONSTRAINT chat_username_hash UNIQUE (md5hash)
);

/* Таблица ключей: */
/* --------------- */

CREATE SEQUENCE key_username_id_seq;

CREATE TABLE key_username (
  id number(10,0) not null,
  status_key number(3,0) not null,
  encryption_method number(3,0) default 0,
  encryption_key clob,
  PRIMARY KEY (id)
);

CREATE OR REPLACE TRIGGER uin_username_trigger BEFORE INSERT ON uin_username FOR EACH ROW
WHEN (new.id IS NULL)
BEGIN
  SELECT uin_username_id_seq.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
\

CREATE OR REPLACE TRIGGER uin_chat_username_trigger BEFORE INSERT ON uin_chat_username FOR EACH ROW
WHEN (new.id IS NULL)
BEGIN
  SELECT uin_chat_username_id_seq.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
\

CREATE OR REPLACE TRIGGER key_username_trigger BEFORE INSERT ON key_username FOR EACH ROW
WHEN (new.id IS NULL)
BEGIN
  SELECT key_username_id_seq.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
\
