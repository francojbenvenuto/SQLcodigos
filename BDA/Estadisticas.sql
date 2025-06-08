/*
Veamos un detalle de las estadisticas

Encabezado: información general de un conjunto de estadísticas dado.
Grafo de densidad: Selectividad, singularidad (uniqueness) de los datos.
Histograma: Cuenta tabulada de las ocurrencias de valores particulares de hasta 200 puntos elegidos por representar toda la tabla.

https://learn.microsoft.com/en-us/sql/t-sql/statements/update-statistics-transact-sql?view=sql-server-ver16
Dataset:
https://archive.org/details/stackexchange
*/

SELECT OBJECT_NAME(s.object_id) AS object_name,
    COL_NAME(sc.object_id, sc.column_id) AS column_name,
    s.name AS statistics_name
FROM sys.stats AS s
INNER JOIN sys.stats_columns AS sc
    ON s.stats_id = sc.stats_id AND s.object_id = sc.object_id
--WHERE s.name like '_WA%' or s.name like 'UK_%' or s.name like 'UQ_%' or s.name like 'PK_%'
ORDER BY s.name;


/*
Como actualizar las estadisticas
*/
-- Primer variante: asi puedo actualizar todas las DB en una sola ejecucion:
sp_MSforeachdb 'use [?]; exec sp_updatestats'

-- Variante: solo las DB de usuario (exceptuamos las de sistema)
DECLARE @TSQL nvarchar(2000)
SET @TSQL = '
IF DB_ID(''?'') > 4
   USE [?]; exec sp_updatestats
'
EXEC sp_MSforeachdb @TSQL

-- Pero las operaciones de estadísticas pueden ir puntualmente a UN indice!

-- Puedo actualizar las estadisticas de un indice particular
-- Por ejemplo con un muestreo del 50%
use pruebasDB
go
create nonclustered index ix_Ciudad
	on ddbba.Venta(Ciudad)
go
UPDATE STATISTICS ddbba.venta(ix_Ciudad)
    WITH SAMPLE 50 PERCENT;

--También podemos actualizar para una tabla, por ejemplo con muestreo de toda la tabla:
UPDATE STATISTICS ddbba.Venta
--WITH FULLSCAN
    WITH SAMPLE 50 PERCENT;

-- ¿Podemos ver las estadisticas?
-- CLARO QUE PODEMOS!
-- Si hay un índice, hay una estadística asociada
DBCC SHOW_STATISTICS ("ddbba.venta", ix_Ciudad) WITH HISTOGRAM;

DBCC SHOW_STATISTICS ("ddbba.cliente",[ClientesPK]) WITH HISTOGRAM;

-- Cuando realizamos consultas en base a otros campos, también se generan
-- estadísticas en forma automática (si está habilitado con AUTO_CREATE_STATISTICS)

use StackOverflow2013
go
-- Si no hice consultas previamente, fallará (sino cambiar el campo)
DBCC SHOW_STATISTICS ("dbo.Users", Reputation)

-- Veamos cuanto estima y de donde obtiene eso:
select COUNT(1)
from dbo.Users
where Reputation=5
DBCC SHOW_STATISTICS ("dbo.Users", Reputation)
-- Ahora SI existe la estadistica!
-- observe el RANGE_EQ_ROWS
-- Observe cuantas filas estima leer para la reputacion=5
-- ¿Qué efecto tiene que estime muy errado (mas o menos)?
-- Observe la memoria reservada

-- ¿y si consultamos un valor que no es idéntico?
select COUNT(1)
from dbo.Users
where Reputation=9900
--option (recompile)
DBCC SHOW_STATISTICS ("dbo.Users", Reputation)
-- observe el AVG_RANGE_ROWS

/*
Steps: "pasos" del histograma
RANGE_HI_KEY: Valor mas alto del rango (incluye todos los valores desde el RANGE_HI_KEY anterior mas uno)
RANGE_ROWS: cantidad de filas en el rango (pero no de valor identico al RANGE_HI_KEY)
EQ_ROWS: filas del mismo valor que el RANGE_HI_KEY
DISTINCT_RANGE_ROWS: valores unicos en el rango dado
AVG_RANGE_ROWS: promedio de filas para cada valor distintivo

*/
select COUNT(1)
from dbo.Users
where Reputation=5480
-- y el valor de EQ_ROWS para RANGE_HI_KEY=5
DBCC SHOW_STATISTICS ("dbo.Users", Reputation)

-- Ahora actualicemos para que se haga muestreo de TODA la tabla
update statistics  dbo.users with fullscan
-- y veamos el histograma
DBCC SHOW_STATISTICS ("dbo.Users", Reputation)

-- Podemos consultas las estadisticas de una tabla puntual:
SELECT s.stats_id StatsID,
  s.name StatsName,
  sc.stats_column_id StatsColID,
  c.name ColumnName 
FROM sys.stats s 
  INNER JOIN sys.stats_columns sc
    ON s.object_id = sc.object_id AND s.stats_id = sc.stats_id
  INNER JOIN sys.columns c
    ON sc.object_id = c.object_id AND sc.column_id = c.column_id
WHERE OBJECT_NAME(s.object_id) = 'Users'
ORDER BY s.stats_id, sc.column_id;

