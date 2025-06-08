


USE TCL
GO

-- Veamos las tablas con las que vamos a trabajar
Select * 
from dbo.Transaccion
/* Copiar el contenido de la tabla
1001	1280981422329509	2023-09-20 19:31:28.060	1000	NULL	V
1005	1280981422329509	2023-09-20 19:43:44.163	61000	NULL	V
1006	1280981422329509	2023-09-20 19:57:49.840	9000	NULL	V
10006	1280981422329509	2023-09-19 16:37:02.807	500	NULL	V
*/

Select * 
from dbo.creditCard_info 
/* Copiar el contenido de la tabla

1280981422329509	Ramos Mejia	9000
1280981422329509	Ramos Mejia	20000

*/
---------------------------------------- Ejemplo 4 REPEATABLE READ
/*Especifica que las instrucciones no pueden leer datos que han sido modificados, pero a�n no confirmados por otras transacciones y
que ninguna otra transacci�n puede modificar los datos le�dos por la transacci�n actual hasta que �sta finalice*/


--Escenario: El cliente de un banco solicita que se le actualice el LC para poder realizar una compra y a su vez necesita que se cambie el domicilio de la tarjeta
-- TCL_5.sql --> Cliente
-- TCL_6.sql --> Empleado1 Banco actualiza limite
-- TCL_7.sql --> Empleado2 Banco actualiza domicilio
--Ejecutar --> Abrir tres instancias de SQL Server, conectarse a la base de datos y abrir los archivos TCL_5.sql - TCL_6.sql - TCL_7.sql

--Actualizacion del limite de credito desde el banco

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; 
		BEGIN TRANSACTION; 
		DECLARE
		@credit_card_nro bigint,
		@credit_card_lim bigint
		SET @credit_card_nro = 1280981422329509
		SET @credit_card_lim = 11000

		/* Actualizamos el limite de credito */
		UPDATE creditCard_info 
		SET credit_card_limit = credit_card_limit + @credit_card_lim 
		WHERE credit_card_nro = @credit_card_nro

		--03 Ejecutar hasta Aqui!!
		--04 ejecutar la consulta de Limite de credito que se encuentra debajo
		--05 Monto del limite: <completar>  Guardar TCL6
		--06 Cerrar el archivo sin realizar commit
		--07 Volver a TCL5
		--11 Ejecutar nuevamente la transaccion como indica el punto 3
		--12 Ir a TLC 7
		--17 Ejecutar la transaccion completa
		--18 Ejecutar la consutla que se encuentra al final
		--19 Ir a TCL5
		/* Confirmamos la transaccion*/
		COMMIT TRANSACTION			 
		--Veamos que sucedi� a nivel tabla 1280981422329509
		
		--confirmar si se actualiz� el limite de credito
		Select * 
		from dbo.creditCard_info 
		Where credit_card_nro = 1280981422329509
		--Monto del limite: <completar> 20000
		--domicilio: <completar>--Ramos Mejia