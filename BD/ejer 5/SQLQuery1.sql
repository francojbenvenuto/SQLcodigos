/*
Pel�cula (CodPel, T�tulo, Duraci�n, A�o, CodRubro)
Rubro    (CodRubro, NombRubro)

Ejemplar (CodEj, CodPel, Estado, Ubicaci�n) 
          Estado: Libre, Ocupado
Cliente  (CodCli, Nombre, Apellido, Direccion, Tel, Email)
Pr�stamo (CodPrest, CodEj, CodPel, CodCli, FechaPrest, FechaDev)

*/


USE EJERCICIO_5

 --1  listar los clientes que no hayan reportado prestamos del rubro "Policial"


select distinct pr.CodCli 
from [dbo].[Prestamo] PR
where PR.CodCli not in
						(
							SELECT distinct PR.CodCli
							from [dbo].[Prestamo] PR
							JOIN [dbo].[Pelicula] PE
							ON PR.CodPel = PE.CodPel
							JOIN [dbo].[Rubro] RU
							on RU.CodRubro = pe.CodRubro
							WHERE RU.NombRubro = 'Policial'
						)

--2. Listar las pel�culas de mayor duraci�n que alguna vez fueron prestadas.

select *
from [dbo].[Pelicula] PE
join [dbo].[Prestamo] PR 
ON pe.CodPel = pr.CodPel
where PE.Duracion = 
					(
					select MAX([Duracion])
					from [dbo].[Pelicula] PE
					join [dbo].[Prestamo] PR 
					ON pe.CodPel = pr.CodPel
					)


--3. Listar los clientes que tienen m�s de un pr�stamo sobre la misma pel�cula (listar Cliente, Pel�cula y cantidad de pr�stamos).

select [CodCli],[CodPel], COUNT(*) as [n prestamos]
from Prestamo PR
group by [CodCli],[CodPel]
having COUNT(*) <> 1

--4. Listar los clientes que han realizado pr�stamos del t�tulo �Rey Le�n� y �Terminador 3� (Ambos).

select pr.CodCli
from [dbo].[Prestamo] PR
JOIN [dbo].[Pelicula] PE 
 ON PR.CodPel = PE.CodPel
where PE.Titulo like 'Rey Le�n'
intersect
select pr.CodCli
from [dbo].[Prestamo] PR
JOIN [dbo].[Pelicula] PE 
 ON PR.CodPel = PE.CodPel
where PE.Titulo like 'Terminador 3'

--5. Listar las pel�culas m�s vistas en cada mes (Mes, Pel�cula, Cantidad de Alquileres).
--NO LO ENTENDI BIEN

SELECT month([FechaPrest]) as [mes],[CodPel], count(*)as[cantidad de veces]
from [dbo].[Prestamo] pr
group by month([FechaPrest]),[CodPel]
having COUNT(*) = (SELECT MAX(Valor) 
					FROM(
							
							SELECT month([FechaPrest])MES ,[CodPel], count(*)Valor
							from  [dbo].[Prestamo] pr1
							WHERE month(pr.[FechaPrest]) = month(pr1.[FechaPrest])
							group by month([FechaPrest]),[CodPel]
							) MAXI
							)
order by 1



--6. Listar los clientes que hayan alquilado todas las pel�culas del video.

select CodCli
from [dbo].[Prestamo]
group by [CodCli]
HAVING COUNT ( DISTINCT [CodPel]) = (

SELECT COUNT(*)
from [dbo].[Pelicula]
)

--7. Listar las pel�culas que no han registrado ning�n pr�stamo a la fecha.

SELECT [CodPel]
FROM [dbo].[Pelicula]

except

select [CodPel]
from [dbo].[Prestamo]


--8. Listar los clientes que no han efectuado la devoluci�n de ejemplares.

select cl.CodCli ,cl.Apellido
from Prestamo pr
join [dbo].[Cliente] cl 
	on cl.CodCli = pr.CodCli
where pr.FechaDev is NULl

--9. Listar los t�tulos de las pel�culas que tienen la mayor cantidad de pr�stamos.

select CodPel
from [dbo].[Prestamo]
group by CodPel
having count (*) = (

-- esto es para tener el numero maximo de prestamos
SELECT MAX(MAXIMO)
FROM (
		select CodPel, COUNT (*)MAXIMO
		from [dbo].[Prestamo]
		group by CodPel
		) PelMax
)
--10. Listar las pel�culas que tienen todos los ejemplares prestados.select [CodPel]from Ejemplar egroup by [CodPel]having count (*) = (						select COUNT (DISTINCT CodEj)						from [dbo].[Prestamo] pr						where pr.CodPel = e.CodPel						and pr.FechaDev is null					)