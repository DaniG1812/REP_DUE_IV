-----------------------------------------------------------
-- MIGRACION DE SEGURIDAD PARA IV_USUARIO
-- Oracle 11g R2 / APEX 20.2
------------------------------------------------------------

------------------------------------------------------------
-- 1. Agregar columnas nuevas
------------------------------------------------------------
ALTER TABLE IVDUE.IV_USUARIO ADD (
    PASSWORD_SALT VARCHAR2(64),
    PASSWORD_HASH VARCHAR2(64)
);
/
    
------------------------------------------------------------
-- 2. Hacer obligatorias las columnas nuevas
------------------------------------------------------------
ALTER TABLE IVDUE.IV_USUARIO MODIFY PASSWORD_SALT NOT NULL;
/
ALTER TABLE IVDUE.IV_USUARIO MODIFY PASSWORD_HASH NOT NULL;
/

------------------------------------------------------------
-- 3. Crear paquete de autenticacion
------------------------------------------------------------
CREATE OR REPLACE PACKAGE IVDUE.IV_AUTH_PKG AS

    FUNCTION generar_salt RETURN VARCHAR2;

    FUNCTION hash_password(
        p_password IN VARCHAR2,
        p_salt     IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION autenticar(
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN;

END IV_AUTH_PKG;
/
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY IVDUE.IV_AUTH_PKG AS

    FUNCTION generar_salt RETURN VARCHAR2 IS
    BEGIN
        RETURN RAWTOHEX(SYS_GUID());
    END generar_salt;

    FUNCTION hash_password(
        p_password IN VARCHAR2,
        p_salt     IN VARCHAR2
    ) RETURN VARCHAR2 IS
        l_hash RAW(32);
    BEGIN
      l_hash := DBMS_CRYPTO.HASH(
              UTL_I18N.STRING_TO_RAW(p_salt || p_password, 'AL32UTF8'),
              DBMS_CRYPTO.HASH_SH1
          );

        RETURN RAWTOHEX(l_hash);
    END hash_password;

    FUNCTION autenticar(
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN IS
        l_salt       IVDUE.IV_USUARIO.PASSWORD_SALT%TYPE;
        l_hash_guard IVDUE.IV_USUARIO.PASSWORD_HASH%TYPE;
        l_hash_calc  VARCHAR2(64);
        l_estado     IVDUE.IV_USUARIO.ESTADO%TYPE;
    BEGIN
        SELECT password_salt,
               password_hash,
               estado
          INTO l_salt,
               l_hash_guard,
               l_estado
          FROM IVDUE.IV_USUARIO
         WHERE UPPER(correo) = UPPER(p_username);

        IF l_estado <> 'ACTIVO' THEN
            APEX_UTIL.SET_CUSTOM_AUTH_STATUS('USUARIO_INACTIVO');
            RETURN FALSE;
        END IF;

        l_hash_calc := hash_password(p_password, l_salt);

        IF l_hash_calc = l_hash_guard THEN
            APEX_UTIL.SET_CUSTOM_AUTH_STATUS('LOGIN_OK');
            RETURN TRUE;
        ELSE
            APEX_UTIL.SET_CUSTOM_AUTH_STATUS('PASSWORD_INVALIDO');
            RETURN FALSE;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            APEX_UTIL.SET_CUSTOM_AUTH_STATUS('USUARIO_NO_EXISTE');
            RETURN FALSE;
        WHEN OTHERS THEN
            APEX_UTIL.SET_CUSTOM_AUTH_STATUS('ERROR: ' || SQLERRM);
            RETURN FALSE;
    END autenticar;

END IV_AUTH_PKG;
/
SHOW ERRORS;
