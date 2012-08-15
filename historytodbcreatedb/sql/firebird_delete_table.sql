SET TERM !!! ;
EXECUTE BLOCK AS
BEGIN
if (exists(select 1 from rdb$relations where rdb$relation_name = 'UIN_USERNAME')) then
execute statement 'DROP TABLE uin_username;';
END
!!!
SET TERM ; !!!
SET TERM !!! ;
EXECUTE BLOCK AS
BEGIN
if (exists(select 1 from rdb$relations where rdb$relation_name = 'UIN_CHAT_USERNAME')) then
execute statement 'DROP TABLE uin_chat_username;';
END
!!!
SET TERM ; !!!
SET TERM !!! ;
EXECUTE BLOCK AS
BEGIN
if (exists(select 1 from rdb$relations where rdb$relation_name = 'KEY_USERNAME')) then
execute statement 'DROP TABLE key_username;';
END
!!!
SET TERM ; !!!