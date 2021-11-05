-- TEST PUNTO 9

-- insert into estacion (id_estacion,tarea, id_linea_de_montaje, id_estacion_siguiente) values (6, 'prueba', 1, null),(5, 'electricidad', 1, 6),(4, 'mecanica rodaje', 1, 5), (3, 'mecanica motor', 1, 4), (2, 'Ensamblado de chapa', 1, 3), (1, 'pintura', 1, 2);

call sp_agregar_tarea('tarea 1', 1, @resultado,@mensaje);
select @resultado , @mensaje;
call sp_agregar_tarea('tarea 2', 1, @resultado,@mensaje);
select @resultado , @mensaje;
call sp_agregar_tarea('tarea 3', 1, @resultado,@mensaje);
select @resultado , @mensaje;

call sp_ingresar_automovil('NBT552',@resultado,@mensaje);
select @resultado , @mensaje;

-- TEST PUNTO 10

call sp_avanzar_automovil('NBT552',@resultado,@mensaje);
select @resultado , @mensaje;

