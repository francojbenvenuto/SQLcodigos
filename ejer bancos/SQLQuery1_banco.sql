
use bancos;
go



--3-Listar los bancos que solamente operan todas las monedas que no son el PESO URUGUAYO. 
--Utilizar una vista para todas las monedas que no son el peso uruguayo.

create view V_MONEDAS_NO_URU AS
select* 
from banco b
where NOT EXISTS
	(
		select 1
		from moneda M
			where  m.id <> 'UY' and NOT EXISTS 
								(
								SELECT 1
								from opera	o
								where o.idMoneda = m.id
								and b.id = o.idBanco
								)
	)


	select *
	from Banco b
	where b.id = (	SELECT V.ID
					FROM V_MONEDAS_NO_URU V

					EXCEPT

					SELECT o.idBanco
					FROM opera o
					where o.idMoneda = 'UY'
				)


--4-Crear una funcion que devuelva el valor oro de una moneda. La misma debe recibir como parametro el codigo de la moneda y 
--devolver el valor -1 para el caso en que la moneda no exista.Escribir la sentencia que prueba el correcto funcionamiento.

CREATE FUNCTION f_moneda (@moneda char(2))  RETURNS decimal(18,3)
AS  BEGIN
	declare @ret decimal(18,3)
	if exists(select * from moneda m where m.id = @moneda) select @ret=m.valorOro from moneda m where m.id = @moneda
	else set @ret = -1

return @ret
END

SELECT dbo.f_moneda('UY') as valor_oro


--5- Crear una funcion que retorne una tabla con el pasaporte y el nombre de las personas que 
--tienen cuenta en todos los bancos. Escribir la sentencia que prueba el correcto funcionamiento.

CREATE FUNCTION f_pasaports ()  RETURNS @todos table 
( 
pasaporte char (15),
nombre varchar(50) 
)
as BEGIN

insert @todos 
					SELECT p.nombre, p.pasaporte
					FROM Persona P
					WHERE NOT EXISTS (
										SELECT 1
										FROM BANCO B
										WHERE NOT EXISTS ( 
															SELECT 1
															FROM cuenta c
															where c.idBanco = b.id
															and c.idPersona = p.pasaporte
															)
										)
return
END

select * from f_pasaports()




--6- Crear un SP que liste por pantalla a las personas que tienen mas de 3 cuentas en dolares 
--en bancos extranjeros. Escribir la sentencia que prueba el correcto funcionamiento.

create procedure sp_cuentas as

select c.idPersona, count(*) numero_cuentas
from cuenta c
join banco b on b.id = c.idBanco
where c.idMoneda = 'US' and b.pais <> 'argentina'
group by c.idPersona
having COUNT(*) > 2

exec sp_cuentas



--8- Crear un Trigger que realice el respaldo de los datos de las cuentas que se eliminen.Si hay cuentas en Pesos Argentinos entre las eliminadas, no debe permitirse la operación.
--NOTA:Se debe crear una tabla "cuenta_respaldo"
--Escribir las sentencias que prueban el correcto funcionamiento.


