# Clase 08 — Triggers y DCL

Base de datos: `tienda` (MySQL)
Tablas: `paises`, `ciudades`, `clientes`, `productos`, `pedidos`, `log_precios`, `log_pedidos_eliminados`

---

## Repaso rápido

| Concepto              | Qué hace                                                       |
|-----------------------|----------------------------------------------------------------|
| `CREATE PROCEDURE`    | Guarda un bloque SQL con nombre, se llama con `CALL`           |
| `CREATE FUNCTION`     | Guarda una función que devuelve un valor, se usa en `SELECT`   |
| `DELIMITER //`        | Cambia el separador para evitar conflictos con `;` internos    |
| `IN / OUT`            | Parámetros de entrada y salida en un procedure                 |
| `DECLARE`             | Variable local dentro de un bloque `BEGIN...END`               |

---

## ¿Qué es un Trigger?

Un **trigger** (disparador) es código SQL que se ejecuta **automáticamente** cuando ocurre un evento sobre una tabla. No se llama manualmente: MySQL lo dispara solo.

### Los 6 tipos de trigger

```
Evento    Momento     Cuándo corre
──────    ───────     ─────────────────────────────────────────
INSERT    BEFORE      Justo ANTES de insertar la fila nueva
INSERT    AFTER       Justo DESPUÉS de insertar la fila nueva
UPDATE    BEFORE      Justo ANTES de actualizar la fila
UPDATE    AFTER       Justo DESPUÉS de actualizar la fila
DELETE    BEFORE      Justo ANTES de eliminar la fila
DELETE    AFTER       Justo DESPUÉS de eliminar la fila
```

### NEW y OLD — acceder a los valores

Dentro del trigger se usan dos pseudo-registros especiales:

| Pseudo-registro | Disponible en      | Contiene                        |
|-----------------|--------------------|---------------------------------|
| `NEW`           | INSERT, UPDATE     | Los valores que van a quedar    |
| `OLD`           | DELETE, UPDATE     | Los valores que había antes     |

```
INSERT  →  solo NEW   (no hay fila anterior que leer)
DELETE  →  solo OLD   (no hay fila nueva que leer)
UPDATE  →  NEW y OLD  (antes y después disponibles)
```

### Sintaxis base

```sql
DELIMITER //

CREATE TRIGGER nombre_trigger
{BEFORE | AFTER} {INSERT | UPDATE | DELETE} ON nombre_tabla
FOR EACH ROW
BEGIN
    -- código SQL
    -- se puede usar NEW.columna y OLD.columna
END //

DELIMITER ;
```

> `FOR EACH ROW` es obligatorio en MySQL. Significa que el trigger se ejecuta una vez por cada fila afectada por el evento.

---

## 1. AFTER INSERT — descontar stock al crear un pedido

**Caso de uso:** cuando se registra un pedido, el stock del producto debe bajar automáticamente. No queremos depender de que la aplicación recuerde hacerlo.

**¿Por qué AFTER?** Queremos actuar solo si el INSERT fue exitoso. Si el INSERT falla (ej: FK inválida), el trigger no se ejecuta.

```sql
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
```

**Flujo:**
```
INSERT INTO pedidos ... (cantidad=5, id_producto=3)
        │
        ▼
  fila insertada en pedidos
        │
        ▼  ← trigger dispara AFTER
  UPDATE productos SET stock = stock - 5 WHERE id_producto = 3
```

---

## 2. BEFORE INSERT — validar datos antes de aceptar el pedido

**Caso de uso:** no queremos que se inserte un pedido si el stock es insuficiente o la cantidad es inválida.

**¿Por qué BEFORE?** Si la validación falla, queremos **cancelar** el INSERT antes de que ocurra. Con `SIGNAL` lanzamos un error que aborta la operación.

```sql
DELIMITER //
CREATE TRIGGER trg_validar_pedido
BEFORE INSERT ON pedidos
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;

    SELECT stock INTO v_stock
    FROM productos WHERE id_producto = NEW.id_producto;

    IF NEW.cantidad > v_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para completar el pedido';
    END IF;

    IF NEW.cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad debe ser mayor a cero';
    END IF;
END //
DELIMITER ;
```

**`SIGNAL SQLSTATE '45000'`** — lanza un error personalizado y cancela la sentencia. El código `45000` es el estándar para errores de usuario en MySQL.

**Flujo cuando falla:**
```
INSERT INTO pedidos ... (cantidad=9999)
        │
        ▼  ← trigger dispara BEFORE
  valida stock → 9999 > 95 → SIGNAL → ERROR
        │
        ✗  INSERT cancelado, nada se escribe en la tabla
```

---

## 3. AFTER UPDATE — auditar cambios de precio

**Caso de uso:** llevar un historial de quién cambió qué precio y cuándo.

**NEW y OLD en UPDATE:**
```
UPDATE productos SET precio = 299 WHERE id_producto = 2;
                          │
              OLD.precio = 320  (valor anterior)
              NEW.precio = 299  (valor nuevo)
```

```sql
DELIMITER //
CREATE TRIGGER trg_auditar_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.precio <> OLD.precio THEN
        INSERT INTO log_precios
            (id_producto, nombre_prod, precio_antes, precio_nuevo, diferencia, usuario, fecha_cambio)
        VALUES
            (OLD.id_producto, OLD.nombre,
             OLD.precio, NEW.precio, NEW.precio - OLD.precio,
             USER(), NOW());
    END IF;
END //
DELIMITER ;
```

- `USER()` — función de MySQL que devuelve el usuario conectado actualmente
- `NOW()` — función de MySQL que devuelve la fecha y hora actual
- El `IF NEW.precio <> OLD.precio` evita registrar el log si el UPDATE no cambió realmente el precio

---

## 4. BEFORE UPDATE — corregir o bloquear valores inválidos

**Caso de uso:** evitar que el precio quede negativo; y si se pone 0, corregirlo automáticamente.

**Poder especial del BEFORE:** se puede usar `SET NEW.columna = valor` para **modificar el dato antes de que se escriba**.

```sql
DELIMITER //
CREATE TRIGGER trg_validar_precio
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.precio < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio no puede ser negativo';
    END IF;

    IF NEW.precio = 0 THEN
        SET NEW.precio = 0.01;   -- corregimos el valor silenciosamente
    END IF;
END //
DELIMITER ;
```

**Diferencia clave BEFORE vs AFTER:**

| BEFORE                                  | AFTER                                     |
|-----------------------------------------|-------------------------------------------|
| Puede cancelar la operación con SIGNAL  | No puede cancelar (ya ocurrió)            |
| Puede modificar NEW.columna             | No puede modificar NEW (ya se escribió)   |
| Útil para validar y corregir            | Útil para registrar, notificar, propagar  |

---

## 5. AFTER DELETE — guardar un pedido antes de perderlo

**Caso de uso:** cuando se borra un pedido, queremos conservar un registro de que existió.

**En DELETE solo existe OLD** (no hay fila nueva):

```sql
DELIMITER //
CREATE TRIGGER trg_log_eliminar_pedido
AFTER DELETE ON pedidos
FOR EACH ROW
BEGIN
    INSERT INTO log_pedidos_eliminados
        (id_pedido, id_cliente, id_producto, cantidad, fecha_pedido, eliminado_el)
    VALUES
        (OLD.id_pedido, OLD.id_cliente, OLD.id_producto,
         OLD.cantidad, OLD.fecha, NOW());
END //
DELIMITER ;
```

**Flujo:**
```
DELETE FROM pedidos WHERE id_pedido = 9
        │
  fila eliminada de pedidos
        │
        ▼  ← trigger dispara AFTER
  INSERT INTO log_pedidos_eliminados ... (con los OLD.valores)
```

---

## 6. BEFORE DELETE — proteger registros críticos

**Caso de uso:** impedir que se elimine un cliente importante sin aprobación manual.

```sql
DELIMITER //
CREATE TRIGGER trg_proteger_cliente_vip
BEFORE DELETE ON clientes
FOR EACH ROW
BEGIN
    DECLARE v_pedidos INT;

    SELECT COUNT(*) INTO v_pedidos
    FROM pedidos WHERE id_cliente = OLD.id_cliente;

    IF v_pedidos >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente VIP: requiere aprobacion manual para eliminar.';
    END IF;
END //
DELIMITER ;
```

---

## Resumen de los 6 tipos — cuándo usar cada uno

```
┌──────────────┬──────────────────────────────────────────────────────┐
│ Trigger      │ Caso de uso típico                                   │
├──────────────┼──────────────────────────────────────────────────────┤
│ BEFORE INSERT│ Validar datos / corregir valores antes de insertar   │
│ AFTER INSERT │ Actualizar otra tabla (ej: bajar stock)              │
│ BEFORE UPDATE│ Validar / corregir el nuevo valor antes de escribir  │
│ AFTER UPDATE │ Auditar cambios (registrar quién cambió qué)         │
│ BEFORE DELETE│ Proteger registros críticos / pedir confirmación      │
│ AFTER DELETE │ Guardar el registro eliminado en un log              │
└──────────────┴──────────────────────────────────────────────────────┘
```

---

## 7. Gestionar triggers

```sql
-- Ver todos los triggers de la base actual
SHOW TRIGGERS;

-- Ver triggers de una tabla específica
SHOW TRIGGERS FROM tienda LIKE 'pedidos';

-- Ver detalle desde information_schema
SELECT trigger_name, event_manipulation, action_timing, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'tienda';

-- Eliminar un trigger
DROP TRIGGER IF EXISTS trg_bajar_stock;
```

> No existe `ALTER TRIGGER` en MySQL. Para modificar un trigger hay que borrarlo y crearlo de nuevo.

---

## 8. DCL — Data Control Language

DCL controla **quién** puede conectarse a MySQL y **qué puede hacer** dentro de las bases de datos.

### Los sublenguajes SQL

```
DDL  →  CREATE, ALTER, DROP               (estructura de tablas)
DML  →  SELECT, INSERT, UPDATE, DELETE    (datos)
DCL  →  GRANT, REVOKE                     (permisos de acceso)
TCL  →  COMMIT, ROLLBACK                  (transacciones)
```

---

## 8a. CREATE USER — crear usuarios

```sql
CREATE USER 'nombre'@'host' IDENTIFIED BY 'password';
```

| Host           | Desde dónde puede conectarse            |
|----------------|-----------------------------------------|
| `'localhost'`  | Solo desde la misma máquina             |
| `'%'`          | Desde cualquier IP                      |
| `'192.168.1.%'`| Solo desde esa subred                   |

```sql
CREATE USER 'analista'@'localhost' IDENTIFIED BY 'Analista2025!';
CREATE USER 'vendedor'@'localhost' IDENTIFIED BY 'Vendedor2025!';
CREATE USER 'admin_bd'@'localhost' IDENTIFIED BY 'Admin2025!';

-- Ver usuarios creados
SELECT user, host FROM mysql.user;

-- Cambiar password
ALTER USER 'vendedor'@'localhost' IDENTIFIED BY 'NuevaClave2025!';

-- Eliminar usuario
DROP USER IF EXISTS 'analista'@'localhost';
```

---

## 8b. GRANT — otorgar permisos

```sql
GRANT privilegio1, privilegio2 ON alcance TO 'usuario'@'host';
```

### Alcance (scope)

```
*.*              → todas las bases, todas las tablas (global)
tienda.*         → toda la base tienda
tienda.clientes  → solo esa tabla en tienda
```

### Ejemplos por rol

```sql
-- Analista: solo puede leer
GRANT SELECT ON tienda.* TO 'analista'@'localhost';

-- Vendedor: puede leer clientes/productos, y leer+agregar pedidos
GRANT SELECT         ON tienda.clientes  TO 'vendedor'@'localhost';
GRANT SELECT         ON tienda.productos TO 'vendedor'@'localhost';
GRANT SELECT, INSERT ON tienda.pedidos   TO 'vendedor'@'localhost';

-- Admin: control total
GRANT ALL PRIVILEGES ON tienda.* TO 'admin_bd'@'localhost';

-- Aplicar cambios inmediatamente
FLUSH PRIVILEGES;
```

---

## 8c. REVOKE — quitar permisos

```sql
REVOKE privilegio ON alcance FROM 'usuario'@'host';
```

```sql
-- Quitamos el INSERT al vendedor
REVOKE INSERT ON tienda.pedidos FROM 'vendedor'@'localhost';

-- Quitamos todo al analista
REVOKE ALL PRIVILEGES ON tienda.* FROM 'analista'@'localhost';

FLUSH PRIVILEGES;
```

---

## 8d. Privilegios más comunes

| Privilegio        | Permite                                        |
|-------------------|------------------------------------------------|
| `SELECT`          | Leer datos de tablas                           |
| `INSERT`          | Agregar filas                                  |
| `UPDATE`          | Modificar filas existentes                     |
| `DELETE`          | Eliminar filas                                 |
| `CREATE`          | Crear tablas y bases de datos                  |
| `DROP`            | Eliminar tablas y bases de datos               |
| `ALTER`           | Modificar estructura de tablas                 |
| `TRIGGER`         | Crear y eliminar triggers                      |
| `ALL PRIVILEGES`  | Todos los privilegios anteriores               |

---

## Diseño de roles típico

```
┌──────────────────────────────────────────────────────────────┐
│ ROL        │ GRANT                                           │
├────────────┼─────────────────────────────────────────────────┤
│ analista   │ SELECT en toda la base                          │
│ vendedor   │ SELECT en clientes/productos + SELECT,INSERT     │
│            │ en pedidos                                      │
│ supervisor │ SELECT, UPDATE en productos                     │
│            │ SELECT, UPDATE, DELETE en pedidos               │
│ admin      │ ALL PRIVILEGES en toda la base                  │
└────────────┴─────────────────────────────────────────────────┘
```

---

## Resumen de la clase

| Concepto              | Sintaxis clave                                              |
|-----------------------|-------------------------------------------------------------|
| Crear trigger         | `CREATE TRIGGER nombre BEFORE/AFTER evento ON tabla ...`   |
| Valores nuevos        | `NEW.columna` (INSERT y UPDATE)                             |
| Valores anteriores    | `OLD.columna` (DELETE y UPDATE)                             |
| Cancelar operación    | `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '...'`         |
| Corregir valor        | `SET NEW.columna = valor` (solo en BEFORE)                 |
| Ver triggers          | `SHOW TRIGGERS`                                             |
| Eliminar trigger      | `DROP TRIGGER IF EXISTS nombre`                             |
| Crear usuario         | `CREATE USER 'x'@'host' IDENTIFIED BY 'pass'`              |
| Dar permisos          | `GRANT privilegio ON base.tabla TO 'x'@'host'`             |
| Quitar permisos       | `REVOKE privilegio ON base.tabla FROM 'x'@'host'`          |
| Ver permisos          | `SHOW GRANTS FOR 'x'@'host'`                               |
| Aplicar cambios       | `FLUSH PRIVILEGES`                                          |
| Eliminar usuario      | `DROP USER IF EXISTS 'x'@'host'`                           |

## Orden de trabajo recomendado para triggers

```
1. Identificar el evento: ¿INSERT, UPDATE o DELETE?
2. Elegir el momento: ¿necesito actuar ANTES o DESPUÉS?
   - Validar / corregir → BEFORE
   - Propagar / auditar → AFTER
3. Identificar qué pseudo-registro necesito: NEW, OLD o ambos
4. Escribir el bloque con DELIMITER // ... DELIMITER ;
5. Probar el caso normal y el caso que debería fallar
```
