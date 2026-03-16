-- ============================================================
-- CLASE 10: TRANSACCIONES Y BACKUP
-- Motor: MySQL
-- ============================================================


-- ============================================================
-- SETUP: continuamos con la base tienda (misma de clases 06-08)
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
    saldo      DECIMAL(10,2) DEFAULT 0.00,
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
    estado      VARCHAR(20) DEFAULT 'pendiente',
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente)  ON DELETE RESTRICT,
    CONSTRAINT fk_pedido_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE RESTRICT
);

-- Tabla de movimientos de saldo (para el ejemplo de transferencia)
CREATE TABLE movimientos (
    id_mov      INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente  INT NOT NULL,
    tipo        VARCHAR(10) NOT NULL,    -- 'debito' o 'credito'
    monto       DECIMAL(10,2) NOT NULL,
    descripcion VARCHAR(200),
    fecha       DATETIME DEFAULT NOW()
);


-- ============================================================
-- DATOS INICIALES
-- ============================================================

INSERT INTO paises (nombre, codigo) VALUES
    ('Argentina', 'ARG'), ('Brasil', 'BRA'), ('Chile', 'CHL');

INSERT INTO ciudades (nombre, id_pais) VALUES
    ('Buenos Aires', 1), ('Rosario', 1), ('Cordoba', 1),
    ('Sao Paulo',    2), ('Santiago', 3);

INSERT INTO clientes (nombre, email, saldo, id_ciudad) VALUES
    ('Lucas Gomez',     'lucas@mail.com',   1500.00, 1),
    ('Maria Fernandez', 'maria@mail.com',    800.00, 1),
    ('Andres Torres',   'andres@mail.com',   300.00, 2),
    ('Paula Ruiz',      'paula@mail.com',   2000.00, 4),
    ('Carlos Silva',    'carlos@mail.com',   650.00, 5);

INSERT INTO productos (nombre, precio, stock) VALUES
    ('Notebook Lenovo',   850.00, 20),
    ('Monitor 27"',       320.00, 35),
    ('Teclado Mecanico',   75.00, 100),
    ('Mouse Inalambrico',  35.00, 150),
    ('Auriculares Gamer',  60.00, 80);

INSERT INTO pedidos (id_cliente, id_producto, cantidad, fecha, estado) VALUES
    (1, 1, 1, '2025-01-10', 'entregado'),
    (1, 3, 2, '2025-01-10', 'entregado'),
    (2, 4, 1, '2025-01-12', 'entregado'),
    (3, 2, 1, '2025-01-15', 'pendiente'),
    (4, 5, 3, '2025-01-18', 'entregado');


-- ============================================================
-- REPASO RAPIDO (clase 08 — triggers y DCL)
-- ============================================================

-- Repaso: ver datos base
SELECT cl.nombre, cl.saldo, ci.nombre AS ciudad
FROM clientes cl JOIN ciudades ci ON cl.id_ciudad = ci.id_ciudad;

-- Repaso: LEFT JOIN para ver todos los clientes aunque no tengan pedidos
SELECT cl.nombre, COUNT(pe.id_pedido) AS pedidos, SUM(pe.cantidad * pr.precio) AS gastado
FROM clientes cl
LEFT JOIN pedidos  pe ON cl.id_cliente  = pe.id_cliente
LEFT JOIN productos pr ON pe.id_producto = pr.id_producto
GROUP BY cl.id_cliente, cl.nombre;


-- ============================================================
-- QUE ES UNA TRANSACCION
-- ============================================================
-- Una transaccion es un conjunto de operaciones SQL que se
-- ejecutan como una unidad ATOMICA:
-- o TODAS se completan correctamente (COMMIT),
-- o NINGUNA tiene efecto (ROLLBACK).
--
-- Problema real que resuelven:
-- Supongamos que transferimos saldo entre dos clientes:
--   1. Descontamos $500 de Lucas
--   2. Acreditamos $500 a Maria
-- Si la DB falla entre el paso 1 y el 2, Lucas pierde $500
-- y Maria no recibe nada. La transaccion evita esto.
--
-- Propiedades ACID:
--   A - Atomicidad:  todo o nada
--   C - Consistencia: la DB pasa de un estado valido a otro
--   I - Isolation (Aislamiento): las transacciones concurrentes
--       no se ven entre si hasta el COMMIT
--   D - Durabilidad: una vez confirmado, el cambio persiste
--       aunque haya un fallo del sistema


-- ============================================================
-- AUTOCOMMIT: el modo por defecto de MySQL
-- ============================================================
-- Por defecto MySQL tiene autocommit = 1 (ON).
-- Esto significa que CADA sentencia es una transaccion propia:
-- se confirma automaticamente en cuanto se ejecuta.

-- Ver el estado actual del autocommit
SELECT @@autocommit;

-- Con autocommit ON, este UPDATE se confirma de inmediato:
UPDATE clientes SET saldo = saldo - 100 WHERE id_cliente = 1;
-- No hay forma de deshacerlo con ROLLBACK

-- Restauramos
UPDATE clientes SET saldo = saldo + 100 WHERE id_cliente = 1;


-- ============================================================
-- TEMA 1: START TRANSACTION + COMMIT
-- ============================================================
-- START TRANSACTION inicia un bloque transaccional.
-- A partir de ahi los cambios son TEMPORALES hasta que
-- hacemos COMMIT (confirmar) o ROLLBACK (deshacer).

-- Estado antes
SELECT id_cliente, nombre, saldo FROM clientes WHERE id_cliente IN (1, 2);

START TRANSACTION;

    -- Descontamos $200 de Lucas
    UPDATE clientes SET saldo = saldo - 200 WHERE id_cliente = 1;

    -- Acreditamos $200 a Maria
    UPDATE clientes SET saldo = saldo + 200 WHERE id_cliente = 2;

    -- Registramos los movimientos
    INSERT INTO movimientos (id_cliente, tipo, monto, descripcion)
    VALUES (1, 'debito',  200, 'Transferencia a Maria Fernandez');

    INSERT INTO movimientos (id_cliente, tipo, monto, descripcion)
    VALUES (2, 'credito', 200, 'Transferencia recibida de Lucas Gomez');

COMMIT;   -- <-- confirma todos los cambios de golpe

-- Estado despues: Lucas tiene 200 menos, Maria 200 mas
SELECT id_cliente, nombre, saldo FROM clientes WHERE id_cliente IN (1, 2);
SELECT * FROM movimientos;


-- ============================================================
-- TEMA 2: START TRANSACTION + ROLLBACK
-- ============================================================
-- Si algo sale mal dentro de la transaccion, ROLLBACK
-- deshace TODOS los cambios desde el START TRANSACTION.

-- Estado antes
SELECT id_cliente, nombre, saldo FROM clientes WHERE id_cliente IN (1, 3);

START TRANSACTION;

    UPDATE clientes SET saldo = saldo - 500 WHERE id_cliente = 1;
    UPDATE clientes SET saldo = saldo + 500 WHERE id_cliente = 3;

    -- Simulamos que detectamos un error: Andres ya no esta activo
    -- En lugar de confirmar, deshacemos todo:

ROLLBACK;   -- <-- los dos UPDATE se anulan como si nunca hubieran ocurrido

-- Estado despues: los saldos NO cambiaron
SELECT id_cliente, nombre, saldo FROM clientes WHERE id_cliente IN (1, 3);


-- ============================================================
-- TEMA 3: ROLLBACK en accion — el INSERT que no quedo
-- ============================================================
-- Demostrar que los INSERT dentro de una transaccion
-- tambien se revierten con ROLLBACK.

SELECT COUNT(*) AS pedidos_actuales FROM pedidos;

START TRANSACTION;

    INSERT INTO pedidos (id_cliente, id_producto, cantidad, fecha, estado)
    VALUES (5, 3, 2, '2025-03-01', 'pendiente');

    INSERT INTO pedidos (id_cliente, id_producto, cantidad, fecha, estado)
    VALUES (5, 5, 1, '2025-03-01', 'pendiente');

    -- Dentro de la transaccion, ya podemos ver los nuevos registros:
    SELECT COUNT(*) AS pedidos_dentro_transaccion FROM pedidos;

ROLLBACK;

-- Fuera de la transaccion, vuelve al estado original:
SELECT COUNT(*) AS pedidos_despues_rollback FROM pedidos;


-- ============================================================
-- TEMA 4: SAVEPOINT — puntos de guardado dentro de la transaccion
-- ============================================================
-- SAVEPOINT permite crear puntos de control intermedios.
-- Con ROLLBACK TO SAVEPOINT podemos deshacer SOLO hasta ese punto
-- sin cancelar toda la transaccion.

START TRANSACTION;

    -- Paso 1: actualizamos el estado de los pedidos de Lucas
    UPDATE pedidos SET estado = 'enviado' WHERE id_cliente = 1;

    SAVEPOINT sp_pedidos_actualizados;    -- punto de control 1

    -- Paso 2: descontamos el saldo de Lucas por los pedidos
    UPDATE clientes SET saldo = saldo - 300 WHERE id_cliente = 1;

    SAVEPOINT sp_saldo_descontado;        -- punto de control 2

    -- Verificamos el estado en este momento
    SELECT id_cliente, nombre, saldo FROM clientes WHERE id_cliente = 1;
    SELECT id_pedido, estado FROM pedidos WHERE id_cliente = 1;

    -- Supongamos que el paso 2 fue un error: deshacemos solo el descuento
    -- pero MANTENEMOS la actualizacion de estados del paso 1
    ROLLBACK TO SAVEPOINT sp_pedidos_actualizados;

    -- El saldo de Lucas volvio a lo que era en sp_pedidos_actualizados
    SELECT id_cliente, nombre, saldo FROM clientes WHERE id_cliente = 1;
    -- Los estados de los pedidos siguen en 'enviado'
    SELECT id_pedido, estado FROM pedidos WHERE id_cliente = 1;

COMMIT;    -- confirmamos lo que quedo (solo el UPDATE de estados)

-- Estado final
SELECT id_cliente, nombre, saldo FROM clientes WHERE id_cliente = 1;
SELECT id_pedido, estado FROM pedidos WHERE id_cliente = 1;


-- ============================================================
-- TEMA 5: RELEASE SAVEPOINT
-- ============================================================
-- RELEASE SAVEPOINT elimina el savepoint (ya no se puede hacer
-- ROLLBACK TO ese punto). No deshace ni confirma nada, solo
-- libera el punto de control.

START TRANSACTION;

    UPDATE productos SET stock = stock + 10 WHERE id_producto = 1;

    SAVEPOINT sp_stock_actualizado;

    UPDATE productos SET precio = precio * 0.90 WHERE id_producto = 1;

    -- Ya no necesitamos el savepoint, lo liberamos
    RELEASE SAVEPOINT sp_stock_actualizado;

    -- A partir de aqui solo podemos COMMIT o ROLLBACK completo

COMMIT;

SELECT id_producto, nombre, precio, stock FROM productos WHERE id_producto = 1;

-- Restauramos para los proximos ejemplos
UPDATE productos SET precio = 850.00, stock = 20 WHERE id_producto = 1;


-- ============================================================
-- TEMA 6: TRANSACCION COMPLETA — caso real de compra
-- ============================================================
-- Simulamos el proceso completo de compra:
-- 1. Verificar stock
-- 2. Crear el pedido
-- 3. Descontar el stock
-- 4. Descontar saldo del cliente
-- Todo dentro de una sola transaccion.

-- Estado antes
SELECT id_producto, nombre, precio, stock FROM productos WHERE id_producto = 2;
SELECT id_cliente, nombre, saldo FROM clientes WHERE id_cliente = 4;

START TRANSACTION;

    -- Paso 1: creamos el pedido
    INSERT INTO pedidos (id_cliente, id_producto, cantidad, fecha, estado)
    VALUES (4, 2, 1, '2025-03-10', 'pendiente');

    -- Paso 2: descontamos stock del Monitor
    UPDATE productos
    SET stock = stock - 1
    WHERE id_producto = 2;

    -- Paso 3: descontamos el precio del saldo de Paula
    UPDATE clientes
    SET saldo = saldo - 320.00
    WHERE id_cliente = 4;

    -- Paso 4: registramos el movimiento
    INSERT INTO movimientos (id_cliente, tipo, monto, descripcion)
    VALUES (4, 'debito', 320.00, 'Compra: Monitor 27"');

COMMIT;

-- Verificamos que todo cambio junto
SELECT id_producto, nombre, precio, stock FROM productos WHERE id_producto = 2;
SELECT id_cliente, nombre, saldo FROM clientes WHERE id_cliente = 4;
SELECT * FROM movimientos WHERE id_cliente = 4;
SELECT * FROM pedidos WHERE id_cliente = 4;


-- ============================================================
-- TEMA 7: DESACTIVAR AUTOCOMMIT
-- ============================================================
-- Otra forma de trabajar con transacciones: desactivar el
-- autocommit. A partir de ese momento, cada sentencia
-- es parte de una transaccion implicita que requiere COMMIT.

-- Desactivamos el autocommit
SET autocommit = 0;

-- A partir de aqui, los cambios NO se confirman automaticamente
UPDATE clientes SET saldo = saldo + 999 WHERE id_cliente = 1;

-- Podemos ver el cambio en la sesion actual:
SELECT nombre, saldo FROM clientes WHERE id_cliente = 1;

-- Pero en otra sesion paralela el saldo todavia seria el anterior
-- (hasta que hagamos COMMIT)

-- Confirmamos
COMMIT;

-- Volvemos a activar el autocommit para no romper el resto
SET autocommit = 1;

-- Corregimos el saldo
UPDATE clientes SET saldo = saldo - 999 WHERE id_cliente = 1;


-- ============================================================
-- COMPARATIVA: con y sin transaccion
-- ============================================================

-- SIN transaccion: cada UPDATE es definitivo de inmediato
UPDATE clientes SET saldo = saldo - 100 WHERE id_cliente = 1;  -- irreversible
UPDATE clientes SET saldo = saldo + 100 WHERE id_cliente = 2;  -- irreversible

-- CON transaccion: podemos deshacer si algo falla
START TRANSACTION;
    UPDATE clientes SET saldo = saldo - 100 WHERE id_cliente = 1;
    UPDATE clientes SET saldo = saldo + 100 WHERE id_cliente = 2;
COMMIT;   -- o ROLLBACK si hubo error


-- ============================================================
-- BACKUP: comandos desde la terminal (fuera de MySQL)
-- ============================================================
-- Los comandos de backup se ejecutan en la TERMINAL del sistema
-- operativo, NO dentro de MySQL Workbench.
-- Se muestran comentados porque son comandos de shell, no SQL.


-- ---- BACKUP COMPLETO de una base de datos ----
-- Exporta toda la base `tienda` a un archivo .sql
-- que contiene los CREATE TABLE y todos los INSERT.
--
-- WINDOWS (PowerShell o CMD):
-- mysqldump -u root -p tienda > C:\backups\tienda_backup.sql
--
-- MAC / LINUX:
-- mysqldump -u root -p tienda > ~/backups/tienda_backup.sql
--
-- El archivo resultante se puede abrir en Workbench o
-- ejecutar desde la terminal para restaurar.


-- ---- BACKUP con fecha en el nombre (buena practica) ----
-- WINDOWS:
-- mysqldump -u root -p tienda > C:\backups\tienda_2025-03-10.sql
--
-- MAC / LINUX:
-- mysqldump -u root -p tienda > ~/backups/tienda_$(date +%Y-%m-%d).sql


-- ---- BACKUP de tablas especificas ----
-- Solo exporta las tablas clientes y pedidos
-- mysqldump -u root -p tienda clientes pedidos > C:\backups\clientes_pedidos.sql


-- ---- BACKUP solo estructura (sin datos) ----
-- Util para documentar el esquema o recrear tablas vacias
-- mysqldump -u root -p --no-data tienda > C:\backups\tienda_estructura.sql


-- ---- BACKUP solo datos (sin CREATE TABLE) ----
-- Util para migrar datos a una base que ya tiene las tablas
-- mysqldump -u root -p --no-create-info tienda > C:\backups\tienda_datos.sql


-- ---- BACKUP de todas las bases del servidor ----
-- mysqldump -u root -p --all-databases > C:\backups\todas_las_bases.sql


-- ---- RESTAURAR desde un backup ----
-- Ejecuta el archivo .sql y recrea todo lo que habia
--
-- WINDOWS:
-- mysql -u root -p tienda < C:\backups\tienda_backup.sql
--
-- Si la base no existe, primero hay que crearla:
-- mysql -u root -p -e "CREATE DATABASE tienda;"
-- mysql -u root -p tienda < C:\backups\tienda_backup.sql


-- ============================================================
-- BACKUP desde MySQL Workbench (sin terminal)
-- ============================================================
-- Workbench tiene una interfaz grafica para exportar e importar.
-- Ruta: Server → Data Export (para backup)
--       Server → Data Import (para restaurar)
--
-- Pasos para exportar:
-- 1. Ir a Server → Data Export
-- 2. Seleccionar la base de datos tienda
-- 3. Elegir que tablas exportar (o todas)
-- 4. Seleccionar "Export to Self-Contained File"
-- 5. Elegir carpeta y nombre del archivo
-- 6. Click en "Start Export"
--
-- Pasos para importar:
-- 1. Ir a Server → Data Import
-- 2. Seleccionar "Import from Self-Contained File"
-- 3. Elegir el archivo .sql generado
-- 4. Seleccionar el schema destino (o crear uno nuevo)
-- 5. Click en "Start Import"


-- ============================================================
-- RESUMEN DE COMANDOS DE TRANSACCION
-- ============================================================

-- Ver estado del autocommit
SELECT @@autocommit;

-- Iniciar transaccion
START TRANSACTION;
-- (alternativa equivalente)
BEGIN;

-- Confirmar todos los cambios
COMMIT;

-- Deshacer todos los cambios desde START TRANSACTION
ROLLBACK;

-- Crear punto de control intermedio
SAVEPOINT nombre_savepoint;

-- Deshacer hasta un punto de control (sin cancelar toda la transaccion)
ROLLBACK TO SAVEPOINT nombre_savepoint;

-- Eliminar un punto de control (no deshace nada)
RELEASE SAVEPOINT nombre_savepoint;

-- Desactivar / activar autocommit
SET autocommit = 0;   -- desactivar
SET autocommit = 1;   -- activar (modo por defecto)
