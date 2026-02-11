-- ============================================================
-- CLASE 01: CONSULTAS SIMPLES EN SQL (MySQL)
-- ============================================================
-- Este script es autocontenido: crea la base de datos, las
-- tablas, inserta datos de ejemplo y luego muestra todos los
-- temas de la primera clase con explicaciones paso a paso.
--
-- Temas cubiertos:
--   1. Crear y seleccionar una base de datos
--   2. Ver tablas y su estructura (SHOW TABLES, DESCRIBE)
--   3. SELECT basico (todos los campos y campos especificos)
--   4. ORDER BY (ASC, DESC, multiples columnas)
--   5. Columnas calculadas, alias (AS), funciones (ROUND, TRUNCATE, NOW)
--   6. WHERE y operadores (aritmeticos, relacionales, logicos)
--   7. BETWEEN / NOT BETWEEN
--   8. Funciones de fecha: YEAR(), MONTH(), DAY()
--   9. IN / NOT IN
--  10. LIKE / NOT LIKE (comodines % y _)
--  11. RLIKE (expresiones regulares)
--  12. LIMIT y OFFSET
--  13. IS NULL / IS NOT NULL
--  14. DISTINCT
--
-- Motor: MySQL
-- ============================================================


-- ============================================================
-- PASO 1: CREAR LA BASE DE DATOS
-- ============================================================
-- Eliminamos la base si ya existe para poder ejecutar este
-- script varias veces sin errores.

DROP DATABASE IF EXISTS negocio;
CREATE DATABASE negocio;
USE negocio;


-- ============================================================
-- PASO 2: CREAR LAS TABLAS (DDL)
-- ============================================================


-- ------------------------------------------------------------
-- TABLA: clientes
-- Almacena los datos personales de cada cliente.
-- ------------------------------------------------------------

CREATE TABLE clientes (
    idcliente   INT AUTO_INCREMENT PRIMARY KEY,  -- Clave primaria
    nombre      VARCHAR(50)  NOT NULL,           -- Nombre del cliente
    apellido    VARCHAR(50)  NOT NULL,           -- Apellido del cliente
    telefono    VARCHAR(20)  DEFAULT NULL,        -- Telefono (puede ser nulo)
    direccion   VARCHAR(100) DEFAULT NULL,        -- Direccion postal
    email       VARCHAR(100) DEFAULT NULL         -- Correo electronico
);


-- ------------------------------------------------------------
-- TABLA: productos
-- Almacena los articulos disponibles para la venta.
-- ------------------------------------------------------------

CREATE TABLE productos (
    idproducto  INT AUTO_INCREMENT PRIMARY KEY,
    articulo    VARCHAR(50)  NOT NULL,            -- Nombre del articulo
    marca       VARCHAR(50)  DEFAULT NULL,        -- Marca del producto
    precio      DECIMAL(10,2) DEFAULT NULL,       -- Precio unitario (puede ser nulo para productos sin precio definido)
    talle       INT          DEFAULT NULL          -- Talle (aplica a prendas de vestir)
);


-- ------------------------------------------------------------
-- TABLA: facturas
-- Registra las facturas emitidas a los clientes.
-- ------------------------------------------------------------

CREATE TABLE facturas (
    idfactura   INT AUTO_INCREMENT PRIMARY KEY,
    idcliente   INT NOT NULL,                     -- FK -> clientes(idcliente)
    tipo        CHAR(1) NOT NULL,                 -- Tipo de factura: 'a', 'b' o 'c'
    fecha       DATE NOT NULL,                    -- Fecha de emision
    total       DECIMAL(10,2) DEFAULT NULL,       -- Monto total
    FOREIGN KEY (idcliente) REFERENCES clientes(idcliente)
);


-- ============================================================
-- PASO 3: INSERTAR DATOS DE EJEMPLO (DML - INSERT)
-- ============================================================


-- ------------------------------------------------------------
-- DATOS: clientes (15 clientes variados)
-- ------------------------------------------------------------

INSERT INTO clientes (nombre, apellido, telefono, direccion, email) VALUES
    ('Maria',   'Gonzalez',   '1155001234', 'Av. Rivadavia 1500',    'maria.gonzalez@mail.com'),
    ('Martin',  'Lopez',      '1155005678', 'Calle Mitre 820',       'martin.lopez@mail.com'),
    ('Marta',   'Rodriguez',  '1155009012', 'Belgrano 340',          'marta.rod@mail.com'),
    ('Carlos',  'Fernandez',  '1155003456', 'San Martin 1200',       'carlos.f@mail.com'),
    ('Miriam',  'Perez',      '1155007890', 'Sarmiento 456',         'miriam.perez@mail.com'),
    ('Lucas',   'Martinez',   '1155002345', 'Av. Corrientes 3200',   'lucas.m@mail.com'),
    ('Morena',  'Garcia',     '1155006789', 'Lavalle 780',           'morena.g@mail.com'),
    ('Marco',   'Diaz',       '1155000123', 'Tucuman 1100',          'marco.diaz@mail.com'),
    ('Ana',     'Torres',     '1155004567', 'Av. Santa Fe 2400',     'ana.torres@mail.com'),
    ('Pedro',   'Ramirez',    '1155008901', 'Florida 500',           'pedro.r@mail.com'),
    ('Mirna',   'Suarez',     '1155001122', 'Junin 350',             'mirna.s@mail.com'),
    ('Jorge',   'Alvarez',    NULL,         'Pueyrredon 900',        'jorge.a@mail.com'),
    ('Mirko',   'Ruiz',       '1155003344', NULL,                    'mirko.r@mail.com'),
    ('Laura',   'Gomez',      '1155005566', 'Callao 1600',           NULL),
    ('Marina',  'Castro',     NULL,         NULL,                    'marina.c@mail.com');


-- ------------------------------------------------------------
-- DATOS: productos (20 productos variados con distintos talles y precios)
-- ------------------------------------------------------------

INSERT INTO productos (articulo, marca, precio, talle) VALUES
    ('Pantalon',    'Nike',     120.50,  2),
    ('Remera',      'Adidas',   85.00,   3),
    ('Campera',     'Puma',     250.00,  1),
    ('Pollera',     'Zara',     95.75,   2),
    ('Camisa',      'Lacoste',  180.00,  4),
    ('Buzo',        'Nike',     145.30,  5),
    ('Pantalon',    'Adidas',   110.00,  1),
    ('Remera',      'Puma',     78.50,   2),
    ('Campera',     'Nike',     320.00,  3),
    ('Bermuda',     'Adidas',   70.00,   5),
    ('Vestido',     'Zara',     135.00,  2),
    ('Chaleco',     'Lacoste',  160.00,  1),
    ('Musculosa',   'Puma',     55.00,   3),
    ('Camiseta',    'Nike',     100.00,  2),
    ('Piloto',      'Zara',     200.00,  4),
    ('Pantalon',    'Puma',     NULL,    1),    -- producto sin precio definido
    ('Calza',       'Adidas',   88.00,   5),
    ('Chomba',      'Lacoste',  125.00,  2),
    ('Corset',      'Zara',     75.00,   1),
    ('Capa',        'Puma',     210.00,  3);


-- ------------------------------------------------------------
-- DATOS: facturas (20 facturas entre 2016 y 2018)
-- ------------------------------------------------------------

INSERT INTO facturas (idcliente, tipo, fecha, total) VALUES
    (1,  'a', '2016-03-15', 1200.00),
    (2,  'b', '2016-07-22', 850.50),
    (3,  'a', '2016-11-10', 320.00),
    (4,  'c', '2017-01-05', 1500.75),
    (5,  'a', '2017-03-18', 670.00),
    (6,  'b', '2017-05-30', 2100.00),
    (7,  'a', '2017-07-14', 430.25),
    (8,  'c', '2017-08-21', 980.00),
    (9,  'b', '2017-09-03', 1750.50),
    (10, 'a', '2017-10-28', 560.00),
    (11, 'b', '2017-12-15', 890.75),
    (1,  'c', '2018-01-20', 1100.00),
    (2,  'a', '2018-03-08', 2300.00),
    (3,  'b', '2018-05-17', 475.50),
    (4,  'a', '2018-06-25', 1650.00),
    (5,  'c', '2018-08-12', 720.00),
    (6,  'a', '2018-09-30', 3100.50),
    (7,  'b', '2018-10-14', 280.00),
    (8,  'a', '2018-11-22', 1450.25),
    (9,  'c', '2018-12-31', 990.00);


-- ============================================================
-- PASO 4: VERIFICAR QUE TODO SE CREO CORRECTAMENTE
-- ============================================================

-- Muestra las tablas que existen en la base "negocio"
SHOW TABLES;

-- Muestra la estructura (columnas, tipos, claves) de cada tabla
DESCRIBE clientes;
DESCRIBE productos;
DESCRIBE facturas;


-- ============================================================
--  TEMA 1: SELECT BASICO
-- ============================================================
-- SELECT es la sentencia para CONSULTAR datos.
-- El asterisco (*) significa "todos los campos/columnas".
-- ============================================================

-- Mostrar TODOS los campos de la tabla clientes
SELECT * FROM clientes;  -- * = todos los campos

-- Mostrar solo ALGUNOS campos de la tabla clientes
SELECT  telefono,
        nombre,
        apellido
FROM    clientes;


-- ============================================================
--  TEMA 2: ORDER BY (ordenar resultados)
-- ============================================================
-- ORDER BY permite ordenar los resultados de la consulta.
--   ASC  = ascendente (A-Z, menor a mayor) --> es el valor por defecto
--   DESC = descendente (Z-A, mayor a menor)
-- ============================================================

-- Ordenar clientes alfabeticamente por apellido (A -> Z)
SELECT  telefono,
        nombre,
        apellido
FROM    clientes
ORDER BY apellido ASC;  -- ASC es opcional, es el orden por defecto

-- Ordenar clientes de la Z a la A (orden inverso/descendente)
SELECT  telefono,
        nombre,
        apellido
FROM    clientes
ORDER BY apellido DESC;

-- Ordenar por multiples columnas:
-- Primero ordena por apellido descendente (Z -> A).
-- Cuando dos clientes tienen el MISMO apellido, desempata por nombre ascendente (A -> Z).
SELECT  telefono,
        nombre,
        apellido
FROM    clientes
ORDER BY apellido DESC, nombre ASC;


-- ============================================================
--  TEMA 3: COLUMNAS CALCULADAS Y ALIAS (AS)
-- ============================================================
-- Podemos agregar "columnas calculadas" al SELECT. Estas columnas
-- NO se agregan a la tabla real, solo aparecen en el resultado
-- de la consulta.
--
-- AS permite darle un "alias" (nombre personalizado) a una columna.
-- ============================================================

SELECT  articulo,
        precio,
        -- Columna calculada: precio + 21% de IVA, redondeado sin decimales
        ROUND(precio * 1.21) AS 'precio con IVA (redondeado)',

        -- TRUNCATE corta los decimales sin redondear (a diferencia de ROUND)
        -- Ejemplo: 12.367 -> ROUND a 2 decimales = 12.37
        --          12.367 -> TRUNCATE a 2 decimales = 12.36
        TRUNCATE(precio * 1.21, 2) AS 'precio con IVA (truncado)',

        -- Columna de texto fijo (es la misma para todas las filas)
        'Precio incluye IVA 21%' AS 'nota',

        -- NOW() es una funcion de MySQL que devuelve la fecha y hora actual
        NOW() AS 'fecha de consulta',

        marca
FROM    productos;

-- DUAL: tabla virtual que MySQL crea automaticamente.
-- Se usa cuando queremos traer columnas que NO estan en ninguna tabla.
SELECT NOW() AS 'fecha y hora actual' FROM dual;


-- ============================================================
--  TEMA 4: WHERE - FILTRAR REGISTROS
-- ============================================================
-- WHERE permite filtrar las filas que devuelve la consulta.
-- Solo muestra las filas que CUMPLAN la condicion indicada.
--
-- Operadores aritmeticos: +  -  *  /
-- Operadores relacionales: <  >  <=  >=  =  <> (o !=)
-- Operadores logicos:      AND  OR  NOT
-- ============================================================


-- ============================================================
--  TEMA 5: BETWEEN (rango de valores)
-- ============================================================
-- BETWEEN filtra valores dentro de un rango CERRADO (incluye extremos).
-- Siempre poner el valor MENOR primero.
-- NOT BETWEEN excluye los extremos.
-- ============================================================

-- Listar productos con precio entre 100 y 150 pesos
SELECT      *
FROM        productos
WHERE       precio BETWEEN 100 AND 150  -- incluye 100 y 150
ORDER BY    precio DESC, idproducto ASC;

-- Forma equivalente sin BETWEEN (mismo resultado):
-- WHERE precio >= 100 AND precio <= 150

-- IMPORTANTE: NO poner el valor mayor primero, no funciona:
-- WHERE precio BETWEEN 150 AND 100  -- MAL! No devuelve resultados


-- ============================================================
--  TEMA 6: BETWEEN CON FECHAS + FUNCIONES DE FECHA
-- ============================================================
-- Para campos de tipo DATE, usar formato japones: 'AAAA-MM-DD'
-- (ano-mes-dia). Siempre poner la fecha MAS ANTIGUA primero.
--
-- Funciones de MySQL para extraer partes de una fecha:
--   YEAR(fecha)  -> extrae el ano
--   MONTH(fecha) -> extrae el mes
--   DAY(fecha)   -> extrae el dia
-- ============================================================

-- Listar las facturas del ano 2017
SELECT  *
FROM    facturas
WHERE   fecha BETWEEN '2017-01-01' AND '2017-12-31';

-- Forma alternativa usando la funcion YEAR():
SELECT  *
FROM    facturas
WHERE   YEAR(fecha) = 2017;

-- Facturas que NO sean del 2017
SELECT  *
FROM    facturas
WHERE   NOT YEAR(fecha) = 2017;

-- Facturas del segundo semestre del 2017 (julio a diciembre)
SELECT  *
FROM    facturas
WHERE   fecha BETWEEN '2017-07-01' AND '2017-12-31';

-- Factura de una fecha especifica (21 de agosto de 2017)
SELECT  *
FROM    facturas
WHERE   YEAR(fecha) = 2017 AND MONTH(fecha) = 8 AND DAY(fecha) = 21;


-- ============================================================
--  TEMA 7: IN (operador de lista)
-- ============================================================
-- IN permite filtrar por una lista de valores posibles.
-- Es una forma mas limpia de escribir multiples OR.
-- NOT IN excluye los valores de la lista.
-- ============================================================

-- Listar productos cuyo talle sea 1, 2 o 5
SELECT  *
FROM    productos
WHERE   talle IN (1, 2, 5);

-- Forma equivalente con OR (mismo resultado, pero mas largo):
-- WHERE talle = 1 OR talle = 2 OR talle = 5

-- Productos cuyo talle NO sea 1, 2 ni 5
SELECT  *
FROM    productos
WHERE   talle NOT IN (1, 2, 5);

-- Facturas de tipo 'a' o 'b'
SELECT  *
FROM    facturas
WHERE   tipo IN ('a', 'b');


-- ============================================================
--  TEMA 8: LIKE (operador de similitud / patrones de texto)
-- ============================================================
-- LIKE busca patrones dentro de valores de texto.
-- Usa dos comodines:
--   %  -> cualquier cantidad de caracteres (0 o mas)
--   _  -> exactamente UN caracter en esa posicion
--
-- NOT LIKE excluye las filas que coincidan con el patron.
-- ============================================================

-- Productos que EMPIECEN con la letra 'P'
SELECT  *
FROM    productos
WHERE   articulo LIKE 'p%';

-- Productos que NO empiecen con 'P'
SELECT  *
FROM    productos
WHERE   articulo NOT LIKE 'p%';

-- Productos que TERMINEN con la letra 'o'
SELECT  *
FROM    productos
WHERE   articulo LIKE '%o';

-- Productos que EMPIECEN con 'C' y TERMINEN con 'a'
SELECT  *
FROM    productos
WHERE   articulo LIKE 'c%a';

-- Clientes cuyo nombre:
--   - empiece con M
--   - el 2do caracter sea cualquiera
--   - el 3er caracter sea R
--   - termine como sea
-- Ejemplos que coinciden: Maria, Martin, Marta, Miriam, Mirna, Mirko, Marco, Morena
SELECT  *
FROM    clientes
WHERE   nombre LIKE 'm_r%';  -- _ es comodin de UN solo caracter


-- ============================================================
--  TEMA 9: RLIKE (expresiones regulares)
-- ============================================================
-- RLIKE (o REGEXP) permite usar expresiones regulares para
-- hacer busquedas mas avanzadas en texto.
--
-- Simbolos principales:
--   ^      -> empieza con (ej: '^a' = empieza con a)
--   $      -> termina con (ej: 'n$' = termina con n)
--   .*     -> cualquier cantidad de caracteres (equivale a % en LIKE)
--   [abc]  -> cualquiera de esos caracteres (lista)
--   [a-z]  -> rango de caracteres
--   [^a]   -> negacion: cualquier caracter EXCEPTO 'a'
--   [0-9]  -> cualquier digito
-- ============================================================

-- Clientes cuyo nombre empiece con 'M'
SELECT  *
FROM    clientes
WHERE   nombre RLIKE '^m';
-- Alternativa con LIKE: WHERE nombre LIKE 'm%'

-- Clientes cuyo nombre termine con 'a'
SELECT  *
FROM    clientes
WHERE   nombre RLIKE 'a$';
-- Alternativa con LIKE: WHERE nombre LIKE '%a'

-- Clientes cuyo nombre empiece con 'M' y termine con 'a'
SELECT  *
FROM    clientes
WHERE   nombre RLIKE '^m.*a$';  -- .* equivale al % de LIKE

-- Clientes cuyo nombre empiece con 'M' o 'L' (usando lista)
SELECT  *
FROM    clientes
WHERE   nombre RLIKE '^[ml]';

-- Clientes cuyo apellido termine en un caracter del rango e-z
SELECT  *
FROM    clientes
WHERE   apellido RLIKE '[e-z]$';


-- ============================================================
--  TEMA 10: LIMIT (limitar cantidad de resultados)
-- ============================================================
-- LIMIT corta la cantidad de filas devueltas.
-- Se usa mucho combinado con ORDER BY para obtener
-- los "top N" registros.
--
-- Sintaxis:
--   LIMIT N          -> muestra las primeras N filas
--   LIMIT offset, N  -> se salta 'offset' filas y muestra las N siguientes
-- ============================================================

-- Los primeros 5 productos
SELECT  *
FROM    productos
LIMIT   5;

-- Los 5 productos MAS CAROS
SELECT      *
FROM        productos
WHERE       precio IS NOT NULL     -- excluimos productos sin precio
ORDER BY    precio DESC            -- ordenamos de mayor a menor
LIMIT       5;                     -- cortamos en los 5 primeros

-- Los 3 productos MAS BARATOS (que tengan precio)
SELECT      *
FROM        productos
WHERE       precio IS NOT NULL
ORDER BY    precio ASC
LIMIT       3;

-- OFFSET: saltear registros
-- Se salta los primeros 5 y muestra los 3 siguientes (posiciones 6, 7 y 8)
SELECT  *
FROM    productos
LIMIT   5, 3;  -- offset: 5, cantidad: 3


-- ============================================================
--  TEMA 11: IS NULL / IS NOT NULL
-- ============================================================
-- NULL significa "ausencia de valor" (no es 0, no es texto vacio).
-- Para comparar con NULL se usa IS NULL o IS NOT NULL.
-- NUNCA usar = NULL o != NULL (no funciona como se espera).
-- ============================================================

-- Productos que NO tienen precio definido (precio es NULL)
SELECT  *
FROM    productos
WHERE   precio IS NULL;

-- Productos que SI tienen precio definido
SELECT  *
FROM    productos
WHERE   precio IS NOT NULL;

-- Clientes que no tienen telefono cargado
SELECT  *
FROM    clientes
WHERE   telefono IS NULL;

-- Clientes que tienen todos sus datos completos (sin ningun NULL)
SELECT  *
FROM    clientes
WHERE   telefono IS NOT NULL
  AND   direccion IS NOT NULL
  AND   email IS NOT NULL;


-- ============================================================
--  TEMA 12: DISTINCT (valores unicos, sin repeticiones)
-- ============================================================
-- DISTINCT elimina las filas duplicadas del resultado.
-- Util para ver los diferentes valores que tiene una columna.
-- ============================================================

-- Ver todas las marcas (CON repeticion)
SELECT marca FROM productos;

-- Ver las marcas sin repetir
SELECT DISTINCT marca FROM productos;

-- Ver los diferentes talles disponibles
SELECT DISTINCT talle FROM productos ORDER BY talle;

-- Ver las combinaciones unicas de tipo de factura
SELECT DISTINCT tipo FROM facturas;


-- ============================================================
--  TEMA 13: EJERCICIOS COMBINADOS
-- ============================================================
-- Estos ejercicios combinan varios de los temas vistos
-- para resolver consultas mas complejas.
-- ============================================================

-- Ejercicio 1: Listar los productos de marca 'Nike' o 'Adidas'
-- con precio mayor a 100, ordenados por precio descendente
SELECT      *
FROM        productos
WHERE       marca IN ('Nike', 'Adidas')
  AND       precio > 100
ORDER BY    precio DESC;

-- Ejercicio 2: Listar las facturas de tipo 'a' del ano 2017
-- ordenadas por total de mayor a menor
SELECT      *
FROM        facturas
WHERE       tipo = 'a'
  AND       YEAR(fecha) = 2017
ORDER BY    total DESC;

-- Ejercicio 3: Listar los clientes cuyo nombre empiece con 'M',
-- el tercer caracter sea 'r', y mostrar solo los 3 primeros resultados
SELECT  *
FROM    clientes
WHERE   nombre LIKE 'm_r%'
LIMIT   3;

-- Ejercicio 4: Listar los productos con precio entre 80 y 200,
-- mostrando el articulo, precio original y precio con IVA,
-- ordenados por precio con IVA de menor a mayor
SELECT      articulo,
            precio AS 'precio sin IVA',
            ROUND(precio * 1.21, 2) AS 'precio con IVA'
FROM        productos
WHERE       precio BETWEEN 80 AND 200
ORDER BY    precio * 1.21 ASC;

-- Ejercicio 5: Contar cuantas facturas hay de cada tipo
-- (adelanto del tema GROUP BY de la proxima clase)
SELECT      tipo,
            COUNT(*) AS 'cantidad de facturas'
FROM        facturas
GROUP BY    tipo
ORDER BY    tipo;


-- ============================================================
-- RESUMEN DE CLAUSULAS Y SU ORDEN EN UNA CONSULTA
-- ============================================================
/*
    SELECT      columnas o expresiones
    FROM        tabla
    WHERE       condicion de filtro (filas individuales)
    GROUP BY    agrupamiento (se ve en clases siguientes)
    HAVING      filtro de grupos (se ve en clases siguientes)
    ORDER BY    ordenamiento del resultado
    LIMIT       cantidad maxima de filas a mostrar

    Operadores vistos:
    +-----------+----------------------------------------------+
    | Operador  | Uso                                          |
    +-----------+----------------------------------------------+
    | =         | Igualdad                                     |
    | <> o !=   | Diferente                                    |
    | > < >= <= | Comparacion                                  |
    | BETWEEN   | Rango cerrado (incluye extremos)             |
    | IN        | Pertenencia a una lista de valores           |
    | LIKE      | Patron de texto (% = varios, _ = uno)        |
    | RLIKE     | Expresion regular                            |
    | IS NULL   | El valor es nulo (sin dato)                  |
    | IS NOT NULL | El valor NO es nulo                        |
    | AND       | Ambas condiciones deben cumplirse            |
    | OR        | Al menos una condicion debe cumplirse        |
    | NOT       | Niega la condicion                           |
    +-----------+----------------------------------------------+

    Funciones vistas:
    +------------+---------------------------------------------+
    | Funcion    | Uso                                         |
    +------------+---------------------------------------------+
    | ROUND()    | Redondea un numero decimal                  |
    | TRUNCATE() | Corta decimales sin redondear               |
    | NOW()      | Fecha y hora actual del servidor            |
    | YEAR()     | Extrae el ano de una fecha                  |
    | MONTH()    | Extrae el mes de una fecha                  |
    | DAY()      | Extrae el dia de una fecha                  |
    +------------+---------------------------------------------+
*/
