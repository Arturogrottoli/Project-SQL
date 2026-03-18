-- ============================================================
-- CLASE 11: DATAWAREHOUSE Y BUSINESS INTELLIGENCE
-- Motor: MySQL
-- ============================================================
-- En esta clase separamos dos conceptos:
--   Base OLTP (tienda)  → la operacional de clases anteriores
--   Base OLAP (tienda_dw) → el datawarehouse que vamos a construir
-- ============================================================


-- ============================================================
-- PARTE A: BASE OPERACIONAL (OLTP)
-- Recreamos la base tienda con datos variados para luego
-- poblar el datawarehouse con ETL
-- ============================================================

DROP DATABASE IF EXISTS tienda;
CREATE DATABASE tienda;
USE tienda;

CREATE TABLE paises (
    id_pais  INT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(80) NOT NULL,
    codigo   CHAR(3)     NOT NULL UNIQUE
);

CREATE TABLE ciudades (
    id_ciudad INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(100) NOT NULL,
    id_pais   INT NOT NULL,
    FOREIGN KEY (id_pais) REFERENCES paises(id_pais)
);

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    email      VARCHAR(120),
    id_ciudad  INT,
    FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad)
);

CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(60) NOT NULL
);

CREATE TABLE productos (
    id_producto  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    precio       DECIMAL(8,2) NOT NULL,
    stock        INT DEFAULT 0,
    id_categoria INT,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE pedidos (
    id_pedido   INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente  INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad    INT NOT NULL DEFAULT 1,
    fecha       DATE NOT NULL,
    FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Datos
INSERT INTO paises VALUES (1,'Argentina','ARG'),(2,'Brasil','BRA'),(3,'Chile','CHL'),(4,'Uruguay','URY');
INSERT INTO ciudades VALUES
    (1,'Buenos Aires',1),(2,'Rosario',1),(3,'Cordoba',1),
    (4,'Sao Paulo',2),(5,'Rio de Janeiro',2),(6,'Santiago',3),(7,'Montevideo',4);
INSERT INTO clientes VALUES
    (1,'Lucas Gomez',    'lucas@mail.com',  1),
    (2,'Maria Fernandez','maria@mail.com',  1),
    (3,'Andres Torres',  'andres@mail.com', 2),
    (4,'Paula Ruiz',     'paula@mail.com',  4),
    (5,'Carlos Silva',   'carlos@mail.com', 6),
    (6,'Ana Lima',       'ana@mail.com',    5),
    (7,'Juan Perez',     'juan@mail.com',   3),
    (8,'Sofia Castro',   'sofia@mail.com',  7),
    (9,'Diego Mora',     'diego@mail.com',  4);

INSERT INTO categorias VALUES (1,'Computacion'),(2,'Perifericos'),(3,'Audio'),(4,'Video');
INSERT INTO productos VALUES
    (1,'Notebook Lenovo', 850.00, 20, 1),
    (2,'Monitor 27"',     320.00, 35, 1),
    (3,'Teclado Mecanico', 75.00,100, 2),
    (4,'Mouse Inalambrico',35.00,150, 2),
    (5,'Auriculares Gamer',60.00, 80, 3),
    (6,'Webcam HD',        45.00, 60, 4),
    (7,'SSD 1TB',         110.00, 50, 1),
    (8,'Hub USB',          25.00,200, 2);

INSERT INTO pedidos (id_cliente, id_producto, cantidad, fecha) VALUES
    -- Enero 2025
    (1,1,1,'2025-01-05'),(1,3,2,'2025-01-05'),(2,4,1,'2025-01-08'),
    (3,2,1,'2025-01-10'),(4,5,3,'2025-01-12'),(5,6,1,'2025-01-15'),
    (6,1,1,'2025-01-18'),(7,3,1,'2025-01-20'),(8,4,2,'2025-01-22'),
    (9,7,1,'2025-01-25'),(1,2,1,'2025-01-28'),
    -- Febrero 2025
    (2,1,1,'2025-02-03'),(3,5,2,'2025-02-05'),(4,8,3,'2025-02-07'),
    (5,3,1,'2025-02-10'),(6,6,2,'2025-02-12'),(7,7,1,'2025-02-15'),
    (8,2,1,'2025-02-18'),(9,4,5,'2025-02-20'),(1,5,1,'2025-02-22'),
    (2,8,2,'2025-02-25'),
    -- Marzo 2025
    (3,1,1,'2025-03-01'),(4,3,3,'2025-03-03'),(5,2,1,'2025-03-05'),
    (6,7,2,'2025-03-08'),(7,4,1,'2025-03-10'),(8,5,2,'2025-03-12'),
    (9,6,1,'2025-03-15'),(1,8,4,'2025-03-18'),(2,3,1,'2025-03-20'),
    (3,6,1,'2025-03-22'),(4,1,1,'2025-03-25');


-- ============================================================
-- REPASO: consultas analiticas sobre la base OLTP
-- ============================================================

-- Ventas totales por categoria
SELECT ca.nombre AS categoria,
       COUNT(pe.id_pedido)              AS pedidos,
       SUM(pe.cantidad)                 AS unidades,
       SUM(pe.cantidad * pr.precio)     AS facturacion
FROM pedidos pe
JOIN productos  pr ON pe.id_producto  = pr.id_producto
JOIN categorias ca ON pr.id_categoria = ca.id_categoria
GROUP BY ca.id_categoria, ca.nombre
ORDER BY facturacion DESC;

-- Top clientes por gasto
SELECT cl.nombre, SUM(pe.cantidad * pr.precio) AS total_gastado
FROM pedidos pe
JOIN clientes  cl ON pe.id_cliente  = cl.id_cliente
JOIN productos pr ON pe.id_producto = pr.id_producto
GROUP BY cl.id_cliente, cl.nombre
ORDER BY total_gastado DESC;


-- ============================================================
-- PARTE B: DATAWAREHOUSE (OLAP)
-- Construimos la base tienda_dw con esquema estrella
-- ============================================================

DROP DATABASE IF EXISTS tienda_dw;
CREATE DATABASE tienda_dw;
USE tienda_dw;


-- ============================================================
-- TEMA 1: ESQUEMA ESTRELLA (Star Schema)
-- ============================================================
-- El esquema estrella tiene:
--   1 tabla de HECHOS (fact table) → numeros que queremos analizar
--   N tablas de DIMENSIONES       → el contexto de esos numeros
--
-- Diferencia con OLTP:
--   OLTP: normalizado, optimizado para escritura (INSERT/UPDATE)
--   OLAP: desnormalizado, optimizado para lectura y agregaciones
--
--       dim_fecha     dim_cliente
--           \              /
--            \            /
--          fact_ventas  (tabla central)
--            /            \
--           /              \
--      dim_producto    dim_geografia


-- ---- DIMENSIONES ----

-- Dimension Fecha: permite analizar por dia, mes, trimestre, anio
CREATE TABLE dim_fecha (
    id_fecha    INT PRIMARY KEY,           -- formato YYYYMMDD: 20250115
    fecha       DATE NOT NULL,
    dia         INT,
    mes         INT,
    nombre_mes  VARCHAR(20),
    trimestre   INT,
    anio        INT,
    dia_semana  VARCHAR(15)
);

-- Dimension Cliente: atributos del cliente para filtrar/agrupar
CREATE TABLE dim_cliente (
    id_cliente  INT PRIMARY KEY,
    nombre      VARCHAR(100),
    email       VARCHAR(120),
    ciudad      VARCHAR(100),
    pais        VARCHAR(80)
);

-- Dimension Producto: atributos del producto
CREATE TABLE dim_producto (
    id_producto  INT PRIMARY KEY,
    nombre       VARCHAR(100),
    categoria    VARCHAR(60),
    precio_lista DECIMAL(8,2)
);

-- Dimension Geografia: permite analizar por zona geografica
CREATE TABLE dim_geografia (
    id_ciudad   INT PRIMARY KEY,
    ciudad      VARCHAR(100),
    pais        VARCHAR(80),
    region      VARCHAR(50)
);

-- ---- TABLA DE HECHOS ----
-- Contiene las metricas (numeros) que queremos analizar
-- y las claves foraneas a todas las dimensiones.

CREATE TABLE fact_ventas (
    id_venta        INT AUTO_INCREMENT PRIMARY KEY,
    id_fecha        INT NOT NULL,
    id_cliente      INT NOT NULL,
    id_producto     INT NOT NULL,
    id_ciudad       INT NOT NULL,
    cantidad        INT NOT NULL,
    precio_unitario DECIMAL(8,2) NOT NULL,
    importe_total   DECIMAL(10,2) NOT NULL,   -- medida precalculada
    FOREIGN KEY (id_fecha)    REFERENCES dim_fecha(id_fecha),
    FOREIGN KEY (id_cliente)  REFERENCES dim_cliente(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES dim_producto(id_producto),
    FOREIGN KEY (id_ciudad)   REFERENCES dim_geografia(id_ciudad)
);


-- ============================================================
-- TEMA 2: ETL — Extract, Transform, Load
-- ============================================================
-- ETL es el proceso de poblar el DW desde la base operacional:
--   Extract   → leemos datos de la fuente (tienda)
--   Transform → los adaptamos al modelo del DW (calculamos, limpiamos)
--   Load      → los insertamos en las tablas del DW (tienda_dw)


-- ---- E: EXTRACT + T: TRANSFORM + L: LOAD — dimension fecha ----
-- Generamos un registro por cada fecha de pedido que existe en tienda.
-- Calculamos todos los atributos de fecha con funciones de MySQL.

INSERT INTO tienda_dw.dim_fecha (id_fecha, fecha, dia, mes, nombre_mes, trimestre, anio, dia_semana)
SELECT DISTINCT
    DATE_FORMAT(pe.fecha, '%Y%m%d')  AS id_fecha,    -- clave: 20250115
    pe.fecha,
    DAY(pe.fecha)                    AS dia,
    MONTH(pe.fecha)                  AS mes,
    DATE_FORMAT(pe.fecha, '%M')      AS nombre_mes,
    QUARTER(pe.fecha)                AS trimestre,
    YEAR(pe.fecha)                   AS anio,
    DATE_FORMAT(pe.fecha, '%W')      AS dia_semana
FROM tienda.pedidos pe
ORDER BY pe.fecha;

SELECT * FROM dim_fecha;


-- ---- ETL — dimension cliente ----
-- Desnormalizamos: combinamos clientes + ciudades + paises en una sola tabla.

INSERT INTO tienda_dw.dim_cliente (id_cliente, nombre, email, ciudad, pais)
SELECT cl.id_cliente, cl.nombre, cl.email,
       ci.nombre AS ciudad,
       pa.nombre AS pais
FROM tienda.clientes cl
LEFT JOIN tienda.ciudades ci ON cl.id_ciudad = ci.id_ciudad
LEFT JOIN tienda.paises   pa ON ci.id_pais   = pa.id_pais;

SELECT * FROM dim_cliente;


-- ---- ETL — dimension producto ----

INSERT INTO tienda_dw.dim_producto (id_producto, nombre, categoria, precio_lista)
SELECT pr.id_producto, pr.nombre,
       ca.nombre AS categoria,
       pr.precio
FROM tienda.productos  pr
LEFT JOIN tienda.categorias ca ON pr.id_categoria = ca.id_categoria;

SELECT * FROM dim_producto;


-- ---- ETL — dimension geografia ----

INSERT INTO tienda_dw.dim_geografia (id_ciudad, ciudad, pais, region)
SELECT ci.id_ciudad, ci.nombre AS ciudad, pa.nombre AS pais,
       CASE pa.codigo
           WHEN 'ARG' THEN 'Cono Sur'
           WHEN 'URY' THEN 'Cono Sur'
           WHEN 'BRA' THEN 'America del Sur Norte'
           WHEN 'CHL' THEN 'Cono Sur'
           ELSE 'Otras'
       END AS region
FROM tienda.ciudades ci
JOIN tienda.paises pa ON ci.id_pais = pa.id_pais;

SELECT * FROM dim_geografia;


-- ---- ETL — tabla de hechos (fact_ventas) ----
-- Aqui cargamos las metricas: cantidad, precio y el importe precalculado.

INSERT INTO tienda_dw.fact_ventas (id_fecha, id_cliente, id_producto, id_ciudad, cantidad, precio_unitario, importe_total)
SELECT
    DATE_FORMAT(pe.fecha, '%Y%m%d')  AS id_fecha,
    pe.id_cliente,
    pe.id_producto,
    cl.id_ciudad,
    pe.cantidad,
    pr.precio                        AS precio_unitario,
    pe.cantidad * pr.precio          AS importe_total
FROM tienda.pedidos  pe
JOIN tienda.clientes  cl ON pe.id_cliente  = cl.id_cliente
JOIN tienda.productos pr ON pe.id_producto = pr.id_producto;

SELECT COUNT(*) AS registros_cargados FROM fact_ventas;
SELECT * FROM fact_ventas LIMIT 10;


-- ============================================================
-- TEMA 3: CONSULTAS ANALITICAS SOBRE EL DATAWAREHOUSE
-- ============================================================
-- Ahora todo el analisis corre sobre tienda_dw, no sobre tienda.
-- Las dimensiones ya tienen los datos desnormalizados: un solo
-- JOIN alcanza para traer todos los atributos.

USE tienda_dw;


-- ---- Facturacion total por mes ----
SELECT df.anio, df.mes, df.nombre_mes,
       COUNT(fv.id_venta)       AS pedidos,
       SUM(fv.cantidad)         AS unidades,
       SUM(fv.importe_total)    AS facturacion
FROM fact_ventas fv
JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
GROUP BY df.anio, df.mes, df.nombre_mes
ORDER BY df.anio, df.mes;


-- ---- Facturacion por categoria ----
SELECT dp.categoria,
       COUNT(fv.id_venta)    AS pedidos,
       SUM(fv.cantidad)      AS unidades,
       SUM(fv.importe_total) AS facturacion
FROM fact_ventas fv
JOIN dim_producto dp ON fv.id_producto = dp.id_producto
GROUP BY dp.categoria
ORDER BY facturacion DESC;


-- ---- Top clientes por facturacion ----
SELECT dc.nombre AS cliente, dc.ciudad, dc.pais,
       COUNT(fv.id_venta)    AS pedidos,
       SUM(fv.importe_total) AS total_comprado
FROM fact_ventas fv
JOIN dim_cliente dc ON fv.id_cliente = dc.id_cliente
GROUP BY dc.id_cliente, dc.nombre, dc.ciudad, dc.pais
ORDER BY total_comprado DESC;


-- ---- Facturacion por pais y categoria (pivot manual) ----
SELECT dg.pais,
       SUM(CASE WHEN dp.categoria = 'Computacion'  THEN fv.importe_total ELSE 0 END) AS computacion,
       SUM(CASE WHEN dp.categoria = 'Perifericos'  THEN fv.importe_total ELSE 0 END) AS perifericos,
       SUM(CASE WHEN dp.categoria = 'Audio'        THEN fv.importe_total ELSE 0 END) AS audio,
       SUM(CASE WHEN dp.categoria = 'Video'        THEN fv.importe_total ELSE 0 END) AS video,
       SUM(fv.importe_total)                                                          AS total
FROM fact_ventas fv
JOIN dim_geografia dg ON fv.id_ciudad   = dg.id_ciudad
JOIN dim_producto  dp ON fv.id_producto = dp.id_producto
GROUP BY dg.pais
ORDER BY total DESC;


-- ============================================================
-- TEMA 4: GROUP BY ROLLUP
-- ============================================================
-- ROLLUP extiende el GROUP BY para generar subtotales
-- y un gran total automaticamente.
-- Muy comun en reportes de BI.

-- Facturacion por anio → mes → con subtotales por anio y gran total
SELECT
    COALESCE(df.anio,  'TOTAL')           AS anio,
    COALESCE(df.nombre_mes, 'Subtotal')   AS mes,
    SUM(fv.importe_total)                 AS facturacion
FROM fact_ventas fv
JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
GROUP BY df.anio, df.nombre_mes WITH ROLLUP
ORDER BY df.anio, df.mes;

-- ROLLUP por pais y categoria
SELECT
    COALESCE(dg.pais,       'TOTAL')      AS pais,
    COALESCE(dp.categoria,  'Subtotal')   AS categoria,
    SUM(fv.importe_total)                 AS facturacion,
    COUNT(fv.id_venta)                    AS pedidos
FROM fact_ventas fv
JOIN dim_geografia dg ON fv.id_ciudad   = dg.id_ciudad
JOIN dim_producto  dp ON fv.id_producto = dp.id_producto
GROUP BY dg.pais, dp.categoria WITH ROLLUP
ORDER BY dg.pais, dp.categoria;


-- ============================================================
-- TEMA 5: CTEs (Common Table Expressions) — WITH
-- ============================================================
-- Un CTE es una consulta nombrada que podemos referenciar
-- dentro de la misma sentencia SQL. Equivale a un subselect
-- pero es mas legible y se puede reusar dentro de la query.
--
-- Sintaxis:
-- WITH nombre_cte AS (
--     SELECT ...
-- )
-- SELECT ... FROM nombre_cte ...

-- ---- CTE simple: ventas mensuales ----
WITH ventas_mensuales AS (
    SELECT df.anio, df.mes, df.nombre_mes,
           SUM(fv.importe_total) AS facturacion
    FROM fact_ventas fv
    JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
    GROUP BY df.anio, df.mes, df.nombre_mes
)
SELECT anio, nombre_mes, facturacion
FROM ventas_mensuales
ORDER BY anio, mes;


-- ---- CTEs multiples: calcular el mes con mayor venta ----
WITH ventas_mensuales AS (
    SELECT df.anio, df.mes, df.nombre_mes,
           SUM(fv.importe_total) AS facturacion
    FROM fact_ventas fv
    JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
    GROUP BY df.anio, df.mes, df.nombre_mes
),
max_ventas AS (
    SELECT MAX(facturacion) AS max_facturacion
    FROM ventas_mensuales
)
SELECT vm.anio, vm.nombre_mes, vm.facturacion
FROM ventas_mensuales vm
JOIN max_ventas mv ON vm.facturacion = mv.max_facturacion;


-- ---- CTE para ranking de clientes + filtro sobre el resultado ----
WITH ranking_clientes AS (
    SELECT dc.nombre, dc.pais,
           SUM(fv.importe_total) AS total_comprado,
           COUNT(fv.id_venta)    AS pedidos
    FROM fact_ventas fv
    JOIN dim_cliente dc ON fv.id_cliente = dc.id_cliente
    GROUP BY dc.id_cliente, dc.nombre, dc.pais
)
SELECT nombre, pais, total_comprado, pedidos
FROM ranking_clientes
WHERE total_comprado > 500
ORDER BY total_comprado DESC;


-- ============================================================
-- TEMA 6: WINDOW FUNCTIONS (funciones de ventana)
-- ============================================================
-- Las window functions calculan un valor por cada fila
-- basandose en un conjunto de filas relacionadas (la "ventana"),
-- SIN colapsar las filas como hace GROUP BY.
--
-- Sintaxis general:
-- FUNCION() OVER (
--     [PARTITION BY columna]   ← divide en grupos (opcional)
--     [ORDER BY columna]       ← ordena dentro del grupo (opcional)
-- )


-- ---- ROW_NUMBER: numero de fila dentro de la ventana ----
-- Numeramos las ventas de cada cliente en orden cronologico
SELECT dc.nombre AS cliente,
       df.fecha,
       fv.importe_total,
       ROW_NUMBER() OVER (
           PARTITION BY fv.id_cliente
           ORDER BY df.fecha
       ) AS nro_compra
FROM fact_ventas fv
JOIN dim_cliente dc ON fv.id_cliente = dc.id_cliente
JOIN dim_fecha   df ON fv.id_fecha   = df.id_fecha
ORDER BY dc.nombre, df.fecha;


-- ---- RANK y DENSE_RANK: ranking con empates ----
-- RANK: si dos filas empatan en el puesto 2, la siguiente es 4
-- DENSE_RANK: si dos filas empatan en el puesto 2, la siguiente es 3

SELECT dp.nombre AS producto, dp.categoria,
       SUM(fv.importe_total) AS facturacion,
       RANK()       OVER (ORDER BY SUM(fv.importe_total) DESC) AS rank_general,
       DENSE_RANK() OVER (ORDER BY SUM(fv.importe_total) DESC) AS dense_rank_general,
       RANK()       OVER (PARTITION BY dp.categoria ORDER BY SUM(fv.importe_total) DESC) AS rank_en_categoria
FROM fact_ventas fv
JOIN dim_producto dp ON fv.id_producto = dp.id_producto
GROUP BY dp.id_producto, dp.nombre, dp.categoria
ORDER BY facturacion DESC;


-- ---- SUM OVER PARTITION BY: acumulado por grupo ----
-- Total acumulado de ventas por mes, particionado por anio
SELECT df.anio, df.mes, df.nombre_mes,
       SUM(fv.importe_total) AS facturacion_mes,
       SUM(SUM(fv.importe_total)) OVER (
           PARTITION BY df.anio
           ORDER BY df.mes
       ) AS acumulado_anio
FROM fact_ventas fv
JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
GROUP BY df.anio, df.mes, df.nombre_mes
ORDER BY df.anio, df.mes;


-- ---- LAG: valor de la fila anterior ----
-- Comparamos la facturacion de cada mes con el mes anterior
WITH mensual AS (
    SELECT df.anio, df.mes, df.nombre_mes,
           SUM(fv.importe_total) AS facturacion
    FROM fact_ventas fv
    JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
    GROUP BY df.anio, df.mes, df.nombre_mes
)
SELECT anio, nombre_mes, facturacion,
       LAG(facturacion) OVER (ORDER BY anio, mes)   AS mes_anterior,
       ROUND(facturacion - LAG(facturacion) OVER (ORDER BY anio, mes), 2) AS variacion
FROM mensual
ORDER BY anio, mes;


-- ---- LEAD: valor de la fila siguiente ----
-- Mostramos la facturacion del mes siguiente para cada fila
WITH mensual AS (
    SELECT df.anio, df.mes, df.nombre_mes,
           SUM(fv.importe_total) AS facturacion
    FROM fact_ventas fv
    JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
    GROUP BY df.anio, df.mes, df.nombre_mes
)
SELECT anio, nombre_mes, facturacion,
       LEAD(facturacion) OVER (ORDER BY anio, mes) AS mes_siguiente
FROM mensual
ORDER BY anio, mes;


-- ---- Combinacion: top 2 productos por categoria ----
-- Usamos RANK() dentro de cada categoria para quedarnos
-- solo con los 2 mejores productos de cada una
WITH ranking AS (
    SELECT dp.categoria, dp.nombre AS producto,
           SUM(fv.importe_total) AS facturacion,
           RANK() OVER (
               PARTITION BY dp.categoria
               ORDER BY SUM(fv.importe_total) DESC
           ) AS ranking
    FROM fact_ventas fv
    JOIN dim_producto dp ON fv.id_producto = dp.id_producto
    GROUP BY dp.id_producto, dp.categoria, dp.nombre
)
SELECT categoria, producto, facturacion, ranking
FROM ranking
WHERE ranking <= 2
ORDER BY categoria, ranking;
