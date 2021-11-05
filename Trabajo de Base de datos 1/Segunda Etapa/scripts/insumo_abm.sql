delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;
-- ===================================================================
-- ============================ INSUMOS ============================
-- ===================================================================

-- =========================== FUNCIONES ===========================

DROP FUNCTION IF EXISTS f_insumo_existe;
CREATE FUNCTION f_insumo_existe ( nombre_insumo VARCHAR(45))
RETURNS tinyint
BEGIN
	declare existe tinyint;
    set existe = exists(select * from insumo i where i.nombre=nombre_insumo);
    return existe;
END;

DROP FUNCTION IF EXISTS f_insumo_activo_existe;
CREATE FUNCTION f_insumo_activo_existe ( nombre_insumo VARCHAR(45))
RETURNS TINYINT
BEGIN
	DECLARE existe TINYINT;
    SET existe = EXISTS(SELECT * FROM insumo i WHERE i.nombre=nombre_insumo AND i.activo=1);
    RETURN existe;
END;

DROP FUNCTION IF EXISTS f_insumo_id_existe;
CREATE FUNCTION f_insumo_id_existe ( id_insumo INT)
RETURNS tinyint
BEGIN
	declare existe tinyint;
    set existe = exists(select * from insumo i where i.id_insumo=id_insumo);
    return existe;
END;

DROP FUNCTION IF EXISTS f_insumo_activo_id_existe;
CREATE FUNCTION f_insumo_activo_id_existe ( id_insumo INT)
RETURNS tinyint
BEGIN
	declare existe tinyint;
    set existe = exists(select * from insumo i where i.id_insumo=id_insumo AND i.activo=1);
    return existe;
END;

DROP FUNCTION IF EXISTS f_insumo_nombre_traer;
CREATE FUNCTION f_insumo_nombre_traer(id_insumo INT) 
RETURNS VARCHAR(45)
BEGIN
	DECLARE nombre VARCHAR(45);
    SELECT i.nombre INTO nombre FROM insumo i WHERE i.id_insumo=id_insumo;
    RETURN nombre;
END;

-- =========================== ALTA ===========================

DROP PROCEDURE IF EXISTS sp_insumo_alta;
CREATE PROCEDURE sp_insumo_alta(IN nombre_insumo VARCHAR(45), OUT resultado INT, OUT msg VARCHAR(255))
BEGIN
	IF (f_insumo_existe(nombre_insumo)) THEN
		SET msg = concat("Ya existe un insumo llamado, ", nombre_insumo);
        SET resultado = -1;
	ELSE
		insert INTO insumo(nombre, activo) values(nombre_insumo, 1);
		SET msg = null;
        SET resultado = 0;
    END IF;
END;

-- =========================== BAJA ===========================
DROP PROCEDURE IF EXISTS sp_insumo_nombre_baja;
CREATE PROCEDURE sp_insumo_nombre_baja(IN nombre_insumo VARCHAR(45), OUT resultado INT, OUT msg VARCHAR(255))
BEGIN
	IF (f_insumo_existe(nombre_insumo)) THEN
		IF (f_insumo_activo_existe(nombre_insumo)) THEN
			update insumo i SET i.activo=0 WHERE i.nombre=nombre_insumo;
			SET msg = null;
            SET resultado = 0;
		ELSE
			SET msg = concat("Ya esta dado de baja el insumo llamado,  ", nombre_insumo);
            SET resultado = -1;
		END IF;
	ELSE
		SELECT concat("No existe un insumo llamado, ", nombre_insumo) ;
        SET resultado = -1;
    END IF;
END;

DROP PROCEDURE IF EXISTS sp_insumo_id_baja;
CREATE PROCEDURE sp_insumo_id_baja(IN id_insumo VARCHAR(45), OUT resultado INT, OUT msg VARCHAR(255))
BEGIN
	IF (f_insumo_id_existe(id_insumo)) THEN
		IF (f_insumo_activo_id_existe(id_insumo)) THEN
			update insumo i SET i.activo=0 WHERE i.id_insumo=id_insumo;
			SET msg = null;
            SET resultado = 0;
		ELSE
			SET msg = concat("Ya esta dado de baja el insumo con id,  ", id_insumo);
            SET resultado = -1;
		END IF;
	ELSE
		SELECT concat("No existe un insumo con el siguiente id: , ", id_insumo) ;
        SET resultado = -1;
    END IF;
END;
-- =========================== MODIFICAR ===========================

DROP PROCEDURE IF EXISTS sp_insumo_modificar;
CREATE PROCEDURE sp_insumo_modificar(IN id_insumo INT, IN nuevo_nombre VARCHAR(45), OUT resultado INT, OUT msg VARCHAR(255))
BEGIN
	DECLARE viejo_nombre VARCHAR(45);
	IF(f_insumo_nombre_traer(id_insumo) IS NULL) THEN
		SET msg = concat("No existe un insumo con id: ", id_insumo);
        SET resultado = -1;
    ELSE
		IF(f_insumo_existe(nuevo_nombre)) THEN
			SET msg = concat("Ya existe un insumo llamado: ", nuevo_nombre);
            SET resultado = -1;
        ELSE
			IF(f_insumo_activo_id_existe(id_insumo)) THEN
				SELECT i.nombre INTO viejo_nombre FROM insumo i WHERE i.id_insumo=id_insumo;
				update insumo i SET i.nombre=nuevo_nombre WHERE i.id_insumo=id_insumo;
				SET msg = null;
				SET resultado = 0;
			ELSE
				SET msg = concat("El insumo con id= ",id_insumo, " que se intento modificar, esta dado de baja.");
				SET resultado = -1;
			END IF;
        END IF;
    END IF;
END;

-- =========================== LEER ===========================

DROP PROCEDURE IF EXISTS sp_insumo_leer;
CREATE PROCEDURE sp_insumo_leer()
BEGIN
	SELECT id_insumo, nombre, f_tinyint_to_varchar(activo) AS activo FROM insumo;
END;

//
