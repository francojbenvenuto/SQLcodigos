
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



*/
---------------------------------------- Ejemplo 4 REPEATABLE READ
/*Especifica que las instrucciones no pueden leer datos que han sido modificados, pero a�n no confirmados por otras transacciones y
que ninguna otra transacci�n puede modificar los datos le�dos por la transacci�n actual hasta que �sta finalice*/


--Escenario: El cliente de un banco solicita que se le actualice el LC para poder realizar una compra y a su vez necesita que se cambie el domicilio de la tarjeta
-- TCL_5.sql --> Cliente
-- TCL_6.sql --> Empleado1 Banco actualiza limite
-- TCL_7.sql --> Empleado2 Banco actualiza domicilio
--Ejecutar --> Abrir tres instancias de SQL Server, conectarse a la base de datos y abrir los archivos TCL_5.sql - TCL_6.sql - TCL_7.sql

--Consultamos el limite actual para setear los valores
		Select * 
		from dbo.creditCard_info 
		Where credit_card_nro = 1280981422329509
		--1280981422329509	Dallas	5000
		--1280981422329509	Dallas	4500

		Select * 
		from dbo.Transaccion
		--1006	1280981422329509	2023-09-20 19:57:49.840	9000	NULL	V

--1 Ejecutar hasta COMMIT TRANSACTION;(sin incluirlo)  y observar el resultado
--2 Ir a TCL6
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- Especifica que las instrucciones pueden leer filas que han sido modificadas por otras transacciones, pero todav�a no se han confirmado
		BEGIN TRANSACTION;
		DECLARE
		@credit_card_limit_1 int,
		@transaction_amount_1 float,
		@credit_card_nro_1 bigint,
		@id_transaction_1 int,
		@date_1 datetime,
		@transaction_type_1 char
		--Seteo de variables
		SET @credit_card_nro_1 = 1280981422329509
		SET @id_transaction_1 = 1006
		SET @date_1 =GETDATE() 
		SET @transaction_amount_1 = 500 
		SET @transaction_type_1= 'V'
		-- Consulta de limite del usuario.
		Select @credit_card_limit_1= credit_card_limit
		from creditCard_info
		where credit_card_nro =@credit_card_nro_1
		--08 Consultar el valor del limite de credito
		--09 Monto del limite: <completar> -- qu� sucede?
		--10 Abrir nuevamente TCL6, e ir a TL6
		--15 Ejecutar la Transaccion completa qu� sucede? 
		--16 IR a TL6
		--20 Que sucede con la transaccion?
		--21 Ir a TCL7
		--25 Ejecutar nuevamente la transaccion de TCL5
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
		COMMIT TRANSACTION; 

		--Consulta de limite del usuario 
		Select * 
		from dbo.creditCard_info
		where credit_card_nro = @credit_card_limit_1


