
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
10007	1280981422329509	2023-09-20 20:35:17.177	500	10006	R
10008	1280981422329509	2023-09-20 20:51:26.653	500	10006	R
*/

Select * 
from dbo.creditCard_info 
/* Copiar el contenido de la tabla
1280981422329509	Dallas	4500

1280981422329509	Dallas	5000
1280981422329509	Dallas	5300

*/
---------------------------------------- Ejemplo 4 SERIALIZABLE
/*
SERIALIZABLE
Las instrucciones no pueden leer datos que hayan sido modificados, pero aún no confirmados, por otras transacciones.
Ninguna otra transacción puede modificar los datos leídos por la transacción actual hasta que la transacción actual finalice.
Otras transacciones no pueden insertar filas nuevas con valores de clave que pudieran estar incluidos en el intervalo 
de claves leído por las instrucciones de la transacción actual hasta que ésta finalice.

*/
--Escenario: El cliente solicita la anulacion (reversion) de la compra recien realizada y quiere realizar otra 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
	BEGIN TRANSACTION;
		DECLARE
		@id_transaction_1 int,
		@transaction_amount_1 float,
		@credit_card_nro_1 bigint,
		@date_1 datetime,
		@transaction_type_1 char,
		@credit_card_limit_1 bigint
		
		--Seteo de variables
		SET @credit_card_nro_1 = 1280981422329509
		SET @id_transaction_1 = 1007
		SET @date_1 =GETDATE() 
		SET @transaction_amount_1 = 200
		SET @transaction_type_1= 'V'


		-- Consulta de limite del usuario.
		Select @credit_card_limit_1= credit_card_limit
		from creditCard_info
		where credit_card_nro =@credit_card_nro_1
		
		if (@credit_card_limit_1 > @transaction_amount_1) 
		BEGIN 
		   /* Registramos la venta*/
			Insert into dbo.Transaccion
			Values  (@id_transaction_1,@credit_card_nro_1,@date_1,@transaction_amount_1,null,@transaction_type_1)
			
			/* Actualizamos el limite de credito */
			UPDATE dbo.creditCard_info 
			SET credit_card_limit = credit_card_limit - @transaction_amount_1 
			WHERE credit_card_nro = @credit_card_nro_1
			
		END
        ELSE
			BEGIN
				PRINT 'No se puede realizar la compra.  Excede limite de credito disponible';
			END;
			-- 3 Ejecutar hasta aqui!
			-- 4 Realizar la consulta de la tabla Transaccion - Que sucede?
			-- 5 Ir a TCL_8.sql
			-- 8 que sucedió con la operacion?
	COMMIT TRANSACTION; 




