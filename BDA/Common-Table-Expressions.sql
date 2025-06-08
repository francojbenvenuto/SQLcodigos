Use pruebasDB
go

-- Ejemplo tranqui... serie de Fibonacci con recursividad
WITH Fibonacci (PrevN, N) AS
(
     SELECT 0, 1
     UNION ALL
     SELECT N, PrevN + N
     FROM Fibonacci
     WHERE N < 100
)
SELECT PrevN as Fibo
     FROM Fibonacci
     OPTION (MAXRECURSION 0);


-- Generemos registros de notas de examen de un par de alumnos

IF OBJECT_ID(N'ddbba.Nota', N'U') IS NOT NULL  
   DROP TABLE ddbba.Nota;  
GO

-- o mas simple
--DROP TABLE IF EXISTS ddbba.nota;

create table ddbba.Nota
(
	id int identity(1,1) primary key ,
	materia	char(20),
	alumno	char(20),
	nota	tinyint
	)
go

-- suprimo los mensajes de "registro insertado'
set nocount on
-- Generemos algunos valores al azar
declare @contador int
	,@limiteSuperior int
	,@limiteInferior int
-- Inicializo valores y limites
set @contador = 0
set @limiteInferior = 3
set @limiteSuperior = 10
-- Las ciudades las hardcodié. Genero otro random y lo convierto
while @contador < 100
begin	
	insert ddbba.Nota (materia, alumno, nota)
		select 
			case Cast(RAND()*(3-1)+1 as int)
				when 1 then 'Filologia'
				when 2 then 'Hermenéutica'
				else  'Reposteria'
				end ,
			case Cast(RAND()*(5-1)+1 as int)
				when 1 then 'Juan Bochazo'
				when 2 then 'Carlos Obresaliente'
				when 3 then 'Jose Raspanding'
				when 4 then 'Eugenia Losetodo'
				else  'Lola Mento'
				end ,
				Cast(RAND()*(@limiteSuperior-@limiteInferior)+@limiteInferior as int)
	set @contador = @contador + 1
	print 'Generado el registro nro ' + cast(@contador as varchar)
end
-- le damos una mirada
select top 20 * from ddbba.nota


-- Combinemos un poco
-- Quiero ver el 20% superior de promedios
select materia, alumno, promedio, EscalaNotas
From (
select materia, alumno, promedio, ntile(4) OVER (partition by materia order by promedio desc) as EscalaNotas
from	(select alumno, materia, avg(nota) Promedio
	from	ddbba.nota
	group by alumno,materia) promedios
	) A
Where	EscalaNotas = 4

--y lo mismo con notacion CTE:
with NotasEscaladas (materia, alumno, promedio, escala) as
(	select materia, alumno, promedio, ntile(4) OVER (partition by materia order by promedio desc) as EscalaNotas

	from	(select alumno, materia, avg(nota) Promedio
			 from	ddbba.nota
			 group by alumno,materia) promedios
)
select * from NotasEscaladas where escala=4;

-- Habra duplicados en nuestro registro de notas?
WITH CTE(alumno, nota, materia,duplicadas)
AS (SELECT	alumno, nota, materia, ROW_NUMBER() OVER(PARTITION BY alumno, nota, materia ORDER BY id) AS duplicadas
    FROM ddbba.nota)
SELECT  *
FROM CTE
WHERE duplicadas>1;

-- y si no hubiera un campo ID unico?
alter table ddbba.nota
	drop column id;
-- Hay una restriccion, no se puede borrar!
-- ¿y como se llama esa constraint?

-- Ver el nombre de la constraint PK generado automaticamente  
SELECT name  
FROM sys.key_constraints  
WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = N'nota';  
GO  
-- Eliminar la constraint de PK 
-- SUGERENCIA: probar SIN LOS CORCHETES 
ALTER TABLE ddbba.nota  
DROP CONSTRAINT PK__Nota__3213E83F9276ABC7;   
GO
-- Recien ahora puedo borrar el campo ID
alter table ddbba.nota
drop column id;

-- ahora veamos como manejar las duplicadas 
-- incluso sin un ID unico
WITH CTE(alumno, nota, materia, Ocurrencias)
AS (SELECT	alumno, nota,materia,
           ROW_NUMBER() OVER( PARTITION BY alumno, nota, materia ORDER BY alumno, nota, materia) AS AcaPuedoPonerCualquierCosa
    FROM ddbba.nota)
SELECT *
FROM CTE
WHERE Ocurrencias>1;

-- Esto funcionará asi?
delete 
from CTE
where Ocurrencias > 1;

-- Tenemos que definir el CTE nuevamente!
WITH CTE(alumno, nota, materia, 
    Ocurrencias)
AS (SELECT	alumno, 
			nota, 
			materia,
           ROW_NUMBER() OVER(
				PARTITION BY alumno, nota, materia
				ORDER BY alumno, nota, materia
		   ) AS Ocurrencias
    FROM ddbba.nota)
delete 
from CTE
where Ocurrencias > 1;


/*
	Un ejemplo mas de CTE en acción
	Quiero los promedios por materia, cada materia en una columna
	Observe que las subconsultas se interpretan de forma más simple
*/

with FilosogiaProm (alumno, promedio)as
		(select alumno, avg(nota) promedio
		from ddbba.Nota
		where materia = 'Filologia'
		group by alumno

















with NotasFilologia (alumno, promedio)
as
	(select alumno, avg(nota) promedio
	from ddbba.nota 
	where materia='Filologia'
	group by alumno)
,
NotasHermeneutica (alumno, promedio)
as
	(select alumno, avg(nota) promedio
	from ddbba.nota 
	where materia='Hermenéutica'
	group by alumno)
,
NotasReposteria (alumno, promedio)
as
	(select alumno, avg(nota) promedio
	from ddbba.nota 
	where materia='Reposteria'
	group by alumno)
-- Al hacer join por alumno hay filas repetidas porque se dan coincidencias
-- multiples en el producto cartesiano
select	distinct N.alumno, NF.promedio as Filologia, NH.promedio as Hermeneutica, NR.promedio as Reposteria
from	ddbba.nota N 
			left join NotasFilologia NF on N.alumno = NF.alumno
			left join NotasHermeneutica NH on N.alumno = NH.alumno
			left join NotasReposteria NR on N.alumno = NR.alumno
order by	N.alumno