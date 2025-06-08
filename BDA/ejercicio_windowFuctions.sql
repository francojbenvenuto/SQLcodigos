use master
go

IF NOT EXISTS ( SELECT name FROM master.dbo.sysdatabases WHERE name =
'PracticaWF')
BEGIN
CREATE DATABASE PracticaWF
COLLATE Latin1_General_CI_AI;
END
go

use PracticaWF
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name =
'tablasWF')
BEGIN
EXEC('CREATE SCHEMA tablasWF')
END
GOIF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'tablasWF' AND TABLE_NAME =
'Empleados')
BEGIN
CREATE TABLE tablaswf.Empleados (
 EmpleadoID INT identity(1,1) primary key,
Nombre VARCHAR(50),
Departamento VARCHAR(50),
Salario DECIMAL(10, 2)
)
END
GOINSERT INTO tablaswf.Empleados (Nombre, Departamento, Salario)
VALUES
('Juan', 'Ventas', 3000.00),
('María', 'Ventas', 2800.00),
('Pedro', 'Marketing', 3200.00),
('Laura', 'Marketing', 3500.00),
('Carlos', 'IT', 4000.00);select  empleadoID, Nombre, Departamento, Salario, rank() over(ORDER BY Salario DESC) as OrdenEmpleadosSalariofrom tablaswf.empleadosgoSELECT EmpleadoID, Nombre, Departamento, Salario,
    ROW_NUMBER() OVER (ORDER BY Salario DESC) AS OrdenEmpleadosSalario
FROM tablaswf.Empleados
go
---2---

INSERT INTO tablaswf.Empleados (Nombre, Departamento, Salario)
VALUES
('Laura', 'Ventas', 1800.00),
('yo', 'Ventas', 32200.00),
('Laura', 'Marketing', 1477.00),
('Esteban', 'Marketing', 15000.00),
('Laura', 'IT', 452.00),
('Romina', 'Ventas', 7855.00),
('Susana', 'Ventas', 1233.00),
('Mateo', 'Marketing', 4755.00),
('Nicolas', 'Marketing', 1236.00),
('Federico', 'IT', 260611.00),
('Miguel', 'Ventas', 4688.00),
('Josefina', 'Ventas', 2855.00),
('Franco', 'Marketing', 7456.00),
('Cesar', 'Marketing', 2555.00),
('Patricio', 'IT', 4000.00)select EmpleadoID, Nombre, Departamento, Salario, rank()over(PARTITION BY Departamento order by Salario desc) as rankingfrom tablaswf.EmpleadosgoSELECT EmpleadoID, Nombre, Departamento, Salario,
    RANK() OVER (PARTITION BY Departamento ORDER BY Salario DESC) AS Ranking
    FROM tablaswf.empleados
go


---3---

select EmpleadoID, Nombre, Departamento, salario, ntile(4) over(order by salario desc) as grupoSocial
from tablaswf.empleados

SELECT EmpleadoID, Nombre, Departamento, Salario,
NTILE(4) OVER (ORDER BY Salario DESC) AS GrupoSalario
FROM tablaswf.Empleados
go


---4---

select empleadoID, Nombre, departamento
, salario
, lag(salario,1,0) over(partition by departamento order by salario) antes
, lead(salario,1,0) over(partition by departamento order by salario) despues
from tablaswf.empleados


	SELECT EmpleadoID, Nombre, Departamento, Salario,
    LAG(Salario, 1, 0) OVER (PARTITION BY Departamento ORDER BY Salario) AS SalarioAnterior,
    LEAD(Salario, 1, 0) OVER (PARTITION BY Departamento ORDER BY Salario) AS SiguienteSalario
    FROM tablaswf.Empleados
go


---5---

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA ='tablasWF' AND TABLE_NAME ='Clientes')
BEGIN
CREATE TABLE tablaswf.Clientes 
(
id_cliente INT identity(1,1) PRIMARY KEY,
nombre VARCHAR(50),
pais VARCHAR(50)
)
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='tablasWF' AND TABLE_NAME ='Pedidos')
BEGIN
CREATE TABLE tablaswf.Pedidos (
 id_pedido INT PRIMARY KEY,
id_cliente INT,
fecha_pedido DATE,
monto DECIMAL(10, 2),
 FOREIGN KEY (id_cliente) REFERENCES tablaswf.Clientes(id_cliente)
)
END
GOINSERT INTO tablaswf.Clientes (nombre, pais)
VALUES	('John Doe', 'Argentina'), 		('Jane Smith', 'Australia'), 		('Juan García', 'Brasil'), 		('Maria Hernandez', 'Canadá'), 		('Michael Johnson', 'China'), 		('Sophie Martin', 'Dinamarca'), 		('Ahmad Khan', 'Egipto'), 		('Emily Brown', 'Francia'), 		('Hans Müller', 'Alemania'), 		('Sofia Rossi', 'Italia'), 		('Takeshi Yamada', 'Japón'), 		('Javier López', 'México'), 		('Eva Novak', 'Países Bajos'), 		('Rafael Silva', 'Portugal'), 		('Olga Petrova', 'Rusia'), 		('Fernanda Gonzalez', 'España'), 		('Mohammed Ali', 'Egipto'), 		('Lena Schmidt', 'Alemania'), 		('Yuki Tanaka', 'Japón'), 		('Lucas Costa', 'Brasil');
DECLARE @startDate DATE = '2023-01-01';
DECLARE @endDate DATE = '2023-12-31';
DECLARE @orderId INT = 1;
WHILE @orderId <= 100
BEGIN
INSERT INTO tablaswf.Pedidos (id_pedido,id_cliente, fecha_pedido, monto)
VALUES (@orderId,((@orderId - 1) % 20) + 1, 
DATEADD(DAY, ABS(CHECKSUM(NEWID())) % (DATEDIFF(DAY, @startDate, @endDate) + 1),
@startDate), ROUND(RAND(CHECKSUM(NEWID())) * 5000 + 1000, 2));
SET @orderId = @orderId + 1;
END

--------------------------------------

select id_pedido, id_cliente,monto
,avg(monto) over(partition by id_cliente) promedio_monto
,rank() over(partition by id_cliente order by monto) posicion
from tablaswf.Pedidos


SELECT id_pedido, id_cliente, monto,
    AVG(monto) OVER (PARTITION BY id_cliente) AS promedio_monto_cliente,
    ROW_NUMBER() OVER (PARTITION BY id_cliente ORDER BY monto) AS posicion_rel_monto_cliente
FROM tablaswf.Pedidos;
go

---6---
-- CTE-----
with rankeCliente (nombre, pais, montoTotal, ranking_x_pais) as (
select c.nombre, c.pais
, Sum(p.monto)
, rank()over(partition by c.pais order by Sum(p.monto) desc) as ranking_x_pais
from tablaswf.clientes c
inner JOIN tablaswf.pedidos p on c.id_cliente = p.id_cliente
group by c.nombre, c.pais
)
select *
from rankeCliente
where ranking_x_pais <= 3
---SIN CTE-------------
SELECT *
FROM (
    SELECT 
        c.nombre,
        c.pais,
        SUM(p.monto) AS monto_total_pedidos,
        RANK() OVER (PARTITION BY c.pais ORDER BY SUM(p.monto) DESC) AS ranking_por_pais
    FROM tablaswf.Clientes c
    INNER JOIN tablaswf.Pedidos p ON c.id_cliente = p.id_cliente
    GROUP BY c.nombre, c.pais
) ranked_clients
WHERE ranking_por_pais <= 3;
go


------7---------

select id_pedido, id_cliente, fecha_pedido, monto
, monto - lead(monto,1) over(partition by id_cliente order by fecha_pedido)as diferenciamonto
from tablaswf.pedidos
order by id_cliente, fecha_pedido


----8------------

select p.id_pedido, c.id_cliente, c.pais,p.monto
,PERCENT_RANK()over(partition by c.pais order by p.monto asc) as porcentil_monto
from tablaswf.Clientes c
inner join tablaswf.Pedidos p on c.id_cliente = p.id_cliente
order by c.pais


SELECT p.id_pedido,p.id_cliente,c.pais,p.monto,
    PERCENT_RANK() OVER (PARTITION BY c.pais ORDER BY p.monto) AS percentil_monto
FROM tablaswf.Pedidos p
INNER JOIN tablaswf.Clientes c ON p.id_cliente = c.id_cliente
ORDER BY c.pais, p.monto;
go



-----9------

select p.id_pedido, c.id_cliente, c.nombre
, count(*) over(partition by c.id_cliente) as totalPedidos
, rank() over(partition by c.id_cliente order by p.fecha_pedido) as pos
from tablaswf.clientes c
inner join tablaswf.pedidos p on p.id_cliente = c.id_cliente
order by c.id_cliente







SELECT  p.id_pedido, p.id_cliente, c.nombre AS nombre_cliente,
    COUNT(*) OVER (PARTITION BY p.id_cliente) AS total_pedidos_cliente,
    ROW_NUMBER() OVER (PARTITION BY p.id_cliente ORDER BY p.fecha_pedido) AS posicion_rel_pedidos_cliente
FROM tablaswf.Pedidos p
JOIN tablaswf.Clientes c ON p.id_cliente = c.id_cliente
ORDER BY p.id_cliente, p.fecha_pedido;






-------------------PRACTICANDO PIVOT-------------------



SELECT nombre, [Argentina], [Chile], [Perú]
FROM (
    SELECT c.nombre, c.pais, p.monto
    FROM clientes c
    JOIN pedidos p ON c.id = p.id_cliente
) AS base
PIVOT (
    SUM(monto)
    FOR pais IN ([Argentina], [Chile], [Perú])
) AS p;


select *
from tablaswf.Empleados
PIVOT ( max(Salario) for nombre in (laura) ) A
order by Salario





tablaswf.Empleados (Nombre, Departamento, Salario)

Marketing
IT
Ventas