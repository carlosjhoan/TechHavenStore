-- Este script contiene las consultas de la base de datos techHaven

# Consultas

/*
*1.*  Obtener la lista de todos los productos con sus precio
*/

select
	nombre,
	precio
from
	Productos;

/*
*2.* Encontrar todos los pedidos realizados por un usuario específico, por ejemplo, Juan Perez
*/

select
	p.id,
	p.fecha,
	p.total
from
	Pedidos as p,
	Usuarios as u
where
	u.nombre = 'Juan Perez' and
	p.id_usuario = u.id;

/*
*3.* Listar los detalles de todos los pedidos, incluyendo el nombre del producto, cantidad y precio
unitario 
*/

select
	p.id as pedidoId,
	pr.nombre as Producto,
	dp.cantidad,
	dp.precio_unitario
from
	Pedidos as p,
	Productos as pr,
	DetallesPedidos as dp
where
	p.id = dp.id_pedido and
	pr.id = dp.id_producto;

/*
*4.* Calcular el total gastado por cada usuario en todos sus pedidos
*/

select
	u.nombre as Cliente,
	sum(dp.cantidad * dp.precio_unitario) as Valor
from
	Usuarios as u,
	Pedidos as p,
	DetallesPedidos as dp
where
	p.id_usuario = u.id and
	p.id = dp.id_pedido
group by
	u.id;

/*	
*5.* Encontrar los productos más caros (precio mayor a $500)
*/

select
	nombre,
	precio
from
	Productos
where
	precio > 500.0;

/*
*6.* Listar los pedidos realizados en una fecha específica, por ejemplo, 2024-03-10 
*/

select
	p.id as pedidoId,
	u.id as usuarioId,
	p.fecha,
	p.total
from
	Usuarios as u,
	Pedidos as p
where
	p.id_usuario = u.id and
	p.fecha = '2024-03-10';
	
/*
*7.*  Obtener el número total de pedidos realizados por cada usuario
*/

select
	u.nombre,
	count(u.id) as numPedidos
from
	Usuarios as u,
	Pedidos as p
where
	p.id_usuario = u.id
group by
	u.id;
	
/*
*8.* Encontrar el nombre del producto más vendido (mayor cantidad total vendida)
*/

select
	pr.nombre,
	sum(dp.cantidad) as numVentas
	
from
	Productos as pr,
	DetallesPedidos as dp
where
	pr.id = dp.id_producto
group by
	pr.id
order by
	numVentas desc
limit 1;

/*
*9.* Listar todos los usuarios que han realizado al menos un pedido
*/

select 
	u.nombre,
	u.correo_electronico
from
	Usuarios as u
left join
	Pedidos as p
on
	u.id = p.id_usuario
where
	p.id is not null;
	
/*
*10.*  Obtener los detalles de un pedido específico, incluyendo los productos y cantidades, por
ejemplo, pedido con id 1
*/

select 
	p.id as pedidoId,
	u.nombre as usuario,
	pr.nombre,
	dp.cantidad,
	dp.precio_unitario
from
	Pedidos as p,
	Usuarios as u,
	Productos as pr,
	DetallesPedidos as dp
where
	p.id = dp.id_pedido and
	p.id_usuario = u.id and
	pr.id = dp.id_producto and
	p.id = 1;
	
-- Subconsultas

/*
*1.*  Encontrar el nombre del usuario que ha gastado más en total
*/
	
select
	nombre as Usuario
from
	Usuarios 
where 
	id = (select
			id
		from
			(select
			u.id,
			u.nombre as Usuario,
			sum(dp.cantidad * dp.precio_unitario) as totalPagado
		from
			Usuarios as u,
			Pedidos as p,
			DetallesPedidos as dp
		where
			p.id_usuario = u.id and
			p.id = dp.id_pedido
		group by
			u.id
		order by
			totalPagado desc
		limit 1) as pago_usuarios);	

/*
*2.* Listar los productos que han sido pedidos al menos una vez 
*/	

select
	pr.nombre as Producto
from
	Productos as pr
left join
	DetallesPedidos as dp
on
	pr.id = dp.id_producto
where
	dp.id_producto is not null;
	
/*
*3.* Obtener los detalles del pedido con el total más alto
*/

select
	id as pedidoId,
	id_usuario,
	fecha,
	total
from
	Pedidos
where
	total >= ALL(	select
				total
			from
				Pedidos);

/*
*4.* Listar los usuarios que han realizado más de un pedido
*/	

select 
	u.nombre,
	u.correo_electronico,
	count(p.id_usuario) as cantidadPedidos
from
	Usuarios as u
inner join
	Pedidos as p
on
	u.id = p.id_usuario
group by
	u.id
having
	cantidadPedidos >1;

/*
*5.*  Encontrar el producto más caro que ha sido pedido al menos una vez
*/

select
	pr.nombre as Producto,
	dp.precio_unitario
from
	Productos as pr
left join
	DetallesPedidos as dp
on
	pr.id = dp.id_producto
where
	dp.id_producto is not null
order by
	dp.precio_unitario desc
limit 1;

-- Procedimientos

/*
*1.*  Enunciado: Crea un procedimiento almacenado llamado AgregarProducto que reciba como
parámetros el nombre, descripción y precio de un nuevo producto y lo inserte en la tabla
Productos .
*/

delimiter $$
create procedure AgregarProductos(in nomProd varchar(100), in descr text, in prec_unit decimal(10, 2))
begin
	declare msj varchar(100);

	insert into Productos(nombre, precio, descripcion) values
	(nomProd, prec_unit, descr);
	
	set msj = 'Producto insertado';
	select msj;
end $$
delimiter ;

set @nomProd = 'Celular afafas';
set @descr = 'Nuevo celular con pantalla tàctil';
set @prec_unit = 60.99;

call AgregarProductos(@nomProd, @descr, @prec_unit);


	
/*
*2.*  Crea un procedimiento almacenado llamado ObtenerDetallesPedido que reciba
como parámetro el ID del pedido y devuelva los detalles del pedido, incluyendo el nombre del
producto, cantidad y precio unitario.
*/

delimiter $$
create procedure ObtenerdetallesPedido(in PedId int)
begin
	select
		p.id as pedidoId,
		pr.nombre as Producto,
		dp.cantidad,
		dp.precio_unitario
	from
		Pedidos as p,
		Productos as pr,
		DetallesPedidos as dp
	where
		p.id = dp.id_pedido and
		pr.id = dp.id_producto and
		p.id = PedId;
end $$
delimiter ;

set @PedId = 1;
call ObtenerdetallesPedido(@PedId);
	
/*
3.* Crea un procedimiento almacenado llamado ActualizarPrecioProducto que reciba
como parámetros el ID del producto y el nuevo precio, y actualice el precio del producto en la
tabla Productos .
*/

delimiter $$
create procedure ActualizarPrecioProducto(in prId int, precioProd decimal(10, 2))
begin
	declare msj varchar(100);
	
	update Productos
	set precio = precioProd
	where id = prId;
	
	
	set msj = 'Precio actualizado exitosamente';
	select msj;
	
end $$
delimiter ;

set @prId = 2;
set @precioProd = 120.99;

call ActualizarPrecioProducto(@prId, @precioProd);

/*
*4.*  Crea un procedimiento almacenado llamado EliminarProducto que reciba como
parámetro el ID del producto y lo elimine de la tabla Productos .
*/

delimiter $$
create procedure EliminarProducto(in prId int)
begin
	declare msj varchar(100);
	
	delete from
		DetallesPedidos
	where
		id_producto = prId;

	delete from
		Productos
	where
		id = prId;
		
	set msj = 'Producto eliminado';
	select msj;
end $$
delimiter ;

set @prId = 5;
call EliminarProducto(@prId);

/*
*5.*  Crea un procedimiento almacenado llamado TotalGastadoPorUsuario que reciba
como parámetro el ID del usuario y devuelva el total gastado por ese usuario en todos sus
pedidos.
*/

delimiter $$
create procedure TotalGastadoPorUsuario(in usId int)
begin
	declare msj varchar(100);	

	if usId = any( select id from Usuarios) then
			select
				u.nombre as Cliente,
				sum(dp.cantidad * dp.precio_unitario) as Valor
			from
				Usuarios as u,
				Pedidos as p,
				DetallesPedidos as dp
			where
				p.id_usuario = u.id and
				p.id = dp.id_pedido
			group by
				u.id
			having
				u.id = @usId;
	else 
		set msj = 'Usuario no existe';
		select msj;
	end if;
	
	
end $$
delimiter ;



set @usId = 5;

call TotalGastadoPorUsuario(@usId);
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
