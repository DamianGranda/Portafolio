delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;
-- ===================================================================
-- ============================ PUNTO 9 =============================
-- ===================================================================

DROP PROCEDURE IF EXISTS sp_ingresar_automovil;
CREATE PROCEDURE sp_ingresar_automovil(in _patente varchar(10), OUT nResultado INT, OUT cMensaje VARCHAR(200))
BEGIN

	DECLARE _id_primera_estacion INT;
    DECLARE _automovil_chasis VARCHAR(45);
    DECLARE _estacion_ocupada_chasis VARCHAR(45);
    
    SET _automovil_chasis = f_traer_chasis_automovil(_patente);
    SET _id_primera_estacion = f_traer_id_primer_estacion(_automovil_chasis);
    
    -- Esta variable la pongo asi para poder hacer pruebas, lo correcto es que este en date(now())

    SET _estacion_ocupada_chasis = f_estacion_ocupada(_id_primera_estacion,'2021-10-14');
    IF _estacion_ocupada_chasis IS NULL THEN
		INSERT INTO estacion_vehiculo (id_estacion, num_chasis, fecha_de_ingreso) values (_id_primera_estacion, _automovil_chasis,'2021-10-14');
        SET nResultado = 0;
	ELSE
		SET nResultado = -1;
        SET cMensaje = concat('La estacion ' , _id_primera_estacion, ' esta ocupada por el vehiculo con el siguiente chasis: ', _estacion_ocupada_chasis);
    END IF;

END;

DROP FUNCTION IF EXISTS f_traer_id_primer_estacion;
CREATE FUNCTION f_traer_id_primer_estacion ( _chasis VARCHAR(45))
RETURNS INT
BEGIN
	DECLARE id_encontrado INT;
    SET id_encontrado = (SELECT l.id_primer_estacion FROM linea_de_montaje l 
						INNER JOIN modelo m on m.id_modelo = l.id_modelo
                        INNER JOIN vehiculo v on v.id_modelo = m.id_modelo
                         WHERE v.num_chasis = _chasis);
    RETURN id_encontrado;
END;

DROP FUNCTION IF EXISTS f_traer_chasis_automovil;
CREATE FUNCTION f_traer_chasis_automovil ( _patente VARCHAR(10))
RETURNS VARCHAR(45)
BEGIN
	DECLARE _chasis VARCHAR(45);
    SET _chasis = (SELECT num_chasis FROM vehiculo WHERE patente = _patente);
    RETURN _chasis;
END;

-- Para ver si esta ocupada se fija si la fecha de salida es nula. Osea que sigue ahi
DROP FUNCTION IF EXISTS f_estacion_ocupada;
CREATE FUNCTION f_estacion_ocupada(_id_estacion int, _fecha DATE)
RETURNS VARCHAR(45)
BEGIN
	DECLARE _num_chasis VARCHAR(45);
    SET _num_chasis = (SELECT num_chasis FROM estacion_vehiculo WHERE id_estacion = _id_estacion AND fecha_salida is null);
    RETURN _num_chasis;
END;

//