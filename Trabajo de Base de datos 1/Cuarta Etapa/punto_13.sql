delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;
-- ===================================================================
-- ============================ PUNTO 13 =============================
-- ===================================================================

DROP PROCEDURE IF EXISTS sp_promedio_construccion_vehiculos;
CREATE PROCEDURE sp_promedio_construccion_vehiculos(IN _id_linea_de_montaje INT, OUT resultadoHoras INT, OUT nResultado INT, OUT cMensaje VARCHAR(200))
proc_label:BEGIN 

	DECLARE cursor_finished INT;
	DECLARE id_primer_estacion INT;
    DECLARE id_ultima_estacion INT;
	DECLARE num_chasis_actual VARCHAR(45);
    DECLARE fecha_de_ingreso_actual DATE;
    DECLARE fecha_salida_actual DATE;
    
	DECLARE cursorVehiculos
        CURSOR FOR
            SELECT num_chasis FROM vehiculo v
            INNER JOIN modelo m ON v.id_modelo = m.id_modelo
            INNER JOIN linea_de_montaje ldm ON ldm.id_modelo = m.id_modelo
            WHERE ldm.id_linea_de_montaje = _id_linea_de_montaje AND v.fecha_de_fin IS NOT NULL;    
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			DROP TEMPORARY TABLE IF EXISTS vehiculos_tiempo_construccion;
			SET nResultado = -1;
			SET cMensaje = "Error en el procedimiento sp_promedio_construccion_vehiculos";
			ROLLBACK;
		END;
 
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_finished = 1;
    
	SET id_primer_estacion = f_traer_id_primer_estacion_linea(_id_linea_de_montaje);
    SET id_ultima_estacion = f_traer_id_ultima_estacion_linea(_id_linea_de_montaje);
    
    CREATE TEMPORARY TABLE vehiculos_tiempo_construccion(tiempo INT);
    
    OPEN cursorVehiculos;
		recorrerVehiculos: LOOP
			FETCH cursorVehiculos INTO num_chasis_actual;
			IF cursor_finished = 1 THEN
				LEAVE recorrerVehiculos;
			END IF;
			
			SELECT fecha_de_ingreso INTO fecha_de_ingreso_actual FROM estacion_vehiculo WHERE num_chasis = num_chasis_actual AND id_estacion = id_primer_estacion;
			SELECT fecha_salida INTO fecha_salida_actual FROM estacion_vehiculo ev WHERE ev.num_chasis = num_chasis_actual AND id_estacion = id_ultima_estacion;
			
			IF fecha_de_ingreso_actual IS NULL OR fecha_salida_actual IS NULL THEN
				SET nResultado = -1;
				SET cMensaje = concat('Error al acceder a las fechas de ingreso/egreso del vehiculo ', num_chasis_actual);
                LEAVE proc_label;
			END IF;
			
			INSERT INTO vehiculos_tiempo_construccion (tiempo) VALUES (TIMESTAMPDIFF(HOUR, fecha_de_ingreso_actual, fecha_salida_actual));
			
		END LOOP recorrerVehiculos;
    CLOSE cursorVehiculos;
    
    SELECT AVG(tiempo) INTO resultadoHoras FROM vehiculos_tiempo_construccion;
    SET cMensaje = concat('Se procesaron ', FOUND_ROWS(), ' vehículos');
    SET nResultado = 0;

	DROP TEMPORARY TABLE vehiculos_tiempo_construccion;

END;

DROP FUNCTION IF EXISTS f_traer_id_primer_estacion_linea;
CREATE FUNCTION f_traer_id_primer_estacion_linea(_id_linea_de_montaje INT)
RETURNS INT
BEGIN
	DECLARE id_encontrado INT;
    SET id_encontrado = (SELECT id_primer_estacion FROM linea_de_montaje WHERE id_linea_de_montaje = _id_linea_de_montaje);
    RETURN id_encontrado;
END;

DROP FUNCTION IF EXISTS f_traer_id_ultima_estacion_linea;
CREATE FUNCTION f_traer_id_ultima_estacion_linea(_id_linea_de_montaje INT)
RETURNS INT
BEGIN
	DECLARE id_encontrado INT;
    SET id_encontrado = (SELECT id_estacion FROM estacion WHERE id_linea_de_montaje = _id_linea_de_montaje AND id_estacion_siguiente IS NULL);
    RETURN id_encontrado;
END;

//