-- 0. SETEO DE DB
USE EJERCICIO_2
GO
/*
Proveedor (NroProv, NomProv, Categoria, CiudadProv)
Artículo  (NroArt, Descripción, CiudadArt, Precio)
Cliente   (NroCli, NomCli, CiudadCli)
Pedido    (NroPed, NroArt, NroCli, NroProv, FechaPedido, Cantidad, PrecioTotal)
Stock     (NroArt, fecha, cantidad)
*/
--0. Liste todos los proveedores
select *
from Proveedor;
--0.1. Liste los proveedores de la ciudad San Justo

select *
from Proveedor
where CiudadProv like 'San Justo';

--0.2. Liste los proveedores de Laferrere y de categoria 'cat2'
select *
from Proveedor
where CiudadProv like 'Laferrere' 
and Categoria like 'cat2' ;


--0.3. Liste los proveedores de San Justo o de categoria 'cat4'
select *
from Proveedor
where CiudadProv like 'San Justo'
or Categoria like 'cat4' ;


--1.	Hallar el código (nroProv) de los proveedores que proveen el artículo a146.
	
	select distinct nroProv
	from Articulo a, Pedido p
	where a.Descripcion = 'a146'
	and a.NroArt = p.NroArt;


	--vista

	create view V_ARTICULOS
	AS
	select distinct nroProv
	from Articulo a, Pedido p
	where a.Descripcion = 'a146'
	and a.NroArt = p.NroArt;

	-- EJECUCION

	select * from V_ARTICULOS

	-- MODIFICAR
	SELECT * from Pedido p
	JOIN Articulo A
	On p.NroArt = a.NroArt
	where a.Descripcion = 'Art3'
	
	alter view V_ARTICULOS
	AS
	SELECT distinct p.NroProv
	from Pedido p
	JOIN Articulo A
	On p.NroArt = a.NroArt
	where a.Descripcion = 'Art3'

	select * from V_ARTICULOS

	--eliminar

	drop view V_ARTICULOS

--2.	Hallar los clientes (nomCli) que solicitan artículos provistos por p015.

	SELECT distinct p.NroCli,cl.NomCli 
	from Pedido p
	JOIn Cliente cl on cl.NroCli = p.NroCli
	JOIN Proveedor pr on pr.NroProv = p.NroProv
	where pr.NomProv like 'p015';


--3.	Hallar los clientes que solicitan algún item provisto por proveedores 
--      con categoría mayor que 4.

select distinct cl.NomCli, cl.NroCli
from Pedido pe
JOIN cliente cl on cl.NroCli = pe.NroCli
JOIN Proveedor pr on pr.NroProv = pe.NroProv
where pr.Categoria > 4;

SELECT distinct c.*
FROM Pedido pe JOIN Cliente c ON pe.NroCli = c.NroCli
WHERE pe.NroProv IN 
	(
	SELECT P.NroProv
	FROM Proveedor P
	WHERE Categoria > 4
)

--4.	Hallar los pedidos en los que un cliente de Rosario solicita artículos 
--      producidos en la ciudad de Mendoza.

select distinct pe.NroCli
from Pedido pe
JOIN cliente cl on cl.NroCli = pe.NroCli
JOIN Articulo ar on ar.NroArt = pe.NroArt
where cl.CiudadCli like 'Rosario'
or ar.CiudadArt like 'Mendoza'

SELECT DISTINCT NroCli
FROM Pedido 
WHERE NroCli IN (SELECT NroCli FROM Cliente WHERE CiudadCli like 'Rosario')
AND NroArt IN (SELECT NroArt FROM Articulo WHERE CiudadArt like 'Mendoza')



--5.	Hallar los pedidos en los que el cliente c23 solicita artículos solicitados 
--      por el cliente c30.

select NroPed
from Pedido p
join cliente cl on p.NroCli = cl.NroCli
where cl.NomCli like 'c23'
and p.NroCli in (
					select p.NroArt
					from Pedido p
					join cliente cl on p.NroCli = cl.NroCli
					where cl.NomCli like 'c30'
				)

--6.0  Hallar los proveedores que suministran todos los artículos
--ayuda:
--1ro contar articulos
--2do contar cuantos art provee cada prov.
-- usar ambas queries

select count(*)
from Articulo

select pe.NroProv,count(distinct pe.NroArt) articulos
from [dbo].[Pedido] PE
group by pe.NroProv
having count(distinct NroArt) = (SELECT COUNT (*) FROM Articulo)


--6.1 Hallar los proveedores que suministran todos los artículos cuyo precio es superior 
--      al precio promedio de todos los art.

SELECT *
FROM Articulo 
WHERE PRECIO > (
				SELECT AVG(PRECIO) FROM Articulo
				)

SELECT NroProv
FROM Proveedor

EXCEPT

SELECT noCumplen.nroProv
FROM
	(
		SELECT p.NroProv, a.NroArt
		FROM Proveedor p, 
			(
				SELECT *
				FROM Articulo 
				WHERE PRECIO > (SELECT AVG(PRECIO) FROM Articulo)
			) AS a

		EXCEPT 

		SELECT pe.NroProv, pe.NroArt
		FROM Pedido pe

	) as noCumplen

-- QUE CAMBIA RESPECTO DE LA QUERY 6.0? QUE EL TODOS, AHORA ES UN CONJUNTO MENOR

--6.2	Hallar los proveedores que suministran todos los artículos cuyo precio es superior 
--      al precio promedio de los artículos que se producen en La Plata.

-- AYUDA: 1ro art precio superior al promedio y producios en la plata
-- luego hago el cociente

--7.	Hallar la cantidad de artículos diferentes provistos por cada proveedor que provee a todos los clientes de Junín.


select distinct  pe.NroProv
from [dbo].[Pedido] pe
JOIN Cliente c on
c.NroCli = pe.NroCli
where c.CiudadCli like 'Junín'
group by  pe.NroProv
HAVING COUNT(DISTINCT C.NROCLI)  = (
									SELECT COUNT (NroCli)
									FROM CLIENTE 
									WHERE CiudadCli like 'Jun_n'
									)




--7.1 Hallar la cantidad de artículos diferentes provistos por cada proveedor que provee a todos los clientes de Junín.

--8.	Hallar los nombres de los proveedores cuya categoría sea mayor que la de todos los 
--      proveedores que proveen el artículo cuaderno.


--AYUDA:
-- LISTAR PROV CON LA CATEGORIA MAYOR
-- LISTAR PROVEE DE ART CUADERNO
-- LISTAR categoria de los prov de cuadernos
-- BUSCAR max categoria de los prov de cuadernos

SELECT * 
FROM proveedor 
WHERE categoria >
		(
		SELECT MAX (pr.Categoria) [max Categoria De Prov De Cuadernos]
		FROM Articulo a 
		JOIN Pedido p ON a.NroArt = p.NroArt
		JOIN Proveedor pr ON p.NroProv = pr.NroProv
		WHERE Descripcion like '%cuaderno%' -- cuaderno tapa dura | cuaderno espiralado | nuevo cuaderno. Cordoba Córdoba 
		)
ORDER BY NomProv


--9.	Hallar los proveedores que han provisto más de 1000 unidades entre los artículos 1 y 100 .

SELECT *
FROM [dbo].[Articulo]
WHERE [Descripcion] BETWEEN  'A001' AND 'A100'


select pr.*
from Pedido p
JOIN Proveedor pr 
ON pr.NroProv = p.NroProv

select pr.NomProv, SUM(p.Cantidad) as [cantidad de ventas]
from Pedido p
JOIN Proveedor pr ON pr.NroProv = p.NroProv
JOIN articulo a   ON a.NroArt = p.NroArt
WHERE a.[Descripcion] BETWEEN  'A001' AND 'A100'
group by pr.NomProv
HAVING SUM(P.cantidad) > 1000
			
		
--10.	Listar la cantidad y el precio total de cada artículo que han pedido los Clientes 
--a sus proveedores entre las fechas 01-01-2004 y 31-03-2004
-- (se requiere visualizar Cliente, Articulo, Proveedor, Cantidad y Precio).


--11.	Idem anterior y que además la Cantidad sea mayor o igual a 1000 o el Precio sea mayor a $1000


--12.	Listar la descripción de los artículos en donde se hayan pedido en el día más del 
--      stock existente para ese mismo día.

--13.	Listar los datos de los proveedores que hayan pedido de todos los artículos en un mismo día. 
--      Verificar sólo en el último mes de pedidos.

--13.1 Listar los datos de los proveedores que hayan pedido de todos los artículos

--13.2 Listar los datos de los proveedores que hayan pedido de todos los artículos en un mismo día.


--14.	Listar los proveedores a los cuales no se les haya solicitado ningún artículo en el último mes, 
--      pero sí se les haya pedido en el mismo mes del año anterior.

/*
Proveedor (NroProv, NomProv, Categoria, CiudadProv)
Artículo  (NroArt, Descripción, CiudadArt, Precio)
Cliente   (NroCli, NomCli, CiudadCli)
Pedido    (NroPed, NroArt, NroCli, NroProv, FechaPedido, Cantidad, PrecioTotal)
Stock     (NroArt, fecha, cantidad)
*/


-- TRABAJO CON FECHAS
SELECT GETDATE() [FECHA HOY], DATEADD(MONTH, -1, GETDATE()) [ UN MES PARA ATRAS], YEAR(GETDATE()) [Año], MONTH(GETDATE()) [MES], DAY(GETDATE()) [DIA]
-- FECHAS DEL AÑO PASADO
SELECT DATEADD(YEAR ,-1, DATEADD(MONTH, -1, GETDATE())) ,  DATEADD(YEAR, -1, GETDATE())
--datediff -- muestra diferencia entre dos fechas
--dateadd -- agregar o substrae respecto de una fecha. puedo agregarle a una fecha dada, X segundos o Y minutos, o Z dias, etc 
--getdate -- | now  retorna la fecha de hoy

-- prov que tuvieron pedidos durante el ultimo mes
-- prov que NO tuvieron pedidos durante el ultimo mes


-- prov que SI tuvieron pedidos durante el ultimo mes, pero del año anterior

--Listar los proveedores a los cuales no se les haya solicitado ningún artículo en el último mes, pero sí se les haya pedido en el mismo mes del año anterior.

--15.	Listar los nombres de los clientes que hayan solicitado más de un artículo cuyo precio sea superior a $100
--y que correspondan a proveedores de Capital Federal. Por ejemplo, se considerará si se ha solicitado el artículo a2 y a3, 
--pero no si solicitaron 5 unidades del articulo a2.
 