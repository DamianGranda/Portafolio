-- ===================================================================
-- ========================= TEST PUNTO 13 ===========================
-- ===================================================================

call sp_modelo_alta('Corolla', 6000, @resultado, @mensaje);

call sp_concesionaria_alta('Strianese', @resultado, @mensaje);

call sp_agregar_tarea('tarea 1', 1, @resultado,@mensaje);
call sp_agregar_tarea('tarea 2', 1, @resultado,@mensaje);
call sp_agregar_tarea('tarea 3', 1, @resultado,@mensaje);

insert into venta(fecha, cuit, id_concesionaria, activo) values (date(now()), '2312345009', 1, 1);

insert into detalle_venta (id_venta, id_modelo, cantidad, precio_unitario, precio_final, activo) values(1, 1, 3, 200, 300,1);

call sp_generar_automoviles(1);

call sp_ingresar_automovil('CWB52',@resultado,@mensaje); -- cambiar patente según corresponda

call sp_avanzar_automovil('CWB52',@resultado,@mensaje);
call sp_avanzar_automovil('CWB52',@resultado,@mensaje);
call sp_avanzar_automovil('CWB52',@resultado,@mensaje);

call sp_promedio_construccion_vehiculos(1, @promedio, @resultado, @mensaje);

select @promedio as promedio_horas, @resultado, @mensaje;