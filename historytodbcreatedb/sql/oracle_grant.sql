grant create session to username;
grant select,insert,update on config to username;
grant select,alter on uin_username_id_seq to username;
grant select,insert,update,delete on uin_username to username;
grant select,alter on uin_chat_username_id_seq to username;
grant select,insert,update,delete on uin_chat_username to username;
grant select,alter on key_username_id_seq to username;
grant select,insert,update,delete on key_username to username;