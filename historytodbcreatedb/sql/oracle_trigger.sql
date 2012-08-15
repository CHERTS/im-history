SET TERM !!! ;
CREATE OR REPLACE TRIGGER uin_username_trigger BEFORE INSERT ON uin_username REFERENCING NEW AS NEW FOR EACH ROW
BEGIN
  SELECT uin_username_id_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
!!!
SET TERM ; !!!
SET TERM !!! ;
CREATE OR REPLACE TRIGGER uin_chat_username_trigger BEFORE INSERT ON uin_chat_username REFERENCING NEW AS NEW FOR EACH ROW
BEGIN
  SELECT uin_chat_username_id_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
!!!
SET TERM ; !!!
SET TERM !!! ;
CREATE OR REPLACE TRIGGER key_username_trigger BEFORE INSERT ON key_username REFERENCING NEW AS NEW FOR EACH ROW
BEGIN
  SELECT key_username_id_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
!!!
SET TERM ; !!!