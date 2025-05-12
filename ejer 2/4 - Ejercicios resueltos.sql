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
SELECT *
FROM Proveedor;

--0.1. Liste los proveedores de la ciudad San Justo
SELECT *
FROM Proveedor
WHERE CiudadProv like 'san justo'

--0.2. Liste los proveedores de Laferrere y de categoria 'cat2'
SELECT *
FROM Proveedor
WHERE CiudadProv like 'Laferrere'
AND Categoria like 'cat2'

--0.3. Liste los proveedores de San Justo o de categoria 'cat4'
SELECT *
FROM Proveedor
WHERE CiudadProv like 'San Justo'
OR Categoria like 'cat4'

--1.	Hallar el código (nroProv) de los proveedores que proveen el artículo a146.
SELECT distinct NroProv
FROM Articulo a, pedido p
WHERE a.NroArt = p.NroArt
AND Descripcion = 'a146'

-- mas info!
SELECT distinct pr.NroProv, pr.NomProv
FROM Articulo a, pedido p, Proveedor pr
WHERE Descripcion = 'a146'
AND a.NroArt = p.NroArt
AND P.NroProv = pr.NroProv

-- con juntas!
SELECT distinct pr.NroProv, pr.NomProv
FROM Articulo a JOIN pedido p ON a.NroArt = p.NroArt
JOIN Proveedor pr ON P.NroProv = pr.NroProv
WHERE Descripcion = 'a146'

--2.	Hallar los clientes (nomCli) que solicitan artículos provistos por p015.

SELECT distinct pe.NroCli, c.NomCli
FROM Proveedor p JOIN pedido pe ON P.NroProv = pe.NroProv
JOIN Cliente c ON c.NroCli = pe.NroCli
WHERE NomProv LIKE 'p015'

--3.	Hallar los clientes que solicitan algún item provisto por proveedores 
--      con categoría mayor que 4.

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

-- clientes de Rosario
SELECT * FROM Cliente WHERE CiudadCli like 'Rosario'

-- articulos producidos en mendoza?
SELECT * FROM Articulo WHERE CiudadArt like 'Mendoza'

-- Junto ambas QUERIES
SELECT DISTINCT NroCli
FROM Pedido 
WHERE NroCli IN (SELECT NroCli FROM Cliente WHERE CiudadCli like 'Rosario')
AND NroArt IN (SELECT NroArt FROM Articulo WHERE CiudadArt like 'Mendoza')


--5.	Hallar los pedidos en los que el cliente c23 solicita artículos solicitados 
--      por el cliente c30.

SELECT P1.NroPed, P1.NroArt
FROM Pedido p1 JOIN Cliente c ON P1.NroCli = C.NroCli 
WHERE NomCli LIKE 'C23'
AND p1.NroArt IN (
				SELECT P1.NroArt
				FROM Pedido p1 JOIN Cliente c ON P1.NroCli = C.NroCli 
				WHERE NomCli LIKE 'C30'
				)

-- OTRA FORMA DE RESOLVER LO MISMO

SELECT P.NroPed 
FROM Pedido p 
	JOIN cliente c ON p.NroCli = c.NroCli
	JOIN pedido p2 ON p.NroArt = p2.NroArt
	JOIN cliente c2 ON C2.NroCli = P2.NroCli
WHERE c.NomCli like 'c23'
AND  c2.NomCli like 'c30'

--6.0  Hallar los proveedores que suministran todos los artículos
--1ro contar articulos
SELECT COUNT (*) AS [CANT TOTAL DE ART] FROM Articulo
--2do contar cuantos art provee cada prov.
SELECT NroProv, count(distinct NroArt) FROM Pedido GROUP BY NroProv

-- uso ambas queries
SELECT NroProv, count(distinct NroArt) 
FROM Pedido 
GROUP BY NroProv
HAVING count(distinct NroArt) = (SELECT COUNT (*) FROM Articulo)

--6.1 Hallar los proveedores que suministran todos los artículos cuyo precio es superior 
--      al precio promedio de todos los art.

-- QUE CAMBIA RESPECTO DE LA QUERY 6.0? QUE EL TODOS, AHORA ES UN CONJUNTO MENOR

-- ESTOS SON LOS articulos que cumplen con precio > promedio
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

--6.2	Hallar los proveedores que suministran todos los artículos cuyo precio es superior 
--      al precio promedio de los artículos que se producen en La Plata.

-- art precio superior al promedio y producios en la plata
SELECT *
FROM Articulo 
WHERE PRECIO > (
				SELECT AVG(PRECIO) FROM Articulo where CiudadArt = 'LA plata'
				)

-- hago el cociente

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
		WHERE PRECIO > (SELECT AVG(PRECIO) FROM Articulo where CiudadArt = 'La Plata')
	) AS a
	EXCEPT 
	SELECT pe.NroProv, pe.NroArt
	FROM Pedido pe
) as noCumplen

--7.	Hallar la cantidad de artículos diferentes provistos por cada proveedor que provee a todos los clientes de Junín.

-- todos los clientes de junin
SELECT COUNT (NroCli)
FROM CLIENTE 
WHERE CiudadCli like 'Jun_n'

-- prov que prov a todos los clientes de junin
SELECT NroProv, COUNT(DISTINCT C.NROCLI) AS [Cant de clientes]
FROM PEDIDO p JOIN Cliente c ON p.NroCli = c.NroCli
WHERE CiudadCli like 'Jun_n'
GROUP BY NroProv
HAVING COUNT(DISTINCT C.NROCLI)  = (
									SELECT COUNT (NroCli)
									FROM CLIENTE 
									WHERE CiudadCli like 'Jun_n'
									)
order by NroProv

-- todos los articulos dif que prov. los prov.
SELECT DISTINCT NroProv, NroArt
FROM pedido
ORDER BY NroProv

--Hallar la cantidad de artículos diferentes provistos por cada proveedor que provee a todos los clientes de Junín.


SELECT T.*, A.NroArt
FROM 
	(
	SELECT NroProv, COUNT(DISTINCT C.NROCLI) AS [Cant de clientes]
	FROM PEDIDO p JOIN Cliente c ON p.NroCli = c.NroCli
	WHERE CiudadCli like 'Jun_n'
	GROUP BY NroProv
	HAVING COUNT(DISTINCT C.NROCLI)  = (
										SELECT COUNT (NroCli)
										FROM CLIENTE 
										WHERE CiudadCli like 'Jun_n'
										)
	) AS T 
	JOIN 
	(
	SELECT DISTINCT NroProv, NroArt
	FROM pedido
	) AS A
	ON T.NroProv = A.NroProv

order by T.NroProv


--8.	Hallar los nombres de los proveedores cuya categoría sea mayor que la de todos los 
--      proveedores que proveen el artículo cuaderno.



-- PROV CON LA CATEGORIA MAYOR

SELECT *
FROM Proveedor
WHERE Categoria = (
					SELECT  MAX(categoria) as maxCategoria
					FROM Proveedor
				  )
ORDER BY NroProv

-- PROVE DE ART CUADERNO

SELECT distinct p.NroProv
FROM Articulo a 
JOIN Pedido p ON a.NroArt = p.NroArt
WHERE Descripcion like '%cuaderno%' -- cuaderno tapa dura | cuaderno espiralado | nuevo cuaderno. Cordoba Córdoba 

-- categoria de los prov de cuadernos
SELECT distinct p.NroProv, pr.Categoria
FROM Articulo a 
JOIN Pedido p ON a.NroArt = p.NroArt
JOIN Proveedor pr ON p.NroProv = pr.NroProv
WHERE Descripcion like '%cuaderno%' -- cuaderno tapa dura | cuaderno espiralado | nuevo cuaderno. Cordoba Córdoba 

-- max categoria de los prov de cuadernos

SELECT MAX (pr.Categoria) [max Categoria De Prov De Cuadernos]
FROM Articulo a 
JOIN Pedido p ON a.NroArt = p.NroArt
JOIN Proveedor pr ON p.NroProv = pr.NroProv
WHERE Descripcion like '%cuaderno%' -- cuaderno tapa dura | cuaderno espiralado | nuevo cuaderno. Cordoba Córdoba 


-- Hallar los nombres de los proveedores cuya categoría sea mayor que la de todos los proveedores que proveen el artículo cuaderno.

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

SELECT NroProv, SUM(cantidad) AS [cantidad total art 1 y 100]
FROM Pedido
WHERE NroArt IN (1, 100)
GROUP BY NroProv
HAVING SUM(cantidad) > 1000
ORDER BY NroProv

----
-- otra forma de ver la misma info

SELECT p1.NroProv, 
		ISNULL(p1.totalP1, 0) as total1, 
		ISNULL(P100.totalP100, 0) as total100, 
		ISNULL(p1.totalP1, 0) + ISNULL(P100.totalP100, 0) as [total = p1 + p100]
FROM 
	(
	SELECT NroProv, SUM(cantidad) AS totalP1
	FROM Pedido  
	WHERE NroArt = 1
	GROUP BY NroProv
	) AS P1
FULL JOIN 
	(
	SELECT NroProv, SUM(cantidad) AS totalP100
	FROM Pedido  
	WHERE NroArt = 100
	GROUP BY NroProv
	) AS P100
ON p1.NroProv = p100.NroProv

	 
--10.	Listar la cantidad y el precio total de cada artículo que han pedido los Clientes 
--a sus proveedores entre las fechas 01-01-2004 y 31-03-2004
-- (se requiere visualizar Cliente, Articulo, Proveedor, Cantidad y Precio).

SELECT pe.NroCli, pe.nroArt, sum(pe.cantidad) cantidad, sum(pe.precioTotal) precio
FROM pedido pe
GROUP BY pe.NroCli, pe.NroArt 

--11.	Idem anterior y que además la Cantidad sea mayor o igual a 1000 o el Precio sea mayor a $1000

SELECT pe.NroCli, pe.nroArt, sum(pe.cantidad) cantidad, sum(pe.precioTotal) precio
FROM pedido pe
GROUP BY pe.NroCli, pe.NroArt 
HAVING sum(pe.cantidad) >= 1000 OR sum(pe.precioTotal) > 1000

--12.	Listar la descripción de los artículos en donde se hayan pedido en el día más del 
--      stock existente para ese mismo día.

SELECT *
FROM 
	(
	SELECT pe.NroArt, cast(pe.fechaPEdido as date) as dia, sum(pe.cantidad) as cantidadPedido
	FROM pedido pe 
	GROUP BY pe.NroArt, cast(pe.fechaPEdido as date) 
	) AS T
	JOIN Articulo a ON t.NroArt = a.NroArt
	LEFT JOIN Stock s ON a.NroArt = s.NroArt AND T.dia = S.fecha
WHERE s.cantidad < t.cantidadPedido


--13.	Listar los datos de los proveedores que hayan pedido de todos los artículos en un mismo día. 
--      Verificar sólo en el último mes de pedidos.

--13.1 Listar los datos de los proveedores que hayan pedido de todos los artículos
SELECT *
FROM Proveedor p
WHERE NOT EXISTS 
	(
	SELECT *
	FROM Articulo A
	WHERE NOT EXISTS
		(
		SELECT * 
		FROM Pedido PE
		WHERE p.NroProv = pe.NroProv AND a.NroArt = pe.NroArt
		)
	)

--13.2 Listar los datos de los proveedores que hayan pedido de todos los artículos en un mismo día.
SELECT PE.NroProv, cast(pe.fechaPEdido as date), COUNT(DISTINCT nroArt)
FROM PEDIDO PE
GROUP BY pe.NroProv, cast(pe.fechaPEdido as date) 
HAVING COUNT(DISTINCT pe.nroArt) = (SELECT COUNT(*) FROM Articulo)


--13.3 query completa
SELECT PE.NroProv, cast(pe.fechaPEdido as date), COUNT(DISTINCT nroArt)
FROM PEDIDO PE
WHERE datediff(month, pe.fechapedido, getdate()) = 0
GROUP BY pe.NroProv, cast(pe.fechaPEdido as date) 
HAVING COUNT(DISTINCT pe.nroArt) = (SELECT COUNT(*) FROM Articulo)


--14.	Listar los proveedores a los cuales no se les haya solicitado ningún artículo en el último mes, 
--      pero sí se les haya pedido en el mismo mes del año anterior.

SELECT p.nroProv
FROM Proveedor p
WHERE EXISTS 
(	SELECT pe.NroProv
	FROM Pedido pe
	WHERE year(pe.fechapedido) = year(DATEADD(YEAR, -1, GETDATE())) 
	and month(pe.fechapedido) = month(DATEADD(YEAR, -1, GETDATE()))
	AND p.NroProv = pe.NroProv
)
EXCEPT 
SELECT pe.NroProv
FROM Pedido pe
WHERE year(pe.fechapedido) = year(getdate()) and month(pe.fechapedido) = month(getdate())


/*
Proveedor (NroProv, NomProv, Categoria, CiudadProv)
Artículo  (NroArt, Descripción, CiudadArt, Precio)
Cliente   (NroCli, NomCli, CiudadCli)
Pedido    (NroPed, NroArt, NroCli, NroProv, FechaPedido, Cantidad, PrecioTotal)
Stock     (NroArt, fecha, cantidad)
*/


-- TRABAJO CON FECHAS
SELECT GETDATE() [FECHA HOY], DATEADD(MONTH, -1, GETDATE()) [ UN MES PARA ATRAS], YEAR(GETDATE()) [Año], MONTH(GETDATE()) [MES], DAY(GETDATE()) [DIA]

-- prov que tuvieron pedidos durante el ultimo mes
SELECT *
FROM Pedido p
WHERE p.FechaPedido >= DATEADD(MONTH, -1, GETDATE()) AND p.FechaPedido <= GETDATE()

-- prov que NO tuvieron pedidos durante el ultimo mes
SELECT *
FROM Proveedor PR
WHERE NOT EXISTS 
				(
				SELECT *
				FROM Pedido p
				WHERE p.FechaPedido >= DATEADD(MONTH, -1, GETDATE()) AND p.FechaPedido <= GETDATE()
				AND p.NroProv = pr.NroProv
				)


-- FECHAS DEL AÑO PASADO
SELECT DATEADD(YEAR ,-1, DATEADD(MONTH, -1, GETDATE())) ,  DATEADD(YEAR, -1, GETDATE())

-- prov que SI tuvieron pedidos durante el ultimo mes, pero del año anterior
SELECT *
FROM Pedido p
WHERE p.FechaPedido >= DATEADD(YEAR ,-1, DATEADD(MONTH, -1, GETDATE())) AND p.FechaPedido <= DATEADD(YEAR, -1, GETDATE())


--Listar los proveedores a los cuales no se les haya solicitado ningún artículo en el último mes, pero sí se les haya pedido en el mismo mes del año anterior.

SELECT pr.NroProv
FROM Proveedor PR
WHERE NOT EXISTS 
				(
				SELECT *
				FROM Pedido p
				WHERE p.FechaPedido >= DATEADD(MONTH, -1, GETDATE()) AND p.FechaPedido <= GETDATE()
				AND p.NroProv = pr.NroProv
				)
INTERSECT -- INTERSECT | UNION | UNION ALL | MINUS | SUBSTRACT 

SELECT NroProv
FROM Pedido p
WHERE p.FechaPedido >= DATEADD(YEAR ,-1, DATEADD(MONTH, -1, GETDATE())) AND p.FechaPedido <= DATEADD(YEAR, -1, GETDATE())


--datediff -- muestra diferencia entre dos fechas
--dateadd -- agregar o substrae respecto de una fecha. puedo agregarle a una fecha dada, X segundos o Y minutos, o Z dias, etc 
--getdate -- | now  retorna la fecha de hoy

--15.	Listar los nombres de los clientes que hayan solicitado más de un artículo cuyo precio sea superior a $100
--y que correspondan a proveedores de Capital Federal. Por ejemplo, se considerará si se ha solicitado el artículo a2 y a3, 
--pero no si solicitaron 5 unidades del articulo a2.
 






