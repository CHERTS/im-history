UPDATE config SET config_value = '1' WHERE config_name = 'system_disable';
UPDATE config SET config_value = '2.0' where config_name = 'icq_version';
UPDATE config SET config_value = '2.0' where config_name = 'qip_version';
UPDATE config SET config_value = '2.0' where config_name = 'rnq_version';
UPDATE config SET config_value = '2.0' where config_name = 'miranda_version';
ALTER TABLE uin_username ADD my_nick varchar(128) default null AFTER proto_name;
ALTER TABLE uin_username ADD my_uin varchar(128) default null AFTER my_nick;
ALTER TABLE uin_username CHANGE direction msg_direction int(1) default 0 not null;
ALTER TABLE uin_username CHANGE time msg_time timestamp;
ALTER TABLE uin_username CHANGE msg msg_text text;
ALTER TABLE uin_username DROP INDEX user_key;
ALTER TABLE uin_username ADD INDEX user_key (uin);
ALTER TABLE uin_username ADD md5hash varchar(32) not null;
ALTER TABLE uin_username ADD UNIQUE KEY `hash` (`md5hash`);
ALTER TABLE uin_chat_username ADD md5hash varchar(32) not null;
ALTER TABLE uin_chat_username ADD UNIQUE KEY `hash` (`md5hash`);
ALTER TABLE uin_username MODIFY msg_time timestamp not null default current_timestamp;
ALTER TABLE uin_chat_username MODIFY msg_time timestamp not null default current_timestamp;
ALTER TABLE uin_username ADD key_id int(10) default null;
ALTER TABLE uin_chat_username ADD key_id int(10) default null;
CREATE TABLE key_username (
  id int(10) not null auto_increment,
  status_key int(1) not null,
  encryption_method int(1) default 0,
  encryption_key text,
  PRIMARY KEY (id)
) DEFAULT CHARSET=utf8;
UPDATE config SET config_value = '0' WHERE config_name = 'system_disable';
