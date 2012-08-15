CREATE TABLE IF NOT EXISTS config (
  config_name varchar(255) not null,
  config_value varchar(255) not null,
  primary key (config_name)
);

CREATE TABLE uin_username (
  id integer primary key autoincrement not null unique,
  proto_name int(2) default 0 not null,
  my_nick varchar(128) default null,
  my_uin varchar(128) default null,
  nick varchar(128) default null,
  uin varchar(128) default null,
  msg_direction int(1) default 0 not null,
  msg_time timestamp(14) not null,
  msg_text text,
  md5hash varchar(32) not null,
  key_id integer default null
);

CREATE TABLE uin_chat_username (
  id integer primary key autoincrement not null unique,
  msg_type int(2) default 0 not null,
  msg_time timestamp(14) not null,
  chat_caption varchar(255) default 0 not null,
  proto_acc varchar(255) default null,
  nick_name varchar(255) default null,
  is_private int(1) default 0 not null,
  is_simple int(1) default 1 not null,
  is_irc int(1) default 0 not null,
  msg_text text,
  md5hash varchar(32) not null,
  key_id integer default null
);

CREATE TABLE key_username (
  id integer primary key autoincrement not null unique,
  status_key int(2) not null,
  encryption_method int(2) default 0,
  encryption_key text
);

CREATE UNIQUE INDEX username_hash ON uin_username(md5hash);
CREATE UNIQUE INDEX chat_username_hash ON uin_chat_username(md5hash);
