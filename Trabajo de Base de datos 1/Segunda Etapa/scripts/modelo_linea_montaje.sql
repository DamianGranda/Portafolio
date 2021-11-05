delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;
-- ===================================================================
-- ============================ MODELO - LINEA DE MONTAJE - ESTACION ============================
-- ===================================================================

-- =========================== FUNCIONES ===========================

DROP FUNCTION IF EXISTS f_modelo_existe;
CREATE FUNCTION f_modelo_existe ( nombre_modelo VARCHAR(45))
RETURNS tinyint
BEGIN
	declare existe tinyint;
    set existe = exists(select * from modelo m where m.nombre=nombre_modelo);
    return existe;
END;


DROP FUNCTION IF EXISTS f_tarea_existe;
CREATE FUNCTION f_tarea_existe(nombre_tarea VARCHAR(45), _id_linea_montaje INT)
RETURNS tinyint
BEGIN
	declare existe tinyint;
    set existe = exists(select e.id_estacion from estacion e where e.tarea=nombre_tarea and e.id_linea_de_montaje=_id_linea_montaje);
    return existe;
END;


-- =========================== ALTA ===========================

DROP PROCEDURE IF EXISTS sp_modelo_alta;
CREATE PROCEDURE sp_modelo_alta(IN nombre_modelo VARCHAR(45), IN numero_precio DOUBLE, OUT resultado INT, OUT msg VARCHAR(255))
BEGIN
	DECLARE id_generado INT;
	IF (f_modelo_existe(nombre_modelo)) THEN
		SET msg = concat("Ya existe un modelo llamado, ", nombre_modelo);
        SET resultado = -1;
	ELSE
		INSERT INTO modelo(nombre, precio) values (nombre_modelo, numero_precio);
        SET id_generado = (SELECT id_modelo FROM modelo where nombre = nombre_modelo);
        INSERT INTO	linea_de_montaje (id_modelo) values(id_generado);
		SET msg = null;
        SET resultado = 0;
    END IF;
END;

-- =========================== AGREGAR TAREAS LINEA MONTAJE ===========================

DROP PROCEDURE IF EXISTS sp_agregar_tarea;
CREATE PROCEDURE sp_agregar_tarea(IN nombre_tarea VARCHAR(45), IN _id_linea_montaje INT, OUT resultado INT, OUT msg VARCHAR(255))
BEGIN
	DECLARE id_generado INT;
	DECLARE id_anterior INT;
	IF (f_tarea_existe(nombre_tarea, _id_linea_montaje)) THEN
		SET msg = concat("Ya existe una tarea llamada: ", nombre_tarea, " en la linea de montaje: " , _id_linea_montaje);
        SET resultado = -1;
	ELSE
		SET id_anterior = (SELECT max(id_estacion) FROM estacion WHERE id_linea_de_montaje = _id_linea_montaje);
		INSERT INTO estacion (tarea, id_linea_de_montaje) values (nombre_tarea, _id_linea_montaje);
        SET id_generado = (SELECT id_estacion FROM estacion WHERE tarea = nombre_tarea AND id_linea_de_montaje=_id_linea_montaje);
		SET msg = null;
        SET resultado = 0;
		call sp_asignar_estacion_anterior_id(id_generado, id_anterior, _id_linea_montaje);
    END IF;
END;

DROP PROCEDURE IF EXISTS sp_asignar_estacion_anterior_id;
CREATE PROCEDURE sp_asignar_estacion_anterior_id( _id_estacion INT, id_anterior INT, _id_linea_montaje INT)
BEGIN
    IF id_anterior IS NULL THEN
		-- Si no existe una anterior es porque este id de estacion es la primera.
		UPDATE linea_de_montaje SET id_primer_estacion = _id_estacion where id_linea_de_montaje = _id_linea_montaje;
    ELSE
		-- Le asigno este id a la estacion anterior.
		UPDATE estacion SET id_estacion_siguiente = _id_estacion WHERE id_estacion = id_anterior;
    END IF;
END;

//
