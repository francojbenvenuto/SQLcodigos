create database bancos;
go
use bancos;
go
create table Pais(pais char(50) primary key);
create table Banco(id int primary key, nombre varchar(50), pais char(50));
create table Moneda(id char(2) primary key, descripcion varchar(50), valorOro
decimal(18,3), valorPetroleo decimal(18,3));
create table Persona(pasaporte char(15) primary key, codigoFiscal int, nombre
varchar(50));
create table Cuenta(id int primary key, monto decimal(18,3), idBanco int not null, idMoneda char(2) not
null, idPersona char(15) not null);
create table Opera(idBanco int not null, idMoneda char(2) not null, cambioCompra
decimal(18,3), cambioVenta decimal(18,3), constraint PK_Opera primary key(idBanco,
idMoneda));
go
alter table cuenta add constraint fk_banco_idBanco foreign key (idBanco) references Banco(id)
alter table cuenta add constraint fk_banco_idMoneda foreign key (idMoneda) references Moneda(id)
alter table cuenta add constraint fk_banco_idPersona foreign key (idPersona) references Persona(pasaporte)

alter table opera add constraint fk_opera_idBanco foreign key (idBanco) references Banco(id)
alter table opera add constraint fk_opera_idMoneda foreign key (idMoneda) references Moneda(id)

alter table banco add constraint fk_pais_idBanco foreign key (pais) references Pais(pais)

go
INSERT INTO pais (pais) VALUES ('Argentina');
INSERT INTO pais (pais) VALUES ('USA');
INSERT INTO pais (pais) VALUES ('Uruguay');
INSERT INTO pais (pais) VALUES ('España');
INSERT INTO pais (pais) VALUES ('Alemania');
INSERT INTO pais (pais) VALUES ('Suiza');
INSERT INTO banco (id, nombre, pais) VALUES ('1', 'Banco Nacion', 'Argentina');
INSERT INTO banco (id, nombre, pais) VALUES ('2', 'Banco Montevideo', 'Uruguay');
INSERT INTO banco (id, nombre, pais) VALUES ('3', 'Banco Ciudad', 'Argentina');
INSERT INTO banco (id, nombre, pais) VALUES ('4', 'City Bank', 'USA');
INSERT INTO banco (id, nombre, pais) VALUES ('5', 'Switzerland Bank', 'Suiza');
INSERT INTO banco (id, nombre, pais) VALUES ('6', 'BBVA', 'España');
INSERT INTO moneda (id, descripcion, valorOro, valorPetroleo) VALUES ('AR', 'Peso Argentino','2', '1');
INSERT INTO moneda (id, descripcion, valorOro, valorPetroleo) VALUES ('UY', 'Peso Uruguayo','5', '2.5');
INSERT INTO moneda (id, descripcion, valorOro, valorPetroleo) VALUES ('US', 'Dolar', '1','1.5');
INSERT INTO moneda (id, descripcion, valorOro, valorPetroleo) VALUES ('EU', 'Euro', '2', '1');
INSERT INTO persona (pasaporte, codigoFiscal, nombre) VALUES ('1', '1234', 'Bill Gates');
INSERT INTO persona (pasaporte, codigoFiscal, nombre) VALUES ('2', '12112', 'Carlos Slim');
INSERT INTO persona (pasaporte, codigoFiscal, nombre) VALUES ('3', '2325', 'Lionel Messi');
INSERT INTO persona (pasaporte, codigoFiscal, nombre) VALUES ('4', '01243', 'Diego Maradona');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (1,'100000', '4', 'US', '1');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (2,'20000', '5', 'EU', '1');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (3,'15000', '2', 'US', '1');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (4,'50000', '4', 'US', '2');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (5,'35000', '5', 'US', '2');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (6,'2000', '1', 'AR', '3');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (7,'10000', '4', 'US', '3');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (8,'15000', '5', 'US', '3');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (9,'15000', '5', 'US', '4');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (10,'2000', '2', 'AR', '3');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (11,'10000', '3', 'US', '3');
INSERT INTO cuenta (id, monto, idBanco, idMoneda, idPersona) VALUES (12,'15000', '6', 'US', '3');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('1', 'US', '1', '1');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('2', 'US', '1', '1');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('3', 'US', '1', '1');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('4', 'US', '1', '1');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('5', 'US', '1', '1');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('6', 'US', '1', '1');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('1', 'EU', '2', '2');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('2', 'EU', '2', '2');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('3', 'EU', '3', '3');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('4', 'EU', '2', '2');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('5', 'EU', '2.2','2.2');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('6', 'EU', '2.2','2.5');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('1', 'AR', '5', '5');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('3', 'AR', '5.5', '5.5');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('2', 'AR', '7', '7');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('1', 'UY', '3', '3');
INSERT INTO opera (idBanco, idMoneda, cambioCompra, cambioVenta) VALUES ('2', 'UY', '2', '2');