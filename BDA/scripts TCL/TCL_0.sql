
USE TCL
GO

-- Veamos las tablas con las que vamos a trabajar
Select * 
from dbo.Transaccion
/* Copiar el contenido de la tabla
10006	1280981422329509	2023-09-19 16:37:02.807	500	NULL	V
1001	1280981422329509	2023-09-20 19:31:28.060	1000	NULL	V
*/


Select * 
from dbo.creditCard_info 
/* Copiar el contenido de la tabla
1280981422329509	Ramos Mejia	60.000
1280981422329509	Ramos Mejia	59000
*/


------------- ejemplo
/*
Cada transacci�n se inicia expl�citamente con la instrucci�n BEGIN TRANSACTION 
y se termina expl�citamente con una instrucci�n COMMIT o ROLLBACK.
*/
--Escenario: Un cliente realiza la compra con tarjeta de credito. 
--Al registrarse la venta se descuenta el limite de credito disponible
--La operaci�n se realiza en un pago o en una cuota.

BEGIN TRANSACTION;
		DECLARE 
		@id_transaction int,
		@transaction_amount float,
		@credit_card_nro bigint,
		@date datetime,
		@transaction_type char,
		@credit_card_limit_1 bigint

		/* Asignamos el monto de la transacci�n */
		SET @id_transaction = 1001
		SET @credit_card_nro = '1280981422329509'
		SET @date =GETDATE() 
		SET @transaction_amount = 61000
		SET @transaction_type= 'V'

		-- Consulta de limite del usuario.
		Select @credit_card_limit_1= credit_card_limit
		from creditCard_info
		where credit_card_nro =@credit_card_nro

		if (@credit_card_limit_1 > @transaction_amount) 
			BEGIN 
				   /* Registramos la venta*/
					Insert into dbo.Transaccion
					Values  (@id_transaction,@credit_card_nro,@date,@transaction_amount,null,@transaction_type)
					
					/* Actualizamos el limite de credito */
					UPDATE dbo.creditCard_info 
					SET credit_card_limit = credit_card_limit - @transaction_amount
					WHERE credit_card_nro = @credit_card_nro
			END
        ELSE
			BEGIN
				PRINT 'No se puede realizar la compra.  Excede limite de credito disponible';
			END;
		COMMIT TRANSACTION; 


--Veamos que sucedi� a nivel tabla 1280981422329509
--confirmar si se actualiz� el limite de credito
Select * 
from dbo.Transaccion
where credit_card_nro = 1280981422329509

Select * 
from dbo.creditCard_info 
Where credit_card_nro = 1280981422329509

--Al no haber otra transacci�n involucrada no hay conflictos ni en la lectura ni en la escritura.
--Cerrar el archivo.