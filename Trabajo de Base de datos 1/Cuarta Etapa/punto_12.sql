delimiter //
SET GLOBAL log_bin_trust_function_creators = 1;

-- ===================================================================
-- ============================ PUNTO 12 ============================
-- ===================================================================
DROP PROCEDURE IF EXISTS sp_generar_reporte_dos;
CREATE PROCEDURE sp_generar_reporte_dos(in _id_venta INT)
BEGIN

    SELECT max(i_e.id_insumo) as Codigo, sum(i_e.cantidad*d_v.cantidad) as Cantidad FROM detalle_venta d_v
    INNER JOIN modelo m on m.id_modelo=d_v.id_modelo
    INNER JOIN linea_de_montaje l_m on l_m.id_modelo=m.id_modelo
    INNER JOIN estacion e on e.id_linea_de_montaje=l_m.id_linea_de_montaje
    INNER JOIN insumo_estacion i_e on i_e.id_estacion=e.id_estacion
    WHERE d_v.id_venta=_id_venta
    GROUP BY i_e.id_insumo;

END;

//