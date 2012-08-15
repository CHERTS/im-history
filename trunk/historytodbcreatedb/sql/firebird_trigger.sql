SET TERM !!! ;
CREATE OR ALTER TRIGGER uin_username_set_id FOR uin_username
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(uin_username_id_seq, 1);
END
!!!
SET TERM ; !!!
SET TERM !!! ;
CREATE OR ALTER TRIGGER uin_chat_username_set_id FOR uin_chat_username
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(uin_chat_username_id_seq, 1);
END
!!!
SET TERM ; !!!
SET TERM !!! ;
CREATE OR ALTER TRIGGER key_username_set_id FOR key_username
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(key_username_id_seq, 1);
END
!!!
SET TERM ; !!!