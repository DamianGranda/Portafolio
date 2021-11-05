-- TEST PUNTO 8 

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


call sp_generar_automoviles(1);
select * from vehiculo;
select * from linea_de_montaje;
