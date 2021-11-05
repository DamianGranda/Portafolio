delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;
-- ===================================================================
-- ============================ CONCESIONARIA ============================
-- ===================================================================

-- =========================== FUNCIONES ===========================

DROP FUNCTION IF EXISTS f_concesionaria_existe;
CREATE FUNCTION f_concesionaria_existe ( nombre_concesionaria VARCHAR(45))
RETURNS tinyint
BEGIN
	declare existe tinyint;
    set existe = exists(select * from concesionaria c where c.nombre=nombre_concesionaria);
    return existe;
END;

DROP FUNCTION IF EXISTS f_concesionaria_activo_existe;
CREATE FUNCTION f_concesionaria_activo_existe ( nombre_concesionaria VARCHAR(45))
RETURNS TINYINT
BEGIN
	DECLARE existe TINYINT;
    SET existe = EXISTS(SELECT * FROM concesionaria c WHERE c.nombre=nombre_concesionaria AND c.activo=1);
    RETURN existe;
END;

DROP FUNCTION IF EXISTS f_concesionaria_id_existe;
CREATE FUNCTION f_concesionaria_id_existe ( id_concesionaria INT)
RETURNS tinyint
BEGIN
	declare existe tinyint;
    set existe = exists(select * from concesionaria c where c.id_concesionaria=id_concesionaria);
    return existe;
END;

DROP FUNCTION IF EXISTS f_concesionaria_activo_id_existe;
CREATE FUNCTION f_concesionaria_activo_id_existe ( id_concesionaria INT)
RETURNS tinyint
BEGIN
	declare existe tinyint;
    set existe = exists(select * from concesionaria c where c.id_concesionaria=id_concesionaria AND c.activo=1);
    return existe;
END;

DROP FUNCTION IF EXISTS f_concesionaria_nombre_traer;
CREATE FUNCTION f_concesionaria_nombre_traer(id_concesionaria INT) 
RETURNS VARCHAR(45)
BEGIN
	DECLARE nombre VARCHAR(45);
    SELECT c.nombre INTO nombre FROM concesionaria c WHERE c.id_concesionaria=id_concesionaria;
    RETURN nombre;
END;

-- =========================== ALTA ===========================

DROP PROCEDURE IF EXISTS sp_concesionaria_alta;
CREATE PROCEDURE sp_concesionaria_alta(IN nombre_concesionaria VARCHAR(45), OUT resultado INT, OUT msg VARCHAR(255))
BEGIN
	IF (f_concesionaria_existe(nombre_concesionaria)) THEN
		SET msg = concat("Ya existe una concesionaria llamada ", nombre_concesionaria);
        SET resultado = -1;
	ELSE
		insert INTO concesionaria(nombre, activo) values(nombre_concesionaria, 1);
		SET msg = null;
        SET resultado = 0;
    END IF;
END;

-- =========================== BAJA ===========================
DROP PROCEDURE IF EXISTS sp_concesionaria_nombre_baja;
CREATE PROCEDURE sp_concesionaria_nombre_baja(IN nombre_concesionaria VARCHAR(45), OUT resultado INT, OUT msg VARCHAR(255))
BEGIN
	IF (f_concesionaria_existe(nombre_concesionaria)) THEN
		IF (f_concesionaria_activo_existe(nombre_concesionaria)) THEN
			update concesionaria c SET c.activo=0 WHERE c.nombre=nombre_concesionaria;
			SET msg = null;
            SET resultado = 0;
		ELSE
			SET msg = concat("Ya esta dada de baja la concesionaria llamada  ", nombre_concesionaria);
            SET resultado = -1;
		END IF;
	ELSE
		SELECT concat("No existe una concesionaria llamada ", nombre_concesionaria) ;
        SET resultado = -1;
    END IF;
END;

DROP PROCEDURE IF EXISTS sp_concesionaria_id_baja;
CREATE PROCEDURE sp_concesionaria_id_baja(IN id_concesionaria VARCHAR(45), OUT resultado INT, OUT msg VARCHAR(255))
BEGIN
	IF (f_concesionaria_id_existe(id_concesionaria)) THEN
		IF (f_concesionaria_activo_id_existe(id_concesionaria)) THEN
			update concesionaria c SET c.activo=0 WHERE c.id_concesionaria=id_concesionaria;
			SET msg = null;
            SET resultado = 0;
		ELSE
			SET msg = concat("Ya esta dada de baja la concesionaria con id  ", id_concesionaria);
            SET resultado = -1;
		END IF;
	ELSE
		SELECT concat("No existe una concesionaria con el siguiente id:  ", id_concesionaria) ;
        SET resultado = -1;
    END IF;
END;
-- =========================== MODIFICAR ===========================

DROP PROCEDURE IF EXISTS sp_concesionaria_modificar;
CREATE PROCEDURE sp_concesionaria_modificar(IN id_concesionaria INT, IN nuevo_nombre VARCHAR(45), OUT resultado INT, OUT msg VARCHAR(255))
BEGIN
	DECLARE viejo_nombre VARCHAR(45);
	IF(f_concesionaria_nombre_traer(id_concesionaria) IS NULL) THEN
		SET msg = concat("No existe una concesionaria con id ", id_concesionaria);
        SET resultado = -1;
    ELSE
		IF(f_concesionaria_existe(nuevo_nombre)) THEN
			SET msg = concat("Ya existe una concesionaria llamada ", nuevo_nombre);
            SET resultado = -1;
        ELSE
			IF (f_concesionaria_activo_id_existe(id_concesionaria)) THEN
				SELECT c.nombre INTO viejo_nombre FROM concesionaria c WHERE c.id_concesionaria=id_concesionaria;
				update concesionaria c SET c.nombre=nuevo_nombre WHERE c.id_concesionaria=id_concesionaria;
				SET msg = null;
				SET resultado = 0;
			ELSE
				SET msg = concat("El concesionaria con id= ",id_concesionaria, " que se intento modificar, esta dado de baja.");
				SET resultado = -1;
			END IF;
        END IF;
    END IF;
END;

-- =========================== LEER ===========================

DROP PROCEDURE IF EXISTS sp_concesionaria_leer;
CREATE PROCEDURE sp_concesionaria_leer()
BEGIN
	SELECT id_concesionaria, nombre, f_tinyint_to_varchar(activo) AS activo FROM concesionaria;
END;

//
