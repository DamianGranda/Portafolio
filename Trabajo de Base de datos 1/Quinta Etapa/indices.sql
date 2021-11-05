-- Creacion de indice ordinario para fechas de ventas
create index idx_fecha_venta on venta(fecha);
show index from venta;

-- Creacion de indice unico para encontrar un auto por patente rapidamente
create unique index idx_patente on vehiculo(patente);
show index from vehiculo;

-- Creacion de indice parte de campos para encontrar un insumo o una concesionaria por nombre rapidamente
create unique index idx_insumo on insumo(nombre(10));
create unique index idx_concesionaria on concesionaria(nombre(10));
show index from insumo;
show index from concesionaria;
