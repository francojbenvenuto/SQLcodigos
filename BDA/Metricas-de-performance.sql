/*
Veamos cómo obtener las métricas que abordamos en clase
de forma "manual"... algo rústico pero efectivo.

Este tipo de análisis suele hacerse con software especializado.
Mínimamente scripts que se ejecutan en forma automática 
generando historial... en tablas obviamente.

*/

-- Cuenta de filas
-- Hay muchas formas, desde alguna trivial...
use pruebasDB
go
set statistics io on

select count(*)
from ddbba.Venta

-- Pero este método requiere un index scan de toda la tabla!
-- (Ver plan de ejecucion)
-- Cuanto más grande la tabla, peor el impacto en el sistema

-- Otra forma es usar una de las vistas internas del sistema
SELECT
  dm_db_partition_stats.row_count CuentaDeFilas
FROM sys.dm_db_partition_stats
	INNER JOIN sys.objects ON objects.object_id = dm_db_partition_stats.object_id
WHERE objects.is_ms_shipped = 0
	AND objects.type_desc = 'USER_TABLE'
	AND objects.name = 'Venta'
	AND dm_db_partition_stats.index_id IN (0,1);

-- Atención! Este método arroja un resultado APROXIMADO de recuento 
-- de filas, basándose en datos en memoria.
-- Sirve para la métrica ya que nos sirve el dato aproximado
-- Podemos incluso obtener incluso más informacion de TODAS las tablas con
-- una sola query, sin necesidad de usar SQL dinámico:

SELECT
  schemas.name Esquema,
  objects.name Tabla,
  CASE WHEN dm_db_partition_stats.index_id = 1 THEN 'Cluster' ELSE 'Heap' END AS TipoTabla,
  dm_db_partition_stats.row_count CuentaDeFilas
FROM sys.dm_db_partition_stats
	INNER JOIN sys.objects ON objects.object_id = dm_db_partition_stats.object_id
	INNER JOIN sys.schemas ON schemas.schema_id = objects.schema_id
WHERE objects.is_ms_shipped = 0
	AND dm_db_partition_stats.index_id IN (0,1);

-- Si necesitamos la cantidad de filas de "diferencia" entre 
-- muestreos en el tiempo, podríamos aprovecharnos de algun
-- campo que guarde un timestamp para consultar las novedades.
-- Esto sería más liviano que leer toda la tabla y más preciso que
-- el método de las vistas de sistema.

-- Otra métrica: Database File IO
-- ¡La vista dm_io_virtual_file_stats se resetea cuando se reinicia el servicio SQL!
-- Debe guardar a intervalos los valores obtenidos. Los valores son acumulativos.
-- Hacemos join con dos tablas de sistema para ver detalles de la DB y su nombre

SELECT
  databases.name DB_Nombre,
  master_files.name DB_Archivo,
  master_files.type_desc TipoArchivo,
  master_files.physical_name NombreFisico,
  dm_io_virtual_file_stats.num_of_reads Lecturas,
  dm_io_virtual_file_stats.num_of_bytes_read BytesLeidos,
  dm_io_virtual_file_stats.num_of_writes Escrituras,
  dm_io_virtual_file_stats.num_of_bytes_written BytesEscritos,
  dm_io_virtual_file_stats.size_on_disk_bytes TamanioBytes
FROM sys.master_files
	INNER JOIN sys.dm_io_virtual_file_stats(NULL, NULL)
		ON master_files.database_id = dm_io_virtual_file_stats.database_id
	INNER JOIN sys.databases
		ON databases.database_id = master_files.database_id
		AND master_files.file_id = dm_io_virtual_file_stats.file_id;

/*
Para probarlo: obtenga los valores, realice algunas operaciones en la DB y vuelva
a generarlo. Luego compare.
*/


/*
Tamaño del backup de log

Cada transacción confirmada se guarda en almacenamiento (sino permanece en memoria).
Inicialmente al transaction log, luego cuando se toma un backup del mismo, 
los cambios impactan en el archivo principal de la DB y se remueve la transacción del log.

El tamaño del backup del log nos dirá aproximadamente la cantidad de datos
Uno pequeño: pocos movimientos, grande: muchos movimientos.

Se puede obtener de los archivos (filesystem) via PS, o de la MSDB
Los datos se retienen por un periodo acotado de tiempo (un día seguro que si).

*/
SELECT
  backupset.database_name DatabaseNombre,
  CAST(8.0 * master_files.size/1024.0 AS DECIMAL(18, 0)) DatabaseArchivoMBs,
  CAST(backupset.backup_size/1024.0/1024.0 AS DECIMAL(18, 2)) BackupMBs,
  backupset.backup_start_date	BackupFechaInicio,
  backupset.backup_finish_date	BackupFechaFin,
  CAST(backupset.backup_finish_date - backupset.backup_start_date AS TIME) BackupDuracion,
  backupmediafamily.physical_device_name UbicacionFisicaBackup
FROM msdb.dbo.backupset
	INNER JOIN msdb.dbo.backupmediafamily ON backupset.media_set_id = backupmediafamily.media_set_id
	INNER JOIN sys.databases ON databases.name = backupset.database_name
	INNER JOIN sys.master_files ON master_files.database_id = databases.database_id
	AND master_files.type_desc = 'ROWS'
WHERE backupset.type = 'L';

/*
Una DB con muchas modificaciones puede derivar en un LOG más grande que la DB misma.

Un UPDATE que mantiene los mismos valores generará LOG
Es un recurso muy comun que se usa en programacion porque se piensa que no tiene impacto.
*/

/*
Esta consulta devuelve todas las esperas actuales.
Se filtran los procesos de sistema para que no aparezcan

*/

SELECT
	  @@SERVERNAME	Servidor,
	  GETDATE()		HoraLocal,
	  dm_exec_requests.session_id,
	  dm_exec_requests.blocking_session_id,
	  databases.name	DB,
	  dm_exec_requests.wait_time,
	  dm_exec_requests.wait_resource,
	  dm_exec_requests.wait_type,
	  dm_exec_sessions.host_name,
	  dm_exec_sessions.program_name,
	  dm_exec_sessions.login_name,
	  dm_exec_requests.command,
  CASE
    WHEN dm_exec_sql_text.text LIKE '%CREATE PROCEDURE%'
    THEN '/* PROC: */ ' + SUBSTRING(dm_exec_sql_text.text, CHARINDEX('CREATE PROCEDURE ', dm_exec_sql_text.text) + 17, 60) + ' ... '
    ELSE SUBSTRING(dm_exec_sql_text.text, 1, 60) + ' ...'
  END Begin_SQL,
  CASE
    WHEN dm_exec_sql_text.text LIKE '%CREATE PROCEDURE%' THEN '/* PROC - SEE SOURCE CODE */'
    ELSE RTRIM(dm_exec_sql_text.text)
  END Script,
  SUBSTRING(dm_exec_sql_text.text, (dm_exec_requests.statement_start_offset/2) + 1,
    ((CASE dm_exec_requests.statement_end_offset WHEN -1 THEN DATALENGTH(dm_exec_sql_text.text) ELSE dm_exec_requests.statement_end_offset
    END - dm_exec_requests.statement_start_offset)/2) + 1) Wait_SQL,
  CONVERT(VARCHAR(MAX), Query_Hash, 1) AS QueryHash,
  CASE WHEN dm_exec_sql_text.text IS NULL THEN NULL ELSE CHECKSUM(dm_exec_sql_text.text) END AS ChecksumTextHash
FROM master.sys.dm_exec_requests
	INNER JOIN master.sys.dm_exec_sessions ON dm_exec_requests.session_id = dm_exec_sessions.session_id
	OUTER APPLY master.sys.dm_exec_sql_text(dm_exec_requests.sql_handle)
	INNER JOIN sys.databases ON databases.database_id = dm_exec_requests.database_id
WHERE dm_exec_sessions.is_user_process = 1 -- Filtra solo los procesos de usuario

/*
La consulta devuelve mucha informacion:
* consulta en espera
* qué la bloquea
* proceso, host, etc	

Dm_exec_requests.wait_time: Dependiendo del sistema podemos enfocarnos en esperas de cierta duracion o mayores.
Dm_exec_requests.status: Filtrando los de status = 'background' quitamos los procesos internos
Databases.name: Filtramos solo la(s) DB de interés
Dm_exec_requests.last_wait_type: Se pueden filtrar las esperas que no nos interesan
Dm_exec_requests.command: Se pueden filtrar backups u otros procesos que no nos interesen

*/