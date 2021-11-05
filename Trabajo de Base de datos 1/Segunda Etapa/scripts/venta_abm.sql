-- ===================================================================
-- ============================ PEDIDO ============================
-- ===================================================================
delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;
DROP FUNCTION IF EXISTS existeConsecionaria;
CREATE FUNCTION existeConsecionaria ( idConsecionaria VARCHAR(45))
RETURNS TINYINT
BEGIN
	declare existe TINYINT;
    set existe = exists(select * from consecionaria c where c.id_consecionaria=idConsecionaria and c.activo = 1);
    return existe;
END;

DROP FUNCTION IF EXISTS existeVenta;
CREATE FUNCTION existeVenta ( idVenta VARCHAR(45))
RETURNS TINYINT
BEGIN
	declare existe TINYINT;
    set existe = exists(select * from venta v where v.id_venta=idVenta and v.activo = 1);
    return existe;
END;

DROP FUNCTION IF EXISTS traerCuitVenta;
CREATE FUNCTION traerCuitVenta(idVenta int) 
RETURNS VARCHAR(45)
BEGIN
	DECLARE cuit VARCHAR(45);
    SELECT c.cuit INTO cuit FROM venta v WHERE v.id_venta=idVenta;
    return cuit;
END;

-- =========================== ALTA ===========================
DROP PROCEDURE IF EXISTS sp_venta_alta;
CREATE PROCEDURE sp_venta_alta(IN idventa INT, IN cuit VARCHAR(45), IN idconsecionaria INT, OUT nResultado INT,OUT cMensaje VARCHAR(225))
BEGIN
    IF (existeConsecionaria(idconsecionaria)) THEN
		SET nResultado = -1;
        SET cMensaje = "La consecionaria que desea agregar ya existe";
	ELSE
		INSERT INTO venta (id_venta,fecha,cuit,id_consecionaria) VALUES (idventa,CURDATE(),cuit,idconsecionaria);
		SET nResultado = 0;
		SET cMensaje = "";
		END IF;
END;

-- =========================== BAJA ===========================
DROP PROCEDURE IF EXISTS sp_venta_baja;
CREATE PROCEDURE sp_venta_baja(IN idVenta INT ,OUT nResultado INT,OUT cMensaje VARCHAR(225))
BEGIN
	IF (NOT existeVenta(idVenta)) THEN
		SET nResultado = -1;
        SET cMensaje = CONCAT("No existe la venta con el ID: ",idVenta);
	ELSE
		UPDATE venta v SET v.activo= 0 WHERE v.id_venta=idVenta;
        SET cMensaje = "";
        SET nResultado = 0;
    END IF;
END;


-- =========================== MODIFICAR ===========================

DROP PROCEDURE IF EXISTS sp_venta_modificar;
CREATE PROCEDURE sp_venta_modificar(IN idVenta INT, IN nuevoCuit VARCHAR(45),IN nuevaFecha DATE ,OUT nResultado INT,OUT cMensaje VARCHAR(225))
BEGIN
	IF(NOT existeVenta(idVenta)) THEN
		SET cMensaje = CONCAT("No existe una venta con id, ", idVenta);
        SET nResultado = -1;
    ELSE
		UPDATE venta v SET v.cuit=nuevoCuit, v.fecha = nuevaFecha WHERE v.id_venta=idVenta;
		SET cMensaje =  "";
		SET nResultado = 0;
    END IF;
END;




//

