-- ============================================================
-- CLASE 08: TRIGGERS + DCL (Data Control Language)
-- Motor: MySQL
-- ============================================================


-- ============================================================
-- SETUP: continuamos con la base tienda (clase06/07)
-- Agregamos tablas de auditoria para los ejemplos de triggers
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

-- Tabla de auditoria: guarda el historial de cambios de precio
CREATE TABLE log_precios (
    id_log       INT AUTO_INCREMENT PRIMARY KEY,
    id_producto  INT,
    nombre_prod  VARCHAR(100),
    precio_antes DECIMAL(8,2),
    precio_nuevo DECIMAL(8,2),
    diferencia   DECIMAL(8,2),
    usuario      VARCHAR(100),
    fecha_cambio DATETIME
);

-- Tabla de auditoria: guarda pedidos que fueron eliminados
CREATE TABLE log_pedidos_eliminados (
    id_log       INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido    INT,
    id_cliente   INT,
    id_producto  INT,
    cantidad     INT,
    fecha_pedido DATE,
    eliminado_el DATETIME
);


-- ============================================================
-- DATOS INICIALES
-- ============================================================

INSERT INTO paises (nombre, codigo) VALUES
    ('Argentina', 'ARG'), ('Brasil', 'BRA'),
    ('Chile',     'CHL'), ('Uruguay','URY');

INSERT INTO ciudades (nombre, id_pais) VALUES
    ('Buenos Aires',   1), ('Rosario',        1), ('Cordoba',  1),
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
-- REPASO RAPIDO (clase 07)
-- ============================================================

-- Repaso de funciones y variables de sesion
SET @total_clientes = (SELECT COUNT(*) FROM clientes);
SET @total_productos = (SELECT COUNT(*) FROM productos);
SELECT @total_clientes AS clientes, @total_productos AS productos;

-- Repaso: clasificar productos con IF (logica de funcion inline)
SELECT nombre, precio, stock,
       IF(stock < 30, 'CRITICO', IF(stock < 70, 'BAJO', 'OK')) AS estado_stock
FROM productos ORDER BY stock;

-- Los triggers, igual que los procedures, necesitan DELIMITER
-- porque tienen multiples ; dentro del bloque BEGIN...END.


-- ============================================================
-- QUE ES UN TRIGGER
-- ============================================================
-- Un trigger (disparador) es codigo SQL que se ejecuta
-- AUTOMATICAMENTE cuando ocurre un evento sobre una tabla.
--
-- Eventos posibles:
--   INSERT → se inserto una fila nueva
--   UPDATE → se modifico una fila existente
--   DELETE → se elimino una fila
--
-- Momento de ejecucion:
--   BEFORE → ANTES de que el cambio se escriba en la tabla
--   AFTER  → DESPUES de que el cambio se escribio con exito
--
-- Pseudo-registros disponibles dentro del trigger:
--   NEW → fila con los NUEVOS valores (INSERT y UPDATE)
--   OLD → fila con los valores ANTERIORES (DELETE y UPDATE)
--
-- Disponibilidad segun evento:
--   INSERT  → solo NEW   (no hay fila anterior)
--   DELETE  → solo OLD   (no hay fila nueva)
--   UPDATE  → NEW y OLD  (ambos disponibles a la vez)


-- ============================================================
-- TEMA 1: AFTER INSERT — descontar stock al crear un pedido
-- ============================================================
-- Cuando se inserta un pedido, el stock del producto baja
-- automaticamente. Usamos AFTER INSERT porque queremos actuar
-- solo si el INSERT fue exitoso (la fila ya existe en pedidos).

DELIMITER //

CREATE TRIGGER trg_bajar_stock
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END //

DELIMITER ;


-- Vemos el stock ANTES del pedido
SELECT nombre, stock FROM productos WHERE id_producto = 3;  -- Teclado: 100

-- Insertamos un pedido: 5 teclados
INSERT INTO pedidos (id_cliente, id_producto, cantidad, fecha)
VALUES (2, 3, 5, '2025-03-01');

-- El trigger bajo el stock automaticamente: 100 - 5 = 95
SELECT nombre, stock FROM productos WHERE id_producto = 3;


-- ============================================================
-- TEMA 2: BEFORE INSERT — validar stock antes de aceptar el pedido
-- ============================================================
-- Con BEFORE INSERT podemos revisar los datos ANTES de que
-- se escriban en la tabla. Si la validacion falla, usamos
-- SIGNAL para lanzar un error y cancelar el INSERT.

DELIMITER //

CREATE TRIGGER trg_validar_pedido
BEFORE INSERT ON pedidos
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;

    -- Consultamos el stock actual del producto pedido
    SELECT stock INTO v_stock
    FROM productos
    WHERE id_producto = NEW.id_producto;

    -- Validacion 1: cantidad pedida mayor al stock disponible
    IF NEW.cantidad > v_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para completar el pedido';
    END IF;

    -- Validacion 2: cantidad invalida (cero o negativa)
    IF NEW.cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad debe ser mayor a cero';
    END IF;
END //

DELIMITER ;


-- Verificamos el stock disponible del Teclado
SELECT nombre, stock FROM productos WHERE id_producto = 3;

-- Pedido valido: deberia funcionar
INSERT INTO pedidos (id_cliente, id_producto, cantidad, fecha)
VALUES (3, 3, 2, '2025-03-05');
SELECT nombre, stock FROM productos WHERE id_producto = 3;

-- Pedido invalido (mas del stock disponible): FALLA
-- INSERT INTO pedidos (id_cliente, id_producto, cantidad, fecha)
-- VALUES (1, 3, 9999, '2025-03-06');
-- Error: Stock insuficiente para completar el pedido

-- Pedido invalido (cantidad negativa): FALLA
-- INSERT INTO pedidos (id_cliente, id_producto, cantidad, fecha)
-- VALUES (1, 3, -1, '2025-03-06');
-- Error: La cantidad debe ser mayor a cero


-- ============================================================
-- TEMA 3: AFTER UPDATE — auditar cambios de precio
-- ============================================================
-- Cada vez que cambia el precio de un producto, guardamos
-- el cambio en log_precios con los valores anteriores y nuevos.
-- Usamos NEW.precio y OLD.precio.

DELIMITER //

CREATE TRIGGER trg_auditar_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Solo registramos si el precio realmente cambio
    IF NEW.precio <> OLD.precio THEN
        INSERT INTO log_precios
            (id_producto, nombre_prod, precio_antes, precio_nuevo, diferencia, usuario, fecha_cambio)
        VALUES
            (OLD.id_producto,
             OLD.nombre,
             OLD.precio,
             NEW.precio,
             NEW.precio - OLD.precio,
             USER(),     -- usuario MySQL actualmente conectado
             NOW());     -- fecha y hora del momento del cambio
    END IF;
END //

DELIMITER ;


-- Estado actual del Monitor
SELECT id_producto, nombre, precio FROM productos WHERE id_producto = 2;

-- Actualizamos el precio del Monitor
UPDATE productos SET precio = 299.00 WHERE id_producto = 2;

-- El trigger registro el cambio automaticamente
SELECT * FROM log_precios;

-- Otro cambio: bajamos el precio de la Notebook
UPDATE productos SET precio = 749.00 WHERE id_producto = 1;

-- Historial completo de cambios de precio
SELECT nombre_prod, precio_antes, precio_nuevo, diferencia, usuario, fecha_cambio
FROM log_precios ORDER BY fecha_cambio;


-- ============================================================
-- TEMA 4: BEFORE UPDATE — impedir precios invalidos
-- ============================================================
-- Antes de que se actualice el precio, verificamos que sea
-- valido. Con BEFORE UPDATE podemos incluso MODIFICAR los
-- nuevos valores (SET NEW.columna = ...) antes de que
-- se escriban en la tabla.

DELIMITER //

CREATE TRIGGER trg_validar_precio
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Si el precio seria negativo, bloqueamos el UPDATE
    IF NEW.precio < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio no puede ser negativo';
    END IF;

    -- Si el precio seria exactamente 0, lo corregimos al minimo
    -- (en vez de bloquear, modificamos el valor automaticamente)
    IF NEW.precio = 0 THEN
        SET NEW.precio = 0.01;
    END IF;
END //

DELIMITER ;


-- Precio negativo: FALLA
-- UPDATE productos SET precio = -50 WHERE id_producto = 3;

-- Precio cero: se corrige automaticamente a 0.01
UPDATE productos SET precio = 0 WHERE id_producto = 4;
SELECT id_producto, nombre, precio FROM productos WHERE id_producto = 4;
-- Resultado: precio = 0.01

-- Restauramos el precio correcto
UPDATE productos SET precio = 35.00 WHERE id_producto = 4;


-- ============================================================
-- TEMA 5: AFTER DELETE — guardar pedidos antes de perderlos
-- ============================================================
-- Cuando se elimina un pedido, lo copiamos al log
-- antes de que desaparezca para siempre.
-- Solo tenemos OLD (no hay fila nueva en un DELETE).

DELIMITER //

CREATE TRIGGER trg_log_eliminar_pedido
AFTER DELETE ON pedidos
FOR EACH ROW
BEGIN
    INSERT INTO log_pedidos_eliminados
        (id_pedido, id_cliente, id_producto, cantidad, fecha_pedido, eliminado_el)
    VALUES
        (OLD.id_pedido,
         OLD.id_cliente,
         OLD.id_producto,
         OLD.cantidad,
         OLD.fecha,
         NOW());
END //

DELIMITER ;


-- Vemos el pedido antes de eliminarlo
SELECT * FROM pedidos WHERE id_pedido = 9;

-- Eliminamos el pedido
DELETE FROM pedidos WHERE id_pedido = 9;

-- El trigger lo guardo en el log automaticamente
SELECT * FROM log_pedidos_eliminados;

-- El pedido ya no existe en la tabla original
SELECT * FROM pedidos WHERE id_pedido = 9;  -- 0 filas


-- ============================================================
-- TEMA 6: BEFORE DELETE — proteger clientes VIP
-- ============================================================
-- Impedimos que se eliminen clientes con muchos pedidos
-- (necesitan aprobacion manual para darse de baja).

DELIMITER //

CREATE TRIGGER trg_proteger_cliente_vip
BEFORE DELETE ON clientes
FOR EACH ROW
BEGIN
    DECLARE v_cantidad_pedidos INT;

    SELECT COUNT(*) INTO v_cantidad_pedidos
    FROM pedidos
    WHERE id_cliente = OLD.id_cliente;

    IF v_cantidad_pedidos >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente VIP: tiene 3 o mas pedidos. Requiere aprobacion manual para eliminar.';
    END IF;
END //

DELIMITER ;


-- Pedidos por cliente
SELECT cl.nombre, COUNT(pe.id_pedido) AS cant_pedidos
FROM clientes cl
LEFT JOIN pedidos pe ON cl.id_cliente = pe.id_cliente
GROUP BY cl.id_cliente, cl.nombre
ORDER BY cant_pedidos DESC;

-- Lucas tiene 3 pedidos → FALLA
-- DELETE FROM clientes WHERE id_cliente = 1;

-- Juan tiene 1 pedido → primero borramos el pedido, luego el cliente
DELETE FROM pedidos  WHERE id_cliente = 7;
DELETE FROM clientes WHERE id_cliente = 7;
SELECT * FROM clientes WHERE id_cliente = 7;  -- 0 filas


-- ============================================================
-- TEMA 7: VER Y ELIMINAR TRIGGERS
-- ============================================================

-- Ver todos los triggers de la base actual
SHOW TRIGGERS;

-- Ver triggers de una tabla especifica
SHOW TRIGGERS FROM tienda LIKE 'pedidos';

-- Ver detalle desde information_schema
SELECT trigger_name, event_manipulation AS evento,
       action_timing AS momento, event_object_table AS tabla
FROM information_schema.triggers
WHERE trigger_schema = 'tienda'
ORDER BY tabla, momento, evento;

-- Eliminar un trigger
DROP TRIGGER IF EXISTS trg_bajar_stock;

-- Verificamos que se elimino
SHOW TRIGGERS;


-- ============================================================
-- TEMA 8: DCL — DATA CONTROL LANGUAGE
-- ============================================================
-- DCL controla QUIENES pueden conectarse a MySQL
-- y QUE pueden hacer dentro de las bases de datos.
--
-- Sublenguajes SQL (recordatorio):
--   DDL → CREATE, ALTER, DROP            (estructura de tablas)
--   DML → SELECT, INSERT, UPDATE, DELETE (datos)
--   DCL → GRANT, REVOKE                  (permisos)
--   TCL → COMMIT, ROLLBACK               (transacciones)
--
-- Dos comandos principales:
--   GRANT  → OTORGA permisos a un usuario
--   REVOKE → QUITA permisos a un usuario


-- ============================================================
-- TEMA 8a: CREAR USUARIOS
-- ============================================================
-- Sintaxis: CREATE USER 'nombre'@'host' IDENTIFIED BY 'password';
--
-- El host indica desde donde puede conectarse:
--   'localhost' → solo desde la misma maquina donde corre MySQL
--   '%'         → desde cualquier IP de la red
--   '192.168.1.%' → solo desde esa subred especifica

CREATE USER 'analista'@'localhost'  IDENTIFIED BY 'Analista2025!';
CREATE USER 'vendedor'@'localhost'  IDENTIFIED BY 'Vendedor2025!';
CREATE USER 'admin_bd'@'localhost'  IDENTIFIED BY 'Admin2025!';

-- Ver todos los usuarios del servidor MySQL
SELECT user, host FROM mysql.user
WHERE user IN ('analista', 'vendedor', 'admin_bd');

-- Cambiar la password de un usuario
ALTER USER 'vendedor'@'localhost' IDENTIFIED BY 'NuevaClave2025!';


-- ============================================================
-- TEMA 8b: GRANT — otorgar permisos
-- ============================================================
-- Sintaxis: GRANT permiso ON scope TO 'user'@'host';
--
-- Alcance (scope):
--   *.*           → global: todas las bases y todas las tablas
--   tienda.*      → toda la base tienda
--   tienda.clientes → solo esa tabla


-- Analista: solo lectura sobre toda la base tienda
GRANT SELECT ON tienda.* TO 'analista'@'localhost';

-- Vendedor: puede leer y agregar pedidos; solo leer clientes y productos
GRANT SELECT          ON tienda.clientes  TO 'vendedor'@'localhost';
GRANT SELECT          ON tienda.productos TO 'vendedor'@'localhost';
GRANT SELECT, INSERT  ON tienda.pedidos   TO 'vendedor'@'localhost';

-- Admin: control total sobre tienda
GRANT ALL PRIVILEGES ON tienda.* TO 'admin_bd'@'localhost';

-- Aplicar cambios de permisos inmediatamente
FLUSH PRIVILEGES;

-- Ver los permisos otorgados
SHOW GRANTS FOR 'analista'@'localhost';
SHOW GRANTS FOR 'vendedor'@'localhost';
SHOW GRANTS FOR 'admin_bd'@'localhost';


-- ============================================================
-- TEMA 8c: REVOKE — quitar permisos
-- ============================================================
-- Sintaxis: REVOKE permiso ON scope FROM 'user'@'host';

-- Quitamos el INSERT al vendedor (solo podra leer pedidos)
REVOKE INSERT ON tienda.pedidos FROM 'vendedor'@'localhost';

SHOW GRANTS FOR 'vendedor'@'localhost';

-- Quitamos todo al analista
REVOKE ALL PRIVILEGES ON tienda.* FROM 'analista'@'localhost';

SHOW GRANTS FOR 'analista'@'localhost';

FLUSH PRIVILEGES;


-- ============================================================
-- TEMA 8d: ELIMINAR USUARIOS
-- ============================================================

DROP USER IF EXISTS 'analista'@'localhost';
DROP USER IF EXISTS 'vendedor'@'localhost';
DROP USER IF EXISTS 'admin_bd'@'localhost';

-- Verificamos que no existen
SELECT user, host FROM mysql.user
WHERE user IN ('analista', 'vendedor', 'admin_bd');

-- Ver los permisos del usuario actualmente conectado
SHOW GRANTS;
