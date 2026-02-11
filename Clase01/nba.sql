#Creacion de la base de datos de la NBA
#Sentencias DDL ----> Create (Crear), Alter (Modificar), Drop (Borrar)
#Create database if not exist;

DROP database IF EXISTS nba;
create database nba;
use nba;

#select * from equipos;

#Creacion de tabla para luego cargar los equipos


DROP table IF EXISTS equipos;
create table equipos(
ID_Equipo int auto_increment primary key,
ID_Estadio int not null,
Nombre varchar(50) DEFAULT NULL,
Ciudad varchar(50) DEFAULT NULL,
Titulos int DEFAULT NULL,
Conferencia varchar(20) DEFAULT NULL
);

describe equipos;

INSERT INTO equipos (ID_Equipo, ID_Estadio,   Nombre, Ciudad, Titulos, Conferencia) 
VALUES 
(01, 01,  'Atlanta Hawks', 'Atlanta', 1, 'Este'), 
(02, 02,  'Boston Celtics','Boston',17, 'Este'),
(03, 03,  'Brooklyn Nets','Brooklyn',2, 'Este'),
(04, 04,  'Charlotte Hornets','Charlotte',0, 'Este'),
(05, 05,  'Chicago Bulls','Chicago',6, 'Este'),
(06, 06,  'Cleveland Cavaliers','Cleveland',1, 'Este'),
(07, 07,  'Detroit Pistons','Detroit',3, 'Este');



#update equipos set Nombre = 'LA Lakers', Ciudad = 'Los  Angeles' where id = 07;

SELECT  ID_EQUIPO, NOMBRE FROM Equipos;
describe equipos;

#Creacion de la tabla estadios

DROP table IF EXISTS estadios;
create table estadios(
ID_Estadio int auto_increment primary key not null,
Ciudad varchar(50) default null,
Nombre varchar(50) default null,
Capacidad int not null
);

#Asignacion de cada estadio con su respectivo equipo

INSERT INTO estadios (ID_Estadio,  Ciudad, Nombre, Capacidad) 
VALUES 
('01',   'Atlanta','State Farm Arena', '16600'), 
('02',   'Boston','TD Garden', '18624'),
('03',   'Brooklyn','Barclays Center', '17732'),
('04',   'Charlotte','Spectrum Center', '19077'),
('05',   'Chicago','United Center', '23500'),
('06',   'Cleveland','	Rocket Mortgage FieldHouse', '19432'),
('07',   'Detroit','	Little Caesars Arena', '20332');

select * from estadios;

#Creo la tabla de los jugadores para asignar a cada equipo

DROP table IF EXISTS jugadores;
create table jugadores(
ID_Jugador int not null primary key,
ID_Equipo int not null,
Nombre varchar(50),
FechaNacimiento date,
Nacionalidad varchar(50),
Posicion varchar(20)
);

#alter table jugadores add column campeonatos int after Posicion

#Agrego los jugadores a su respectivo equipo junto con sus datos

INSERT INTO jugadores ( ID_Jugador, ID_Equipo,  Nombre, FechaNacimiento, Nacionalidad, Posicion) 
VALUES 
(01, 01,  'Bogdan Bogdanovic', '1992/08/18', 'Serbio', 'Escolta'), 
(02, 01,  'Clint Capela', '1994/05/18', 'Suizo', 'Pivot'), 
(03, 01,  '	John Collins', '1997/09/23', 'Estadounidense', 'Ala Pivot'), 
(04, 01,  'Sharife Cooper', '2001/06/11', 'Estadounidense', 'Base'), 
(05, 01,  '	Gorgui Dieng', '1990/01/18', 'Senegales', 'Pivot'), 
(06, 02,  'Bol Bol', '1999/11/16', 'Estadounidense', 'Pivot'), 
(07, 02,  'Jaylen Brown', '1996/10/24', 'Estadounidense', 'Escolta'), 
(08, 02,  '	P.J. Dozier', '1996/10/25', 'Estadounidense', 'Base'), 
(09, 03,  '	LaMarcus Aldridge', '1985/07/19', 'Estadounidense', 'Ala Pivot'), 
(10, 03,  '	DeAndre Bembry', '1994/07/04', 'Estadounidense', 'Alero'),
(11, 03,  '	Bruce Brown', '1996/07/15', 'Estadounidense', 'Ala Pivot'),
(12, 03,  'Jevon Carter', '1995/09/14', 'Estadounidense', 'Base'),
(13, 04,  'LaMelo Ball', '2001/08/22', 'Estadounidense', 'Base'),
(14, 04,  'James Bouknigh', '2000/09/18', 'Estadounidense', 'Escolta'),
(15, 04,  'Miles Bridges', '1998/03/21', 'Estadounidense', 'Alero'),
(16, 04,  '	Montrezl Harrell', '1994/01/26', 'Estadounidense', 'Ala Pivot'),
(17, 04,  '	Gordon Hayward', '1990/03/23', 'Estadounidense', 'Alero'),
(18, 04,  '	Kai Jones', '2001/01/19', 'Bahameño', 'Pivot');

#Se crea una tabla para saber de que temporada son los equipos y datos obtenidos
select * from jugadores;

DROP table IF EXISTS temporada;
create table temporada(
ID_Temporada int auto_increment primary key,
ID_Equipo int not null,
Season varchar(50)
);

#Se agregan algunas temporadas de algunos equipos

INSERT INTO Temporada (ID_Temporada, ID_Equipo, Season) 
VALUES 
(01,   03,  1947), 
(02,   02,  1948),
(03,   02,  1949),
(04,   01,  1950);

#Se crea tabla que refleje resultados de partidos entre equipos en determinada temporada

DROP table IF EXISTS Partidos;
create table Partidos(
ID_Partido int auto_increment primary key,
ID_Temporada int not null,
ID_Equipo_Local int not null,
ID_Equipo_Visitante int not null,
Resultado varchar(20)
);

#Se cargan algunos resultados de partidos en cada temporada cargada

INSERT INTO partidos (ID_Partido,ID_Temporada, ID_Equipo_Local,ID_Equipo_Visitante, Resultado) 
VALUES 
(01,   01,  01, 02, '120-80'), 
(02,   02,  03, 04, '110-89'), 
(03,   03,  01, 03, '90-95'), 
(04,   04,  02, 04, '99-82') ;

#se crea tabla en la cual se va a ver el record (Cantidad de partidos ganados y perdidos) de determinada temporada


DROP table IF EXISTS record;
create table record(
ID_Record int auto_increment primary key,
ID_Equipo int not null,
ID_Temporada int not null,
PartidosGanados int,
PartidosPerdidos int,
Ratio float,
Posicion int not null
);

#Se cargan los records correspondientes

INSERT INTO Record (ID_Record,ID_Equipo, ID_Temporada,PartidosGanados, PartidosPerdidos, Ratio, Posicion) 
VALUES 
(01,   01,  01, 45, 37, 54.87, 6), 
(02,   02,  04, 50, 32, 60.97, 3), 
(03,   01,  02, 30, 52, 36.58, 10), 
(04,   04,  03, 40, 42, 48.78, 8);

#Se crea una tabla para llevar reconto de los puntos de cada jugador

DROP table IF EXISTS puntos;
create table puntos(
ID_Puntos int primary key,
ID_Jugador int not null,
ID_Temporada int not null,
Cantidad int,
Promedio float
);


#Se cargan los puntos de algunos jugadores

INSERT INTO puntos (ID_Puntos,ID_Jugador, ID_Temporada, Cantidad, Promedio) 
VALUES 
(01,   01,  01, 820,  10.00), 
(02,   02,  04, 1437,  17.52),
(03,   03,  02, 752,  9.17), 
(04,   04,  03, 452,  5.51);

#Se crea tabla para llevar cuenta de rebotes de los jugadores

DROP table IF EXISTS rebotes;
create table rebotes(
ID_Rebotes int primary key,
ID_Jugador int not null,
ID_Temporada int not null,
Cantidad int,
Promedio float
);


#Se carga informacion acerca de los rebotes de los jugadores

INSERT INTO rebotes (ID_Rebotes,ID_Jugador, ID_Temporada, Cantidad, Promedio) 
VALUES 
(01,   01,  01, 620,  7.56), 
(02,   02,  04, 1022,  12.46),
(03,   03,  02, 256,  3.12), 
(04,   04,  03, 427,  5.20);

#Mismo caso que los dos anteriores pero con asistencias

DROP table IF EXISTS asistencias;
create table asistencias(
ID_Asistencias int primary key,
ID_Jugador int not null,
ID_Temporada int not null,
Cantidad int,
Promedio float
);

INSERT INTO asistencias (ID_Asistencias,ID_Jugador, ID_Temporada, Cantidad, Promedio) 
VALUES 
(01,   01,  01, 510,  6.21), 
(02,   02,  04, 856,  10.43),
(03,   03,  02, 420,  5.12), 
(04,   04,  03, 512,  6.24);


#Creo una tabla llamada estadisticas donde se juntan varias observaciones

DROP table IF EXISTS estadisticas;
create table estadisticas(
ID_Estadisticas int  primary key,
ID_Jugador int not null,
ID_Temporada int not null,
ID_Puntos int not null,
ID_Rebotes int not null,
ID_Asistencias int not null
);

INSERT INTO estadisticas (ID_Estadisticas ,ID_Jugador, ID_Temporada, ID_Puntos, ID_Rebotes, ID_Asistencias) 
VALUES 
(01,   01,  01, 01,  01, 01), 
(02,   02,  02, 02, 02,02),
(03,   03,  03, 03, 03,03),
(04,   04,  04, 04, 04,04);

