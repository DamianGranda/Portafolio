delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;

-- ===================================================================
-- ============================ PUNTO 11 ============================
-- ===================================================================
DROP PROCEDURE IF EXISTS sp_generar_reporte_uno;
CREATE PROCEDURE sp_generar_reporte_uno(in _id_venta INT)
BEGIN

	SELECT v.num_chasis, v.fecha_de_fin as terminado, 
    (SELECT max(ev.id_estacion) group by ev.num_chasis)  as estacion_actual 
    FROM vehiculo v
	LEFT JOIN estacion_vehiculo ev ON ev.num_chasis = v.num_chasis
	WHERE v.id_venta = _id_venta
    GROUP BY v.num_chasis;

END;


//