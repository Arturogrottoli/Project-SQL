-- ============================================================
-- CLASE 06: IMPORTACIÓN DE DATOS + INTEGRIDAD REFERENCIAL
-- Motor: MySQL
-- ============================================================


-- ============================================================
-- SETUP: base de datos tienda
-- Tablas: paises, ciudades, clientes, productos, pedidos
-- ============================================================

DROP DATABASE IF EXISTS tienda;
CREATE DATABASE tienda;
USE tienda;

-- Tabla padre: paises
CREATE TABLE paises (
    id_pais  INT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(80) NOT NULL,
    codigo   CHAR(3) NOT NULL UNIQUE
);

-- Tabla hija de paises: ciudades
-- ON DELETE CASCADE: si se borra un pais, sus ciudades se borran solas
CREATE TABLE ciudades (
    id_ciudad INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(100) NOT NULL,
    id_pais   INT NOT NULL,
    CONSTRAINT fk_ciudad_pais
        FOREIGN KEY (id_pais) REFERENCES paises(id_pais)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Tabla hija de ciudades: clientes
-- ON DELETE SET NULL: si se borra la ciudad, el cliente queda sin ciudad (NULL)
-- ON UPDATE CASCADE: si cambia el id de ciudad, el cliente se actualiza solo
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    email      VARCHAR(120),
    id_ciudad  INT,
    CONSTRAINT fk_cliente_ciudad
        FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Tabla independiente: productos
CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    precio      DECIMAL(8,2) NOT NULL,
    stock       INT DEFAULT 0
);

-- Tabla hija de clientes y productos: pedidos
-- ON DELETE RESTRICT: no se puede borrar un cliente con pedidos activos
CREATE TABLE pedidos (
    id_pedido   INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente  INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad    INT NOT NULL DEFAULT 1,
    fecha       DATE NOT NULL,
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
        ON DELETE RESTRICT,
    CONSTRAINT fk_pedido_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
        ON DELETE RESTRICT
);


-- ============================================================
-- DATOS INICIALES
-- ============================================================

INSERT INTO paises (nombre, codigo) VALUES
    ('Argentina',      'ARG'),
    ('Brasil',         'BRA'),
    ('Chile',          'CHL'),
    ('Uruguay',        'URY'),
    ('Colombia',       'COL');

INSERT INTO ciudades (nombre, id_pais) VALUES
    ('Buenos Aires',   1),
    ('Rosario',        1),
    ('Cordoba',        1),
    ('Sao Paulo',      2),
    ('Rio de Janeiro', 2),
    ('Santiago',       3),
    ('Valparaiso',     3),
    ('Montevideo',     4),
    ('Bogota',         5);

INSERT INTO clientes (nombre, email, id_ciudad) VALUES
    ('Lucas Gomez',     'lucas@mail.com',   1),
    ('Maria Fernandez', 'maria@mail.com',   1),
    ('Andres Torres',   'andres@mail.com',  2),
    ('Paula Ruiz',      'paula@mail.com',   4),
    ('Carlos Silva',    'carlos@mail.com',  6),
    ('Ana Lima',        'ana@mail.com',     5),
    ('Juan Perez',      'juan@mail.com',    3);

INSERT INTO productos (nombre, precio, stock) VALUES
    ('Notebook Lenovo',    850.00,  20),
    ('Monitor 27"',        320.00,  35),
    ('Teclado Mecanico',    75.00, 100),
    ('Mouse Inalambrico',   35.00, 150),
    ('Auriculares Gamer',   60.00,  80),
    ('Webcam HD',           45.00,  60);

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
-- REPASO RAPIDO (conceptos de clases anteriores)
-- ============================================================

-- Ver las tablas creadas
SELECT * FROM paises;
SELECT * FROM ciudades;
SELECT * FROM clientes;

-- JOIN: clientes con su ciudad y pais
SELECT cl.nombre AS cliente, ci.nombre AS ciudad, p.nombre AS pais
FROM clientes cl
JOIN ciudades ci ON cl.id_ciudad = ci.id_ciudad
JOIN paises   p  ON ci.id_pais   = p.id_pais
ORDER BY p.nombre, ci.nombre;

-- Pedidos con detalle usando LEFT JOIN (incluye clientes sin ciudad)
SELECT pe.id_pedido, cl.nombre AS cliente, pr.nombre AS producto,
       pe.cantidad, pe.fecha,
       ROUND(pe.cantidad * pr.precio, 2) AS total
FROM pedidos pe
JOIN clientes  cl ON pe.id_cliente  = cl.id_cliente
JOIN productos pr ON pe.id_producto = pr.id_producto
ORDER BY pe.fecha;


-- ============================================================
-- TEMA 1: IMPORTACION DE DATOS
-- ============================================================
-- Hay dos formas principales de importar datos masivos a MySQL:
-- A) Asistente visual de MySQL Workbench (no requiere SQL)
-- B) Comando LOAD DATA LOCAL INFILE (desde la consola o editor)


-- ---- 1a: LOAD DATA LOCAL INFILE ----
-- Lee un archivo CSV y lo inserta directamente en una tabla.
-- El archivo debe estar accesible desde el servidor MySQL
-- o estar habilitado LOCAL INFILE en la configuracion.

-- Sintaxis general:
-- LOAD DATA LOCAL INFILE 'ruta/al/archivo.csv'
-- INTO TABLE nombre_tabla
-- FIELDS TERMINATED BY ','
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS          -- para saltear el encabezado
-- (columna1, columna2, ...);

-- Ejemplo concreto: si tuvieramos un archivo productos.csv con este formato:
-- nombre,precio,stock
-- "SSD 1TB",110.00,50
-- "Hub USB 4 puertos",25.00,200

-- Lo importariamos asi:
-- LOAD DATA LOCAL INFILE 'C:/datos/productos.csv'
-- INTO TABLE productos
-- FIELDS TERMINATED BY ','
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\r\n'
-- IGNORE 1 ROWS
-- (nombre, precio, stock);


-- ---- 1b: Simulacion de importacion con INSERT multiple ----
-- (equivalente al resultado de importar un CSV)

INSERT INTO productos (nombre, precio, stock) VALUES
    ('SSD 1TB',           110.00, 50),
    ('Hub USB 4 puertos',  25.00, 200),
    ('Pad Mouse XL',       18.00, 300),
    ('Cable HDMI 2m',       8.00, 500);

SELECT * FROM productos;


-- ---- 1c: EXPORTAR a CSV con SELECT INTO OUTFILE ----
-- Complemento de la importacion: exportar datos a un archivo CSV.
-- (Requiere permisos FILE en el servidor)

-- SELECT id_producto, nombre, precio, stock
-- FROM productos
-- INTO OUTFILE 'C:/datos/productos_exportados.csv'
-- FIELDS TERMINATED BY ','
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\r\n';


-- ============================================================
-- TEMA 2: INTEGRIDAD REFERENCIAL - ON DELETE CASCADE
-- ============================================================
-- Cuando se elimina un registro padre, todos sus hijos
-- se eliminan automaticamente.
-- En nuestro modelo: paises -> ciudades (con CASCADE)


-- Estado actual: Argentina tiene 3 ciudades
SELECT p.nombre AS pais, c.nombre AS ciudad
FROM ciudades c
JOIN paises p ON c.id_pais = p.id_pais
WHERE p.nombre = 'Argentina';

-- Estado actual: clientes en esas ciudades
SELECT cl.nombre AS cliente, ci.nombre AS ciudad
FROM clientes cl
JOIN ciudades ci ON cl.id_ciudad = ci.id_ciudad
JOIN paises   p  ON ci.id_pais   = p.id_pais
WHERE p.nombre = 'Argentina';

-- Como la FK de ciudades tiene ON DELETE CASCADE,
-- eliminar Argentina borrara sus ciudades automaticamente.
-- NOTA: los clientes de esas ciudades quedan con id_ciudad = NULL
--       porque su FK tiene ON DELETE SET NULL.

DELETE FROM paises WHERE nombre = 'Argentina';

-- Verificamos: Argentina desaparecio, y sus ciudades tambien
SELECT * FROM paises;
SELECT * FROM ciudades;

-- Los clientes argentinos ahora tienen id_ciudad = NULL
SELECT id_cliente, nombre, id_ciudad FROM clientes;


-- ============================================================
-- TEMA 3: INTEGRIDAD REFERENCIAL - ON DELETE SET NULL
-- ============================================================
-- Cuando se elimina el padre, la FK en el hijo queda en NULL
-- en vez de eliminar el registro hijo.
-- En nuestro modelo: ciudades -> clientes (con SET NULL)


-- Verificamos el estado luego del DELETE anterior
-- Lucas, Maria, Andres y Juan tienen id_ciudad = NULL
SELECT id_cliente, nombre, email, id_ciudad FROM clientes ORDER BY id_cliente;

-- Vamos a hacer otra prueba: borramos Uruguay (id_pais = 4)
-- Primero chequeamos que tiene ciudades y clientes
SELECT c.nombre AS ciudad
FROM ciudades c
WHERE c.id_pais = 4;

-- Uruguay no tenia clientes en nuestra carga inicial,
-- asi que el CASCADE de paises->ciudades eliminara Montevideo,
-- y al no haber clientes en Montevideo, SET NULL no afecta a nadie.
DELETE FROM paises WHERE nombre = 'Uruguay';

SELECT * FROM paises;
SELECT * FROM ciudades;


-- ============================================================
-- TEMA 4: INTEGRIDAD REFERENCIAL - ON DELETE RESTRICT
-- ============================================================
-- El padre NO se puede eliminar si tiene registros hijos.
-- MySQL devuelve un error (1451) para proteger la integridad.
-- En nuestro modelo: clientes -> pedidos (con RESTRICT)


-- El cliente 4 (Paula Ruiz) tiene pedidos:
SELECT pe.id_pedido, cl.nombre AS cliente, pr.nombre AS producto
FROM pedidos pe
JOIN clientes  cl ON pe.id_cliente  = cl.id_cliente
JOIN productos pr ON pe.id_producto = pr.id_producto
WHERE pe.id_cliente = 4;

-- Intentamos borrar a Paula: esto FALLA con Error 1451
-- DELETE FROM clientes WHERE id_cliente = 4;

-- Para poder eliminarla, primero hay que borrar sus pedidos
DELETE FROM pedidos  WHERE id_cliente = 4;
DELETE FROM clientes WHERE id_cliente = 4;

-- Verificamos
SELECT * FROM clientes;
SELECT * FROM pedidos ORDER BY id_pedido;


-- RESTRICT en productos: tampoco podemos borrar un producto con pedidos
-- Este intento fallaria:
-- DELETE FROM productos WHERE id_producto = 3;

-- Comprobamos que producto 3 (Teclado) tiene pedidos:
SELECT pe.id_pedido, cl.nombre, pr.nombre AS producto
FROM pedidos pe
JOIN clientes  cl ON pe.id_cliente  = cl.id_cliente
JOIN productos pr ON pe.id_producto = pr.id_producto
WHERE pe.id_producto = 3;


-- ============================================================
-- TEMA 5: INTEGRIDAD REFERENCIAL - ON UPDATE CASCADE
-- ============================================================
-- Cuando se actualiza la PK del padre, la FK del hijo
-- se actualiza automaticamente.
-- En nuestro modelo: paises -> ciudades (con UPDATE CASCADE)


-- Estado actual de paises y ciudades
SELECT p.id_pais, p.nombre, c.id_ciudad, c.nombre AS ciudad
FROM ciudades c
JOIN paises p ON c.id_pais = p.id_pais;

-- Vamos a cambiar el id_pais de Brasil (2 -> 20)
-- Las ciudades de Brasil deben actualizarse solas
UPDATE paises SET id_pais = 20 WHERE nombre = 'Brasil';

-- Verificamos que las ciudades de Brasil ahora tienen id_pais = 20
SELECT p.id_pais, p.nombre, c.id_ciudad, c.nombre AS ciudad, c.id_pais
FROM ciudades c
JOIN paises p ON c.id_pais = p.id_pais
ORDER BY p.nombre;

-- Restauramos el id para no desorganizar el resto del ejemplo
UPDATE paises SET id_pais = 2 WHERE nombre = 'Brasil';


-- ============================================================
-- TEMA 6: COMPARATIVA DE RESTRICCIONES DE INTEGRIDAD
-- ============================================================
-- Resumen practico: cada tipo tiene un comportamiento distinto

-- Creamos dos tablas de ejemplo para mostrar los 4 comportamientos
-- en un escenario controlado

CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY,
    nombre       VARCHAR(50)
);

CREATE TABLE articulos_cascade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion  VARCHAR(100),
    id_categoria INT,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE articulos_setnull (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion  VARCHAR(100),
    id_categoria INT,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE articulos_restrict (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion  VARCHAR(100),
    id_categoria INT,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO categorias VALUES (1, 'Electronica'), (2, 'Hogar'), (3, 'Deportes');

INSERT INTO articulos_cascade (descripcion, id_categoria) VALUES
    ('TV 55"', 1), ('Laptop', 1), ('Lampara', 2);

INSERT INTO articulos_setnull (descripcion, id_categoria) VALUES
    ('Auriculares', 1), ('Radio', 1), ('Sarten', 2);

INSERT INTO articulos_restrict (descripcion, id_categoria) VALUES
    ('Mouse', 1), ('Teclado', 1), ('Almohadon', 2);

-- Verificamos antes del DELETE
SELECT 'cascade' AS tabla, id, descripcion, id_categoria FROM articulos_cascade
UNION ALL
SELECT 'setnull',          id, descripcion, id_categoria FROM articulos_setnull
UNION ALL
SELECT 'restrict',         id, descripcion, id_categoria FROM articulos_restrict;

-- Intentamos borrar Electronica (id_categoria = 1)
-- articulos_restrict bloqueara el DELETE, descomentando la linea veriamos el error:
-- DELETE FROM categorias WHERE id_categoria = 1;

-- Primero borramos los articulos_restrict para que el DELETE pueda proceder
DELETE FROM articulos_restrict WHERE id_categoria = 1;
DELETE FROM categorias WHERE id_categoria = 1;

-- Resultado:
-- articulos_cascade: los de id_categoria=1 se BORRARON automaticamente
-- articulos_setnull: los de id_categoria=1 tienen id_categoria = NULL
-- articulos_restrict: ya los borramos manualmente antes

SELECT 'cascade' AS tabla, id, descripcion, id_categoria FROM articulos_cascade
UNION ALL
SELECT 'setnull',          id, descripcion, id_categoria FROM articulos_setnull
UNION ALL
SELECT 'restrict',         id, descripcion, id_categoria FROM articulos_restrict;

-- Limpieza de tablas de ejemplo
DROP TABLE articulos_cascade, articulos_setnull, articulos_restrict;
DROP TABLE categorias;
