-- ============================================================
-- CLASE 07: FUNCIONES Y STORED PROCEDURES
-- Motor: MySQL
-- ============================================================


-- ============================================================
-- SETUP: reutilizamos la base tienda de clase06
-- Tablas: paises, ciudades, clientes, productos, pedidos
-- ============================================================

DROP DATABASE IF EXISTS tienda;
CREATE DATABASE tienda;
USE tienda;

CREATE TABLE paises (
    id_pais  INT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(80)  NOT NULL,
    codigo   CHAR(3)      NOT NULL UNIQUE
);

CREATE TABLE ciudades (
    id_ciudad INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(100) NOT NULL,
    id_pais   INT NOT NULL,
    CONSTRAINT fk_ciudad_pais
        FOREIGN KEY (id_pais) REFERENCES paises(id_pais)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    email      VARCHAR(120),
    id_ciudad  INT,
    CONSTRAINT fk_cliente_ciudad
        FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    precio      DECIMAL(8,2) NOT NULL,
    stock       INT DEFAULT 0
);

CREATE TABLE pedidos (
    id_pedido   INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente  INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad    INT NOT NULL DEFAULT 1,
    fecha       DATE NOT NULL,
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente)  ON DELETE RESTRICT,
    CONSTRAINT fk_pedido_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE RESTRICT
);

INSERT INTO paises (nombre, codigo) VALUES
    ('Argentina', 'ARG'), ('Brasil',   'BRA'),
    ('Chile',     'CHL'), ('Uruguay',  'URY');

INSERT INTO ciudades (nombre, id_pais) VALUES
    ('Buenos Aires',   1), ('Rosario',        1), ('Cordoba',        1),
    ('Sao Paulo',      2), ('Rio de Janeiro', 2),
    ('Santiago',       3), ('Montevideo',     4);

INSERT INTO clientes (nombre, email, id_ciudad) VALUES
    ('Lucas Gomez',     'lucas@mail.com',   1),
    ('Maria Fernandez', 'maria@mail.com',   1),
    ('Andres Torres',   'andres@mail.com',  2),
    ('Paula Ruiz',      'paula@mail.com',   4),
    ('Carlos Silva',    'carlos@mail.com',  6),
    ('Ana Lima',        'ana@mail.com',     5),
    ('Juan Perez',      'juan@mail.com',    3);

INSERT INTO productos (nombre, precio, stock) VALUES
    ('Notebook Lenovo',   850.00, 20),
    ('Monitor 27"',       320.00, 35),
    ('Teclado Mecanico',   75.00, 100),
    ('Mouse Inalambrico',  35.00, 150),
    ('Auriculares Gamer',  60.00, 80),
    ('Webcam HD',          45.00, 60);

INSERT INTO pedidos (id_cliente, id_producto, cantidad, fecha) VALUES
    (1, 1, 1, '2025-01-10'),
    (1, 3, 2, '2025-01-10'),
    (2, 4, 1, '2025-01-12'),
    (3, 2, 1, '2025-01-15'),
    (4, 5, 3, '2025-01-18'),
    (5, 6, 1, '2025-01-20'),
    (6, 1, 1, '2025-02-01'),
    (7, 3, 1, '2025-02-05'),
    (1, 2, 1, '2025-02-10');


-- ============================================================
-- REPASO RAPIDO (clases anteriores)
-- ============================================================

-- JOIN de 3 tablas: pedidos con cliente y producto
SELECT pe.id_pedido,
       cl.nombre                                AS cliente,
       pr.nombre                                AS producto,
       pe.cantidad,
       ROUND(pe.cantidad * pr.precio, 2)        AS total,
       pe.fecha
FROM pedidos pe
JOIN clientes  cl ON pe.id_cliente  = cl.id_cliente
JOIN productos pr ON pe.id_producto = pr.id_producto
ORDER BY pe.fecha;

-- Agregacion: total gastado por cliente (repaso GROUP BY)
SELECT cl.nombre AS cliente, SUM(pe.cantidad * pr.precio) AS total_gastado
FROM pedidos pe
JOIN clientes  cl ON pe.id_cliente  = cl.id_cliente
JOIN productos pr ON pe.id_producto = pr.id_producto
GROUP BY cl.id_cliente, cl.nombre
ORDER BY total_gastado DESC;


-- ============================================================
-- POR QUE NECESITAMOS DELIMITER
-- ============================================================
-- MySQL usa ';' para detectar el fin de cada sentencia.
-- Dentro de un procedimiento hay MUCHAS sentencias con ';'.
-- Si no cambiamos el delimitador, MySQL corta el bloque a la mitad.
--
-- Solucion: cambiamos el delimitador a '//' (o cualquier otro
-- simbolo que no aparezca dentro del codigo) mientras escribimos
-- el procedimiento, y lo restauramos a ';' al terminar.
--
-- DELIMITER //
-- CREATE PROCEDURE ...
-- BEGIN
--     sentencia1;    <- estos ; no confunden a MySQL porque el
--     sentencia2;       delimitador ahora es //
-- END //
-- DELIMITER ;
-- ============================================================


-- ============================================================
-- TEMA 1: STORED PROCEDURES SIN PARAMETROS
-- ============================================================
-- Un stored procedure (procedimiento almacenado) es un bloque
-- de codigo SQL guardado en la base de datos con un nombre.
-- Se llama con CALL nombre_procedimiento().
-- Util para encapsular logica repetitiva.

DELIMITER //

-- Procedimiento 1: reporte rapido de stock
CREATE PROCEDURE reporte_stock()
BEGIN
    SELECT nombre, precio, stock,
           CASE
               WHEN stock < 30  THEN 'CRITICO'
               WHEN stock < 70  THEN 'BAJO'
               ELSE                  'OK'
           END AS estado_stock
    FROM productos
    ORDER BY stock ASC;
END //

-- Procedimiento 2: resumen de ventas del periodo
CREATE PROCEDURE resumen_ventas()
BEGIN
    -- Cantidad total de pedidos
    SELECT COUNT(*)            AS total_pedidos,
           SUM(pe.cantidad)    AS unidades_vendidas,
           SUM(pe.cantidad * pr.precio) AS facturacion_total
    FROM pedidos pe
    JOIN productos pr ON pe.id_producto = pr.id_producto;
END //

DELIMITER ;

-- Llamamos a los procedimientos con CALL
CALL reporte_stock();
CALL resumen_ventas();

-- Ver los procedimientos guardados en la base actual
SHOW PROCEDURE STATUS WHERE Db = 'tienda';


-- ============================================================
-- TEMA 2: STORED PROCEDURES CON PARAMETRO IN
-- ============================================================
-- IN: el procedimiento RECIBE un valor del exterior.
-- Es el tipo de parametro por defecto.

DELIMITER //

-- Procedimiento: pedidos de un cliente especifico
CREATE PROCEDURE pedidos_de_cliente(IN p_id_cliente INT)
BEGIN
    SELECT pe.id_pedido,
           cl.nombre                          AS cliente,
           pr.nombre                          AS producto,
           pe.cantidad,
           pe.cantidad * pr.precio            AS subtotal,
           pe.fecha
    FROM pedidos pe
    JOIN clientes  cl ON pe.id_cliente  = cl.id_cliente
    JOIN productos pr ON pe.id_producto = pr.id_producto
    WHERE pe.id_cliente = p_id_cliente
    ORDER BY pe.fecha;
END //

-- Procedimiento: productos por debajo de un stock minimo
CREATE PROCEDURE productos_con_poco_stock(IN p_minimo INT)
BEGIN
    SELECT nombre, precio, stock
    FROM productos
    WHERE stock <= p_minimo
    ORDER BY stock ASC;
END //

-- Procedimiento: actualizar precio de un producto (recibe id y nuevo precio)
CREATE PROCEDURE actualizar_precio(IN p_id_producto INT, IN p_nuevo_precio DECIMAL(8,2))
BEGIN
    UPDATE productos
    SET precio = p_nuevo_precio
    WHERE id_producto = p_id_producto;

    -- Mostramos el resultado del cambio
    SELECT id_producto, nombre, precio AS precio_nuevo
    FROM productos
    WHERE id_producto = p_id_producto;
END //

DELIMITER ;

-- Usamos los procedimientos con parametros
CALL pedidos_de_cliente(1);          -- pedidos de Lucas Gomez
CALL pedidos_de_cliente(4);          -- pedidos de Paula Ruiz

CALL productos_con_poco_stock(70);   -- productos con stock <= 70

CALL actualizar_precio(1, 799.00);   -- Notebook baja de 850 a 799


-- ============================================================
-- TEMA 3: STORED PROCEDURES CON PARAMETRO OUT
-- ============================================================
-- OUT: el procedimiento DEVUELVE un valor al exterior.
-- La variable se pasa vacia y el procedimiento la llena.

DELIMITER //

-- Procedimiento: devuelve la cantidad de clientes registrados
CREATE PROCEDURE contar_clientes(OUT p_total INT)
BEGIN
    SELECT COUNT(*) INTO p_total
    FROM clientes;
END //

-- Procedimiento: devuelve el producto mas caro
CREATE PROCEDURE producto_mas_caro(OUT p_nombre VARCHAR(100), OUT p_precio DECIMAL(8,2))
BEGIN
    SELECT nombre, precio
    INTO p_nombre, p_precio
    FROM productos
    ORDER BY precio DESC
    LIMIT 1;
END //

-- Procedimiento: calcula el total facturado por un cliente
CREATE PROCEDURE total_cliente(IN p_id_cliente INT, OUT p_total DECIMAL(10,2))
BEGIN
    SELECT COALESCE(SUM(pe.cantidad * pr.precio), 0)
    INTO p_total
    FROM pedidos pe
    JOIN productos pr ON pe.id_producto = pr.id_producto
    WHERE pe.id_cliente = p_id_cliente;
END //

DELIMITER ;

-- Usamos los procedimientos OUT
-- La variable de salida se declara con @ (variable de sesion)
CALL contar_clientes(@total);
SELECT @total AS total_clientes;

CALL producto_mas_caro(@nombre, @precio);
SELECT @nombre AS producto, @precio AS precio;

CALL total_cliente(1, @facturado);
SELECT @facturado AS total_facturado_lucas;

CALL total_cliente(3, @facturado);
SELECT @facturado AS total_facturado_andres;


-- ============================================================
-- TEMA 4: VARIABLES LOCALES (DECLARE y SET)
-- ============================================================
-- Las variables locales se declaran DENTRO del BEGIN...END
-- con DECLARE y solo existen mientras el procedimiento corre.
-- Son distintas de las variables de sesion (@nombre).

DELIMITER //

CREATE PROCEDURE descuento_por_volumen(IN p_id_cliente INT)
BEGIN
    -- Declaramos variables locales
    DECLARE v_total        DECIMAL(10,2);
    DECLARE v_descuento    DECIMAL(5,2);
    DECLARE v_final        DECIMAL(10,2);
    DECLARE v_nivel        VARCHAR(20);

    -- Calculamos el total del cliente
    SELECT COALESCE(SUM(pe.cantidad * pr.precio), 0)
    INTO v_total
    FROM pedidos pe
    JOIN productos pr ON pe.id_producto = pr.id_producto
    WHERE pe.id_cliente = p_id_cliente;

    -- Determinamos el descuento segun el nivel de compra
    IF v_total >= 1500 THEN
        SET v_descuento = 15.00;
        SET v_nivel     = 'ORO';
    ELSEIF v_total >= 800 THEN
        SET v_descuento = 10.00;
        SET v_nivel     = 'PLATA';
    ELSEIF v_total >= 300 THEN
        SET v_descuento = 5.00;
        SET v_nivel     = 'BRONCE';
    ELSE
        SET v_descuento = 0.00;
        SET v_nivel     = 'SIN NIVEL';
    END IF;

    -- Calculamos el precio final con descuento
    SET v_final = v_total - (v_total * v_descuento / 100);

    -- Devolvemos el resultado
    SELECT cl.nombre              AS cliente,
           v_nivel                AS nivel,
           v_total                AS total_bruto,
           v_descuento            AS descuento_pct,
           ROUND(v_final, 2)      AS total_con_descuento
    FROM clientes cl
    WHERE cl.id_cliente = p_id_cliente;
END //

DELIMITER ;

CALL descuento_por_volumen(1);   -- Lucas: deberia ser nivel ORO o PLATA
CALL descuento_por_volumen(4);   -- Paula: depende de sus pedidos
CALL descuento_por_volumen(5);   -- Carlos


-- ============================================================
-- TEMA 5: IF / ELSEIF / ELSE dentro de procedimientos
-- ============================================================

DELIMITER //

-- Clasifica un producto segun su precio
CREATE PROCEDURE clasificar_producto(IN p_id_producto INT)
BEGIN
    DECLARE v_precio    DECIMAL(8,2);
    DECLARE v_nombre    VARCHAR(100);
    DECLARE v_categoria VARCHAR(30);

    SELECT nombre, precio INTO v_nombre, v_precio
    FROM productos
    WHERE id_producto = p_id_producto;

    IF v_precio >= 500 THEN
        SET v_categoria = 'PREMIUM';
    ELSEIF v_precio >= 100 THEN
        SET v_categoria = 'ESTANDAR';
    ELSEIF v_precio >= 50 THEN
        SET v_categoria = 'ECONOMICO';
    ELSE
        SET v_categoria = 'BASICO';
    END IF;

    SELECT v_nombre AS producto, v_precio AS precio, v_categoria AS segmento;
END //

DELIMITER ;

-- Probamos con distintos productos
CALL clasificar_producto(1);   -- Notebook 799 -> PREMIUM
CALL clasificar_producto(2);   -- Monitor 320  -> ESTANDAR
CALL clasificar_producto(3);   -- Teclado 75   -> ECONOMICO
CALL clasificar_producto(4);   -- Mouse 35     -> BASICO


-- ============================================================
-- TEMA 6: CASE dentro de procedimientos
-- ============================================================
-- CASE es mas limpio que IF/ELSEIF cuando comparamos
-- una misma variable contra varios valores fijos.

DELIMITER //

CREATE PROCEDURE info_pais(IN p_codigo CHAR(3))
BEGIN
    DECLARE v_moneda   VARCHAR(30);
    DECLARE v_idioma   VARCHAR(30);
    DECLARE v_capital  VARCHAR(80);

    -- CASE simple: compara p_codigo contra valores fijos
    CASE p_codigo
        WHEN 'ARG' THEN
            SET v_moneda  = 'Peso Argentino';
            SET v_idioma  = 'Espanol';
            SET v_capital = 'Buenos Aires';
        WHEN 'BRA' THEN
            SET v_moneda  = 'Real';
            SET v_idioma  = 'Portugues';
            SET v_capital = 'Brasilia';
        WHEN 'CHL' THEN
            SET v_moneda  = 'Peso Chileno';
            SET v_idioma  = 'Espanol';
            SET v_capital = 'Santiago';
        WHEN 'URY' THEN
            SET v_moneda  = 'Peso Uruguayo';
            SET v_idioma  = 'Espanol';
            SET v_capital = 'Montevideo';
        ELSE
            SET v_moneda  = 'Desconocida';
            SET v_idioma  = 'Desconocido';
            SET v_capital = 'Desconocida';
    END CASE;

    SELECT p_codigo  AS codigo,
           v_capital AS capital,
           v_idioma  AS idioma,
           v_moneda  AS moneda;
END //

DELIMITER ;

CALL info_pais('ARG');
CALL info_pais('BRA');
CALL info_pais('URY');


-- ============================================================
-- TEMA 7: WHILE (bucle)
-- ============================================================
-- WHILE ejecuta un bloque mientras la condicion sea TRUE.
-- Util para generar datos de prueba, procesar rangos, etc.

DELIMITER //

-- Genera N registros de prueba en una tabla temporal
CREATE PROCEDURE generar_prueba(IN p_cantidad INT)
BEGIN
    DECLARE v_i INT DEFAULT 1;

    -- Creamos tabla temporal si no existe
    DROP TABLE IF EXISTS prueba_numeros;
    CREATE TABLE prueba_numeros (
        numero INT,
        cuadrado INT,
        es_par VARCHAR(2)
    );

    -- Bucle: inserta filas del 1 al p_cantidad
    WHILE v_i <= p_cantidad DO
        INSERT INTO prueba_numeros (numero, cuadrado, es_par)
        VALUES (
            v_i,
            v_i * v_i,
            IF(v_i MOD 2 = 0, 'SI', 'NO')
        );
        SET v_i = v_i + 1;
    END WHILE;

    -- Mostramos el resultado
    SELECT * FROM prueba_numeros;
END //

DELIMITER ;

CALL generar_prueba(10);
DROP TABLE IF EXISTS prueba_numeros;


-- ============================================================
-- TEMA 8: FUNCIONES (CREATE FUNCTION)
-- ============================================================
-- Una funcion es como un procedimiento pero:
--   - SIEMPRE retorna un valor (con RETURN)
--   - Se puede usar dentro de un SELECT, WHERE, etc.
--   - No puede usar OUT/INOUT
--
-- Diferencia clave:
--   PROCEDURE → se llama con CALL, puede hacer varias cosas
--   FUNCTION  → se llama dentro de una consulta, devuelve un valor

DELIMITER //

-- Funcion 1: calcula el subtotal de una linea de pedido
CREATE FUNCTION calcular_subtotal(p_cantidad INT, p_precio DECIMAL(8,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_cantidad * p_precio;
END //


-- Funcion 2: clasifica el stock de un producto
CREATE FUNCTION estado_stock(p_stock INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE v_estado VARCHAR(10);

    IF p_stock < 30 THEN
        SET v_estado = 'CRITICO';
    ELSEIF p_stock < 70 THEN
        SET v_estado = 'BAJO';
    ELSE
        SET v_estado = 'OK';
    END IF;

    RETURN v_estado;
END //


-- Funcion 3: devuelve el nombre completo del pais a partir de su codigo
CREATE FUNCTION nombre_pais(p_codigo CHAR(3))
RETURNS VARCHAR(80)
READS SQL DATA
BEGIN
    DECLARE v_nombre VARCHAR(80);

    SELECT nombre INTO v_nombre
    FROM paises
    WHERE codigo = p_codigo;

    RETURN COALESCE(v_nombre, 'Desconocido');
END //

DELIMITER ;


-- ---- Usamos las funciones dentro de SELECT ----

-- calcular_subtotal dentro de un SELECT normal
SELECT pe.id_pedido,
       cl.nombre                                       AS cliente,
       pr.nombre                                       AS producto,
       pe.cantidad,
       pr.precio,
       calcular_subtotal(pe.cantidad, pr.precio)       AS subtotal
FROM pedidos pe
JOIN clientes  cl ON pe.id_cliente  = cl.id_cliente
JOIN productos pr ON pe.id_producto = pr.id_producto
ORDER BY subtotal DESC;


-- estado_stock dentro de SELECT sobre productos
SELECT nombre, precio, stock,
       estado_stock(stock)   AS estado
FROM productos
ORDER BY stock ASC;


-- nombre_pais usada en la consulta de ciudades
SELECT ci.nombre AS ciudad, nombre_pais(pa.codigo) AS pais
FROM ciudades ci
JOIN paises pa ON ci.id_pais = pa.id_pais
ORDER BY pa.codigo, ci.nombre;


-- ---- Diferencia practica: PROCEDURE vs FUNCTION ----
-- FUNCTION: la usas dentro de un SELECT, WHERE, SET, etc.
-- PROCEDURE: la llamas con CALL y puede retornar varias cosas

-- Esto FUNCIONA (funcion en WHERE):
SELECT nombre, stock
FROM productos
WHERE estado_stock(stock) = 'CRITICO';

-- Esto NO FUNCIONA (no se puede usar CALL en WHERE):
-- SELECT ... WHERE (CALL reporte_stock()) ...


-- ============================================================
-- TEMA 9: DROP de procedimientos y funciones
-- ============================================================

-- Ver todos los procedimientos
SHOW PROCEDURE STATUS WHERE Db = 'tienda';

-- Ver todas las funciones
SHOW FUNCTION STATUS WHERE Db = 'tienda';

-- Borrar procedimiento
DROP PROCEDURE IF EXISTS generar_prueba;

-- Borrar funcion
DROP FUNCTION IF EXISTS calcular_subtotal;

-- Verificar que ya no existen
SHOW PROCEDURE STATUS WHERE Db = 'tienda';
SHOW FUNCTION STATUS WHERE Db = 'tienda';
