delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;
-- ===================================================================
-- ============================= UTILES ==============================
-- ===================================================================

DROP FUNCTION IF EXISTS f_es_mayor_float;
CREATE FUNCTION f_es_mayor_float(valor float, min float)
RETURNS TINYINT
BEGIN
	DECLARE es_mayor TINYINT;
    SET es_mayor = valor > min;
    RETURN es_mayor;
END;

DROP FUNCTION IF EXISTS f_es_mayor_int;
CREATE FUNCTION f_es_mayor_int(valor int, min int)
RETURNS TINYINT
BEGIN
	DECLARE es_mayor TINYINT;
    SET es_mayor = valor > min;
    RETURN es_mayor;
END;

DROP FUNCTION IF EXISTS f_tinyint_to_varchar;
CREATE FUNCTION f_tinyint_to_varchar(activo TINYINT) 
RETURNS VARCHAR(2)
BEGIN
	DECLARE activoS VARCHAR(2);
    IF (activo>0) THEN
		SET activoS = "SI";
	ELSE
		SET activoS = "NO";
	END IF;
	RETURN activoS;
END;
//