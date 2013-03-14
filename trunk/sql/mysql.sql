/* Конфигурация плагина */
/* -------------------- */

CREATE TABLE config (
	config_name varchar(255) NOT NULL,
	config_value varchar(255) NOT NULL,
	PRIMARY KEY (config_name)
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

CREATE TABLE uin_username (
  id int(11) not null auto_increment,
  proto_name int(2) default 0 not null,
  my_nick varchar(128) default null,
  my_uin varchar(128) default null,
  nick varchar(128) default null,
  uin varchar(128) default null,
  msg_direction int(1) default 0 not null,
  msg_time timestamp not null default current_timestamp,
  msg_text mediumtext,
  md5hash varchar(32) not null,
  key_id int(10) default null,
  PRIMARY KEY (id),
  KEY user_key (uin),
  UNIQUE KEY hash (md5hash)
) DEFAULT CHARSET=utf8;

/* Базовая таблица пользователя с чат-сообщениями: */
/* ----------------------------------------------- */

CREATE TABLE uin_chat_username (
  id int(11) not null auto_increment,
  msg_type int(2) default 0 not null,
  msg_time timestamp not null default current_timestamp,
  chat_caption varchar(255) default 0 not null,
  proto_acc varchar(255) default null,
  nick_name varchar(255) default null,
  is_private int(1) default 0 not null,
  is_simple int(1) default 1 not null,
  is_irc int(1) default 0 not null,
  msg_text mediumtext,
  md5hash varchar(32) not null,
  key_id int(10) default null,
  PRIMARY KEY (id),
  KEY user_key (msg_time),
  UNIQUE KEY hash (md5hash)
) DEFAULT CHARSET=utf8;

/* Таблица ключей: */
/* --------------- */

CREATE TABLE key_username (
  id int(10) not null auto_increment,
  status_key int(1) not null,
  encryption_method int(1) default 0,
  encryption_key text,
  PRIMARY KEY (id)
) DEFAULT CHARSET=utf8;
