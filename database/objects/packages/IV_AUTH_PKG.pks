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