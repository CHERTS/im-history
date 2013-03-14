UPDATE config SET config_value = '1' WHERE config_name = 'system_disable';
UPDATE config SET config_value = '2.3' where config_name = 'icq_version';
UPDATE config SET config_value = '2.3' where config_name = 'qip_version';
UPDATE config SET config_value = '2.3' where config_name = 'rnq_version';
UPDATE config SET config_value = '2.3' where config_name = 'miranda_version';
INSERT INTO config (config_name, config_value) VALUES ('skype_version','2.3');
UPDATE config SET config_value = '0' WHERE config_name = 'system_disable';
