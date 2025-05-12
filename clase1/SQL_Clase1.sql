
 
 -- LENGUAJE SQL. ESTANDAR. ANSI-SQL (ver 92, 97, 99, 2007, 2014, etc)
 -- MOTORES TIENEN LENGUAJES PROPIOS: 
		-- POSTGRES PG/PLSQL
		-- ORACLE PLSQL
		-- ETC
		-- MS SQL (SQL SERVER) TRANSACT SQL (TSQL) link: https://go.microsoft.com/fwlink/?linkid=866662
		-- link MS-SQLMS https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16
		dsd

 -- BASES DE DATOS
 -- Una base de datos, es un elemento dentro del motor de bases de datos. 
 -- Esta compuesto por dos o mas archivos fisicos, 
 -- donde las tablas seran elementos dentro de estos archivos. 
 -- Uno de los archivos es el que contiene la base de datos en si, 
 -- mientras que el otro es un archivo de log.

 
----Crear una base de datos
CREATE DATABASE ejemplo123 ;-------------;
CREATE DATABASE [CLASE SABADO '23]   -- entre corchetes es para tener caracteres especificos como comillas para el nombre

-- ejemplo de modificacion de parametros.  
 ALTER DATABASE [CLASE SABADO '23] MODIFY NAME = new_database_name
 --ALTER DATABASE new_database_name MODIFY NAME = ejemplo123 
 --> DA ERROR PORQUE YA EXISTIA UNA DB CON ESE NOMBRE

-- borrado de una base de datos
 DROP DATABASE new_database_name;

 
 -- validar si existe la base de datos
 SELECT * FROM sys.databases;

 -- Usar la base de datos;
 USE ejemplo123;   --entra en esta base de datos

----Que es un esquema?
-- Un esquema es un conjunto o agrupador de elementos dentro de la base 
-- de datos. Por ejemplo, podemos tener dentro de una misma 
-- base de datos, 1 esquema para desarrollo, 1 para testing y uno 
-- para produccion.

-- CREAR Esquema
CREATE SCHEMA desarrollo;


-- BORRAR Esquema
DROP SCHEMA desarrollo;

--> dbo -> ESQUEMA POR DEFECTO DE MSSQL SERVER 
		-- dbo == DataBaseOwner 

----Tipos de datos
-- dentro de un motor de base de datos (SQL server 2017)

-- ENTEROS --
bigint		--> ENTERO 8 bytes   --como el long
int			--> ENTERO 4 bytes
smallint	--> ENTERO 2 bytes
tinyint		--> ENTERO 1 byte

-- BOOLEANO --
bit			--> ENTERO 1 byte 1 / 0 / NULL / booleano

-- CON DECIMALES --
numeric (L, d)	--> L= largo total (parte entera + decimal) 
				--> d = cantidad de decimales 1.000.000,00 DECIMAL(9,2)
decimal	(L, d) 
FLOAT 
smallmoney		--> 4 Bytes. Representa numeros con simbolo de dinero. 
money			--> 8 bytes

-- CADENAS DE TEXTO --
char (L)		--> Almacena la cantidad indicada en "L". 
                --  si pongo Char(5) y guardo ANA, guarara 3 carateres 
				--  para ANA y 2 mas hasta llegar a 5 ( completa con basura)
varchar (L)     --> Almacena la cadena ingresada y si es de largo menor 
				--  a "L" guarda la cantidad de la cadena.  (este no)
				--> ejemplo: VARCHAR(5) "ANA" guarda ANA y 3. si guarda JUAN guarda la cadena y 4.
varchar(MAX)    --> MAXIMO PERMITIDO POR EL MOTOR 

-- CADENAS DE TEXTO UNICODE --
nchar (L)
nvarchar (L)
nvarchar(MAX)

-- FECHAS & HORAS --
--> todos los datos de fecha se guardan como un numero, numero que se toma 
--  como 0 un momento dado en el tiempo y luego en milisegundos a partir 
--  de ahi.

date		  --> el ANSI SQL (estandar) indica que el 0 es 1582, 10, 15, 
			  --  y llegara hasta el 9999, 12, 31, segun el tamano en bytes 
			  --  del campo
time		  --> horas
datetime      --> fecha y hora. Arrancando 1753, 1 de enero.
smalldatetime --> fecha y hora, pero el "0" es un valor mas proximo que 1753,
			  -- arrancando de 1900, 1, 1. 
datetime2	  --> arranca en 1900, 1, 1 y almacena en 6 bytes el tamano, 
			  -- mayor precision en los milisegundos


 -->> QUE VALOR TIENE, EN MILISEGUNDOS, LA FECHA DE INICIO DE LA CLASE DE HOY? 
 --  2023/10/07 08:35:00.0000 tomando como 0 el 2023/01/01 00:00:00.0000
 -- y si tomaramos como 0 el 1900/01/01 00:00:00.0000 ?


----Crear una tabla
-- EN MR nombreTabla(campo1, campo2, nombre_largo_campo)
CREATE TABLE nombreTabla   -- dbo es el esquema por defecto
(
	CAMPO1 int,
	CAMPO2 VARCHAR(6),
	[NOMBRE LARGO CAMPO] DECIMAL(12,2)
);


CREATE TABLE desarrollo.nombreTabla --este es una tabla en el esquema desarrollo, util para separar
(
	CAMPO1 int,
	CAMPO2 VARCHAR(6)
);	

--EJEMPLO SCHEMA ERRONEO
/*
CREATE TABLE SCHEMA_INEXISTENTE.nombreTabla
(
	CAMPO1 int,
	CAMPO2 VARCHAR(6)
)	
*/

select * from nombreTabla; -- solo nombre de la tabla
select * from dbo.nombreTabla; --  nombre de la tabla con el esquema
select * from ejemplo123.dbo.nombreTabla; -- nombre de la DB.SCHEMA.TABLA
select * from ejemplo123.desarrollo.nombreTabla;

-- MODIFICAR
ALTER TABLE nombreTabla
	ADD campo3 bigint;

ALTER TABLE nombreTabla
	ALTER COLUMN campo3 datetime;

ALTER TABLE nombreTabla
	DROP COLUMN campo3;

-- BORRAR
DROP TABLE nombreTabla;

----Mostrar pk
-- PARA CREAR UNA TABLA CON CLAVE PRIMARIA O PRIMARY KEY, HAY DOS OPCIONES
CREATE TABLE tablaUno
(
	CAMPO1 int primary key,
	CAMPO2 VARCHAR(6)
);

CREATE TABLE tablaDos
(
	CAMPO1 int,
	CAMPO2 nvarchar(max),   -- <<--- si agregamos la palabra reservada MAX tendremos el largo maximo del tipo nvarchar
	PRIMARY KEY (campo1)
);	

--> pk's compuestas
CREATE TABLE tablaTres
(
	CAMPO1 INT,
	CAMPO2 VARCHAR(6),
	PRIMARY KEY (campo1, CAMPO2)
)	;

--EJEMPLO

CREATE TABLE Persona1
(
	NroDoc INT,
	tipoDoc VARCHAR(3),
	PRIMARY KEY (NroDoc, tipoDoc)
)	;


-- NO DISCRIMNA ENTRE MAYUSCULAS Y MIN. ( se puede cambiar el unsencibilited)
Select * from tablaTres
Select * frOm TABLATRES
Select * from tAblAtREs
SeLeCt * FrOm TABLATRES

-- ejemplo
CREATE TABLE persona
(
	nroDoc BIGINT, 
	tipoDoc CHAR(3),
	nombre VARCHAR(40),
	apellido VARCHAR(40),
	PRIMARY KEY (nroDoc, tipoDoc)
)

-- drop table persona

-- CLAVES FORANEAS -- 
--> Las claves foraneas estan asociadas a campos clave de otras tablas

CREATE TABLE tablaPk
(
	CAMPO1 int primary key,
	CAMPO2 VARCHAR(6)
)	

-- NO PUEDO CAMBIAR EL TIPO DE DATO 
ALTER TABLE tablapk
	ALTER COLUMN CAMPO1 VARCHAR(50)

--drop table tablapk

CREATE TABLE tablaFk
(
	CAMPOa int primary key,
	CAMPOb VARCHAR(6),
	CAMPOc int,
	FOREIGN KEY (campoC) REFERENCES tablaPk(campo1) -- <<--- indicamos que campo de la tablaFk apunta a que campo de la tablaPk
)

--ejemplo

CREATE TABLE pais
(
	id int,
	nombre varchar(40),
	primary key(id)
)

CREATE TABLE provincia
(
	id int,
	nombre varchar(40),
	pais int, 
	primary key(id),
	foreign key(pais) references pais(id)
)
-- drop table provincia
-- comentario una linea
/* comentario
muchas lineas
*/
CREATE TABLE localidad
(
	codigo int,
	nombre varchar(40),
	provincia int, 
	primary key(codigo),
	foreign key (provincia) references provincia(id)
)

-- drop table localidad
-- COMO CONOCER LA ESTRUCTURA DE UNA TABLA?
SP_HELP localidad

-- ERROR AL REFERENCIAR CON DISTINTO TIPO
CREATE TABLE tablaFk_ERROR
(
	CAMPOa int primary key,
	CAMPOb VARCHAR(6),
	CAMPOc VARCHAR(5),
	FOREIGN KEY (campoC) REFERENCES tablaPk(campo1) -- <<--- indicamos que campo de la tablaFk apunta a que campo de la tablaPk
)
----------->>> EJEMPLO TERNARIA 
-- A(a1 pk, a2, a3)
-- B(b1 pk, b2, b3)
-- C(c1 pk, c2, c3)
-- R (a1, b1, c1) donde todos son PK y FK

CREATE TABLE A 
(
	a1 int primary key,
	a2 int,
	a3 int
);

CREATE TABLE B
(
	b1 int primary key,
	b2 int,
	b3 int
);

CREATE TABLE C
(
	c1 int primary key,
	c int,
	c3 int
);

CREATE TABLE R
(
	a1 int,
	b1 int,
	c1 int,
	primary key (a1, b1, c1),
	foreign key (a1) references A(a1),
	foreign key (b1) references B(b1),
	foreign key (c1) references C(c1)
);

sp_help R

-<<<<<---------- EJEMPLO TERNARIA 


-->>>>>>> JERARQUIA 

CREATE TABLE PADRE
(
	id int primary key,
	nombre varchar(50)
)

CREATE TABLE Hijo1
(
	id int primary key, 
	apellido varchar(50),
	foreign key (id) references padre(id)
);

CREATE TABLE Hijo2
(
	id int primary key, 
	fan_club varchar(50),
	foreign key (id) references padre(id)
);
--<<<<<<<<<< JERARQUIA 

-->>>>>>> ENTIDAD DEBIL 

CREATE TABLE libro
(
	isbn int primary key,
	nombre varchar(50)
)

CREATE TABLE ejemplar
(
	nro int, 
	fecha_compra date,
	isbn int, 
	primary key(nro, isbn),
	foreign key (isbn) references libro(isbn)
)
--<<<<<<< ENTIDAD DEBIL 


-- TRABAJANDO CON DATOS

-- INSERT / UPDATE / DELETE 

----Insertar en tabla
-- Hay varias formas de insertar datos en una base de datos, por fila o tupla o con muchas filas o tuplas

-- INSERTAR 1 FILA
sp_help tablaUno
INSERT INTO tablaUno (CAMPO1, CAMPO2) VALUES (1, 'A'); -- ORDEN RELATIVO AL CONJUNTO DE CAMPOS
INSERT INTO tablaUno (CAMPO2, CAMPO1) VALUES ('A', 10); -- ORDEN RELATIVO AL CONJUNTO DE CAMPOS

INSERT INTO tablaUno VALUES (2, 'B'); -- ORDEN POR POSICION

-- INSERTANDO MAS DE UNA TUPLA A LA VEZ
INSERT INTO tablaUno VALUES (3, 'C'), (4, 'H'), (5, 'G'), (6, 'F'); -- ORDEN POR POSICION


-- INSERTANDO MAS DE UNA TUPLA DESDE OTRA TABLA
INSERT INTO tablaDos (CAMPO1, CAMPO2)
SELECT database_id, name FROM sys.Databases -- << inserto todos los elementos de la tabla sys.databases

-- resultado:
SELECT * FROM tablaUno;
SELECT * FROM tablaDos;
-- delete from tablaDos;

----MODIFICAR TUPLAS DE UNA TABLA			-- UPPER PARA MAYUSCULAS / CREO LOWER MINUSCULAS
--PRUEBA:
SELECT *, upper(campo2) + ' - MODIFICADO' as [campo2 en mayuscula] FROM tablaDos -- listo el contenido de la tabla

UPDATE tablaDos              -- INDICO LA TABLA A MODIFICARLE INFORMACION
SET
	CAMPO2 = UPPER(CAMPO2) + ' - MODIFICADO',  -- INDICO EL CAMPO2 Y SU NUEVO VALOR
	CAMPO1 = CAMPO1 + 100                      -- INDICO EL CAMPO1 Y SU NUEVO VALOR

WHERE CAMPO2 = 'master';                      -- FILTRO		-- cuando se cumpla este where, hace lo que esta entre el SET y el where,   (como do while pero con if)

SELECT * FROM tablaDos -- listo el contenido de la tabla, para ver los cambios.

----Borrar
DELETE FROM tablaDos -- << indico la tabla donde voy a borrar info
WHERE campo2 = 'msdb' -- << indico la condicion   

----OBTENIENDO INFORMACION
-- Para obtener informacion de las tablas, se debe utilizar lo que llamamos consultas tipo "SELECT"

-->> CONSULTAS SIN CONDICION --> SIMILAR A LA SELECCION
SELECT *             -- << indicamos la palabra SELECT y luego "*" asterisco para listar todos los campos, o detallo los campos 1 a 1
FROM tablaDos        -- << detallamos la tabla


---- CON CONDICION --> (ES LA SELECCION EN AR)
SELECT * 
FROM tablaDos 
WHERE campo1 = 3;	-- << con la clausula where, podemos detallar las condiciones, para hacer un filtro horizontal de filas
					-- operadores: = <= >= <>, LIKE, EXISTS, IN, NOT, OR, AND

SELECT * 
FROM tablaDos 
WHERE campo1 < 3;

SELECT * 
FROM tablaDos 
WHERE campo1 > 3;

SELECT * 
FROM tablaDos 
WHERE campo1 <= 3;

SELECT * 
FROM tablaDos 
WHERE campo1 >= 3;

-- EJEMPLO: IN
SELECT * 
FROM tablaDos 
WHERE campo1 IN (3, 4, 5)  

--- equivalente a 
SELECT * 
FROM tablaDos 
WHERE campo1 = 3 OR campo1 = 4 OR campo1 = 5

---- NOT IN
SELECT * 
FROM tablaDos 
WHERE campo1 NOT IN (3, 4, 5)

SELECT * 
FROM tablaDos 
WHERE campo1 = 4 OR campo2 LIKE 'MASTER%'	-- << LIKE SIRVE PARA COMPARAR TEXTOS, CAMPOS TIPO CHAR / VARCHAR.
											-- << SE PUEDEN USAR "wildcards" o comodines "%", 0 o m�s caracteres
											-- << "_" UN CARACTER		
											-- SI EMPIEZA CON MASTER, YA ACTIVA, EL % ES PARA IGNORAR EL RESTO
SELECT * 
FROM tablaDos 
WHERE campo1 = 4 OR campo2 LIKE 'mode_'		-- SI O SI CON _ EN EL INICIO O FIN PARA REPRESENTAR QUE TERMINO, SINO NO LO RECONOCE

SELECT * 
FROM tablaDos 
WHERE campo2 LIKE 'tem_db'	                -- << "_" UN CARACTER en medio de otros 

SELECT * 
FROM tablaDos 
WHERE campo2 LIKE 'tex_db'	                


----Union: el operador union "une" dos consultas en un unico resultado
--SP_HELP TABLAUNO
--SP_HELP  TABLADOS

SELECT *	
FROM tablaUno

UNION						-- CONCATENA LAS DOS TABLAS

SELECT CAMPO1, CAMPO2
FROM tablaDos


----Resta
SELECT * 
FROM tablaUno

EXCEPT					-- NOS DA LA 1 PERO NOS ELIMINA LOS ELEMENTOS QUE SE REPITEN EN LA DOS

SELECT * 
FROM tablaDos

----Interseccion
SELECT * 
FROM tablaUno

INTERSECT			-- NOS DEVUELVE LOS DATOS QUE SE REPITEN ( TIENEN QUE SER AMBOS CAMPOS)

SELECT * 
FROM tablaDos

----Producto 
SELECT *
FROM tablaUno, tablaDos -- << separando en el FROM las tablas por comas, se realiza un producto cartesiano.
--> AR: tablaUno X tablaDos 

----Juntas 
SELECT * 
FROM tablaUno JOIN tablaDos ON tablaUno.CAMPO1 = tablaDos.CAMPO1 
-- luego del "ON" se indica los campos relacionados entre las tablas
--> AR: tablaUno |X| tablaDos

-- esto es equivalente a
SELECT * 
FROM tablaUno, tablaDos 
WHERE tablaUno.CAMPO1 = tablaDos.CAMPO1 
-- AR:  PRODUCTO CARTESIANO + UNA SELECCION


---- JUNTAS A IZQUIERDA
-- ESTE tipo de juntas mostrara todas las filas de la tabla a izquierda, lo que pueda juntar a derecha. Cuando no tenga con que 
-- emparejar.
SELECT * 
FROM tablaUno LEFT JOIN tablaDos 
	ON tablaUno.CAMPO1 = tablaDos.CAMPO1
--> AR: tablaUno |X tablaDos

---- JUNTAS A DERECHA
-- ESTE tipo de juntas mostrara todas las filas de la tabla a DERECHA, lo que pueda juntar a derecha. Cuando no tenga con que 
-- emparejar.
SELECT * 
FROM tablaUno RIGHT JOIN tablaDos 
	ON tablaUno.CAMPO1 = tablaDos.CAMPO1
--> AR: tablaUno X| tablaDos


-- EJEMPLO DE REEMPLAZO DE NULOS POR UN VALOR QUE YO QUIERA
SELECT ISNULL(tablaUno.CAMPO1, -1) as campo1, 
	   tablaUno.CAMPO2, 
	   tablaDos.CAMPO1, 
	   tablaDos.CAMPO2
FROM tablaUno RIGHT JOIN tablaDos 
	ON tablaUno.CAMPO1 = tablaDos.CAMPO1

---- JUNTAS COMPLETAS
-- ESTE tipo de juntas mostrara todas las filas de la tabla a izquierda y derecha, 
-- lo que pueda juntar a derecha. Cuando no tenga con que emparejar.
SELECT * 
FROM tablaUno FULL JOIN tablaDos 
	ON tablaUno.CAMPO1 = tablaDos.CAMPO1

-- PARA SABER CUALES VALORES DE AMBAS TABLAS NO TIENEN CORRESPONDENCIA EN LA OTRA.
SELECT * 
FROM tablaUno FULL JOIN tablaDos 
	ON tablaUno.CAMPO1 = tablaDos.CAMPO1
WHERE tablaUno.CAMPO1 is null or tablaDos.CAMPO1 is null
 

----Group by: Los grupos son el equivalente a la AGRUPACION de AR.
SELECT CAMPO2
FROM tablaUno 
GROUP BY campo2  -- << SE LISTARA, CON ESTE EJEMPLO, LOS VALORES DISTINTOS QUE SE TENGAN EN "CAMPO2" 
				--	agrupa (une) los elementos repetidos en el campo2

-- EJEMPLO, CUENTO CUANTAS OCURRENCIAS HAY DE CADA UNA
SELECT CAMPO2, COUNT(*) as [cantidad de ocurrencias]
FROM tablaUno 
GROUP BY campo2  -- << SE LISTARA, CON ESTE EJEMPLO, LOS VALORES DISTINTOS QUE SE TENGAN EN "CAMPO2" 

----Having: SI SE QUIERE REALIZAR SELECCIONES O APLICAR CONDICIONES LUEGO DEL GROUP BY, SE UTILIZA LA PALABRA RESERVADA HAVING
SELECT CAMPO2
FROM tablaUno
GROUP BY campo2
HAVING campo2 LIKE 'C' -- << ES IMPORTATE QUE LOS CAMPOS A UTILIZAR EN EL HAVING DEBEN ESTAR CONTENIDOS EN EL GROUP BY

----Orden by 
-- LA ULTIMA LINEA QUE SE TIENE EN EL SELECT ES EL order by. como su nombre lo indica, sirve para ordenar el resultado. 
-- con los decoradores ASC y DESC se indica ordenar ascendente o descendente.

SELECT *
FROM tablaUno
ORDER BY CAMPO1 -- << por defecto, ordena de forma ascendente

SELECT *
FROM tablaUno
ORDER BY CAMPO2 -- << por defecto, ordena de forma ascendente


SELECT *
FROM tablaUno
ORDER BY CAMPO2, CAMPO1 ASC

SELECT *
FROM tablaUno
ORDER BY CAMPO2, CAMPO1 DESC -- << ORDENAMOS Primero por el campo 2, luego por el campo 1. El campo2 de forma asc y el 2 de forma desc

SELECT *
FROM tablaUno
ORDER BY CAMPO2 DESC, CAMPO1 DESC -- << ORDENAMOS Primero por el campo 2, luego por el campo 1. El campo2 de forma asc y el 2 de forma desc

-------------

----Funciones de agregado
MIN -- toma el minimo de un conjunto
SUM -- suma el conjunto
COUNT -- cuenta los elementos de un conjunto. Es la UNICA que si no hay elementos en el 
      --  conjunto no da NULL, da 0.
MAX	  -- toma el maximo de un conjunto.
AVG	  -- promedia el conjunto
STRING_AGG -- acumula strings (concatena) -- incluida en SQL server 2017!!!

-- EJEMPLO CON TABLA VACIA
CREATE TABLE ejemploFuncAgr ( campo1 int );
INSERT INTO ejemploFuncAgr values (1), (2), (3), (4), (5), (1), (2), (3), (4), (5),(1), (2), (3), (4), (5)
SELECT * FROM ejemploFuncAgr ;

SELECT MIN(CAMPO1) AS MINIMO, MAX(campo1) MAXIMO, SUM(CAMPO1) SUMA, COUNT(CAMPO1) CUENTA 
FROM ejemploFuncAgr;

-- EJEMPLO CON DATOS
SELECT MAX(campo1) AS maximo, MIN(campo1) as minimo, AVG(campo1) AS PROMEDIO, count(campo1) AS CANTIDAD, string_agg(campo2, ', ') [CONCAT STRING]
FROM tablaUno
select * from tablaUno;

-- FUNCIONES DE AGREGADO CON AGRUPADORES
select * from tablaUno;

-- sin alias en las columnas!
SELECT MAX(campo1) , MIN(campo1) , AVG(campo1), 
count(campo1), campo2
FROM tablaUno
GROUP BY campo2
HAVING max(campo1) > 4

SELECT MAX(campo1) as maximo, MIN(campo1) minimo, AVG(campo1) [el promedio], 
count(campo1)[conteo de filas], campo2
FROM tablaUno
GROUP BY campo2
HAVING max(campo1) > 4

-- FUNCIONES DE AGREGADO CON AGRUPADORES Y FILTRO 
SELECT MAX(campo1) as [CAMPO max], MIN(campo1), AVG(campo1), count(campo1), campo2
FROM tablaUno
GROUP BY campo2
HAVING max(campo1) > 4

-- ALIAS: Renombrar tablas o columnas
SELECT T.CAMPO1 as c1, CAMPO2 c2
FROM tablaUno t
WHERE t.campo1 = 1
-- AR -->>>> tablaX (c1, c2) <- SEL campo1 = 1 (tabla1)

--distinct 
---> LISTAR SOLO LOS VALORES DISTINTOS DE UNA QUERY
--SIN
SELECT campo2 FROM tablaUno
--CON
SELECT distinct campo2 FROM tablaUno

---- Sub Consultas -----
-- en el select

SELECT *, (SELECT campo2 FROM tablaDos d WHERE u.campo1 = d.campo1) as subquery
FROM tablaUno u
-- ES IMPORTANTE ACLARAR QUE LAS SUB CONSULTAS EN EL SELECT DEBEN DEVOLVER 1 SOLA FILA POR CADA UNA DE LAS DEL SELECT PRINCIPAL
-- LA SUBCONSULTA DEL SELECT SE EJECUTARA TANTAS VECES COMO FILAS TENGA LA CONSULTA PRINCIPAL

-- EN EL FROM 
SELECT * 
FROM ( 
		SELECT campo1 AS id, campo2 AS descripcion 
		FROM tablaDos 
		WHERE campo1 > 3
	  ) AS T  
WHERE t.descriPcion LIKE '%pruebas'

-- ES IMPORTANTE ACLARAR QUE LAS SUB CONSULTAS EN EL FROM, 
-- TIENE QUE TENER SIEMPRE UN ALIAS!!!

-- EN EL WHERE
SELECT *
FROM tablaUno
WHERE campo1 IN (
				SELECT campo1
				FROM tablaDos
				WHERE campo2 LIKE 'm%'
				)
SELECT *
FROM tablaUno u
SELECT *
FROM tablaUno u
WHERE EXISTS (
		SELECT 'a'
		FROM tablaDos d
		WHERE d.campo2 LIKE 'm%'
		AND u.CAMPO1 = d.CAMPO1
		)
-- MISMA CONSULTA CON EXISTS E IN

-----------------------------------------------------------------------


--==========================================================================
--======                                                              ======
--======                     FIN CLASE SQL 1                          ======
--======                                                              ======
--==========================================================================

