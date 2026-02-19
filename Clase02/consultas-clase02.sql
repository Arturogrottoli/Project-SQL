-- ============================================================
-- CLASE 02: CONSULTAS Y SUBCONSULTAS SQL
-- ============================================================
-- Script autocontenido: crea el esquema, inserta datos
-- y muestra cada tema de la clase con ejemplos comentados.
--
-- Temas cubiertos:
--   1.  DDL: CREATE TABLE con constraints
--   2.  DDL: ALTER TABLE (agregar/modificar/eliminar columnas)
--   3.  DDL: DROP TABLE IF EXISTS
--   4.  DML: INSERT con multiples filas
--   5.  SELECT, FROM, DISTINCT
--   6.  WHERE y operadores (=, !=, <, >, <=, >=)
--   7.  BETWEEN / NOT BETWEEN
--   8.  LIKE / NOT LIKE  y  ILIKE (PostgreSQL)
--   9.  IN / NOT IN
--  10.  IS NULL / IS NOT NULL
--  11.  AND, OR, NOT
--  12.  UNION y UNION ALL
--  13.  Subconsultas (en WHERE, en FROM, con IN)
--  14.  Subconsultas correlacionadas
--  15.  CTE (WITH) -- incluyendo CTE encadenadas
--  16.  LATERAL (PostgreSQL)
--  17.  EXPLAIN / EXPLAIN ANALYZE
--  18.  Indices: CREATE INDEX
--
-- Motor: PostgreSQL 14+
-- Nota MySQL: donde la sintaxis difiere se aclara en comentarios.
-- ============================================================


-- ============================================================
-- PASO 0: LIMPIAR EL ENTORNO
-- ============================================================
-- Eliminamos el esquema previo para poder re-ejecutar el script
-- sin errores. CASCADE elimina todas las tablas dentro del esquema.

DROP SCHEMA IF EXISTS gamer CASCADE;
CREATE SCHEMA gamer;
SET search_path TO gamer;

-- MySQL equivalente:
--   DROP DATABASE IF EXISTS gamer;
--   CREATE DATABASE gamer;
--   USE gamer;


-- ============================================================
-- PASO 1: DDL - CREAR TABLAS CON CONSTRAINTS
-- ============================================================
-- Aqui aplicamos todos los constraints vistos:
--   PRIMARY KEY   -> identifica cada fila de forma unica
--   NOT NULL      -> el campo no puede quedar vacio
--   UNIQUE        -> el valor no puede repetirse
--   FOREIGN KEY   -> conecta con la PK de otra tabla
--   CHECK         -> el valor debe cumplir una condicion
--   DEFAULT       -> valor por defecto si no se especifica


-- ------------------------------------------------------------
-- TABLA: genres
-- Generos de videojuegos. Tabla de referencia sin dependencias.
-- ------------------------------------------------------------

CREATE TABLE genres (
    genre_id    SERIAL        PRIMARY KEY,       -- PK auto-incremental (MySQL: INT AUTO_INCREMENT)
    name        VARCHAR(50)   NOT NULL UNIQUE,   -- UNIQUE: no puede repetirse
    description TEXT
);


-- ------------------------------------------------------------
-- TABLA: developers
-- Empresas desarrolladoras de videojuegos.
-- ------------------------------------------------------------

CREATE TABLE developers (
    developer_id SERIAL       PRIMARY KEY,
    name         VARCHAR(100) NOT NULL UNIQUE,
    country      VARCHAR(50)  NOT NULL,
    founded_year SMALLINT     CHECK (founded_year BETWEEN 1970 AND 2025)
    -- CHECK: solo acepta anios entre 1970 y 2025
);


-- ------------------------------------------------------------
-- TABLA: games
-- Videojuegos disponibles en la plataforma.
-- ------------------------------------------------------------

CREATE TABLE games (
    game_id      SERIAL         PRIMARY KEY,
    title        VARCHAR(150)   NOT NULL,
    genre_id     INT            REFERENCES genres(genre_id),       -- FOREIGN KEY
    developer_id INT            REFERENCES developers(developer_id),
    release_date DATE           NOT NULL,
    level        SMALLINT       NOT NULL CHECK (level BETWEEN 1 AND 20),
    price        DECIMAL(8,2)   CHECK (price >= 0),
    active       BOOLEAN        NOT NULL DEFAULT TRUE
    -- DEFAULT TRUE: si no se especifica, el juego queda activo
);


-- ------------------------------------------------------------
-- TABLA: system_users
-- Usuarios registrados en la plataforma.
-- ------------------------------------------------------------

CREATE TABLE system_users (
    user_id        SERIAL        PRIMARY KEY,
    username       VARCHAR(50)   NOT NULL UNIQUE,
    email          VARCHAR(200)  NOT NULL UNIQUE,
    registered_at  DATE          NOT NULL DEFAULT CURRENT_DATE,
    user_type_id   INT           NOT NULL DEFAULT 1,
    -- 1 = jugador, 2 = moderador, 3 = admin
    is_active      BOOLEAN       NOT NULL DEFAULT TRUE
);


-- ------------------------------------------------------------
-- TABLA: comments
-- Comentarios de usuarios sobre juegos.
-- ------------------------------------------------------------

CREATE TABLE comments (
    comment_id  SERIAL      PRIMARY KEY,
    game_id     INT         NOT NULL REFERENCES games(game_id),
    user_id     INT         NOT NULL REFERENCES system_users(user_id),
    comment_txt TEXT        NOT NULL,
    posted_at   DATE        NOT NULL DEFAULT CURRENT_DATE,
    score       SMALLINT    CHECK (score BETWEEN 1 AND 5)
    -- score puede ser NULL (comentario sin puntuacion)
);


-- ------------------------------------------------------------
-- TABLA: archived_games
-- Juegos dados de baja. Usaremos esta tabla para UNION.
-- ------------------------------------------------------------

CREATE TABLE archived_games (
    game_id      INT          PRIMARY KEY,
    title        VARCHAR(150) NOT NULL,
    genre_id     INT,
    archived_at  DATE         NOT NULL DEFAULT CURRENT_DATE
);


-- ============================================================
-- PASO 2: DDL - ALTER TABLE (modificar la estructura)
-- ============================================================


-- Agregar una columna nueva a la tabla games
ALTER TABLE games ADD COLUMN trailer_url VARCHAR(300);

-- Renombrar una columna
ALTER TABLE games RENAME COLUMN trailer_url TO trailer_link;

-- Cambiar el tipo de datos de una columna (PostgreSQL)
-- MySQL: ALTER TABLE games MODIFY COLUMN trailer_link TEXT;
ALTER TABLE games ALTER COLUMN trailer_link TYPE TEXT;

-- Eliminar la columna (no la necesitamos mas)
ALTER TABLE games DROP COLUMN trailer_link;

-- Agregar un constraint en una tabla existente
ALTER TABLE games
ADD CONSTRAINT uq_game_title_developer UNIQUE (title, developer_id);

-- Eliminar ese constraint
ALTER TABLE games DROP CONSTRAINT uq_game_title_developer;


-- ============================================================
-- PASO 3: DML - INSERTAR DATOS DE EJEMPLO
-- ============================================================


-- ------------------------------------------------------------
-- DATOS: genres (6 generos)
-- ------------------------------------------------------------

INSERT INTO genres (name, description) VALUES
    ('RPG',        'Juegos de rol con desarrollo de personaje'),
    ('FPS',        'Disparos en primera persona'),
    ('Sports',     'Simulacion deportiva'),
    ('Adventure',  'Exploracion y narrativa'),
    ('Strategy',   'Planificacion y gestion de recursos'),
    ('Fighting',   'Combate cuerpo a cuerpo');


-- ------------------------------------------------------------
-- DATOS: developers (8 desarrolladoras)
-- ------------------------------------------------------------

INSERT INTO developers (name, country, founded_year) VALUES
    ('CD Projekt Red',  'Poland',        1994),
    ('Rockstar Games',  'United States', 1998),
    ('Ubisoft',         'France',        1986),
    ('EA Sports',       'United States', 1991),
    ('FromSoftware',    'Japan',         1986),
    ('Naughty Dog',     'United States', 1984),
    ('Bethesda',        'United States', 1986),
    ('Capcom',          'Japan',         1979);


-- ------------------------------------------------------------
-- DATOS: games (20 juegos)
-- ------------------------------------------------------------

INSERT INTO games (title, genre_id, developer_id, release_date, level, price, active) VALUES
    ('The Witcher 3',               1, 1, '2015-05-19', 18, 29.99,  TRUE),
    ('Cyberpunk 2077',              1, 1, '2020-12-10', 16, 39.99,  TRUE),
    ('Grand Theft Auto V',          4, 2, '2013-09-17', 17, 19.99,  TRUE),
    ('Red Dead Redemption 2',       4, 2, '2018-10-26', 19, 44.99,  TRUE),
    ('Assassins Creed Odyssey',     4, 3, '2018-10-05', 14, 24.99,  TRUE),
    ('Assassins Creed Valhalla',    4, 3, '2020-11-10', 15, 34.99,  TRUE),
    ('FIFA 23',                     3, 4, '2022-09-30', 5,  59.99,  TRUE),
    ('FIFA 24',                     3, 4, '2023-09-29', 5,  69.99,  TRUE),
    ('Elden Ring',                  1, 5, '2022-02-25', 20, 49.99,  TRUE),
    ('Dark Souls III',              1, 5, '2016-03-24', 19, 19.99,  TRUE),
    ('The Last of Us Part I',       4, 6, '2022-09-02', 15, 49.99,  TRUE),
    ('The Last of Us Part II',      4, 6, '2020-06-19', 16, 39.99,  TRUE),
    ('Starfield',                   4, 7, '2023-09-06', 14, 59.99,  TRUE),
    ('Skyrim',                      1, 7, '2011-11-11', 15, 14.99,  TRUE),
    ('Resident Evil 4',             4, 8, '2023-03-24', 13, 44.99,  TRUE),
    ('Riders Republic',             3, 3, '2021-10-28', 8,  29.99,  FALSE),
    ('Gran Turismo 7',              3, 4, '2022-03-04', 10, 54.99,  TRUE),
    ('Gran Theft Auto: San Andreas',4, 2, '2004-10-26', 12, 14.99,  FALSE),
    ('Bloodfield Online',           2, 5, '2019-04-25', 17, 24.99,  FALSE),
    ('Battlefield 2042',            2, 4, '2021-11-19', 11, 29.99,  TRUE);


-- ------------------------------------------------------------
-- DATOS: system_users (10 usuarios)
-- ------------------------------------------------------------

INSERT INTO system_users (username, email, registered_at, user_type_id, is_active) VALUES
    ('Gillie',      'gillie@mail.com',    '2020-03-10', 1, TRUE),
    ('gamer_pro',   'gpro@mail.com',      '2021-07-22', 1, TRUE),
    ('ana_plays',   'ana@mail.com',       '2019-11-05', 2, TRUE),
    ('reinaldo',    'rein@mail.com',      '2022-01-15', 1, FALSE),
    ('marcos_g',    'marcos@mail.com',    '2021-09-30', 1, TRUE),
    ('mod_lucia',   'lucia@mail.com',     '2020-06-18', 2, TRUE),
    ('carlos_r',    'carlos@mail.com',    '2023-02-28', 1, TRUE),
    ('admin_juan',  'admin@mail.com',     '2019-05-01', 3, TRUE),
    ('retrogamer',  'retro@mail.com',     '2023-08-14', 1, TRUE),
    ('dark_mario',  'dark@mail.com',      '2022-12-03', 1, TRUE);


-- ------------------------------------------------------------
-- DATOS: comments (20 comentarios)
-- ------------------------------------------------------------

INSERT INTO comments (game_id, user_id, comment_txt, posted_at, score) VALUES
    (1,  1, 'Obra maestra absoluta.',                         '2021-04-10', 5),
    (1,  2, 'Enorme mapa, horas de contenido.',               '2021-05-20', 5),
    (2,  3, 'Buggy al lanzamiento pero mejoró mucho.',        '2021-06-15', 3),
    (3,  1, 'Un clasico que nunca envejece.',                 '2022-01-08', 4),
    (4,  4, 'La mejor narrativa en un juego de mundo abierto.','2022-02-14', 5),
    (5,  5, 'Buen juego pero repetitivo.',                    '2022-03-20', 3),
    (6,  2, 'Excelente ambientacion vikinga.',                '2022-04-05', 4),
    (7,  6, 'El mejor FIFA en anos.',                         '2023-01-11', 4),
    (9,  1, 'Brutal dificultad. Muy recomendado.',            '2023-02-28', 5),
    (9,  3, 'Igual que Dark Souls pero mas pulido.',          '2023-03-10', 4),
    (10, 7, 'Clasico del genero souls.',                      '2023-04-18', 5),
    (11, 8, 'Narrativa impecable.',                           '2023-05-22', 5),
    (13, 9, 'Interesante pero le falta contenido.',           '2023-06-30', 3),
    (14, 5, 'Lo jugue cientos de horas, sigue valiendo.',     '2020-07-15', 5),
    (15, 2, 'Remake perfecto.',                               '2023-08-01', 5),
    (17, 6, 'Los graficos son increibles.',                   '2022-09-10', 5),
    (19, 3, 'Entretenido para jugar en linea.',               '2020-11-20', 3),
    (20, 7, 'Promete pero necesita mas parches.',             '2022-12-05', 2),
    (2,  9, 'Mucho mejor que en su lanzamiento.',             '2023-01-28', 4),
    (1,  10,'Empezando a jugarlo. Impresionante.',            NULL);    -- sin puntuacion


-- ------------------------------------------------------------
-- DATOS: archived_games (juegos dados de baja)
-- ------------------------------------------------------------

INSERT INTO archived_games (game_id, title, genre_id, archived_at) VALUES
    (16, 'Riders Republic',              3, '2024-01-15'),
    (18, 'Gran Theft Auto: San Andreas', 4, '2024-02-01'),
    (19, 'Bloodfield Online',            2, '2024-03-10');


-- ============================================================
-- VERIFICACION: ver lo que creamos
-- ============================================================

-- En PostgreSQL se usa information_schema para ver las tablas:
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'gamer'
ORDER BY table_name;

-- Ver estructura de una tabla (PostgreSQL):
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'gamer' AND table_name = 'games'
ORDER BY ordinal_position;

-- MySQL equivalente:
--   SHOW TABLES;
--   DESCRIBE games;


-- ============================================================
--  TEMA 1: SELECT, FROM y DISTINCT
-- ============================================================

-- Todos los campos de games
SELECT * FROM games;

-- Campos especificos (el orden que elegis es el orden del resultado)
SELECT title, release_date, level, price
FROM games;

-- DISTINCT: valores unicos de nivel disponibles
SELECT DISTINCT level FROM games ORDER BY level;

-- DISTINCT combinando dos columnas (combinaciones unicas)
SELECT DISTINCT genre_id, developer_id FROM games ORDER BY genre_id;


-- ============================================================
--  TEMA 2: WHERE - OPERADORES DE COMPARACION
-- ============================================================

-- Igualdad: juegos de nivel exactamente 5
SELECT title, level FROM games WHERE level = 5;

-- Diferente: juegos que NO son deportivos (genre_id != 3)
SELECT title, genre_id FROM games WHERE genre_id <> 3;

-- Mayor/menor: juegos con precio mayor a 40
SELECT title, price FROM games WHERE price > 40.00;

-- Mayor o igual: juegos de nivel 15 o superior
SELECT title, level FROM games WHERE level >= 15;

-- Combinando condiciones con AND:
-- Juegos de nivel >= 15 Y precio <= 40
SELECT title, level, price
FROM games
WHERE level >= 15
  AND price <= 40.00
ORDER BY level DESC;

-- Combinando con OR: juegos de genero RPG (1) o Adventure (4)
SELECT title, genre_id FROM games
WHERE genre_id = 1 OR genre_id = 4;


-- ============================================================
--  TEMA 3: BETWEEN / NOT BETWEEN
-- ============================================================

-- Juegos de nivel entre 10 y 15 (inclusivo en ambos extremos)
SELECT title, level FROM games
WHERE level BETWEEN 10 AND 15
ORDER BY level;

-- Equivalente sin BETWEEN:
-- WHERE level >= 10 AND level <= 15

-- Juegos que NO estan en ese rango
SELECT title, level FROM games
WHERE level NOT BETWEEN 10 AND 15
ORDER BY level;

-- BETWEEN con fechas: juegos lanzados entre 2019 y 2022
SELECT title, release_date FROM games
WHERE release_date BETWEEN '2019-01-01' AND '2022-12-31'
ORDER BY release_date;

-- Comentarios posteados en 2023
SELECT comment_id, game_id, posted_at FROM comments
WHERE posted_at BETWEEN '2023-01-01' AND '2023-12-31';


-- ============================================================
--  TEMA 4: LIKE, NOT LIKE e ILIKE (PostgreSQL)
-- ============================================================
-- %  -> cualquier cantidad de caracteres (0 o mas)
-- _  -> exactamente UN caracter
-- LIKE    -> sensible a mayusculas en PostgreSQL
-- ILIKE   -> insensible a mayusculas (solo PostgreSQL)
-- MySQL:  LIKE ya es case-insensitive por defecto

-- Juegos cuyo titulo empiece con 'Grand'
SELECT title FROM games WHERE title LIKE 'Grand%';

-- Juegos cuyo titulo contenga 'field' en cualquier posicion
SELECT title FROM games WHERE title LIKE '%field%';

-- ILIKE: igual que arriba pero ignora mayusculas/minusculas
SELECT title FROM games WHERE title ILIKE '%field%';
SELECT title FROM games WHERE title ILIKE 'gran%';   -- encuentra Gran Turismo y GTA San Andreas

-- Juegos cuyo titulo termina con '2'
SELECT title FROM games WHERE title LIKE '%2';

-- Usuarios cuyo username tenga exactamente 6 caracteres
SELECT username FROM system_users WHERE username LIKE '______';  -- 6 guiones bajos

-- NOT LIKE: titulos que NO contienen 'the' (case-insensitive)
SELECT title FROM games WHERE title NOT ILIKE '%the%';


-- ============================================================
--  TEMA 5: IN / NOT IN
-- ============================================================

-- Juegos de los developers Ubisoft (3) o EA Sports (4) o Capcom (8)
SELECT title, developer_id FROM games
WHERE developer_id IN (3, 4, 8)
ORDER BY developer_id;

-- Equivalente con OR (mas verboso):
-- WHERE developer_id = 3 OR developer_id = 4 OR developer_id = 8

-- Usuarios de tipo 1 o 2 (jugadores y moderadores)
SELECT username, user_type_id FROM system_users
WHERE user_type_id IN (1, 2);

-- NOT IN: juegos que NO son de esos developers
SELECT title, developer_id FROM games
WHERE developer_id NOT IN (3, 4, 8);


-- ============================================================
--  TEMA 6: IS NULL / IS NOT NULL
-- ============================================================

-- Comentarios SIN puntuacion (score es NULL)
SELECT comment_id, comment_txt, score FROM comments
WHERE score IS NULL;

-- Comentarios CON puntuacion
SELECT comment_id, comment_txt, score FROM comments
WHERE score IS NOT NULL
ORDER BY score DESC;

-- IMPORTANTE: esto NO funciona como se espera (nunca devuelve filas):
-- WHERE score = NULL      -- INCORRECTO
-- WHERE score != NULL     -- INCORRECTO


-- ============================================================
--  TEMA 7: UNION y UNION ALL
-- ============================================================
-- UNION     -> combina resultados y ELIMINA duplicados
-- UNION ALL -> combina resultados SIN eliminar duplicados (mas rapido)
-- Ambas consultas deben tener el mismo numero y tipo de columnas.

-- Listado de todos los juegos: activos + archivados (sin duplicados)
SELECT game_id, title, genre_id, 'activo'    AS estado FROM games
UNION
SELECT game_id, title, genre_id, 'archivado' AS estado FROM archived_games
ORDER BY title;

-- Con UNION ALL: si un juego estuviese en ambas tablas apareceria dos veces
SELECT game_id, title, 'activo'    AS estado FROM games
UNION ALL
SELECT game_id, title, 'archivado' AS estado FROM archived_games
ORDER BY estado, title;

-- Caso practico: juegos de nivel 5 unidos con juegos de nivel 20
-- (no hay duplicados posibles, UNION ALL es mas eficiente)
SELECT title, level FROM games WHERE level = 5
UNION ALL
SELECT title, level FROM games WHERE level = 20;

-- Comparacion: UNION elimina duplicados, UNION ALL no.
-- Si ejecutamos la misma query dos veces:
SELECT title FROM games WHERE developer_id = 5
UNION
SELECT title FROM games WHERE developer_id = 5;
-- Resultado: cada titulo UNA vez (UNION deduplicó)

SELECT title FROM games WHERE developer_id = 5
UNION ALL
SELECT title FROM games WHERE developer_id = 5;
-- Resultado: cada titulo DOS veces (UNION ALL conservó todo)


-- ============================================================
--  TEMA 8: SUBCONSULTAS
-- ============================================================

-- ---- 8a. Subconsulta en WHERE ----

-- Juegos con precio mayor al precio promedio de todos los juegos
SELECT title, price
FROM games
WHERE price > (SELECT AVG(price) FROM games)
ORDER BY price DESC;

-- Juegos del mismo developer que 'Elden Ring'
SELECT title, developer_id
FROM games
WHERE developer_id = (
    SELECT developer_id FROM games WHERE title = 'Elden Ring'
)
ORDER BY title;


-- ---- 8b. Subconsulta con IN ----

-- Juegos que tienen al menos un comentario
SELECT title FROM games
WHERE game_id IN (
    SELECT DISTINCT game_id FROM comments
)
ORDER BY title;

-- Juegos que NO tienen ningun comentario
SELECT title FROM games
WHERE game_id NOT IN (
    SELECT DISTINCT game_id FROM comments
)
ORDER BY title;

-- ---- 8c. Subconsulta en FROM (tabla derivada) ----

-- Promedio de puntuacion por juego, filtrado por los que superan 4.0
SELECT g.title, puntuaciones.avg_score
FROM games g
JOIN (
    SELECT game_id, ROUND(AVG(score), 2) AS avg_score
    FROM comments
    WHERE score IS NOT NULL
    GROUP BY game_id
) AS puntuaciones ON g.game_id = puntuaciones.game_id
WHERE puntuaciones.avg_score > 4.0
ORDER BY puntuaciones.avg_score DESC;


-- ============================================================
--  TEMA 9: SUBCONSULTAS CORRELACIONADAS
-- ============================================================
-- La subconsulta hace referencia a columnas de la consulta exterior.
-- Se ejecuta UNA VEZ POR CADA FILA del exterior (puede ser lenta).

-- Para cada juego, mostrar cuantos comentarios tiene
SELECT
    g.title,
    (SELECT COUNT(*) FROM comments c WHERE c.game_id = g.game_id) AS total_comments
FROM games g
ORDER BY total_comments DESC;

-- Juegos cuyo precio supera el promedio de precio de su genero
SELECT g.title, g.price, g.genre_id
FROM games g
WHERE g.price > (
    SELECT AVG(g2.price)
    FROM games g2
    WHERE g2.genre_id = g.genre_id   -- referencia a la consulta exterior
)
ORDER BY g.genre_id, g.price DESC;

-- Alternativa mas eficiente con JOIN (mismo resultado):
SELECT g.title, g.price, g.genre_id
FROM games g
JOIN (
    SELECT genre_id, AVG(price) AS avg_price
    FROM games
    GROUP BY genre_id
) AS promedios ON g.genre_id = promedios.genre_id
WHERE g.price > promedios.avg_price
ORDER BY g.genre_id, g.price DESC;


-- ============================================================
--  TEMA 10: CTE - Common Table Expressions (WITH)
-- ============================================================
-- Las CTEs nombran una subconsulta para reutilizarla.
-- Mejoran la legibilidad respecto a subconsultas anidadas.
-- MySQL soporta CTEs desde version 8.0.

-- CTE simple: juegos con comentarios y su promedio de puntuacion
WITH avg_scores AS (
    SELECT
        game_id,
        ROUND(AVG(score), 2) AS avg_score,
        COUNT(*) AS total_comments
    FROM comments
    WHERE score IS NOT NULL
    GROUP BY game_id
)
SELECT
    g.title,
    a.avg_score,
    a.total_comments
FROM games g
JOIN avg_scores a ON g.game_id = a.game_id
ORDER BY a.avg_score DESC, a.total_comments DESC;


-- CTE encadenada: primero obtenemos juegos top, luego sus developers
WITH juegos_top AS (
    SELECT game_id, title, developer_id, price
    FROM games
    WHERE price >= 40.00 AND active = TRUE
),
developers_top AS (
    SELECT DISTINCT d.name AS developer, d.country
    FROM developers d
    JOIN juegos_top jt ON d.developer_id = jt.developer_id
)
SELECT * FROM developers_top ORDER BY developer;


-- CTE con UNION: todos los titulos (activos + archivados) con su estado
WITH todos_los_juegos AS (
    SELECT title, 'activo'    AS estado, release_date AS fecha FROM games
    UNION ALL
    SELECT title, 'archivado' AS estado, archived_at  AS fecha FROM archived_games
)
SELECT * FROM todos_los_juegos ORDER BY estado, title;


-- ============================================================
--  TEMA 11: LATERAL (PostgreSQL)
-- ============================================================
-- LATERAL permite que una subconsulta en el FROM referencie
-- columnas de tablas anteriores en el mismo FROM.
-- Util para "top N por grupo".
-- MySQL no soporta LATERAL (alternativa: window functions).

-- Para cada usuario activo, traer sus ultimos 2 comentarios
SELECT
    u.username,
    ultimos.comment_txt,
    ultimos.posted_at,
    ultimos.score
FROM system_users u,
LATERAL (
    SELECT comment_txt, posted_at, score
    FROM comments c
    WHERE c.user_id = u.user_id    -- referencia a la tabla exterior
    ORDER BY posted_at DESC
    LIMIT 2
) AS ultimos
WHERE u.is_active = TRUE
ORDER BY u.username, ultimos.posted_at DESC;

-- Para cada genero, traer el juego mas caro
SELECT
    gen.name AS genre,
    mas_caro.title,
    mas_caro.price
FROM genres gen,
LATERAL (
    SELECT title, price
    FROM games g
    WHERE g.genre_id = gen.genre_id
    ORDER BY price DESC
    LIMIT 1
) AS mas_caro
ORDER BY mas_caro.price DESC;


-- ============================================================
--  TEMA 12: EXPLAIN y rendimiento
-- ============================================================
-- EXPLAIN muestra el plan de ejecucion sin correr la consulta.
-- EXPLAIN ANALYZE lo ejecuta y muestra tiempos reales.
--
-- MySQL: EXPLAIN SELECT ... (no tiene ANALYZE integrado del mismo modo)

-- Plan de una consulta simple (probablemente Seq Scan en tabla chica)
EXPLAIN
SELECT * FROM games WHERE level >= 15;

-- Plan con mas detalle y tiempos reales
EXPLAIN ANALYZE
SELECT title, price FROM games
WHERE price > (SELECT AVG(price) FROM games);

-- Comparar plan de UNION vs UNION ALL
EXPLAIN
SELECT game_id, title FROM games
UNION
SELECT game_id, title FROM archived_games;

EXPLAIN
SELECT game_id, title FROM games
UNION ALL
SELECT game_id, title FROM archived_games;
-- UNION ALL produce un plan mas simple (Append) sin el paso de deduplicacion


-- ============================================================
--  TEMA 13: INDICES
-- ============================================================
-- Los indices aceleran las busquedas pero ocupan espacio
-- y ralentizan ligeramente los INSERT/UPDATE/DELETE.

-- Indice en una columna muy consultada en WHERE
CREATE INDEX idx_games_level ON games(level);

-- Indice en clave foranea (siempre conviene indexarlas)
CREATE INDEX idx_games_genre ON games(genre_id);
CREATE INDEX idx_comments_game ON comments(game_id);

-- Indice compuesto: util si filtramos por developer Y activo juntos
CREATE INDEX idx_games_dev_active ON games(developer_id, active);

-- LIKE con % al inicio NO usa indices B-tree.
-- En PostgreSQL, la extension pg_trgm permite indexar estos casos:

-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE INDEX idx_games_title_trgm ON games USING gin(title gin_trgm_ops);
-- Luego LIKE '%field%' o ILIKE '%elden%' pueden usar ese indice.

-- Ver los indices creados en el esquema:
SELECT indexname, tablename, indexdef
FROM pg_indexes
WHERE schemaname = 'gamer'
ORDER BY tablename, indexname;


-- ============================================================
--  TEMA 14: EJERCICIOS COMBINADOS
-- ============================================================

-- Ejercicio 1: Juegos de FromSoftware (developer_id = 5) con
-- nivel mayor a 17, ordenados por fecha de lanzamiento
SELECT title, level, release_date
FROM games
WHERE developer_id = 5
  AND level > 17
ORDER BY release_date;


-- Ejercicio 2: Titulos que contengan 'Grand' o 'Gran' (ILIKE),
-- activos, precio entre 10 y 30
SELECT title, price, active
FROM games
WHERE title ILIKE '%gran%'
  AND active = TRUE
  AND price BETWEEN 10.00 AND 30.00;


-- Ejercicio 3: Usuarios que comentaron juegos de nivel >= 18
-- (usando subconsulta con IN)
SELECT DISTINCT u.username
FROM system_users u
WHERE u.user_id IN (
    SELECT c.user_id
    FROM comments c
    JOIN games g ON c.game_id = g.game_id
    WHERE g.level >= 18
)
ORDER BY u.username;


-- Ejercicio 4: CTE para obtener el juego con mas comentarios
-- y cuantos usuarios distintos lo comentaron
WITH comentarios_por_juego AS (
    SELECT
        game_id,
        COUNT(*)                    AS total_comments,
        COUNT(DISTINCT user_id)     AS unique_users
    FROM comments
    GROUP BY game_id
)
SELECT
    g.title,
    cpj.total_comments,
    cpj.unique_users
FROM games g
JOIN comentarios_por_juego cpj ON g.game_id = cpj.game_id
ORDER BY cpj.total_comments DESC
LIMIT 5;


-- Ejercicio 5: UNION de juegos activos e inactivos,
-- mostrando titulo, estado y developer
SELECT g.title, 'activo' AS estado, d.name AS developer
FROM games g
JOIN developers d ON g.developer_id = d.developer_id
WHERE g.active = TRUE
UNION ALL
SELECT g.title, 'inactivo' AS estado, d.name AS developer
FROM games g
JOIN developers d ON g.developer_id = d.developer_id
WHERE g.active = FALSE
ORDER BY estado, title;


-- ============================================================
-- RESUMEN: ORDEN DE EJECUCION DE UNA CONSULTA SQL
-- ============================================================
/*
    El motor SQL ejecuta las clausulas en este orden
    (aunque las escribamos en otro orden):

    1. FROM / JOIN       -> de donde salen los datos
    2. WHERE             -> filtrar filas individuales
    3. GROUP BY          -> agrupar
    4. HAVING            -> filtrar grupos
    5. SELECT            -> elegir columnas y calcular expresiones
    6. DISTINCT          -> eliminar duplicados
    7. UNION / UNION ALL -> combinar con otras queries
    8. ORDER BY          -> ordenar el resultado
    9. LIMIT / OFFSET    -> recortar el resultado

    Por eso:
    - No podes usar un alias del SELECT dentro del WHERE
      (WHERE se ejecuta antes que SELECT)
    - Si filtrás sobre una funcion de agregacion (SUM, COUNT...),
      usas HAVING, no WHERE

    +--------------+----------------------------------------------+
    | Clausula     | Para que sirve                               |
    +--------------+----------------------------------------------+
    | SELECT       | Elegir columnas y expresiones                |
    | FROM         | Tabla(s) de origen                           |
    | WHERE        | Filtro ANTES de agrupar                      |
    | GROUP BY     | Agrupar filas (proximas clases)              |
    | HAVING       | Filtro DESPUES de agrupar                    |
    | UNION/ALL    | Combinar con otra consulta                   |
    | ORDER BY     | Ordenar el resultado final                   |
    | LIMIT        | Limitar cantidad de filas (FETCH en std SQL) |
    +--------------+----------------------------------------------+

    Operadores vistos:
    +---------------+-------------------------------------------+
    | Operador      | Uso                                       |
    +---------------+-------------------------------------------+
    | =             | Igualdad                                  |
    | <> o !=       | Diferente                                 |
    | < > <= >=     | Comparacion numerica / fecha              |
    | BETWEEN       | Rango cerrado (incluye extremos)          |
    | LIKE          | Patron (case-sensitive en PostgreSQL)     |
    | ILIKE         | Patron case-insensitive (PostgreSQL)      |
    | IN            | Pertenencia a una lista                   |
    | IS NULL       | Sin valor                                 |
    | IS NOT NULL   | Con valor                                 |
    | AND / OR      | Combinar condiciones                      |
    | NOT           | Negar una condicion                       |
    +---------------+-------------------------------------------+

    Tecnicas de consultas avanzadas:
    +------------------------+----------------------------------+
    | Tecnica                | Para que sirve                   |
    +------------------------+----------------------------------+
    | Subconsulta en WHERE   | Filtrar con resultado dinamico   |
    | Subconsulta en FROM    | Tabla derivada                   |
    | Subconsulta con IN     | Lista dinamica de valores        |
    | Subconsulta correlac.  | Calculo por cada fila exterior   |
    | CTE (WITH)             | Subconsulta con nombre           |
    | LATERAL                | Subconsulta correlac. en FROM    |
    | UNION / UNION ALL      | Combinar resultados              |
    | EXPLAIN / ANALYZE      | Ver plan de ejecucion            |
    | CREATE INDEX           | Acelerar busquedas               |
    +------------------------+----------------------------------+
*/
