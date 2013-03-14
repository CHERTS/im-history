UPDATE config SET config_value = '1' WHERE config_name = 'system_disable';
UPDATE config SET config_value = '2.1' where config_name = 'icq_version';
UPDATE config SET config_value = '2.1' where config_name = 'qip_version';
UPDATE config SET config_value = '2.1' where config_name = 'rnq_version';
UPDATE config SET config_value = '2.1' where config_name = 'miranda_version';
ALTER TABLE uin_username MODIFY msg_text mediumtext;
ALTER TABLE uin_chat_username MODIFY msg_text mediumtext;
UPDATE config SET config_value = '0' WHERE config_name = 'system_disable';
