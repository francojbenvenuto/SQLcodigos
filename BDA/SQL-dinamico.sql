use pruebasDB
go

/*
Empecemos con algo bien simple e incorrecto
*/

declare @stringSQL nvarchar(200)
declare @monto		decimal(10,2)
set @monto = '1000'
set @stringSQL = 'Select fecha, ciudad, monto from ddbba.venta where monto > ' + cast(@monto as varchar) + ' order by fecha'
exec (@stringSQL)
/*
Observe que la variable @monto tuvimos que convertirla a cadena de texto para poder concatenar todo
*/

/* Ahora usemos una variable de texto
*/
declare @stringSQL2 nvarchar(200)
declare @ciudad		char(20)
set @ciudad = 'Buenos Aires'
set @stringSQL2 = 'Select fecha, ciudad, monto from ddbba.venta where ciudad = ' + @ciudad + ' order by fecha'
print @stringSQL2
exec (@stringSQL2)


/* Al concatenar el texto se produce un error. 
Necesitamos comillas. Se pone feo. 
Note que los espacios al final "trailing" no impiden la coincidencia
*/
declare @stringSQL3 nvarchar(200)
declare @ciudad2		char(20)
set @ciudad2 = 'Buenos Aires'
set @stringSQL3 = 'Select fecha, ciudad, monto from ddbba.venta where ciudad = ''' + @ciudad2 + ''' order by fecha'
print @stringSQL3
exec (@stringSQL3)

/* Pero esto se pone realmente interesante con las FECHAS
Hagamos un ejemplo simple
*/
declare @stringSQL4 nvarchar(200)
declare @fecha		smalldatetime
set @fecha = '2/5/2023'
set @stringSQL4 = 'Select fecha, ciudad, monto from ddbba.venta where fecha < ' + @fecha + ' order by fecha'
print @stringSQL4
exec (@stringSQL4)
/*
Ese formato de fecha no le gusto... probemos convertir a texto...
y ademas usar fecha ISO yyyymmdd
*/
declare @stringSQL5 nvarchar(200)
declare @fecha2		smalldatetime
set @fecha2 = '20230502'
set @stringSQL5 = 'Select fecha, ciudad, monto from ddbba.venta where fecha < ''' + convert(varchar, @fecha2,103) 
+ ''' order by fecha'
print @stringSQL5
exec (@stringSQL5)
-- Moraleja: cada tipo de dato debe ser convertido a cadena con sus particularidades


/*
Hagamos algo más interesante.
Vamos a generar una consulta para ver la cantidad de filas de cada tabla de la DB.
Esto funciona en cualquier DB SQL Server.

Estaremos accediendo a tablas de sistema como sys.objects
*/

DECLARE @CadenaSQL NVARCHAR(MAX) ;
SELECT @CadenaSQL = COALESCE(@CadenaSQL + ' UNION ALL ','')
                      + 'SELECT '
                      + '''' + QUOTENAME(SCHEMA_NAME(sOBJ.schema_id))
                      + '.' + QUOTENAME(sOBJ.name) + '''' + ' AS [Tabla]
                      , COUNT(1) AS [CuentaDeFilas] FROM '
                      + QUOTENAME(SCHEMA_NAME(sOBJ.schema_id))
                      + '.' + QUOTENAME(sOBJ.name) 
FROM sys.objects AS sOBJ
WHERE
      sOBJ.type = 'U'	-- significa objeto del usuario, incluiria indices
ORDER BY SCHEMA_NAME(sOBJ.schema_id), sOBJ.name ;
EXEC sp_executesql @CadenaSQL

