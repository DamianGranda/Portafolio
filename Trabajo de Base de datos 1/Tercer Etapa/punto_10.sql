delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;
-- ===================================================================
-- ============================ PUNTO 10 =============================
-- ===================================================================

DROP PROCEDURE IF EXISTS sp_avanzar_automovil;
CREATE PROCEDURE sp_avanzar_automovil(in _patente varchar(10), OUT nResultado INT, OUT cMensaje VARCHAR(200))
BEGIN

	DECLARE _id_actual_estacion INT;
    DECLARE _id_siguiente_estacion INT;
    DECLARE _automovil_chasis VARCHAR(45);
    DECLARE _estacion_ocupada_chasis VARCHAR(45);
    
    SET _automovil_chasis = f_traer_chasis_automovil(_patente);
    SET _id_actual_estacion = f_traer_id_estacion_actual(_automovil_chasis);
    SET _id_siguiente_estacion = (SELECT id_estacion_siguiente FROM estacion WHERE id_estacion = _id_actual_estacion);
    
    UPDATE estacion_vehiculo SET fecha_salida = date(now()) WHERE id_estacion = _id_actual_estacion and num_chasis = _automovil_chasis; -- FECHA FINAL SETEADA
    
    IF _id_siguiente_estacion IS NULL THEN -- Es la ultima estacion -> auto finalizado.
		SET nResultado = 0;
        SET cMensaje = concat('El auto con chasis ' , _automovil_chasis, ' ha finalizado.');
		UPDATE vehiculo SET fecha_de_fin = date(now()) WHERE num_chasis = _automovil_chasis;
    ELSE
        SET _estacion_ocupada_chasis = f_estacion_ocupada(_id_siguiente_estacion,date(now()));
		IF _estacion_ocupada_chasis IS NULL THEN
			INSERT INTO estacion_vehiculo (id_estacion, num_chasis, fecha_de_ingreso) values (_id_siguiente_estacion, _automovil_chasis,date(now()));
			SET nResultado = 0;
		ELSE
			SET nResultado = -1;
			SET cMensaje = concat('La estacion ' , _id_primera_estacion, ' esta ocupada por el vehiculo con el siguiente chasis: ', _estacion_ocupada_chasis);
		END IF;
    END IF;
END;

DROP FUNCTION IF EXISTS f_traer_id_estacion_actual;
CREATE FUNCTION f_traer_id_estacion_actual( _chasis VARCHAR(45))
RETURNS INT
BEGIN
	DECLARE id_encontrado INT;
    SET id_encontrado = (SELECT id_estacion FROM estacion_vehiculo WHERE num_chasis = _chasis AND fecha_salida is null);
    RETURN id_encontrado;
END;

//