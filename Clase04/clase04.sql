-- ============================================================
-- CLASE 04: REPASO + VISTAS
-- Motor: MySQL
-- ============================================================


-- ============================================================
-- PASO 1: CREAR LA BASE DE DATOS
-- ============================================================

DROP DATABASE IF EXISTS musica;
CREATE DATABASE musica;
USE musica;


-- ============================================================
-- PASO 2: CREAR LAS TABLAS
-- ============================================================

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
    duracion_seg    INT,           -- duracion en segundos
    reproducciones  BIGINT,        -- total de reproducciones
    precio          DECIMAL(5,2),  -- precio en USD (NULL = gratuita / sin precio)
    FOREIGN KEY (id_artista) REFERENCES artistas(id_artista)
);


-- ============================================================
-- PASO 3: INSERTAR DATOS
-- ============================================================

-- Forma 1: especificando las columnas (recomendada, mas segura)
INSERT INTO artistas (nombre, pais, genero, anio_debut)
VALUES
    ('Nirvana',                   'Estados Unidos', 'Grunge',        1987),
    ('Metallica',                 'Estados Unidos', 'Heavy Metal',   1981),
    ('Arctic Monkeys',            'Reino Unido',    'Rock',          2002),
    ('Los Redonditos de Ricota',  'Argentina',      'Rock Nacional', 1976),
    ('La Renga',                  'Argentina',      'Rock Nacional', 1989);

-- Forma 2: sin especificar columnas (el orden debe coincidir con la tabla)
-- Util para inserciones rapidas cuando conocemos bien la estructura
INSERT INTO canciones
VALUES
    -- Nirvana (id_artista = 1)
    (1,  1, 'Smells Like Teen Spirit', 5*60+1,  1800000000, 1.29),
    (2,  1, 'Come as You Are',         3*60+38, 1200000000, 1.29),
    (3,  1, 'Lithium',                 4*60+17, 980000000,  1.29),
    (4,  1, 'Heart-Shaped Box',        4*60+41, 760000000,  1.29),

    -- Metallica (id_artista = 2)
    (5,  2, 'Enter Sandman',           5*60+31, 1500000000, 1.29),
    (6,  2, 'Master of Puppets',       8*60+35, 1100000000, 1.29),
    (7,  2, 'Nothing Else Matters',    6*60+28, 1900000000, 1.29),
    (8,  2, 'One',                     7*60+25, 880000000,  1.29),

    -- Arctic Monkeys (id_artista = 3)
    (9,  3, 'Do I Wanna Know?',        4*60+32, 1500000000, 1.29),
    (10, 3, 'R U Mine?',               3*60+21, 980000000,  1.29),
    (11, 3, '505',                     4*60+13, 1100000000, 1.29),
    (12, 3, 'Fluorescent Adolescent',  2*60+57, 720000000,  1.29),

    -- Los Redonditos de Ricota (id_artista = 4)
    (13, 4, 'La Bestia Pop',           4*60+18, 45000000,   NULL),
    (14, 4, 'Jijiji',                  3*60+52, 38000000,   NULL),
    (15, 4, 'Motor Psico',             4*60+5,  29000000,   NULL),
    (16, 4, 'Maldicion Poco Elegante', 3*60+40, 21000000,   NULL),

    -- La Renga (id_artista = 5)
    (17, 5, 'Panic Show',                    4*60+22, 18000000, NULL),
    (18, 5, 'La Balada del Diablo y la Muerte', 5*60+8,  24000000, NULL),
    (19, 5, 'Me Muero de Amor',              3*60+55, 14000000, NULL),
    (20, 5, 'Todo a Pulmon',                 4*60+10, 11000000, NULL);


-- ============================================================
-- PASO 4: VER EL CONTENIDO
-- ============================================================

SELECT * FROM artistas;
SELECT * FROM canciones;


-- ============================================================
-- PASO 5: FILTROS (repaso)
-- ============================================================

-- ---- ORDER BY ----

-- Canciones ordenadas de mas a menos reproducidas
SELECT titulo, reproducciones
FROM canciones
ORDER BY reproducciones DESC;

-- Artistas ordenados por año de debut
SELECT nombre, anio_debut
FROM artistas
ORDER BY anio_debut ASC;


-- ---- WHERE ----

-- Artistas que debutaron antes de 1990
SELECT nombre, anio_debut
FROM artistas
WHERE anio_debut < 1990;

-- Canciones de mas de 6 minutos (360 segundos)
SELECT titulo, duracion_seg
FROM canciones
WHERE duracion_seg > 360;


-- ---- BETWEEN ----

-- Artistas que debutaron entre 1980 y 2000
SELECT nombre, anio_debut
FROM artistas
WHERE anio_debut BETWEEN 1980 AND 2000;

-- Canciones entre 3 y 4 minutos (180 a 240 segundos)
SELECT titulo, duracion_seg
FROM canciones
WHERE duracion_seg BETWEEN 180 AND 240;


-- ---- IN ----

-- Bandas argentinas o britanicas
SELECT nombre, pais
FROM artistas
WHERE pais IN ('Argentina', 'Reino Unido');

-- Canciones de Metallica y Arctic Monkeys (id 2 y 3)
SELECT titulo, id_artista
FROM canciones
WHERE id_artista IN (2, 3);


-- ---- LIKE ----

-- Canciones que empiecen con la letra 'M'
SELECT titulo FROM canciones WHERE titulo LIKE 'M%';

-- Canciones que contengan la palabra 'the' en cualquier posicion
SELECT titulo FROM canciones WHERE titulo LIKE '%the%';


-- ---- IS NULL / IS NOT NULL ----

-- Canciones sin precio (bandas argentinas, no tienen precio en plataformas pagas)
SELECT titulo FROM canciones WHERE precio IS NULL;

-- Canciones con precio definido
SELECT titulo, precio FROM canciones WHERE precio IS NOT NULL;


-- ---- DISTINCT ----

-- Generos distintos
SELECT DISTINCT genero FROM artistas ORDER BY genero;

-- Paises distintos
SELECT DISTINCT pais FROM artistas ORDER BY pais;


-- ---- Columnas calculadas ----

-- Duracion en formato legible y reproducciones en millones
SELECT
    titulo,
    CONCAT(duracion_seg DIV 60, 'm ', duracion_seg MOD 60, 's') AS duracion,
    ROUND(reproducciones / 1000000, 1)                          AS reprod_millones,
    precio,
    ROUND(precio * 1.21, 2)                                     AS precio_con_iva
FROM canciones
WHERE precio IS NOT NULL
ORDER BY reproducciones DESC;
