--------------------------------------------------------
-- MIGRATION V001 - CONSTRAINT ESTADO TRAMITE 
--------------------------------------------------------

ALTER TABLE IV_TRAMITE
ADD CONSTRAINT CK_IV_TRAMITE_ESTADO
CHECK (
    ESTADO_TRAMITE IN (
        'PENDIENTE',
        'RADICADO',
        'EN DESARROLLO',
        'AVANZADO',
        'TERMINADO'
    )
);