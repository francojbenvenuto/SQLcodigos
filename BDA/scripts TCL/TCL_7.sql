


USE TCL
GO

-- Veamos las tablas con las que vamos a trabajar
Select * 
from dbo.Transaccion
/* Copiar el contenido de la tabla

*/

Select * 
from dbo.creditCard_info 
/* Copiar el contenido de la tabla
1280981422329509	Ramos Mejia	5000

*/
---------------------------------------- Ejemplo 4 REPEATABLE READ
/*Especifica que las instrucciones no pueden leer datos que han sido modificados, pero a�n no confirmados por otras transacciones y
que ninguna otra transacci�n puede modificar los datos le�dos por la transacci�n actual hasta que �sta finalice*/




/*1280981422329509	Ramos Mejia	9000

*/

--Escenario: El cliente de un banco solicita que se le actualice el LC para poder realizar una compra y a su vez necesita que se cambie el domicilio de la tarjeta
-- TCL_5.sql --> Cliente
-- TCL_6.sql --> Empleado1 Banco actualiza limite
-- TCL_7.sql --> Empleado2 Banco actualiza domicilio
--Ejecutar --> Abrir tres instancias de SQL Server, conectarse a la base de datos y abrir los archivos TCL_5.sql - TCL_6.sql - TCL_7.sql

--Actualizacion del Domicilio

--13 Ejecutar la transaccion completa
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; 
		BEGIN TRANSACTION; 
		DECLARE
		@credit_card_nro bigint,
		@city [nvarchar](50)
		SET @credit_card_nro = 1280981422329509
		SET @city = 'Ramos Mejia'
				/* Actualizamos el domicilio  */
				UPDATE creditCard_info 
				SET city = @city 
				WHERE credit_card_nro = 1280981422329509

		
		/* Confirmamos la transaccion*/
		COMMIT TRANSACTION	
--14 Volver a TCL5
--22 Ejecutar la consulta que se encuentra al final y guardar TCL7
--23 que sucede con los datos?
--24 IR a TCL5
		
		Select * 
		from dbo.creditCard_info 
		Where credit_card_nro = 1280981422329509
		--Monto del limite: <completar>--24200
		--domicilio: <completar>-- Ramos Mejia