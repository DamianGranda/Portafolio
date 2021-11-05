delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;

-- =========================== FUNCIONES ===========================

DROP FUNCTION IF EXISTS f_detalle_venta_existe;
CREATE FUNCTION f_detalle_venta_existe(id_venta INT, id_modelo INT)
RETURNS TINYINT
BEGIN
	DECLARE existe TINYINT;
    SET existe = EXISTS(
		SELECT * FROM detalle_venta d_v 
        WHERE (d_v.id_modelo=id_modelo 
        and d_v.id_venta=id_venta)
        );
    RETURN existe;
END;

DROP FUNCTION IF EXISTS f_detalle_venta_activo_existe;
CREATE FUNCTION f_detalle_venta_activo_existe(id_venta INT, id_modelo INT)
RETURNS TINYINT
BEGIN
	DECLARE existe TINYINT;
    SET existe = EXISTS(SELECT * FROM detalle_venta d_v WHERE (d_v.id_modelo=id_modelo and d_v.id_venta=id_venta and d_v.activo=1));
    RETURN existe;
END;

-- =========================== ALTA ===========================

DROP PROCEDURE IF EXISTS sp_detalle_venta_alta;
CREATE PROCEDURE sp_detalle_venta_alta(id_modelo int, id_venta int, cantidad int, precio_unitario double , OUT resultado INT, OUT msg VARCHAR(225))
BEGIN
	IF (f_detalle_venta_existe(id_venta, id_modelo)) THEN
		SET msg = concat("Ya existe un detalle-venta con id_venta= ", id_venta,", id_modelo=",id_modelo);
        SET resultado = -1;
	ELSE
		IF(existeVenta(id_venta) IS NULL) THEN
			SET msg = concat("No existe una venta con id_venta= ", id_venta);
			SET resultado = -1;
		ELSE
	
				insert INTO detalle_venta
				values(id_modelo, id_venta, cantidad,precio_unitario,(precio_unitario*cantidad), 1);
				
				SET msg = concat("Se ha creado correctamente detalle-venta con id_modelo= ", id_modelo,", id_venta=",id_venta);
				SET resultado = 0;
		
            END IF;
        END IF;
    
END;

-- =========================== BAJA ===========================

DROP PROCEDURE IF EXISTS sp_detalle_venta_baja;
CREATE PROCEDURE sp_detalle_venta_baja(id_modelo int, id_venta int, OUT resultado INT, OUT msg VARCHAR(225))
BEGIN
	IF (f_detalle_venta_existe(id_venta, id_modelo)) THEN
		IF (f_detalle_venta_activo_existe(id_venta, id_modelo)) THEN
			update detalle_venta d_v SET d_v.activo=0 WHERE d_v.id_modelo=id_modelo and d_v.id_venta=id_venta;
			SET msg = concat("Se ha dado de baja un detalle-venta con id_modelo= ", id_modelo,", id_venta=",id_venta);
            SET resultado = 0;
		ELSE
			SET msg = concat("Ya esta dado de baja un detalle-venta con id_modelo= ", id_modelo,", id_venta=",id_venta);
            SET resultado = -1;
		END IF;
	ELSE
		SET msg = concat("No existe un detalle-venta con id_modelo= ", id_modelo,", id_venta=",id_venta);
        SET resultado = -1;
    END IF;
END;

-- =========================== MODIFICAR ===========================

DROP PROCEDURE IF EXISTS sp_detalle_venta_modificar;
CREATE PROCEDURE sp_detalle_venta_modificar(id_modelo int, id_venta int, cantidad_nuevo int,precio_unitario_nuevo double, OUT resultado INT, OUT msg VARCHAR(225))
BEGIN
	IF(f_detalle_venta_existe(id_modelo, id_venta)) THEN
		IF(f_detalle_venta_activo_existe(id_proveedor, id_insumo)) THEN
			
					UPDATE detalle_venta d_v
					SET
						d_v.cantidad=cantidad_nuevo, d_v.precio_unitario=precio_unitario_nuevo, d_v.precio_final=(precio_unitario_nuevo*cantidad_nuevo)
					WHERE
						(d_v.id_modelo=id_modelo and d_v.id.venta=id_venta);
					SET msg = concat("Se modifico un detalle-venta con id_modelo= ", id_modelo,", id_venta=",id_venta);
					SET resultado = 0;
               
             
			
		ELSE
			SET msg = concat("El detalle-venta, que se intento modificar, con id_modelo= ", id_modelo,", id_venta=",id_venta, ", esta dado de baja.");
			SET resultado = -1;
        END IF;
    ELSE
		SET msg = concat("No existe un detalle-venta con id_modelo= ", id_modelo,", id_venta=",id_venta);
        SET resultado = -1;
    END IF;
END;

//