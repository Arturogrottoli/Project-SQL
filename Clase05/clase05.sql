-- ============================================================
-- CLASE 05: DML - INSERT, UPDATE, DELETE + SUBCONSULTAS
-- Motor: MySQL
-- ============================================================


-- ============================================================
-- SETUP: recreamos la base musica (misma que clase04)
-- Agregamos dos tablas nuevas para los ejercicios de hoy
-- ============================================================

DROP DATABASE IF EXISTS musica;
CREATE DATABASE musica;
USE musica;

CREATE TABLE artistas (
    id_artista  INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    pais        VARCHAR(50),
    genero      VARCHAR(50),
    anio_debut  INT
);

CREATE TABLE canciones (
    id_cancion      INT AUTO_INCREMENT PRIMARY KEY,
    id_artista      INT NOT NULL,
    titulo          VARCHAR(150) NOT NULL,
    duracion_seg    INT,
    reproducciones  BIGINT,
    precio          DECIMAL(5,2),
    FOREIGN KEY (id_artista) REFERENCES artistas(id_artista)
);

-- Tabla nueva: listas de reproduccion
CREATE TABLE listas (
    id_lista    INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255)
);

-- Tabla nueva: canciones dentro de cada lista (tabla puente)
CREATE TABLE lista_canciones (
    id_lista    INT NOT NULL,
    id_cancion  INT NOT NULL,
    PRIMARY KEY (id_lista, id_cancion),
    FOREIGN KEY (id_lista)   REFERENCES listas(id_lista),
    FOREIGN KEY (id_cancion) REFERENCES canciones(id_cancion)
);

INSERT INTO artistas (nombre, pais, genero, anio_debut) VALUES
    ('Nirvana',                  'Estados Unidos', 'Grunge',        1987),
    ('Metallica',                'Estados Unidos', 'Heavy Metal',   1981),
    ('Arctic Monkeys',           'Reino Unido',    'Rock',          2002),
    ('Los Redonditos de Ricota', 'Argentina',      'Rock Nacional', 1976),
    ('La Renga',                 'Argentina',      'Rock Nacional', 1989);

INSERT INTO canciones VALUES
    (1,  1, 'Smells Like Teen Spirit',       5*60+1,  1800000000, 1.29),
    (2,  1, 'Come as You Are',               3*60+38, 1200000000, 1.29),
    (3,  1, 'Lithium',                       4*60+17, 980000000,  1.29),
    (4,  1, 'Heart-Shaped Box',              4*60+41, 760000000,  1.29),
    (5,  2, 'Enter Sandman',                 5*60+31, 1500000000, 1.29),
    (6,  2, 'Master of Puppets',             8*60+35, 1100000000, 1.29),
    (7,  2, 'Nothing Else Matters',          6*60+28, 1900000000, 1.29),
    (8,  2, 'One',                           7*60+25, 880000000,  1.29),
    (9,  3, 'Do I Wanna Know?',              4*60+32, 1500000000, 1.29),
    (10, 3, 'R U Mine?',                     3*60+21, 980000000,  1.29),
    (11, 3, '505',                           4*60+13, 1100000000, 1.29),
    (12, 3, 'Fluorescent Adolescent',        2*60+57, 720000000,  1.29),
    (13, 4, 'La Bestia Pop',                 4*60+18, 45000000,   NULL),
    (14, 4, 'Jijiji',                        3*60+52, 38000000,   NULL),
    (15, 4, 'Motor Psico',                   4*60+5,  29000000,   NULL),
    (16, 4, 'Maldicion Poco Elegante',       3*60+40, 21000000,   NULL),
    (17, 5, 'Panic Show',                    4*60+22, 18000000,   NULL),
    (18, 5, 'La Balada del Diablo y la Muerte', 5*60+8, 24000000, NULL),
    (19, 5, 'Me Muero de Amor',              3*60+55, 14000000,   NULL),
    (20, 5, 'Todo a Pulmon',                 4*60+10, 11000000,   NULL);

INSERT INTO listas (nombre, descripcion) VALUES
    ('Rock Clasico',   'Los clasicos que nunca fallan'),
    ('Argentinos',     'Lo mejor del rock nacional'),
    ('Para el gym',    'Temas con energia para entrenar');


-- ============================================================
-- REPASO RAPIDO (conceptos de clases anteriores)
-- ============================================================

-- Ver el contenido de las tablas
SELECT * FROM artistas;
SELECT * FROM canciones;

-- Filtros combinados: bandas argentinas con canciones de mas de 4 minutos
SELECT a.nombre AS artista, c.titulo, c.duracion_seg
FROM canciones c
JOIN artistas a ON c.id_artista = a.id_artista
WHERE a.pais = 'Argentina'
  AND c.duracion_seg > 240
ORDER BY c.duracion_seg DESC;

-- Vista rapida: canciones con mas de 1000 millones de reproducciones
SELECT titulo, ROUND(reproducciones / 1000000000, 2) AS reprod_billones
FROM canciones
WHERE reproducciones > 1000000000
ORDER BY reproducciones DESC;


-- ============================================================
-- TEMA 1: INSERT
-- ============================================================


-- ---- 1a: INSERT completo (todos los campos, sin especificar columnas) ----
-- El orden de los valores debe coincidir exactamente con la tabla

INSERT INTO artistas
VALUES (6, 'AC/DC', 'Australia', 'Hard Rock', 1973);

SELECT * FROM artistas;


-- ---- 1b: INSERT parcial (especificando solo algunas columnas) ----
-- Los campos omitidos quedan en NULL o toman su valor DEFAULT

INSERT INTO canciones (id_artista, titulo, reproducciones)
VALUES (6, 'Highway to Hell', 890000000);
-- duracion_seg y precio quedan NULL porque no los especificamos

SELECT * FROM canciones WHERE id_artista = 6;


-- ---- 1c: INSERT de multiples filas en una sola sentencia ----
-- Mas eficiente que ejecutar un INSERT por cada fila

INSERT INTO canciones (id_artista, titulo, duracion_seg, reproducciones, precio)
VALUES
    (6, 'Back in Black',   4*60+15, 1400000000, 1.29),
    (6, 'Thunderstruck',   4*60+52, 1600000000, 1.29),
    (6, 'T.N.T.',          3*60+35, 650000000,  1.29);

SELECT * FROM canciones WHERE id_artista = 6;


-- ============================================================
-- TEMA 2: UPDATE
-- ============================================================
-- Sintaxis: UPDATE tabla SET columna = valor WHERE condicion
-- SIEMPRE escribir el WHERE antes del SET para no olvidarlo.
-- Un UPDATE sin WHERE modifica TODOS los registros de la tabla.


-- ---- 2a: UPDATE de un solo registro ----

-- Agregamos el precio a 'Highway to Hell' que lo insertamos sin precio
UPDATE canciones
SET precio = 1.29
WHERE id_cancion = 21;

SELECT id_cancion, titulo, precio FROM canciones WHERE id_cancion = 21;


-- ---- 2b: UPDATE de multiples columnas a la vez ----

-- Corregimos la duracion de Highway to Hell y actualizamos reproducciones
UPDATE canciones
SET duracion_seg    = 3*60+28,
    reproducciones  = 920000000
WHERE id_cancion = 21;

SELECT id_cancion, titulo, duracion_seg, reproducciones FROM canciones WHERE id_cancion = 21;


-- ---- 2c: UPDATE masivo (afecta varios registros a la vez) ----

-- Aplicamos un descuento del 20% a todas las canciones con precio mayor a 1.00
UPDATE canciones
SET precio = ROUND(precio * 0.80, 2)
WHERE precio > 1.00;

SELECT titulo, precio FROM canciones WHERE precio IS NOT NULL ORDER BY precio;


-- ============================================================
-- TEMA 3: DELETE
-- ============================================================
-- Sintaxis: DELETE FROM tabla WHERE condicion
-- SIEMPRE escribir el WHERE. Sin WHERE se eliminan TODOS los registros.


-- ---- 3a: DELETE de un solo registro ----

-- Eliminamos T.N.T. (fue el ultimo que insertamos, id_cancion = 24)
DELETE FROM canciones
WHERE id_cancion = 24;

SELECT * FROM canciones WHERE id_artista = 6;


-- ---- 3b: DELETE con multiples condiciones ----

-- Eliminamos canciones de AC/DC que no tengan precio asignado
DELETE FROM canciones
WHERE id_artista = 6
  AND precio IS NULL;

SELECT * FROM canciones WHERE id_artista = 6;


-- ---- 3c: Error por FOREIGN KEY ----
-- Si intentamos eliminar un artista que tiene canciones asociadas, MySQL lo rechaza.
-- La FK en "canciones" protege la integridad referencial.

-- Esto va a fallar con error 1451:
-- DELETE FROM artistas WHERE id_artista = 6;

-- Para eliminarlo correctamente: primero borramos sus canciones, luego al artista
DELETE FROM canciones WHERE id_artista = 6;
DELETE FROM artistas  WHERE id_artista = 6;

SELECT * FROM artistas;


-- ---- 3d: TRUNCATE vs DELETE ----
-- TRUNCATE elimina TODOS los registros de una tabla de golpe.
-- Es mas rapido que DELETE sin WHERE porque no recorre fila por fila.
-- Ademas reinicia el AUTO_INCREMENT.

-- Creamos una tabla temporal para demostrar TRUNCATE
CREATE TABLE temp_log (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    mensaje VARCHAR(100)
);

INSERT INTO temp_log (mensaje) VALUES ('log 1'), ('log 2'), ('log 3');
SELECT * FROM temp_log;  -- vemos los 3 registros con ids 1, 2, 3

TRUNCATE temp_log;

INSERT INTO temp_log (mensaje) VALUES ('nuevo log');
SELECT * FROM temp_log;  -- el id vuelve a empezar desde 1

DROP TABLE temp_log;


-- ============================================================
-- TEMA 4: DML CON SUBCONSULTAS
-- ============================================================
-- Las subconsultas permiten usar el resultado de un SELECT
-- como fuente de datos para un INSERT, UPDATE o DELETE.


-- ---- 4a: INSERT + subconsulta ----
-- Poblamos lista_canciones con el top 5 de canciones mas reproducidas
-- para la lista "Para el gym" (id_lista = 3)

INSERT INTO lista_canciones (id_lista, id_cancion)
SELECT 3, id_cancion
FROM canciones
ORDER BY reproducciones DESC
LIMIT 5;

SELECT * FROM lista_canciones;

-- Verificamos que canciones quedaron en la lista
SELECT l.nombre AS lista, c.titulo, ROUND(c.reproducciones / 1000000, 0) AS millones
FROM lista_canciones lc
JOIN listas    l ON lc.id_lista   = l.id_lista
JOIN canciones c ON lc.id_cancion = c.id_cancion
WHERE lc.id_lista = 3
ORDER BY c.reproducciones DESC;


-- ---- 4b: UPDATE + subconsulta ----
-- Bajamos el precio a 0.99 para todas las canciones de artistas del Reino Unido
-- La subconsulta devuelve los id_artista donde pais = 'Reino Unido'

UPDATE canciones
SET precio = 0.99
WHERE id_artista IN (
    SELECT id_artista
    FROM artistas
    WHERE pais = 'Reino Unido'
);

SELECT c.titulo, a.pais, c.precio
FROM canciones c
JOIN artistas a ON c.id_artista = a.id_artista
WHERE a.pais = 'Reino Unido';


-- ---- 4c: DELETE + subconsulta ----
-- Eliminamos de la lista 3 las canciones que no tienen precio definido
-- (las bandas argentinas no tienen precio, no corresponde tenerlas en "Para el gym")

DELETE FROM lista_canciones
WHERE id_lista = 3
  AND id_cancion IN (
      SELECT id_cancion
      FROM canciones
      WHERE precio IS NULL
  );

-- Verificamos el resultado final de la lista
SELECT l.nombre AS lista, c.titulo, c.precio
FROM lista_canciones lc
JOIN listas    l ON lc.id_lista   = l.id_lista
JOIN canciones c ON lc.id_cancion = c.id_cancion
WHERE lc.id_lista = 3
ORDER BY c.reproducciones DESC;
