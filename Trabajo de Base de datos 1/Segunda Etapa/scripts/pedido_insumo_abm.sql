-- ===================================================================
-- ========================== PEDIDO INSUMO ==========================
-- ===================================================================

SET GLOBAL log_bin_trust_function_creators = 1;
-- =========================== FUNCIONES =============================
DROP FUNCTION IF EXISTS existe_pedido_insumo_activo;
DELIMITER //
CREATE FUNCTION existe_pedido_insumo_activo( id_pedido_insumo int)
RETURNS TINYINT
BEGIN
	DECLARE existe TINYINT;
    SET existe = EXISTS(SELECT * FROM pedido_insumo pi WHERE pi.id_pedido_insumo = id_insumo AND pi.activo=1);
    RETURN existe;
END //
DELIMITER ;

-- =========================== ALTA ===================================
-- setea la fecha con día de hoy, busca el proveedor_insumo de ese insumo con el menor precio_actual
-- setea el precio como precio_actual * cantidad

DROP PROCEDURE IF EXISTS sp_pedido_insumo_alta;
DELIMITER //
CREATE PROCEDURE sp_pedido_insumo_alta(IN p_idinsumo int, IN p_cantidad int, OUT p_status int, OUT p_mensaje varchar(100)) 
proc_label:BEGIN 

	DECLARE precio_unitario DOUBLE;
    DECLARE cant_resultados INT;
	DECLARE EXIT handler for sqlexception
    BEGIN
		SET p_status = -1;
        SET p_mensaje = "Error en el procedimiento";
		ROLLBACK;
	END;
        
	SELECT MIN(precio_actual), COUNT(*) INTO precio_unitario, cant_resultados
		FROM
			proveedor_insumo pi
		INNER JOIN
			insumo i ON i.id_insumo = pi.id_insumo
		WHERE
			i.id_insumo = p_idinsumo AND
            i.activo = 1 AND
            pi.activo = 1;
        
	IF (cant_resultados = 0) THEN
		SET p_status = -2;
        SET p_mensaje = CONCAT("No existe insumo con id ", p_idinsumo);
        LEAVE proc_label;
    END IF;

	INSERT INTO pedido_insumo (`fecha`, `precio`, `cantidad`, `id_insumo`, `activo`) VALUES ( CURDATE(), precio_unitario*p_cantidad, p_cantidad, p_idinsumo, true );
	SET p_status = 1;
    SET p_mensaje = CONCAT("Se ha agregado un nuevo pedido_insumo con id ", LAST_INSERT_ID());

END //
DELIMITER ;

-- =========================== BAJA ===========================

DROP PROCEDURE IF EXISTS sp_pedido_insumo_baja;
DELIMITER //
CREATE PROCEDURE sp_pedido_insumo_baja(IN p_id_pedido_insumo int, OUT p_status int, OUT p_mensaje varchar(100)) 
proc_label:BEGIN 

	DECLARE EXIT handler for sqlexception
    BEGIN
		SET p_status = -1;
        SET p_mensaje = "Error en el procedimiento";
		ROLLBACK;
	END;
    
	IF (existe_pedido_insumo_activo(p_id_pedido_insumo)) THEN
		UPDATE pedido_insumo pi SET pi.activo=0 WHERE pi.id_pedido_insumo=p_id_pedido_insumo;
        SET p_status = 1;
		SET p_mensaje = CONCAT("Se ha dado de baja al pedido_insumo con id ", p_id_pedido_insumo);
	ELSE
		SET p_status = -2;
		SET p_mensaje = CONCAT("ERROR. No existe ningún pedido_insumo activo con id ", p_id_pedido_insumo);
	END IF;
    
END //
DELIMITER ;

-- =========================== MODIFICACION ===========================

DROP PROCEDURE IF EXISTS sp_pedido_insumo_modificar;
DELIMITER //
CREATE PROCEDURE sp_pedido_insumo_modificar(IN p_id_pedido_insumo int, IN p_nueva_cant int, OUT p_status int, OUT p_mensaje varchar(100)) 
proc_label:BEGIN 

	DECLARE precio_unitario_actual DOUBLE;
	DECLARE EXIT handler for sqlexception
    BEGIN
		SET p_status = -1;
        SET p_mensaje = "Error en el procedimiento";
		ROLLBACK;
	END;
    
	IF (existe_pedido_insumo_activo(p_id_pedido_insumo)) THEN
		SELECT precio/cantidad INTO precio_unitario_actual FROM pedido_insumo pi WHERE pi.id_pedido_insumo=p_id_pedido_insumo;
		UPDATE pedido_insumo pi SET pi.cantidad = p_nueva_cant, pi.precio = precio_unitario_actual*p_nueva_cant WHERE pi.id_pedido_insumo=p_id_pedido_insumo;
        SET p_status = 1;
		SET p_mensaje = CONCAT("Se modificó el pedido_insumo con id ", p_id_pedido_insumo);
	ELSE
		SET p_status = -2;
		SET p_mensaje = CONCAT("ERROR. No existe ningún pedido_insumo activo con id ", p_id_pedido_insumo);
	END IF;
    
END //
DELIMITER ;