# Clase 07 — Funciones y Stored Procedures

Base de datos: `tienda` (MySQL)
Tablas: `paises`, `ciudades`, `clientes`, `productos`, `pedidos`

---

## Repaso rápido

| Concepto           | Qué hace                                                          |
|--------------------|-------------------------------------------------------------------|
| `JOIN`             | Une tablas en una consulta por una columna en común               |
| `GROUP BY`         | Agrupa filas para aplicar funciones de agregación                 |
| `FOREIGN KEY`      | Garantiza integridad referencial entre tablas                     |
| `ON DELETE CASCADE`| Si se borra el padre, los hijos se borran solos                   |
| `INSERT INTO SELECT`| Inserta datos tomados de otra tabla o consulta                   |

---

## El problema que resuelven los Stored Procedures

Imagine que cada vez que queremos el reporte de ventas ejecutamos 10 líneas de SQL. Si lo necesitamos en 5 partes distintas de la aplicación, copiamos y pegamos 5 veces. Si hay que corregir algo, hay que encontrar las 5 copias.

**Solución:** guardamos ese bloque de SQL con un nombre dentro de la base de datos. Luego lo llamamos con `CALL nombre()`.

---

## Por qué necesitamos DELIMITER

MySQL usa `;` para saber cuándo termina una sentencia. Dentro de un procedimiento hay muchas sentencias que terminan con `;`. Sin cambiar el delimitador, MySQL cortaría el bloque a la mitad y daría error.

**Flujo correcto:**

```sql
DELIMITER //          -- cambiamos el delimitador a //

CREATE PROCEDURE mi_proc()
BEGIN
    SELECT * FROM productos;    -- este ; no confunde a MySQL
    SELECT * FROM clientes;     -- este tampoco
END //                          -- ← acá sí termina el bloque

DELIMITER ;           -- volvemos al ; normal
```

> En MySQL Workbench, el botón "ejecutar script" (rayo) ya maneja DELIMITER automáticamente. Si ejecutas línea a línea puede fallar — siempre ejecutar el bloque completo del DELIMITER.

---

## 1. Stored Procedures sin parámetros

El caso más simple: un bloque de SQL guardado que siempre hace lo mismo.

### Sintaxis

```sql
DELIMITER //
CREATE PROCEDURE nombre_procedimiento()
BEGIN
    -- sentencias SQL
END //
DELIMITER ;
```

### Llamada

```sql
CALL nombre_procedimiento();
```

### Ejemplo — reporte de stock

```sql
DELIMITER //
CREATE PROCEDURE reporte_stock()
BEGIN
    SELECT nombre, precio, stock,
           CASE
               WHEN stock < 30 THEN 'CRITICO'
               WHEN stock < 70 THEN 'BAJO'
               ELSE                 'OK'
           END AS estado_stock
    FROM productos
    ORDER BY stock ASC;
END //
DELIMITER ;

CALL reporte_stock();
```

### Administración

```sql
SHOW PROCEDURE STATUS WHERE Db = 'tienda';  -- ver todos los procedimientos
DROP PROCEDURE IF EXISTS reporte_stock;      -- eliminar
```

---

## 2. Parámetro IN — el procedimiento recibe un valor

`IN` es el tipo por defecto. El procedimiento recibe un dato del exterior y lo usa internamente. **No puede modificar la variable original del que llama.**

```
Quien llama  ──── valor ────►  Procedimiento
```

### Ejemplo — pedidos de un cliente específico

```sql
DELIMITER //
CREATE PROCEDURE pedidos_de_cliente(IN p_id_cliente INT)
BEGIN
    SELECT pe.id_pedido, cl.nombre AS cliente,
           pr.nombre AS producto, pe.cantidad,
           pe.cantidad * pr.precio AS subtotal, pe.fecha
    FROM pedidos pe
    JOIN clientes  cl ON pe.id_cliente  = cl.id_cliente
    JOIN productos pr ON pe.id_producto = pr.id_producto
    WHERE pe.id_cliente = p_id_cliente
    ORDER BY pe.fecha;
END //
DELIMITER ;

CALL pedidos_de_cliente(1);   -- pedidos de Lucas
CALL pedidos_de_cliente(4);   -- pedidos de Paula
```

### Ejemplo — actualizar precio

```sql
DELIMITER //
CREATE PROCEDURE actualizar_precio(IN p_id_producto INT, IN p_nuevo_precio DECIMAL(8,2))
BEGIN
    UPDATE productos SET precio = p_nuevo_precio WHERE id_producto = p_id_producto;
    SELECT id_producto, nombre, precio FROM productos WHERE id_producto = p_id_producto;
END //
DELIMITER ;

CALL actualizar_precio(1, 799.00);
```

> Se pueden tener varios parámetros IN separados por coma.

---

## 3. Parámetro OUT — el procedimiento devuelve un valor

`OUT` permite que el procedimiento **escriba** en una variable del llamador. La variable se pasa vacía y el procedimiento la llena.

```
Quien llama  ◄── valor ────  Procedimiento
```

Para capturar el resultado se usan **variables de sesión** (con `@`):

```sql
CALL mi_proc(@resultado);
SELECT @resultado;
```

### Ejemplo — contar clientes

```sql
DELIMITER //
CREATE PROCEDURE contar_clientes(OUT p_total INT)
BEGIN
    SELECT COUNT(*) INTO p_total FROM clientes;
END //
DELIMITER ;

CALL contar_clientes(@total);
SELECT @total AS total_clientes;
```

### Ejemplo — varios OUT a la vez

```sql
DELIMITER //
CREATE PROCEDURE producto_mas_caro(OUT p_nombre VARCHAR(100), OUT p_precio DECIMAL(8,2))
BEGIN
    SELECT nombre, precio INTO p_nombre, p_precio
    FROM productos ORDER BY precio DESC LIMIT 1;
END //
DELIMITER ;

CALL producto_mas_caro(@nombre, @precio);
SELECT @nombre AS producto, @precio AS precio;
```

### `SELECT ... INTO variable` — la clave de OUT

```sql
SELECT COUNT(*) INTO p_total FROM clientes;
--     ^^^^^^^^^           ^^^^^^^^^^^^^^^
--     resultado            variable donde se guarda
```

---

## 4. Variables locales — DECLARE y SET

Las **variables locales** solo existen dentro del `BEGIN...END`. Se declaran con `DECLARE` al comienzo del bloque, **antes de cualquier otra sentencia**.

```sql
DECLARE nombre_variable tipo [DEFAULT valor];
SET nombre_variable = expresion;
```

| Variable local (`DECLARE`) | Variable de sesión (`@`)      |
|---------------------------|-------------------------------|
| Solo vive dentro del proc | Vive toda la sesión            |
| Se declara con DECLARE     | No necesita declaración        |
| Tipo estricto              | Tipado flexible                |
| Ejemplo: `v_total`         | Ejemplo: `@total`             |

### Ejemplo con variables locales

```sql
DELIMITER //
CREATE PROCEDURE descuento_por_volumen(IN p_id_cliente INT)
BEGIN
    DECLARE v_total     DECIMAL(10,2);
    DECLARE v_descuento DECIMAL(5,2);

    SELECT SUM(pe.cantidad * pr.precio)
    INTO v_total
    FROM pedidos pe JOIN productos pr ON pe.id_producto = pr.id_producto
    WHERE pe.id_cliente = p_id_cliente;

    IF v_total >= 1500 THEN
        SET v_descuento = 15;
    ELSEIF v_total >= 800 THEN
        SET v_descuento = 10;
    ELSE
        SET v_descuento = 0;
    END IF;

    SELECT v_total AS total_bruto,
           v_descuento AS descuento_pct,
           ROUND(v_total - (v_total * v_descuento / 100), 2) AS total_final;
END //
DELIMITER ;
```

---

## 5. IF / ELSEIF / ELSE

Control de flujo condicional dentro de un procedimiento.

```sql
IF condicion1 THEN
    -- bloque 1
ELSEIF condicion2 THEN
    -- bloque 2
ELSE
    -- bloque por defecto
END IF;
```

> El `END IF;` con punto y coma es obligatorio.

### Cuándo usar IF vs CASE

| Situación                                          | Usar    |
|----------------------------------------------------|---------|
| Comparar rangos o condiciones complejas            | `IF`    |
| Comparar una variable contra valores exactos fijos | `CASE`  |

---

## 6. CASE dentro de procedimientos

```sql
CASE variable
    WHEN valor1 THEN
        SET x = 'a';
    WHEN valor2 THEN
        SET x = 'b';
    ELSE
        SET x = 'c';
END CASE;
```

### Ejemplo — info del país por código

```sql
DELIMITER //
CREATE PROCEDURE info_pais(IN p_codigo CHAR(3))
BEGIN
    DECLARE v_capital VARCHAR(80);

    CASE p_codigo
        WHEN 'ARG' THEN SET v_capital = 'Buenos Aires';
        WHEN 'BRA' THEN SET v_capital = 'Brasilia';
        WHEN 'CHL' THEN SET v_capital = 'Santiago';
        ELSE            SET v_capital = 'Desconocida';
    END CASE;

    SELECT p_codigo AS codigo, v_capital AS capital;
END //
DELIMITER ;

CALL info_pais('ARG');
```

---

## 7. WHILE — bucle

Repite un bloque mientras la condición sea verdadera.

```sql
WHILE condicion DO
    -- sentencias
    SET contador = contador + 1;   -- importante: actualizar el contador
END WHILE;
```

> **Peligro:** si la condición nunca se vuelve falsa → bucle infinito. Siempre asegurarse de actualizar la variable que controla el loop.

### Ejemplo — generar tabla de cuadrados

```sql
DELIMITER //
CREATE PROCEDURE generar_prueba(IN p_cantidad INT)
BEGIN
    DECLARE v_i INT DEFAULT 1;

    CREATE TABLE IF NOT EXISTS prueba_numeros (numero INT, cuadrado INT);

    WHILE v_i <= p_cantidad DO
        INSERT INTO prueba_numeros VALUES (v_i, v_i * v_i);
        SET v_i = v_i + 1;
    END WHILE;

    SELECT * FROM prueba_numeros;
END //
DELIMITER ;

CALL generar_prueba(5);
```

---

## 8. Funciones (CREATE FUNCTION)

Una función es como un procedimiento con una diferencia clave: **siempre devuelve exactamente un valor** con `RETURN`.

### Sintaxis

```sql
DELIMITER //
CREATE FUNCTION nombre_funcion(parametro TIPO)
RETURNS tipo_retorno
[DETERMINISTIC | READS SQL DATA | MODIFIES SQL DATA]
BEGIN
    -- lógica
    RETURN valor;
END //
DELIMITER ;
```

### Características obligatorias

| Parte         | Qué hace                                                            |
|---------------|---------------------------------------------------------------------|
| `RETURNS tipo`| Declara el tipo del valor que va a devolver                         |
| `RETURN valor`| Devuelve el valor (puede estar en cualquier parte del BEGIN...END)  |
| Modificadores | Le dicen a MySQL qué tipo de acceso hace la función a los datos     |

### Modificadores

| Modificador        | Cuándo usarlo                                           |
|--------------------|---------------------------------------------------------|
| `DETERMINISTIC`    | Mismo input → mismo output siempre (ej: cálculo puro)  |
| `READS SQL DATA`   | Solo lee tablas, no modifica nada                       |
| `MODIFIES SQL DATA`| Hace INSERT/UPDATE/DELETE dentro                        |

### Ejemplos

```sql
-- Función pura (cálculo sin acceder a tablas)
DELIMITER //
CREATE FUNCTION calcular_subtotal(p_cantidad INT, p_precio DECIMAL(8,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_cantidad * p_precio;
END //
DELIMITER ;


-- Función que lee una tabla
DELIMITER //
CREATE FUNCTION estado_stock(p_stock INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    IF p_stock < 30 THEN RETURN 'CRITICO';
    ELSEIF p_stock < 70 THEN RETURN 'BAJO';
    ELSE RETURN 'OK';
    END IF;
END //
DELIMITER ;
```

### Cómo se usan — dentro de SELECT

```sql
-- Las funciones se usan como cualquier función de MySQL nativa
SELECT nombre, stock, estado_stock(stock) AS estado
FROM productos;

SELECT pe.id_pedido, calcular_subtotal(pe.cantidad, pr.precio) AS subtotal
FROM pedidos pe
JOIN productos pr ON pe.id_producto = pr.id_producto;

-- También en WHERE
SELECT nombre, stock
FROM productos
WHERE estado_stock(stock) = 'CRITICO';
```

---

## Procedure vs Function — diferencias clave

```
┌────────────────────────────────────────────────────────────────┐
│                    STORED PROCEDURE                            │
│  - Se llama con CALL                                           │
│  - Puede devolver 0, 1 o muchos valores (con OUT)              │
│  - Puede devolver múltiples filas (result sets)                │
│  - Puede usar IN, OUT, INOUT                                   │
│  - No se puede usar dentro de un SELECT                        │
├────────────────────────────────────────────────────────────────┤
│                    FUNCTION                                    │
│  - Se usa dentro de SELECT, WHERE, SET, etc.                   │
│  - Devuelve exactamente un valor con RETURN                    │
│  - Solo puede tener parámetros IN                              │
│  - No puede devolver result sets                               │
│  - Es como una función nativa de MySQL (NOW(), ROUND(), etc.)  │
└────────────────────────────────────────────────────────────────┘
```

### ¿Cuándo usar cada uno?

| Necesito…                                      | Usar       |
|------------------------------------------------|------------|
| Ejecutar lógica compleja con múltiples SELECTs | PROCEDURE  |
| Devolver un cálculo dentro de un SELECT        | FUNCTION   |
| Insertar/actualizar varias tablas a la vez     | PROCEDURE  |
| Reutilizar una fórmula en muchas consultas     | FUNCTION   |
| Devolver un result set completo                | PROCEDURE  |

---

## 9. Gestión de procedimientos y funciones

```sql
-- Listar todos los procedimientos de la base actual
SHOW PROCEDURE STATUS WHERE Db = 'tienda';

-- Listar todas las funciones
SHOW FUNCTION STATUS WHERE Db = 'tienda';

-- Ver el código de un procedimiento
SHOW CREATE PROCEDURE reporte_stock;

-- Ver el código de una función
SHOW CREATE FUNCTION estado_stock;

-- Eliminar
DROP PROCEDURE IF EXISTS reporte_stock;
DROP FUNCTION  IF EXISTS estado_stock;
```

---

## Resumen de la clase

| Concepto               | Cómo se escribe                      | Cómo se usa              |
|------------------------|--------------------------------------|--------------------------|
| Procedure sin params   | `CREATE PROCEDURE nombre()`          | `CALL nombre()`          |
| Parámetro IN           | `IN p_var TIPO`                      | `CALL nombre(valor)`     |
| Parámetro OUT          | `OUT p_var TIPO`                     | `CALL nombre(@var)`      |
| Variable local         | `DECLARE v_var TIPO [DEFAULT x]`     | `SET v_var = ...`        |
| Condicional            | `IF ... ELSEIF ... ELSE ... END IF`  | Dentro del BEGIN...END   |
| Selección fija         | `CASE var WHEN ... END CASE`         | Dentro del BEGIN...END   |
| Bucle                  | `WHILE cond DO ... END WHILE`        | Dentro del BEGIN...END   |
| Función                | `CREATE FUNCTION ... RETURNS tipo`   | Dentro de `SELECT`       |
| Cambiar delimitador    | `DELIMITER //` ... `DELIMITER ;`     | Antes/después del bloque |

## Flujo para crear un procedimiento

```
1. Cambiar DELIMITER a //
2. CREATE PROCEDURE nombre(parámetros)
3. BEGIN
4.     DECLARE variables locales (si hacen falta)
5.     Lógica con SELECT, IF, CASE, WHILE...
6. END //
7. Restaurar DELIMITER a ;
8. Probar con CALL nombre(args)
```
