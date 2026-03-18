# Clase 11 — Datawarehouse y Business Intelligence

Bases de datos: `tienda` (OLTP, operacional) + `tienda_dw` (OLAP, datawarehouse)

---

## Repaso rápido

| Concepto              | Qué hace                                                  |
|-----------------------|-----------------------------------------------------------|
| `START TRANSACTION`   | Abre un bloque atómico de operaciones                     |
| `COMMIT / ROLLBACK`   | Confirma o deshace todos los cambios del bloque           |
| `SAVEPOINT`           | Punto de control intermedio dentro de una transacción     |
| `GRANT / REVOKE`      | Controla permisos de usuarios (DCL)                       |
| `mysqldump`           | Genera un backup de la base en un archivo `.sql`          |

---

## OLTP vs OLAP — dos mundos distintos

Hasta ahora trabajamos con bases **OLTP** (bases operacionales). En esta clase construimos una base **OLAP** (datawarehouse).

```
┌──────────────────────────────────────────────────────────────────┐
│                OLTP (tienda)         OLAP (tienda_dw)            │
├─────────────────┬────────────────────┬───────────────────────────┤
│ Objetivo        │ Registrar operaciones│ Analizar el negocio      │
│ Operaciones     │ INSERT, UPDATE       │ SELECT con GROUP BY      │
│ Diseño          │ Normalizado (3FN)    │ Desnormalizado (estrella)│
│ Usuarios        │ Cajeros, vendedores  │ Gerentes, analistas      │
│ Volumen filas   │ Miles (activas)      │ Millones (históricas)    │
│ Velocidad       │ Rápido en escritura  │ Rápido en lectura        │
│ Ejemplo         │ Registrar un pedido  │ ¿Qué mes vendimos más?   │
└─────────────────┴────────────────────┴───────────────────────────┘
```

---

## 1. Esquema Estrella (Star Schema)

El modelo estrella es la forma más común de organizar un datawarehouse. Tiene una **tabla de hechos** en el centro y varias **tablas de dimensiones** alrededor.

```
                    dim_fecha
                        │
                        │
    dim_cliente ──── fact_ventas ──── dim_producto
                        │
                        │
                    dim_geografia
```

### Tabla de hechos

Contiene las **métricas numéricas** que queremos analizar y las **claves foráneas** a todas las dimensiones.

```sql
CREATE TABLE fact_ventas (
    id_venta        INT AUTO_INCREMENT PRIMARY KEY,
    id_fecha        INT,    -- FK → dim_fecha
    id_cliente      INT,    -- FK → dim_cliente
    id_producto     INT,    -- FK → dim_producto
    id_ciudad       INT,    -- FK → dim_geografia
    cantidad        INT,            -- métrica
    precio_unitario DECIMAL(8,2),   -- métrica
    importe_total   DECIMAL(10,2)   -- métrica precalculada
);
```

> Las métricas precalculadas (como `importe_total = cantidad * precio`) son una práctica habitual en DW para acelerar las consultas analíticas.

### Tablas de dimensiones

Contienen los **atributos descriptivos** que usamos para filtrar, agrupar y darle contexto a los números.

```sql
-- dim_fecha: permite analizar por día, mes, trimestre, año
CREATE TABLE dim_fecha (
    id_fecha    INT PRIMARY KEY,   -- formato YYYYMMDD: 20250115
    fecha       DATE,
    dia         INT,
    mes         INT,
    nombre_mes  VARCHAR(20),
    trimestre   INT,
    anio        INT,
    dia_semana  VARCHAR(15)
);

-- dim_cliente: desnormalizado (ciudad y país ya incluidos)
CREATE TABLE dim_cliente (
    id_cliente INT PRIMARY KEY,
    nombre     VARCHAR(100),
    ciudad     VARCHAR(100),
    pais       VARCHAR(80)
);

-- dim_producto: categoría incluida (sin JOIN extra)
CREATE TABLE dim_producto (
    id_producto  INT PRIMARY KEY,
    nombre       VARCHAR(100),
    categoria    VARCHAR(60),
    precio_lista DECIMAL(8,2)
);
```

### Diferencia con el modelo OLTP

```
OLTP (normalizado):                    OLAP (desnormalizado):
  clientes                               dim_cliente
  ciudades      → 3 JOINs para           (nombre, ciudad, pais)
  paises          traer ciudad y país    → 1 JOIN, todo junto
```

---

## 2. ETL — Extract, Transform, Load

ETL es el proceso que **mueve los datos** desde la base operacional al datawarehouse.

```
EXTRACT   →  leer de la fuente (tienda)
TRANSFORM →  adaptar al modelo del DW (calcular, limpiar, desnormalizar)
LOAD      →  insertar en el DW (tienda_dw)
```

Se implementa con `INSERT INTO ... SELECT` entre las dos bases.

### ETL de la dimensión fecha

```sql
INSERT INTO tienda_dw.dim_fecha
    (id_fecha, fecha, dia, mes, nombre_mes, trimestre, anio, dia_semana)
SELECT DISTINCT
    DATE_FORMAT(pe.fecha, '%Y%m%d'),   -- id: 20250115
    pe.fecha,
    DAY(pe.fecha),
    MONTH(pe.fecha),
    DATE_FORMAT(pe.fecha, '%M'),        -- nombre del mes en inglés
    QUARTER(pe.fecha),
    YEAR(pe.fecha),
    DATE_FORMAT(pe.fecha, '%W')         -- nombre del día
FROM tienda.pedidos pe;
```

### ETL de la dimensión cliente (desnormalización)

```sql
INSERT INTO tienda_dw.dim_cliente (id_cliente, nombre, email, ciudad, pais)
SELECT cl.id_cliente, cl.nombre, cl.email,
       ci.nombre AS ciudad,
       pa.nombre AS pais
FROM tienda.clientes cl
LEFT JOIN tienda.ciudades ci ON cl.id_ciudad = ci.id_ciudad
LEFT JOIN tienda.paises   pa ON ci.id_pais   = pa.id_pais;
```

En el DW quedó todo en una sola tabla. La normalización desapareció intencionalmente.

### ETL de la tabla de hechos

```sql
INSERT INTO tienda_dw.fact_ventas
    (id_fecha, id_cliente, id_producto, id_ciudad, cantidad, precio_unitario, importe_total)
SELECT
    DATE_FORMAT(pe.fecha, '%Y%m%d'),
    pe.id_cliente,
    pe.id_producto,
    cl.id_ciudad,
    pe.cantidad,
    pr.precio,
    pe.cantidad * pr.precio            -- métrica precalculada
FROM tienda.pedidos  pe
JOIN tienda.clientes  cl ON pe.id_cliente  = cl.id_cliente
JOIN tienda.productos pr ON pe.id_producto = pr.id_producto;
```

---

## 3. Consultas analíticas básicas sobre el DW

Con el esquema estrella, las consultas analíticas son muy simples: un JOIN por dimensión y un `GROUP BY`.

```sql
-- Facturación por mes
SELECT df.anio, df.nombre_mes, SUM(fv.importe_total) AS facturacion
FROM fact_ventas fv
JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
GROUP BY df.anio, df.mes, df.nombre_mes
ORDER BY df.anio, df.mes;

-- Pivot manual: ventas por país y categoría en columnas
SELECT dg.pais,
    SUM(CASE WHEN dp.categoria = 'Computacion' THEN fv.importe_total ELSE 0 END) AS computacion,
    SUM(CASE WHEN dp.categoria = 'Perifericos' THEN fv.importe_total ELSE 0 END) AS perifericos,
    SUM(fv.importe_total) AS total
FROM fact_ventas fv
JOIN dim_geografia dg ON fv.id_ciudad   = dg.id_ciudad
JOIN dim_producto  dp ON fv.id_producto = dp.id_producto
GROUP BY dg.pais;
```

---

## 4. GROUP BY WITH ROLLUP

`ROLLUP` es una extensión de `GROUP BY` que genera **subtotales automáticos** para cada nivel de agrupación y un gran total al final.

```sql
SELECT
    COALESCE(df.anio,       'TOTAL')    AS anio,
    COALESCE(df.nombre_mes, 'Subtotal') AS mes,
    SUM(fv.importe_total)               AS facturacion
FROM fact_ventas fv
JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
GROUP BY df.anio, df.nombre_mes WITH ROLLUP;
```

**Resultado:**
```
anio    mes        facturacion
2025    January    ...
2025    February   ...
2025    March      ...
2025    Subtotal   ...    ← subtotal de 2025 (generado por ROLLUP)
TOTAL   Subtotal   ...    ← gran total (generado por ROLLUP)
```

> `COALESCE(columna, 'texto')` convierte los `NULL` que genera `ROLLUP` en etiquetas legibles.

---

## 5. CTEs — Common Table Expressions (`WITH`)

Un CTE es una **consulta nombrada** que podemos referenciar dentro de la misma sentencia SQL. Hace lo mismo que un subselect, pero es más legible y se puede reusar.

```sql
WITH nombre_cte AS (
    SELECT ...   -- esta es la consulta del CTE
)
SELECT ... FROM nombre_cte ...   -- la usamos como si fuera una tabla
```

### CTE simple

```sql
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
```

### Múltiples CTEs encadenados

```sql
WITH
ventas_mensuales AS (
    SELECT df.mes, SUM(fv.importe_total) AS facturacion
    FROM fact_ventas fv JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
    GROUP BY df.mes
),
max_ventas AS (
    SELECT MAX(facturacion) AS pico FROM ventas_mensuales
)
SELECT vm.mes, vm.facturacion
FROM ventas_mensuales vm
JOIN max_ventas mv ON vm.facturacion = mv.pico;
```

### CTE vs Subquery — ¿cuándo usar cada uno?

| Situación                                 | Usar           |
|-------------------------------------------|----------------|
| La subconsulta se usa una sola vez        | Subquery       |
| La subconsulta se necesita en 2+ lugares  | CTE            |
| La query se vuelve difícil de leer        | CTE            |
| Querés nombrar un paso intermedio         | CTE            |

---

## 6. Window Functions — funciones de ventana

Las window functions calculan un valor **por cada fila**, basándose en un grupo de filas relacionadas (la "ventana"), **sin colapsar las filas** como hace `GROUP BY`.

```sql
FUNCION() OVER (
    PARTITION BY columna   -- divide en grupos (como GROUP BY, pero no colapsa)
    ORDER BY columna       -- ordena dentro de cada grupo
)
```

### ROW_NUMBER — número de fila dentro del grupo

```sql
SELECT dc.nombre, df.fecha, fv.importe_total,
       ROW_NUMBER() OVER (
           PARTITION BY fv.id_cliente   -- reinicia el contador por cliente
           ORDER BY df.fecha
       ) AS nro_compra
FROM fact_ventas fv
JOIN dim_cliente dc ON fv.id_cliente = dc.id_cliente
JOIN dim_fecha   df ON fv.id_fecha   = df.id_fecha;
```

**Resultado:** cada cliente tiene su propio contador 1, 2, 3...

### RANK y DENSE_RANK — ranking con empates

```sql
SELECT dp.nombre, SUM(fv.importe_total) AS facturacion,
       RANK()       OVER (ORDER BY SUM(fv.importe_total) DESC) AS rank,
       DENSE_RANK() OVER (ORDER BY SUM(fv.importe_total) DESC) AS dense_rank
FROM fact_ventas fv
JOIN dim_producto dp ON fv.id_producto = dp.id_producto
GROUP BY dp.id_producto, dp.nombre;
```

```
producto     facturacion   RANK   DENSE_RANK
Notebook     2550          1      1
Monitor      960           2      2
SSD          770           3      3
SSD (empate) 770           3      3         ← mismo puesto
Auriculares  540           5      4         ← RANK salta a 5, DENSE_RANK va a 4
```

### SUM OVER — acumulado dentro del grupo

```sql
SELECT df.anio, df.nombre_mes,
       SUM(fv.importe_total) AS facturacion_mes,
       SUM(SUM(fv.importe_total)) OVER (
           PARTITION BY df.anio
           ORDER BY df.mes
       ) AS acumulado_anio
FROM fact_ventas fv
JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
GROUP BY df.anio, df.mes, df.nombre_mes;
```

**Resultado:** `acumulado_anio` suma todos los meses anteriores del mismo año.

### LAG — valor de la fila anterior

```sql
LAG(columna) OVER (ORDER BY columna_orden)
```

```sql
-- Comparar cada mes con el mes anterior
SELECT nombre_mes, facturacion,
       LAG(facturacion) OVER (ORDER BY mes)                       AS mes_anterior,
       facturacion - LAG(facturacion) OVER (ORDER BY mes)         AS variacion
FROM ventas_mensuales;
```

### LEAD — valor de la fila siguiente

```sql
LEAD(columna) OVER (ORDER BY columna_orden)
```

```sql
-- Ver cuánto va a facturar el mes que viene (si ya tenemos el dato)
SELECT nombre_mes, facturacion,
       LEAD(facturacion) OVER (ORDER BY mes) AS proximo_mes
FROM ventas_mensuales;
```

### Comparativa de window functions

| Función        | Qué devuelve                                          |
|----------------|-------------------------------------------------------|
| `ROW_NUMBER()` | Número de fila único dentro de la ventana             |
| `RANK()`       | Ranking con saltos en empates (1,2,2,4)               |
| `DENSE_RANK()` | Ranking sin saltos en empates (1,2,2,3)               |
| `SUM() OVER`   | Suma acumulada o total del grupo                      |
| `LAG(col)`     | Valor de la columna en la fila anterior               |
| `LEAD(col)`    | Valor de la columna en la fila siguiente              |

---

## Resumen de la clase

| Concepto              | Para qué sirve                                                |
|-----------------------|---------------------------------------------------------------|
| OLTP                  | Base operacional: registrar transacciones del día a día       |
| OLAP / DW             | Base analítica: analizar el historial del negocio             |
| Esquema estrella      | 1 fact table + N dimension tables (desnormalizadas)           |
| ETL                   | Proceso de carga: Extract → Transform → Load                  |
| `WITH ROLLUP`         | Genera subtotales automáticos en un `GROUP BY`                |
| CTE (`WITH`)          | Consulta nombrada reutilizable dentro del mismo `SELECT`      |
| `ROW_NUMBER()`        | Numera filas dentro de un grupo                               |
| `RANK() / DENSE_RANK`  | Ranking con manejo de empates                                |
| `SUM() OVER`          | Acumulado o totales sin colapsar filas                        |
| `LAG() / LEAD()`      | Acceder al valor de la fila anterior o siguiente              |

## Flujo de construcción de un DW

```
1. Identificar las preguntas de negocio:
   ¿qué queremos analizar?

2. Diseñar el esquema estrella:
   ¿qué es la tabla de hechos? ¿qué son las dimensiones?

3. ETL — cargar las dimensiones primero:
   INSERT INTO dim_X SELECT ... FROM tabla_oltp ...

4. ETL — cargar la tabla de hechos:
   INSERT INTO fact_Y SELECT ... (con JOINs y cálculos)

5. Consultas analíticas:
   GROUP BY, ROLLUP, CTEs, Window Functions
```
