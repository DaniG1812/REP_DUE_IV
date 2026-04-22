--------------------------------------------------------
-- BASELINE INICIAL - TRIGGERS
--------------------------------------------------------

-- Trigger: TRG_IV_CHAT_REGLA
CREATE OR REPLACE TRIGGER TRG_IV_CHAT_REGLA
BEFORE INSERT ON IV_CHAT_REGLA
FOR EACH ROW
BEGIN
  SELECT SEQ_IV_CHAT_REGLA.NEXTVAL
  INTO :NEW.ID_REGLA
  FROM dual;
END;
/