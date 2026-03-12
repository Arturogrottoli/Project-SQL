-- ============================================================
-- EJERCICIO CLASE 06 — FKs con CASCADE + INSERT INTO SELECT
-- Motor: MySQL
-- Tablas: cliente, producto, pedido, detalle_pedido,
--         detalle_pedidos_2
-- ============================================================


-- ============================================================
-- SETUP: creamos la base de datos y las tablas SIN FKs todavia
-- (las FK las agregamos en el Tema 1, con ALTER TABLE)
-- ============================================================

DROP DATABASE IF EXISTS ejercicio06;
CREATE DATABASE ejercicio06;
USE ejercicio06;

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    email      VARCHAR(120),
    ciudad     VARCHAR(80)
);

CREATE TABLE producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    precio      DECIMAL(8,2) NOT NULL,
    categoria   VARCHAR(60)
);

-- pedido referencia a cliente, pero todavia sin FK
CREATE TABLE pedido (
    id_pedido  INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha      DATE NOT NULL,
    estado     VARCHAR(30) DEFAULT 'pendiente'
);

-- detalle_pedido referencia a pedido y a producto, todavia sin FKs
CREATE TABLE detalle_pedido (
    id_detalle      INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido       INT NOT NULL,
    id_producto     INT NOT NULL,
    cantidad        INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(8,2) NOT NULL
);

-- tabla alternativa con la misma estructura que detalle_pedido
-- (es la fuente de datos para el INSERT INTO SELECT del ejercicio)
CREATE TABLE detalle_pedidos_2 (
    id_detalle      INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido       INT NOT NULL,
    id_producto     INT NOT NULL,
    cantidad        INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(8,2) NOT NULL
);


-- ============================================================
-- DATOS INICIALES
-- ============================================================

INSERT INTO cliente (nombre, email, ciudad) VALUES
    ('Lucas Gomez',     'lucas@mail.com',   'Buenos Aires'),
    ('Maria Fernandez', 'maria@mail.com',   'Rosario'),
    ('Andres Torres',   'andres@mail.com',  'Cordoba'),
    ('Paula Ruiz',      'paula@mail.com',   'Mendoza'),
    ('Carlos Silva',    'carlos@mail.com',  'Buenos Aires');

INSERT INTO producto (nombre, precio, categoria) VALUES
    ('Notebook Lenovo',    850.00, 'Computacion'),
    ('Monitor 27"',        320.00, 'Computacion'),
    ('Teclado Mecanico',    75.00, 'Perifericos'),
    ('Mouse Inalambrico',   35.00, 'Perifericos'),
    ('Auriculares Gamer',   60.00, 'Audio'),
    ('Webcam HD',           45.00, 'Video');

INSERT INTO pedido (id_cliente, fecha, estado) VALUES
    (1, '2025-01-10', 'entregado'),
    (1, '2025-02-15', 'entregado'),
    (2, '2025-01-12', 'entregado'),
    (3, '2025-01-20', 'cancelado'),
    (4, '2025-02-01', 'pendiente'),
    (5, '2025-02-10', 'entregado');

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
    (1, 1, 1, 850.00),   -- Lucas: Notebook
    (1, 3, 2,  75.00),   -- Lucas: 2 teclados
    (2, 2, 1, 320.00),   -- Lucas: Monitor (segundo pedido)
    (3, 4, 1,  35.00),   -- Maria: Mouse
    (3, 5, 2,  60.00),   -- Maria: 2 auriculares
    (4, 6, 1,  45.00),   -- Andres: Webcam (pedido cancelado)
    (5, 3, 1,  75.00),   -- Paula: Teclado
    (6, 1, 1, 850.00),   -- Carlos: Notebook
    (6, 4, 3,  35.00);   -- Carlos: 3 mouses

-- detalle_pedidos_2 tiene datos nuevos (distinto proveedor, migracion, etc.)
INSERT INTO detalle_pedidos_2 (id_pedido, id_producto, cantidad, precio_unitario) VALUES
    (1, 4, 2,  35.00),   -- Lucas: 2 mouses (nuevos)
    (2, 5, 1,  60.00),   -- Lucas: auriculares (nuevo pedido 2)
    (3, 1, 1, 850.00),   -- Maria: Notebook
    (5, 6, 2,  45.00),   -- Paula: 2 webcams
    (6, 2, 1, 320.00);   -- Carlos: Monitor


-- ============================================================
-- VERIFICACION INICIAL
-- ============================================================

SELECT * FROM cliente;
SELECT * FROM producto;
SELECT * FROM pedido;
SELECT * FROM detalle_pedido;
SELECT * FROM detalle_pedidos_2;


-- ============================================================
-- TEMA 1: AGREGAR FKs CON CASCADE USANDO ALTER TABLE
-- ============================================================
-- Las tablas ya existen y tienen datos.
-- Usamos ALTER TABLE para agregar las FOREIGN KEYS con CASCADE.


-- ---- FK 1: pedido → cliente ----
-- Si se borra un cliente, sus pedidos se borran solos (CASCADE).
-- Si cambia el id del cliente, los pedidos se actualizan (CASCADE).

ALTER TABLE pedido
ADD CONSTRAINT fk_pedido_cliente
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
    ON DELETE CASCADE
    ON UPDATE CASCADE;


-- ---- FK 2: detalle_pedido → pedido ----
-- Si se borra un pedido, sus lineas de detalle se borran solas (CASCADE).
-- Esto es el caso tipico: sin pedido no tiene sentido el detalle.

ALTER TABLE detalle_pedido
ADD CONSTRAINT fk_detalle_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
    ON DELETE CASCADE
    ON UPDATE CASCADE;


-- ---- FK 3: detalle_pedido → producto ----
-- Un producto no se puede borrar si tiene detalles de pedido asociados (RESTRICT).
-- Queremos proteger el historial de ventas.

ALTER TABLE detalle_pedido
ADD CONSTRAINT fk_detalle_producto
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;


-- Verificamos que las FKs se crearon bien
-- (en Workbench: click derecho sobre la tabla → Table Inspector → Foreign Keys)
SHOW CREATE TABLE pedido;
SHOW CREATE TABLE detalle_pedido;


-- ============================================================
-- TEMA 2: PROBAR DELETE EN PEDIDO — QUE PASA CON DETALLE?
-- ============================================================


-- Estado ANTES del DELETE
-- Pedidos del cliente 3 (Andres Torres):
SELECT p.id_pedido, c.nombre AS cliente, p.fecha, p.estado
FROM pedido p
JOIN cliente c ON p.id_cliente = c.id_cliente
WHERE c.nombre = 'Andres Torres';

-- Detalle de esos pedidos (id_pedido = 4):
SELECT dp.id_detalle, dp.id_pedido, pr.nombre AS producto, dp.cantidad
FROM detalle_pedido dp
JOIN producto pr ON dp.id_producto = pr.id_producto
WHERE dp.id_pedido = 4;


-- Eliminamos el pedido 4 (de Andres Torres)
-- Como la FK de detalle_pedido tiene ON DELETE CASCADE,
-- el detalle de ese pedido se borra automaticamente.
DELETE FROM pedido WHERE id_pedido = 4;


-- Estado DESPUES del DELETE
-- El pedido 4 ya no existe:
SELECT * FROM pedido WHERE id_pedido = 4;

-- Y su detalle tampoco:
SELECT * FROM detalle_pedido WHERE id_pedido = 4;
-- → devuelve 0 filas: se elimino en cascada automaticamente


-- Ahora probamos el DELETE EN CASCADA a nivel cliente
-- Si borramos a Maria Fernandez (id_cliente = 2),
-- sus pedidos se borran solos, y a su vez el detalle de esos pedidos tambien.

-- Antes:
SELECT p.id_pedido, dp.id_detalle, pr.nombre AS producto
FROM pedido p
JOIN detalle_pedido dp ON p.id_pedido    = dp.id_pedido
JOIN producto       pr ON dp.id_producto = pr.id_producto
WHERE p.id_cliente = 2;

DELETE FROM cliente WHERE id_cliente = 2;

-- Despues: ni el cliente, ni su pedido, ni el detalle existen
SELECT * FROM cliente       WHERE id_cliente = 2;   -- vacio
SELECT * FROM pedido        WHERE id_cliente = 2;   -- vacio
-- (el detalle ya se borro en cascada junto con el pedido)


-- ============================================================
-- TEMA 3: CONSULTA — NOMBRE DEL CLIENTE Y QUE COMPRO
-- ============================================================
-- JOIN entre cliente → pedido → detalle_pedido → producto


SELECT
    c.nombre                                    AS cliente,
    c.ciudad,
    pr.nombre                                   AS producto,
    pr.categoria,
    dp.cantidad,
    dp.precio_unitario,
    ROUND(dp.cantidad * dp.precio_unitario, 2)  AS subtotal,
    p.fecha,
    p.estado
FROM detalle_pedido dp
JOIN pedido  p  ON dp.id_pedido    = p.id_pedido
JOIN cliente c  ON p.id_cliente    = c.id_cliente
JOIN producto pr ON dp.id_producto = pr.id_producto
ORDER BY c.nombre, p.fecha;


-- Variante: solo clientes con pedidos entregados, total por cliente
SELECT
    c.nombre                              AS cliente,
    COUNT(dp.id_detalle)                  AS lineas_compradas,
    SUM(dp.cantidad * dp.precio_unitario) AS total_gastado
FROM detalle_pedido dp
JOIN pedido  p  ON dp.id_pedido    = p.id_pedido
JOIN cliente c  ON p.id_cliente    = c.id_cliente
WHERE p.estado = 'entregado'
GROUP BY c.id_cliente, c.nombre
ORDER BY total_gastado DESC;


-- ============================================================
-- TEMA 4: REEMPLAZAR DETALLE_PEDIDO CON INSERT INTO SELECT
-- ============================================================
-- Paso 1: borrar todo el contenido de detalle_pedido
-- Paso 2: cargar los datos desde detalle_pedidos_2

-- Ver detalle_pedidos_2 (fuente de datos)
SELECT * FROM detalle_pedidos_2;

-- PASO 1: vaciamos detalle_pedido
-- Usamos DELETE en vez de TRUNCATE para no romper AUTO_INCREMENT
-- y respetar posibles logs de auditoria.
DELETE FROM detalle_pedido;

-- Verificamos que quedo vacia
SELECT * FROM detalle_pedido;   -- 0 filas


-- PASO 2: INSERT INTO SELECT
-- Insertamos en detalle_pedido todo lo que esta en detalle_pedidos_2.
-- No copiamos id_detalle (es AUTO_INCREMENT, se genera solo).

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
SELECT id_pedido, id_producto, cantidad, precio_unitario
FROM detalle_pedidos_2;


-- Verificamos el resultado
SELECT dp.id_detalle, dp.id_pedido, pr.nombre AS producto,
       dp.cantidad, dp.precio_unitario
FROM detalle_pedido dp
JOIN producto pr ON dp.id_producto = pr.id_producto
ORDER BY dp.id_pedido;

-- Comparamos con el origen para validar que son iguales
SELECT COUNT(*) AS filas_origen    FROM detalle_pedidos_2;
SELECT COUNT(*) AS filas_destino   FROM detalle_pedido;
