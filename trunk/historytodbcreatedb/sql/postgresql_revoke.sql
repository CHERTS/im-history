revoke select,insert,update on config from username;
revoke usage,select,update on uin_username_id_seq from username;
revoke select,insert,update,delete on uin_username from username;
revoke usage,select,update on uin_chat_username_id_seq from username;
revoke select,insert,update,delete on uin_chat_username from username;
revoke usage,select,update on key_username_id_seq from username;
revoke select,insert,update,delete on key_username from username;