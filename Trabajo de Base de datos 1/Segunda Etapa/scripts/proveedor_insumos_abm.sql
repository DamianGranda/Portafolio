delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;
-- ===================================================================
-- ======================== PROVEEDOR INSUMOS ========================
-- ===================================================================
-- TODO: AGREGAR VALIDACIONES DE IDS
-- 		PROVEEDOR[✔]
--		INSUMO[ ]

-- =========================== FUNCIONES ===========================

DROP FUNCTION IF EXISTS f_proveedor_insumo_existe;
CREATE FUNCTION f_proveedor_insumo_existe(id_proveedor INT, id_insumo INT)
RETURNS TINYINT
BEGIN
	DECLARE existe TINYINT;
    SET existe = EXISTS(
		SELECT * FROM proveedor_insumo p_i 
        WHERE (p_i.id_proveedor=id_proveedor 
        and p_i.id_insumo=id_insumo)
        );
    RETURN existe;
END;

DROP FUNCTION IF EXISTS f_proveedor_insumo_activo_existe;
CREATE FUNCTION f_proveedor_insumo_activo_existe(id_proveedor INT, id_insumo INT)
RETURNS TINYINT
BEGIN
	DECLARE existe TINYINT;
    SET existe = EXISTS(SELECT * FROM proveedor_insumo p_i WHERE (p_i.id_proveedor=id_proveedor and p_i.id_insumo=id_insumo and p_i.activo=1));
    RETURN existe;
END;

-- =========================== ALTA ===========================

DROP PROCEDURE IF EXISTS sp_proveedor_insumo_alta;
CREATE PROCEDURE sp_proveedor_insumo_alta(id_proveedor int, id_insumo int, precio_actual float, OUT resultado INT, OUT msg VARCHAR(45))
BEGIN
	IF (f_proveedor_insumo_existe(id_proveedor, id_insumo)) THEN
		SET msg = concat("Ya existe un proveedor-insumo con id_proveedor= ", id_proveedor,", id_insumo=",id_insumo);
        SET resultado = -1;
	ELSE
		IF(f_proveedor_nombre_traer(id_proveedor) IS NULL) THEN
			SET msg = concat("No existe un proveedor con id_proveedor= ", id_proveedor);
			SET resultado = -1;
		ELSE
			IF(f_es_mayor_float(precio_actual, 0))THEN
				insert INTO proveedor_insumo
				values(id_proveedor, id_insumo, precio_actual, 1);
				
				SET msg = concat("Se ha creado correctamente proveedor-insumo con id_proveedor= ", id_proveedor,", id_insumo=",id_insumo, ", precio_actual= ",precio_actual);
				SET resultado = 0;
            ELSE
				SET msg = concat("El precio no puede ser negativo");
				SET resultado = -1;
            END IF;
        END IF;
    END IF;
END;

-- =========================== BAJA ===========================

DROP PROCEDURE IF EXISTS sp_proveedor_insumo_baja;
CREATE PROCEDURE sp_proveedor_insumo_baja(id_proveedor int, id_insumo int, OUT resultado INT, OUT msg VARCHAR(45))
BEGIN
	IF (f_proveedor_insumo_existe(id_proveedor, id_insumo)) THEN
		IF (f_proveedor_insumo_activo_existe(id_proveedor, id_insumo)) THEN
			update proveedor_insumo p_i SET p_i.activo=0 WHERE p_i.id_proveedor=id_proveedor and p_i.id_insumo=id_insumo;
			SET msg = concat("Se ha dado de baja un proveedor-insumo con id_proveedor= ", id_proveedor,", id_insumo=",id_insumo);
            SET resultado = 0;
		ELSE
			SET msg = concat("Ya esta dado de baja un proveedor-insumo con id_proveedor= ", id_proveedor,", id_insumo=",id_insumo);
            SET resultado = -1;
		END IF;
	ELSE
		SET msg = concat("No existe un proveedor-insumo con id_proveedor= ", id_proveedor,", id_insumo=",id_insumo);
        SET resultado = -1;
    END IF;
END;

-- =========================== MODIFICAR ===========================

DROP PROCEDURE IF EXISTS sp_proveedor_insumo_modificar;
CREATE PROCEDURE sp_proveedor_insumo_modificar(id_proveedor int, id_insumo int, precio_nuevo float, OUT resultado INT, OUT msg VARCHAR(45))
BEGIN
	IF(f_proveedor_insumo_existe(id_proveedor, id_insumo)) THEN
		IF(f_proveedor_insumo_activo_existe(id_proveedor, id_insumo)) THEN
			IF(f_proveedor_nombre_traer(id_proveedor) IS NULL) THEN
				SET msg = concat("No existe un proveedor con id_proveedor= ", id_proveedor);
				SET resultado = -1;
            ELSE
				IF(f_es_mayor_float(precio_actual, 0))THEN
					UPDATE proveedor_insumo p_i
					SET
						p_i.precio_actual=precio_nuevo
					WHERE
						(p_i.id_proveedor=id_proveedor and p_i.id.insumo=id_insumo);
					SET msg = concat("Se modifico un proveedor-insumo con id_proveedor= ", id_proveedor,", id_insumo=",id_insumo);
					SET resultado = 0;
                ELSE
					SET msg = concat("El precio no puede ser negativo");
					SET resultado = -1;
                END IF;
            END IF;
			
		ELSE
			SET msg = concat("El proveedor-insumo, que se intento modificar, con id_proveedor= ", id_proveedor,", id_insumo=",id_insumo, ", esta dado de baja.");
			SET resultado = -1;
        END IF;
    ELSE
		SET msg = concat("No existe un proveedor-insumo con id_proveedor= ", id_proveedor,", id_insumo=",id_insumo);
        SET resultado = -1;
    END IF;
END;

-- =========================== LEER ===========================

DROP PROCEDURE IF EXISTS sp_proveedor_insumo_leer;
CREATE PROCEDURE sp_proveedor_insumo_leer()
BEGIN
	select id_proveedor id_insumo, precio_actual, f_tinyint_to_varchar(activo) as activo from proveedor_insumo;
END;

