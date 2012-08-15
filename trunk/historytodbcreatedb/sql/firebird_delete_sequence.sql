SET TERM !!! ;
EXECUTE BLOCK AS
BEGIN
if (exists(select 1 from RDB$GENERATORS where RDB$GENERATOR_NAME = 'UIN_USERNAME_ID_SEQ')) then
execute statement 'DROP SEQUENCE uin_username_id_seq;';
END
!!!
SET TERM ; !!!
SET TERM !!! ;
EXECUTE BLOCK AS
BEGIN
if (exists(select 1 from RDB$GENERATORS where RDB$GENERATOR_NAME = 'UIN_CHAT_USERNAME_ID_SEQ')) then
execute statement 'DROP SEQUENCE uin_chat_username_id_seq;';
END
!!!
SET TERM ; !!!
SET TERM !!! ;
EXECUTE BLOCK AS
BEGIN
if (exists(select 1 from RDB$GENERATORS where RDB$GENERATOR_NAME = 'KEY_USERNAME_ID_SEQ')) then
execute statement 'DROP SEQUENCE key_username_id_seq;';
END
!!!
SET TERM ; !!!