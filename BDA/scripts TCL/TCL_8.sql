
USE TCL
GO

-- Veamos las tablas con las que vamos a trabajar
Select * 
from dbo.Transaccion
/* Copiar el contenido de la tabla
10006	1280981422329509	2023-09-19 16:37:02.807	500	NULL	V
10007	1280981422329509	2023-09-20 20:35:17.177	500	10006	R
10008	1280981422329509	2023-09-20 20:51:26.653	500	10006	R
*/

Select * 
from dbo.creditCard_info 
/* Copiar el contenido de la tabla
1280981422329509	Dallas	4500
1280981422329509	Dallas	5000
1280981422329509	Dallas	5500
*/

---------------------------------------- Ejemplo 4 SERIALIZABLE
/*
SERIALIZABLE
Las instrucciones no pueden leer datos que hayan sido modificados, pero a�n no confirmados, por otras transacciones.
Ninguna otra transacci�n puede modificar los datos le�dos por la transacci�n actual hasta que la transacci�n actual finalice.
Otras transacciones no pueden insertar filas nuevas con valores de clave que pudieran estar incluidos en el intervalo 
de claves le�do por las instrucciones de la transacci�n actual hasta que �sta finalice.

*/
--Escenario: El cliente solicita la anulacion (reversion) de la compra recien realizada y quiere realizar otra 
--Ejecutar --> Abrir otra instancia de SQL Server, conectarse a la base de datos y abrir el archivo TCL_9.sql


SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- Especifica que las instrucciones pueden leer filas que han sido modificadas por otras transacciones, pero todav�a no se han confirmado
	BEGIN TRANSACTION;
		DECLARE
		@id_transaction_1 int,
		@transaction_amount_1 float,
		@credit_card_nro_1 bigint,
		@date_1 datetime,
		@transaction_type_1 char,
		@credit_card_limit_1 bigint,
		@id_transaction_Reversion int
		
		--Seteo de variables
		SET @credit_card_nro_1 = 1280981422329509
		SET @id_transaction_1 = 10008
		SET @date_1 =GETDATE() 
		SET @transaction_amount_1 = 500
		SET @transaction_type_1= 'R'
		SET @id_transaction_Reversion= 10006

		/*Registramos la Reversion/Anulacion*/
		Insert into dbo.Transaccion
		Values  (@id_transaction_1,@credit_card_nro_1,@date_1,@transaction_amount_1,@id_transaction_Reversion,@transaction_type_1)

		/* Actualizamos el limite de credito */
		UPDATE dbo.creditCard_info 
		SET credit_card_limit = credit_card_limit + @transaction_amount_1 
		WHERE credit_card_nro = @credit_card_nro_1
		--1 ejecutar hasta Aqui!!
		--2 ir a TCL_9.sql
		--6 ejecutar el COMMIT TRANSACTION
		--7 ir a TCL_9.sql
	COMMIT TRANSACTION; 




