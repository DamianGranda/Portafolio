delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;
-- ===================================================================
-- ============================ PROVEEDOR ============================
-- ===================================================================


-- =========================== FUNCIONES ===========================

DROP FUNCTION IF EXISTS f_proveedor_existe;
CREATE FUNCTION f_proveedor_existe ( nombre_proveedor VARCHAR(45))
RETURNS TINYINT
BEGIN
	DECLARE existe TINYINT;
    SET existe = EXISTS(SELECT * FROM proveedor p WHERE p.nombre=nombre_proveedor);
    RETURN existe;
END;

DROP FUNCTION IF EXISTS f_proveedor_activo_existe;
CREATE FUNCTION f_proveedor_activo_existe ( nombre_proveedor VARCHAR(45))
RETURNS TINYINT
BEGIN
	DECLARE existe TINYINT;
    SET existe = EXISTS(SELECT * FROM proveedor p WHERE p.nombre=nombre_proveedor AND p.activo=1);
    RETURN existe;
END;

DROP FUNCTION IF EXISTS f_proveedor_nombre_traer;
CREATE FUNCTION f_proveedor_nombre_traer(id_proveedor INT) 
RETURNS VARCHAR(45)
BEGIN
	DECLARE nombre VARCHAR(45);
    SELECT p.nombre INTO nombre FROM proveedor p WHERE p.id_proveedor=id_proveedor;
    RETURN nombre;
END;

-- =========================== ALTA ===========================

DROP PROCEDURE IF EXISTS sp_proveedor_alta;
CREATE PROCEDURE sp_proveedor_alta(IN nombre_proveedor VARCHAR(45), OUT resultado INT, OUT msg VARCHAR(45))
BEGIN
	IF (f_proveedor_existe(nombre_proveedor)) THEN
		SET msg = concat("Ya existe un proveedor llamado, ", nombre_proveedor);
        SET resultado = -1;
	ELSE
		insert INTO proveedor(nombre, activo)
        values(nombre_proveedor, 1);
        
		SET msg = concat("Se ha creado correctamente un proveedor llamado, ", nombre_proveedor);
        SET resultado = 0;
    END IF;
END;

-- =========================== BAJA ===========================

DROP PROCEDURE IF EXISTS sp_proveedor_baja;
CREATE PROCEDURE sp_proveedor_baja(IN nombre_proveedor VARCHAR(45), OUT resultado INT, OUT msg VARCHAR(45))
BEGIN
	IF (f_proveedor_existe(nombre_proveedor)) THEN
		IF (f_proveedor_activo_existe(nombre_proveedor)) THEN
			update proveedor p SET p.activo=0 WHERE p.nombre=nombre_proveedor;
			SET msg = concat("Se ha dado de baja un proveedor llamado, ", nombre_proveedor);
            SET resultado = 0;
		ELSE
			SET msg = concat("Ya esta dado de baja el proveedor llamado,  ", nombre_proveedor);
            SET resultado = -1;
		END IF;
	ELSE
		SELECT concat("No existe un proveedor llamado, ", nombre_proveedor) ;
        SET resultado = -1;
    END IF;
END;

-- =========================== MODIFICAR ===========================

DROP PROCEDURE IF EXISTS sp_proveedor_modificar;
CREATE PROCEDURE sp_proveedor_modificar(IN id_proveedor INT, IN nuevo_nombre VARCHAR(45), OUT resultado INT, OUT msg VARCHAR(45))
BEGIN
	DECLARE viejo_nombre VARCHAR(45);
	IF(f_proveedor_nombre_traer(id_proveedor) IS NULL) THEN
		SET msg = concat("No existe un proveedor con id, ", id_proveedor);
        SET resultado = -1;
    ELSE
		IF(f_proveedor_existe(nuevo_nombre)) THEN
			SET msg = concat("Ya existe un proveedor llamado, ", nuevo_nombre);
            SET resultado = -1;
        ELSE
			SELECT p.nombre INTO viejo_nombre FROM proveedor p WHERE p.id_proveedor=id_proveedor;
			IF(f_proveedor_activo_existe(viejo_nombre)) THEN
				update proveedor p SET p.nombre=nuevo_nombre WHERE p.id_proveedor=id_proveedor;
				SET msg = concat("Se modifico el proveedor con id: ", id_proveedor);
				SET resultado = 0;
			ELSE
				SET msg = concat("El proveedor con id= ",id_proveedor, " que se intento modificar, esta dado de baja.");
				SET resultado = -1;
			END IF;
        END IF;
    END IF;
END;

-- =========================== LEER ===========================

DROP PROCEDURE IF EXISTS sp_proveedor_leer;
CREATE PROCEDURE sp_proveedor_leer()
BEGIN
	SELECT id_proveedor, nombre, f_tinyint_to_varchar(activo) AS activo FROM proveedor;
END;

//
