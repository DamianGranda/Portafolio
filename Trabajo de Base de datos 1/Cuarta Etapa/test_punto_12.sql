-- TEST PUNTO 12

call sp_modelo_alta('Toyota', 6000, @resultado, @mensaje);
call sp_modelo_alta('volkswagen', 3000, @resultado, @mensaje);
call sp_modelo_alta('Nissan', 3500, @resultado, @mensaje);
call sp_modelo_alta('Ford k', 1400, @resultado, @mensaje);
select @resultado, @mensaje;
call sp_modelo_alta('Modelo 1', 1400, @resultado, @mensaje);
select @resultado, @mensaje;
call sp_concesionaria_alta('Strianese', @resultado, @mensaje);

insert into venta(fecha, cuit, id_concesionaria,activo) values (date(now()), '2312345009',1,1);

insert into detalle_venta (id_venta, id_modelo, cantidad, precio_unitario, precio_final, activo) values(1, 1, 3, 200, 300,1);
insert into detalle_venta (id_venta, id_modelo, cantidad, precio_unitario, precio_final, activo) values(1, 2, 2, 200, 300,1);
insert into detalle_venta (id_venta, id_modelo, cantidad, precio_unitario, precio_final, activo) values(1, 3, 2, 200, 300,1);
insert into detalle_venta (id_venta, id_modelo, cantidad, precio_unitario, precio_final, activo) values(1, 5, 5, 200, 300,1);

-- Modelo Toyota, Cantidad 3
insert into estacion(tarea, id_linea_de_montaje, activo) values("ejemplo", 1, 1);
insert into estacion(tarea, id_linea_de_montaje, activo) values("ejemplo", 2, 1);
insert into estacion(tarea, id_linea_de_montaje, activo) values("ejemplo", 3, 1);
insert into estacion(tarea, id_linea_de_montaje, activo) values("ejemplo", 4, 1);
insert into estacion(tarea, id_linea_de_montaje, activo) values("ejemplo", 5, 1);

insert into insumo(nombre, activo) values("A", 1);
insert into insumo(nombre, activo) values("B", 1);
insert into insumo(nombre, activo) values("C", 1);
insert into insumo(nombre, activo) values("D", 1);
insert into insumo(nombre, activo) values("E", 1);

-- Modelo Toyota
-- Cod 1, cant 120
-- Cod 2, cant 300
insert into insumo_estacion
(id_insumo, id_estacion, id_linea_de_montaje, cantidad, activo)
values
    (1, 1, 1, 40, 1),
    (2, 1, 1, 100, 1);

-- Modelo Nissan
-- Cod 3 80
-- Code 2 200
insert into insumo_estacion
(id_insumo, id_estacion, id_linea_de_montaje, cantidad, activo)
values
    (3, 3, 3, 40, 1),
    (2, 3, 3, 100, 1);


-- TOTAL
-- Cod 1, cant 120
-- Cod 2, cant 500
-- COd 3, cant 80
call sp_generar_reporte_dos(1);