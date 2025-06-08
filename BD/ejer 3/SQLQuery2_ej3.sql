USE Ejercicio3;

select *
from Producto

select *
from Proveedor


--1. Indique la cantidad de productos que tiene la empresa.

select count(*)
from Producto

--2. Indique la cantidad de productos en estado 'en stock' que tiene la empresa.

select count(*)
from Producto
where Estado = 'stock'

--3. Indique los productos que nunca fueron vendidos.select pr.Id_productofrom Producto prwhere pr.Id_producto not in ( 							select Id_producto							from Detalle_venta							)--4. Indique la cantidad de unidades que fueron vendidas de cada producto.

select Id_producto, count(*)Cantidad
from Detalle_venta
group by Id_producto

--5. Indique cual es la cantidad promedio de unidades vendidas de cada producto.

select Id_producto, count(*)Cantidad, AVG(Cantidad)promedio
from Detalle_venta
group by Id_producto

select * 
from Vendedor
--6. Indique quien es el vendedor con mas ventas realizadas.

select v.Id_vendedor,count (*)
from Vendedor ve
JOIN venta v ON 
v.Id_vendedor = ve.Id_vendedor
group by v.Id_vendedor
having count (*) = (
						select MAX(Maximo)
						FROM (
									select count(*)Maximo
									from Vendedor ve
									JOIN venta v ON 
									v.Id_vendedor = ve.Id_vendedor
									group by v.Id_vendedor
							)venMax
					)

--7. Indique todos los productos de lo que se hayan vendido más de 15.000 unidades.

select *
from Producto PR
where   NOT EXISTS (
					SELECT 1
					FROM venta	VE
					WHERE NOT EXISTS (
										SELECT 1
										FROM Detalle_venta V
										WHERE PR.Id_producto = V.Id_producto
										AND VE.Nro_factura = V.Nro_factura
										and v.Cantidad > 15.000
										)
				)

				SELECT *
				from Detalle_venta


--8. Indique quien es el vendedor con mayor volumen de ventas.