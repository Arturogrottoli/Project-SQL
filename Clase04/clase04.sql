-- ============================================================
-- BASE DE DATOS NBA
-- ============================================================
-- Este script crea una base de datos para gestionar informacion
-- de la NBA: equipos, estadios, jugadores, temporadas,
-- partidos, records y estadisticas individuales.
--
-- Motor: MySQL
-- Sentencias utilizadas:
--   DDL -> CREATE (crear), ALTER (modificar), DROP (eliminar)
--   DML -> INSERT (insertar datos), SELECT (consultar datos)
-- ============================================================


-- ============================================================
-- PASO 1: CREAR LA BASE DE DATOS
-- ============================================================
-- Primero eliminamos la base si ya existe para empezar de cero.
-- Luego la creamos y la seleccionamos con USE para trabajar dentro de ella.

DROP DATABASE IF EXISTS nba;
CREATE DATABASE nba;
USE nba;


-- ============================================================
-- PASO 2: CREAR LAS TABLAS (DDL - CREATE TABLE)
-- ============================================================
-- Creamos las tablas en orden logico: primero las que NO dependen
-- de otras (estadios), luego las que SI dependen (equipos, jugadores, etc.)
-- Esto es importante porque las FOREIGN KEYS necesitan que la tabla
-- referenciada ya exista.
-- ============================================================


-- ------------------------------------------------------------
-- TABLA: estadios
-- Almacena la informacion de cada estadio de la NBA.
-- Se crea PRIMERO porque la tabla "equipos" la va a referenciar.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS estadios;
CREATE TABLE estadios (
    ID_Estadio INT AUTO_INCREMENT PRIMARY KEY,  -- Clave primaria, se autoincrementa
    Ciudad     VARCHAR(50) DEFAULT NULL,         -- Ciudad donde esta el estadio
    Nombre     VARCHAR(50) DEFAULT NULL,         -- Nombre del estadio
    Capacidad  INT NOT NULL                      -- Capacidad de espectadores
);


-- ------------------------------------------------------------
-- TABLA: equipos
-- Almacena los equipos de la NBA con su estadio, ciudad y titulos.
-- Tiene una FK que apunta a la tabla estadios.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS equipos;
CREATE TABLE equipos (
    ID_Equipo   INT AUTO_INCREMENT PRIMARY KEY,   -- Clave primaria
    ID_Estadio  INT NOT NULL,                     -- FK -> estadios(ID_Estadio)
    Nombre      VARCHAR(50) DEFAULT NULL,         -- Nombre del equipo
    Ciudad      VARCHAR(50) DEFAULT NULL,         -- Ciudad del equipo
    Titulos     INT DEFAULT NULL,                 -- Cantidad de campeonatos ganados
    Conferencia VARCHAR(20) DEFAULT NULL,         -- Conferencia: 'Este' u 'Oeste'
    FOREIGN KEY (ID_Estadio) REFERENCES estadios(ID_Estadio)
);


-- ------------------------------------------------------------
-- TABLA: jugadores
-- Almacena los jugadores con su equipo, datos personales y posicion.
-- Tiene una FK que apunta a la tabla equipos.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS jugadores;
CREATE TABLE jugadores (
    ID_Jugador      INT NOT NULL PRIMARY KEY,     -- Clave primaria (manual, no autoincrement)
    ID_Equipo       INT NOT NULL,                 -- FK -> equipos(ID_Equipo)
    Nombre          VARCHAR(50),                  -- Nombre completo del jugador
    FechaNacimiento DATE,                         -- Fecha de nacimiento
    Nacionalidad    VARCHAR(50),                  -- Pais de origen
    Posicion        VARCHAR(20),                  -- Posicion en cancha (Base, Escolta, Alero, Ala Pivot, Pivot)
    FOREIGN KEY (ID_Equipo) REFERENCES equipos(ID_Equipo)
);


-- ------------------------------------------------------------
-- TABLA: temporada
-- Registra las temporadas en las que participo cada equipo.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS temporada;
CREATE TABLE temporada (
    ID_Temporada INT AUTO_INCREMENT PRIMARY KEY,  -- Clave primaria
    ID_Equipo    INT NOT NULL,                    -- FK -> equipos(ID_Equipo)
    Season       VARCHAR(50),                     -- Ano de la temporada (ej: '1947')
    FOREIGN KEY (ID_Equipo) REFERENCES equipos(ID_Equipo)
);


-- ------------------------------------------------------------
-- TABLA: partidos
-- Registra los resultados de partidos entre equipos en cada temporada.
-- Tiene 3 FK: una a temporada y dos a equipos (local y visitante).
-- ------------------------------------------------------------

DROP TABLE IF EXISTS partidos;
CREATE TABLE partidos (
    ID_Partido          INT AUTO_INCREMENT PRIMARY KEY,
    ID_Temporada        INT NOT NULL,             -- FK -> temporada(ID_Temporada)
    ID_Equipo_Local     INT NOT NULL,             -- FK -> equipos(ID_Equipo) del equipo local
    ID_Equipo_Visitante INT NOT NULL,             -- FK -> equipos(ID_Equipo) del equipo visitante
    Resultado           VARCHAR(20),              -- Resultado del partido (ej: '120-80')
    FOREIGN KEY (ID_Temporada) REFERENCES temporada(ID_Temporada),
    FOREIGN KEY (ID_Equipo_Local) REFERENCES equipos(ID_Equipo),
    FOREIGN KEY (ID_Equipo_Visitante) REFERENCES equipos(ID_Equipo)
);


-- ------------------------------------------------------------
-- TABLA: record
-- Almacena el record de cada equipo en una temporada:
-- partidos ganados, perdidos, porcentaje de victorias y posicion.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS record;
CREATE TABLE record (
    ID_Record       INT AUTO_INCREMENT PRIMARY KEY,
    ID_Equipo       INT NOT NULL,                 -- FK -> equipos(ID_Equipo)
    ID_Temporada    INT NOT NULL,                 -- FK -> temporada(ID_Temporada)
    PartidosGanados  INT,                         -- Cantidad de partidos ganados
    PartidosPerdidos INT,                         -- Cantidad de partidos perdidos
    Ratio           FLOAT,                        -- Porcentaje de victorias (ej: 54.87%)
    Posicion        INT NOT NULL,                 -- Posicion en la tabla de la conferencia
    FOREIGN KEY (ID_Equipo) REFERENCES equipos(ID_Equipo),
    FOREIGN KEY (ID_Temporada) REFERENCES temporada(ID_Temporada)
);


-- ------------------------------------------------------------
-- TABLA: puntos
-- Registra los puntos totales y promedio de un jugador en una temporada.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS puntos;
CREATE TABLE puntos (
    ID_Puntos    INT PRIMARY KEY,
    ID_Jugador   INT NOT NULL,                    -- FK -> jugadores(ID_Jugador)
    ID_Temporada INT NOT NULL,                    -- FK -> temporada(ID_Temporada)
    Cantidad     INT,                             -- Puntos totales en la temporada
    Promedio     FLOAT,                           -- Promedio de puntos por partido
    FOREIGN KEY (ID_Jugador) REFERENCES jugadores(ID_Jugador),
    FOREIGN KEY (ID_Temporada) REFERENCES temporada(ID_Temporada)
);


-- ------------------------------------------------------------
-- TABLA: rebotes
-- Registra los rebotes totales y promedio de un jugador en una temporada.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS rebotes;
CREATE TABLE rebotes (
    ID_Rebotes   INT PRIMARY KEY,
    ID_Jugador   INT NOT NULL,                    -- FK -> jugadores(ID_Jugador)
    ID_Temporada INT NOT NULL,                    -- FK -> temporada(ID_Temporada)
    Cantidad     INT,                             -- Rebotes totales en la temporada
    Promedio     FLOAT,                           -- Promedio de rebotes por partido
    FOREIGN KEY (ID_Jugador) REFERENCES jugadores(ID_Jugador),
    FOREIGN KEY (ID_Temporada) REFERENCES temporada(ID_Temporada)
);


-- ------------------------------------------------------------
-- TABLA: asistencias
-- Registra las asistencias totales y promedio de un jugador en una temporada.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS asistencias;
CREATE TABLE asistencias (
    ID_Asistencias INT PRIMARY KEY,
    ID_Jugador     INT NOT NULL,                  -- FK -> jugadores(ID_Jugador)
    ID_Temporada   INT NOT NULL,                  -- FK -> temporada(ID_Temporada)
    Cantidad       INT,                           -- Asistencias totales en la temporada
    Promedio       FLOAT,                         -- Promedio de asistencias por partido
    FOREIGN KEY (ID_Jugador) REFERENCES jugadores(ID_Jugador),
    FOREIGN KEY (ID_Temporada) REFERENCES temporada(ID_Temporada)
);


-- ------------------------------------------------------------
-- TABLA: estadisticas
-- Tabla resumen que vincula a un jugador en una temporada con
-- sus puntos, rebotes y asistencias. Funciona como una tabla
-- de relacion (o tabla puente) que conecta todas las stats.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS estadisticas;
CREATE TABLE estadisticas (
    ID_Estadisticas INT PRIMARY KEY,
    ID_Jugador      INT NOT NULL,                 -- FK -> jugadores(ID_Jugador)
    ID_Temporada    INT NOT NULL,                 -- FK -> temporada(ID_Temporada)
    ID_Puntos       INT NOT NULL,                 -- FK -> puntos(ID_Puntos)
    ID_Rebotes      INT NOT NULL,                 -- FK -> rebotes(ID_Rebotes)
    ID_Asistencias  INT NOT NULL,                 -- FK -> asistencias(ID_Asistencias)
    FOREIGN KEY (ID_Jugador) REFERENCES jugadores(ID_Jugador),
    FOREIGN KEY (ID_Temporada) REFERENCES temporada(ID_Temporada),
    FOREIGN KEY (ID_Puntos) REFERENCES puntos(ID_Puntos),
    FOREIGN KEY (ID_Rebotes) REFERENCES rebotes(ID_Rebotes),
    FOREIGN KEY (ID_Asistencias) REFERENCES asistencias(ID_Asistencias)
);


-- ============================================================
-- PASO 3: INSERTAR DATOS (DML - INSERT INTO)
-- ============================================================
-- Insertamos los datos en el mismo orden que creamos las tablas:
-- primero estadios, luego equipos, jugadores, etc.
-- Esto respeta las FOREIGN KEYS (no puedo insertar un equipo
-- que referencia un estadio que todavia no existe).
-- ============================================================


-- ------------------------------------------------------------
-- DATOS: estadios (7 estadios de la conferencia Este)
-- ------------------------------------------------------------

INSERT INTO estadios (ID_Estadio, Ciudad, Nombre, Capacidad)
VALUES
    (1, 'Atlanta',   'State Farm Arena',              16600),
    (2, 'Boston',    'TD Garden',                     18624),
    (3, 'Brooklyn',  'Barclays Center',               17732),
    (4, 'Charlotte', 'Spectrum Center',               19077),
    (5, 'Chicago',   'United Center',                 23500),
    (6, 'Cleveland', 'Rocket Mortgage FieldHouse',    19432),
    (7, 'Detroit',   'Little Caesars Arena',           20332);


-- ------------------------------------------------------------
-- DATOS: equipos (7 equipos de la conferencia Este)
-- Cada equipo se asocia a su estadio mediante ID_Estadio (FK)
-- ------------------------------------------------------------

INSERT INTO equipos (ID_Equipo, ID_Estadio, Nombre, Ciudad, Titulos, Conferencia)
VALUES
    (1, 1, 'Atlanta Hawks',        'Atlanta',    1,  'Este'),
    (2, 2, 'Boston Celtics',       'Boston',     17, 'Este'),
    (3, 3, 'Brooklyn Nets',        'Brooklyn',   2,  'Este'),
    (4, 4, 'Charlotte Hornets',    'Charlotte',  0,  'Este'),
    (5, 5, 'Chicago Bulls',        'Chicago',    6,  'Este'),
    (6, 6, 'Cleveland Cavaliers',  'Cleveland',  1,  'Este'),
    (7, 7, 'Detroit Pistons',      'Detroit',    3,  'Este');


-- ------------------------------------------------------------
-- DATOS: jugadores (18 jugadores repartidos en 4 equipos)
-- Cada jugador se asocia a su equipo mediante ID_Equipo (FK)
--
-- Posiciones en basquet:
--   Base (PG)       = El que dirige el juego y distribuye el balon
--   Escolta (SG)    = Tirador principal desde el perimetro
--   Alero (SF)      = Jugador versatil, ataque y defensa
--   Ala Pivot (PF)  = Juega cerca del aro, pero tambien puede tirar
--   Pivot (C)       = El mas alto, juega debajo del aro
-- ------------------------------------------------------------

INSERT INTO jugadores (ID_Jugador, ID_Equipo, Nombre, FechaNacimiento, Nacionalidad, Posicion)
VALUES
    -- Atlanta Hawks (ID_Equipo = 1)
    (1,  1, 'Bogdan Bogdanovic', '1992-08-18', 'Serbio',          'Escolta'),
    (2,  1, 'Clint Capela',      '1994-05-18', 'Suizo',           'Pivot'),
    (3,  1, 'John Collins',      '1997-09-23', 'Estadounidense',  'Ala Pivot'),
    (4,  1, 'Sharife Cooper',    '2001-06-11', 'Estadounidense',  'Base'),
    (5,  1, 'Gorgui Dieng',     '1990-01-18', 'Senegales',       'Pivot'),

    -- Boston Celtics (ID_Equipo = 2)
    (6,  2, 'Bol Bol',          '1999-11-16', 'Estadounidense',  'Pivot'),
    (7,  2, 'Jaylen Brown',     '1996-10-24', 'Estadounidense',  'Escolta'),
    (8,  2, 'P.J. Dozier',      '1996-10-25', 'Estadounidense',  'Base'),

    -- Brooklyn Nets (ID_Equipo = 3)
    (9,  3, 'LaMarcus Aldridge', '1985-07-19', 'Estadounidense',  'Ala Pivot'),
    (10, 3, 'DeAndre Bembry',    '1994-07-04', 'Estadounidense',  'Alero'),
    (11, 3, 'Bruce Brown',       '1996-07-15', 'Estadounidense',  'Ala Pivot'),
    (12, 3, 'Jevon Carter',      '1995-09-14', 'Estadounidense',  'Base'),

    -- Charlotte Hornets (ID_Equipo = 4)
    (13, 4, 'LaMelo Ball',       '2001-08-22', 'Estadounidense',  'Base'),
    (14, 4, 'James Bouknight',   '2000-09-18', 'Estadounidense',  'Escolta'),
    (15, 4, 'Miles Bridges',     '1998-03-21', 'Estadounidense',  'Alero'),
    (16, 4, 'Montrezl Harrell',  '1994-01-26', 'Estadounidense',  'Ala Pivot'),
    (17, 4, 'Gordon Hayward',    '1990-03-23', 'Estadounidense',  'Alero'),
    (18, 4, 'Kai Jones',         '2001-01-19', 'Bahameno',        'Pivot');


-- ------------------------------------------------------------
-- DATOS: temporada
-- Registra en que temporadas participaron algunos equipos.
-- Season indica el ano de inicio de la temporada.
-- ------------------------------------------------------------

INSERT INTO temporada (ID_Temporada, ID_Equipo, Season)
VALUES
    (1, 3, '1947'),    -- Brooklyn Nets, temporada 1947
    (2, 2, '1948'),    -- Boston Celtics, temporada 1948
    (3, 2, '1949'),    -- Boston Celtics, temporada 1949
    (4, 1, '1950');    -- Atlanta Hawks, temporada 1950


-- ------------------------------------------------------------
-- DATOS: partidos
-- Resultados de partidos entre equipos en cada temporada.
-- Formato del resultado: 'puntos_local-puntos_visitante'
-- ------------------------------------------------------------

INSERT INTO partidos (ID_Partido, ID_Temporada, ID_Equipo_Local, ID_Equipo_Visitante, Resultado)
VALUES
    (1, 1, 1, 2, '120-80'),   -- Temporada 1947: Hawks (local) vs Celtics (visitante)
    (2, 2, 3, 4, '110-89'),   -- Temporada 1948: Nets (local) vs Hornets (visitante)
    (3, 3, 1, 3, '90-95'),    -- Temporada 1949: Hawks (local) vs Nets (visitante)
    (4, 4, 2, 4, '99-82');    -- Temporada 1950: Celtics (local) vs Hornets (visitante)


-- ------------------------------------------------------------
-- DATOS: record
-- Record de cada equipo en una temporada:
-- - PartidosGanados / PartidosPerdidos
-- - Ratio = porcentaje de victorias (ganados / total * 100)
-- - Posicion = lugar en la tabla de la conferencia
-- ------------------------------------------------------------

INSERT INTO record (ID_Record, ID_Equipo, ID_Temporada, PartidosGanados, PartidosPerdidos, Ratio, Posicion)
VALUES
    (1, 1, 1, 45, 37, 54.87, 6),    -- Hawks en temporada 1947: 45-37, 6to lugar
    (2, 2, 4, 50, 32, 60.97, 3),    -- Celtics en temporada 1950: 50-32, 3er lugar
    (3, 1, 2, 30, 52, 36.58, 10),   -- Hawks en temporada 1948: 30-52, 10mo lugar
    (4, 4, 3, 40, 42, 48.78, 8);    -- Hornets en temporada 1949: 40-42, 8vo lugar


-- ------------------------------------------------------------
-- DATOS: puntos
-- Puntos totales y promedio por partido de cada jugador en una temporada.
-- ------------------------------------------------------------

INSERT INTO puntos (ID_Puntos, ID_Jugador, ID_Temporada, Cantidad, Promedio)
VALUES
    (1, 1, 1, 820,  10.00),   -- Bogdanovic en temp. 1947: 820 puntos, 10.00 PPG
    (2, 2, 4, 1437, 17.52),   -- Capela en temp. 1950: 1437 puntos, 17.52 PPG
    (3, 3, 2, 752,  9.17),    -- Collins en temp. 1948: 752 puntos, 9.17 PPG
    (4, 4, 3, 452,  5.51);    -- Cooper en temp. 1949: 452 puntos, 5.51 PPG


-- ------------------------------------------------------------
-- DATOS: rebotes
-- Rebotes totales y promedio por partido de cada jugador en una temporada.
-- ------------------------------------------------------------

INSERT INTO rebotes (ID_Rebotes, ID_Jugador, ID_Temporada, Cantidad, Promedio)
VALUES
    (1, 1, 1, 620,  7.56),    -- Bogdanovic en temp. 1947: 620 rebotes, 7.56 RPG
    (2, 2, 4, 1022, 12.46),   -- Capela en temp. 1950: 1022 rebotes, 12.46 RPG
    (3, 3, 2, 256,  3.12),    -- Collins en temp. 1948: 256 rebotes, 3.12 RPG
    (4, 4, 3, 427,  5.20);    -- Cooper en temp. 1949: 427 rebotes, 5.20 RPG


-- ------------------------------------------------------------
-- DATOS: asistencias
-- Asistencias totales y promedio por partido de cada jugador en una temporada.
-- ------------------------------------------------------------

INSERT INTO asistencias (ID_Asistencias, ID_Jugador, ID_Temporada, Cantidad, Promedio)
VALUES
    (1, 1, 1, 510, 6.21),     -- Bogdanovic en temp. 1947: 510 asistencias, 6.21 APG
    (2, 2, 4, 856, 10.43),    -- Capela en temp. 1950: 856 asistencias, 10.43 APG
    (3, 3, 2, 420, 5.12),     -- Collins en temp. 1948: 420 asistencias, 5.12 APG
    (4, 4, 3, 512, 6.24);     -- Cooper en temp. 1949: 512 asistencias, 6.24 APG


-- ------------------------------------------------------------
-- DATOS: estadisticas
-- Tabla resumen que vincula jugador + temporada + puntos + rebotes + asistencias.
-- Cada fila conecta los IDs de las otras tablas para tener
-- todas las estadisticas de un jugador en un solo lugar.
-- ------------------------------------------------------------

INSERT INTO estadisticas (ID_Estadisticas, ID_Jugador, ID_Temporada, ID_Puntos, ID_Rebotes, ID_Asistencias)
VALUES
    (1, 1, 1, 1, 1, 1),   -- Bogdanovic, temp. 1947: stats completas
    (2, 2, 2, 2, 2, 2),   -- Capela, temp. 1948: stats completas
    (3, 3, 3, 3, 3, 3),   -- Collins, temp. 1949: stats completas
    (4, 4, 4, 4, 4, 4);   -- Cooper, temp. 1950: stats completas


-- ============================================================
-- CONSULTAS DE VERIFICACION (DML - SELECT)
-- ============================================================
-- Estas consultas sirven para verificar que los datos se
-- insertaron correctamente. Usa SELECT * para ver todo el
-- contenido de cada tabla.
-- ============================================================

SELECT * FROM estadios;
SELECT * FROM equipos;
SELECT * FROM jugadores;
SELECT * FROM temporada;
SELECT * FROM partidos;
SELECT * FROM record;
SELECT * FROM puntos;
SELECT * FROM rebotes;
SELECT * FROM asistencias;
SELECT * FROM estadisticas;
