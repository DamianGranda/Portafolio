delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;
-- ===================================================================
-- ============================ PUNTO 8 ============================
-- ===================================================================

-- Aca declaro el cursos para recorrer los detalles pero solo del pedido indicado en el parametro
DROP PROCEDURE IF EXISTS sp_generar_automoviles;
CREATE PROCEDURE sp_generar_automoviles(in _id_venta INT)
BEGIN

	DECLARE cursor_finished INT;
	DECLARE idModeloParametro INT;
	DECLARE idVentaParametro INT;
	DECLARE nCantidadDetalle INT; 
	DECLARE nInsertados INT;

    DECLARE curDetallePedido
        CURSOR FOR
            SELECT id_modelo, cantidad FROM detalle_venta d
            WHERE d.id_venta=_id_venta;
 
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_finished = 1;

    OPEN curDetallePedido;
		   -- Aca comienzo el loop recorriendo el cursor.
			getDetalle: LOOP
				FETCH curDetallePedido INTO idModeloParametro, nCantidadDetalle;
                IF cursor_finished = 1 THEN
					LEAVE getDetalle;
				END IF;
                
                SET nInsertados = 0;

				-- Aca loopeo para hacer N inserts.
				WHILE nInsertados < nCantidadDetalle DO
					INSERT INTO vehiculo (num_chasis, patente, id_modelo, id_venta, fecha_de_inicio) VALUES (f_generar_chasis(), f_generar_patente(), idModeloParametro, _id_venta, date(now()));
					SET nInsertados = nInsertados + 1;
				END WHILE;
                
			END LOOP getDetalle;
    CLOSE curDetallePedido;

END;

DROP FUNCTION IF EXISTS f_generar_patente;
CREATE FUNCTION f_generar_patente()
RETURNS VARCHAR(10)
BEGIN
	DECLARE patente VARCHAR(45);
    SET patente = concat(substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ', rand()*26, 1),
              substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ', rand()*26, 1),
              substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ', rand()*26, 1),
              substring('0123456789', rand()*10, 1),
              substring('0123456789', rand()*10, 1),
              substring('0123456789', rand()*10, 1));
    
	WHILE f_patente_existe(patente) DO
		SET patente = concat(substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ', rand()*26, 1),
              substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ', rand()*26, 1),
              substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ', rand()*26, 1),
              substring('0123456789', rand()*10, 1),
              substring('0123456789', rand()*10, 1),
              substring('0123456789', rand()*10, 1));
	END WHILE;
    RETURN patente;
END;

DROP FUNCTION IF EXISTS f_generar_chasis;
CREATE FUNCTION f_generar_chasis()
RETURNS VARCHAR(45)
BEGIN
	DECLARE chasis VARCHAR(45);
    
    SET chasis = LEFT(MD5(RAND()), 17);
    
	WHILE f_chasis_existe(chasis) DO
		SET chasis = LEFT(MD5(RAND()), 17);
	END WHILE;
    
    RETURN chasis;
END;

DROP FUNCTION IF EXISTS f_chasis_existe;
CREATE FUNCTION f_chasis_existe ( _chasis VARCHAR(45))
RETURNS TINYINT
BEGIN
	DECLARE existe TINYINT;
    SET existe = EXISTS(SELECT * FROM vehiculo v WHERE v.num_chasis=_chasis);
    RETURN existe;
END;

DROP FUNCTION IF EXISTS f_patente_existe;
CREATE FUNCTION f_patente_existe ( _patente VARCHAR(10))
RETURNS TINYINT
BEGIN
	DECLARE existe TINYINT;
    SET existe = EXISTS(SELECT * FROM vehiculo v WHERE v.patente=_patente);
    RETURN existe;
END;

//
