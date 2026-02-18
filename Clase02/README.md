# Clase 02 - Consultas y Subconsultas SQL

---

## Patrones de Diseño de Esquemas: OLTP vs OLAP

Antes de escribir una sola consulta, hay que entender **para que fue diseñada** la base de datos que estamos consultando. Existen dos grandes patrones:

### OLTP (Online Transaction Processing)

Diseñado para **registrar operaciones en tiempo real**: ventas, reservas, pagos, actualizaciones de stock. Caracteristicas:

- Muchas tablas pequeñas y normalizadas (sin datos repetidos)
- Operaciones de lectura y escritura frecuentes y rapidas
- Pensado para muchos usuarios simultaneos haciendo inserciones y actualizaciones
- Ejemplo: el sistema de una tienda que registra cada compra al instante

```
Clientes ─┐
           ├─> Pedidos ─> DetallePedido ─> Productos
Empleados ─┘
```

### OLAP / Analitico (Online Analytical Processing)

Diseñado para **analizar grandes volumenes de datos historicos**: reportes, dashboards, KPIs. Caracteristicas:

- Pocas tablas grandes o esquemas estrella/copo de nieve
- Lecturas masivas, pocas escrituras
- Optimizado para agregaciones (SUM, COUNT, AVG) sobre millones de filas
- Ejemplo: un data warehouse que consolida ventas de los ultimos 5 años

```
           ┌─ DimCliente
           ├─ DimProducto
FactVentas ┤
           ├─ DimTiempo
           └─ DimRegion
```

| | OLTP | OLAP |
|--|------|------|
| **Operaciones** | INSERT, UPDATE, DELETE frecuentes | SELECT masivos |
| **Estructura** | Muchas tablas normalizadas | Pocas tablas grandes o esquema estrella |
| **Usuarios** | Muchos usuarios concurrentes | Pocos analistas |
| **Datos** | Actuales | Historicos |
| **Motores tipicos** | PostgreSQL, MySQL, SQL Server | BigQuery, Redshift, Snowflake |

---

## Panorama de Tipos de Datos por Motor

Cada columna de una tabla necesita un **tipo de dato** que le dice a la base de datos que clase de informacion va a guardar. La eleccion correcta impacta en espacio, rendimiento e integridad.

### Tipos Numericos

| Tipo | PostgreSQL | MySQL | SQL Server | ¿Para que? |
|------|-----------|-------|------------|-----------|
| Entero chico | `SMALLINT` | `SMALLINT` | `SMALLINT` | Edades, codigos |
| Entero | `INTEGER` / `INT` | `INT` | `INT` | IDs, cantidades |
| Entero grande | `BIGINT` | `BIGINT` | `BIGINT` | IDs de alto volumen |
| Decimal exacto | `DECIMAL(p,s)` / `NUMERIC` | `DECIMAL(p,s)` | `DECIMAL(p,s)` | Precios, saldos |
| Decimal aprox. | `REAL` / `DOUBLE PRECISION` | `FLOAT` / `DOUBLE` | `FLOAT` / `REAL` | Coordenadas, sensores |
| Auto-incremental | `SERIAL` / `BIGSERIAL` | `AUTO_INCREMENT` | `IDENTITY(1,1)` | Claves primarias |

> **Regla de oro:** Para dinero, **siempre** usa `DECIMAL`/`NUMERIC`. `FLOAT` puede tener errores de redondeo (10.00 podria guardarse como 9.9999998).

### Tipos de Texto

| Tipo | Descripcion | Cuando usarlo |
|------|------------|--------------|
| `CHAR(n)` | Longitud **fija** — siempre ocupa n caracteres | Codigos de pais (`'AR'`), estados fijos |
| `VARCHAR(n)` | Longitud **variable** — hasta n caracteres | Nombres, emails, descripciones cortas |
| `TEXT` | Sin limite practico | Comentarios, contenido largo |

> `CHAR(10)` guardando `'Hola'` rellena con 6 espacios. `VARCHAR(10)` guarda solo `'Hola'` (4 bytes). Usa `VARCHAR` por defecto.

### Tipos de Fecha y Hora

| Tipo | Guarda | Ejemplo |
|------|--------|---------|
| `DATE` | Solo fecha | `'2024-11-15'` |
| `TIME` | Solo hora | `'14:30:00'` |
| `DATETIME` / `TIMESTAMP` | Fecha y hora | `'2024-11-15 14:30:00'` |
| `TIMESTAMP WITH TIME ZONE` | Fecha/hora + zona horaria | `'2024-11-15 17:30:00+03:00'` |

> Usa `TIMESTAMP WITH TIME ZONE` si tu aplicacion opera en multiples zonas horarias.

### Tipos Binarios y Otros

| Tipo | PostgreSQL | MySQL | ¿Para que? |
|------|-----------|-------|-----------|
| Binario | `BYTEA` | `BLOB` | Archivos, imagenes |
| Booleano | `BOOLEAN` | `TINYINT(1)` | Verdadero/Falso |
| JSON | `JSON` / `JSONB` | `JSON` | Datos semiestructurados |
| UUID | `UUID` | `CHAR(36)` | Identificadores unicos globales |

---

## Guias para Elegir Tipos en Sistemas Analiticos

En sistemas analiticos el volumen de datos es grande, por lo que elegir bien el tipo impacta directamente en el costo y la velocidad:

1. **Usar el entero mas chico posible:** Si un campo nunca supera 100, usa `SMALLINT` en lugar de `INT`. Menos bytes = mas filas en memoria = consultas mas rapidas.
2. **Evitar `TEXT` para campos que se filtran o agrupan:** Preferir `VARCHAR(n)` con un limite razonable. Los indices funcionan mejor con longitud definida.
3. **Fechas como `DATE` o `TIMESTAMP`, nunca como `VARCHAR`:** Guardar `'2024-11-15'` como texto impide ordenar correctamente y usar funciones de fecha.
4. **`JSONB` sobre `JSON` en PostgreSQL:** `JSONB` se indexa y se consulta mas rapido que `JSON` (que es solo texto).
5. **Evitar `FLOAT` para metricas de negocio:** Un error de redondeo en un campo de ventas puede sumar miles en reportes agregados.

---

## Consulta de Seleccion: SELECT y FROM

### Sintaxis basica

```sql
SELECT campo1, campo2
FROM nombre_tabla;
```

**Seleccionar todos los campos:**

```sql
SELECT *
FROM system_user;
```

**Eliminar duplicados con DISTINCT:**

```sql
SELECT DISTINCT id_user_type
FROM system_user;
```

`DISTINCT` colapsa filas identicas en el resultado. Si 50 usuarios tienen el mismo `id_user_type`, en el resultado aparece una sola vez.

---

## WHERE y Operadores

`WHERE` es el filtro de SQL. Solo pasan al resultado las filas que cumplen la condicion.

```sql
SELECT columnas
FROM tabla
WHERE condicion;
```

### Operadores de Comparacion

| Operador | Significado | Ejemplo |
|----------|------------|---------|
| `=` | Igual a | `WHERE name = 'Ana'` |
| `!=` o `<>` | Distinto de | `WHERE estado <> 'inactivo'` |
| `<` | Menor a | `WHERE precio < 100` |
| `>` | Mayor a | `WHERE salario > 50000` |
| `<=` | Menor o igual | `WHERE edad <= 18` |
| `>=` | Mayor o igual | `WHERE nivel >= 14` |

### BETWEEN

Filtra un rango **inclusivo** (incluye ambos extremos):

```sql
SELECT * FROM game WHERE level BETWEEN 5 AND 10;

-- Con fechas:
SELECT * FROM commentary WHERE year BETWEEN 2015 AND 2019;
```

### LIKE, ILIKE y Comodines

`LIKE` busca patrones dentro de texto. `ILIKE` es la version **case-insensitive** de PostgreSQL (MySQL ya es insensible por defecto).

| Comodin | Significado | Ejemplo |
|---------|------------|---------|
| `%` | Cualquier cantidad de caracteres | `'Gran%'` → "Gran Turismo", "Grand Theft Auto" |
| `_` | Exactamente un caracter | `'_uan'` → "Juan", "Luan" |

```sql
-- Juegos que empiezan con 'Gran' (sensible a mayusculas)
SELECT * FROM game WHERE name LIKE 'Gran%';

-- Lo mismo pero ignorando mayusculas (PostgreSQL)
SELECT * FROM game WHERE name ILIKE 'gran%';

-- Nombres que contienen 'field'
SELECT * FROM game WHERE name LIKE '%field%';

-- Exactamente 3 caracteres
SELECT * FROM employees WHERE code LIKE '___';
```

> **Rendimiento:** `LIKE '%texto%'` (con `%` al principio) **no puede usar indices**. Escanea toda la tabla. Para busquedas de texto a escala, considerar indices de texto completo o extensiones como `pg_trgm`.

### IN

Filtra filas que coinciden con cualquiera de los valores de una lista:

```sql
SELECT * FROM game
WHERE name IN ('Riders Republic', 'The Dark Pictures: House Of Ashes');
```

### IS NULL / IS NOT NULL

`NULL` es ausencia de dato. **No se puede comparar con `=`**:

```sql
-- INCORRECTO:
SELECT * FROM employees WHERE department = NULL;

-- CORRECTO:
SELECT * FROM employees WHERE department IS NULL;
SELECT * FROM employees WHERE department IS NOT NULL;
```

### AND, OR, NOT

```sql
-- Juegos de nivel 1 a 5 del genero 'RPG'
SELECT * FROM game
WHERE level BETWEEN 1 AND 5
  AND genre = 'RPG';

-- Juegos de nivel 1 o de nivel 14 en adelante
SELECT * FROM game
WHERE level = 1
   OR level >= 14;

-- Juegos que no son de nivel 0
SELECT * FROM game WHERE NOT level = 0;
```

> Usa siempre **parentesis** cuando mezcles `AND` y `OR`. `AND` tiene mayor precedencia que `OR` y puede darte resultados inesperados si no los usas.

---

## Fundamentos DDL: CREATE, ALTER, DROP

**DDL** (Data Definition Language) son las sentencias que crean y modifican la **estructura** de la base de datos, no los datos en si.

### CREATE TABLE

```sql
CREATE TABLE employees (
    employee_id   INT           PRIMARY KEY,
    first_name    VARCHAR(50)   NOT NULL,
    last_name     VARCHAR(50)   NOT NULL,
    email         VARCHAR(200)  UNIQUE NOT NULL,
    hire_date     DATE          NOT NULL,
    salary        DECIMAL(10,2) NOT NULL,
    department_id INT           REFERENCES departments(department_id)
);
```

### ALTER TABLE

Modifica una tabla que ya existe:

```sql
-- Agregar una columna
ALTER TABLE employees ADD COLUMN phone VARCHAR(20);

-- Cambiar el tipo de una columna (PostgreSQL)
ALTER TABLE employees ALTER COLUMN phone TYPE VARCHAR(30);

-- Renombrar una columna
ALTER TABLE employees RENAME COLUMN phone TO phone_number;

-- Eliminar una columna
ALTER TABLE employees DROP COLUMN phone_number;
```

### DROP TABLE

Elimina la tabla **y todos sus datos**. No hay vuelta atras:

```sql
DROP TABLE employees;

-- Version segura (no falla si no existe):
DROP TABLE IF EXISTS employees;
```

---

## Constraints (Restricciones)

Los constraints son **reglas** que la base de datos aplica automaticamente para garantizar la integridad de los datos.

| Constraint | Descripcion | Ejemplo |
|------------|-------------|---------|
| `PRIMARY KEY` | Identifica cada fila de forma unica. No puede ser NULL ni repetirse | `id INT PRIMARY KEY` |
| `NOT NULL` | El campo no puede quedar vacio | `name VARCHAR(100) NOT NULL` |
| `UNIQUE` | Los valores no pueden repetirse (puede haber NULL) | `email VARCHAR(200) UNIQUE` |
| `FOREIGN KEY` | Apunta a la PK de otra tabla. Garantiza integridad referencial | `REFERENCES clientes(id)` |
| `CHECK` | El valor debe cumplir una condicion | `CHECK (score BETWEEN 1 AND 5)` |
| `DEFAULT` | Valor por defecto si no se especifica uno | `DEFAULT NOW()` |

```sql
CREATE TABLE evaluations (
    eval_id     INT           PRIMARY KEY,
    employee_id INT           NOT NULL REFERENCES employees(employee_id),
    eval_date   DATE          NOT NULL DEFAULT CURRENT_DATE,
    score       TINYINT       NOT NULL CHECK (score BETWEEN 1 AND 5),
    comments    VARCHAR(400)
);
```

### Agregar constraints a tablas existentes

```sql
-- Agregar una clave foranea
ALTER TABLE employees
ADD CONSTRAINT fk_dept
FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- Agregar un CHECK
ALTER TABLE employees
ADD CONSTRAINT chk_salary CHECK (salary > 0);

-- Eliminar un constraint
ALTER TABLE employees DROP CONSTRAINT chk_salary;
```

---

## Migraciones y ALTER TABLE Seguras

En produccion, modificar una tabla con millones de filas puede **bloquear** toda la aplicacion. Buenas practicas:

### 1. Agregar columnas con DEFAULT antes de NOT NULL

```sql
-- MAL: Bloquea la tabla mientras rellena millones de filas
ALTER TABLE orders ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'pending';

-- BIEN: Primero agregar nullable, luego poblar, luego aplicar NOT NULL
ALTER TABLE orders ADD COLUMN status VARCHAR(20);
UPDATE orders SET status = 'pending' WHERE status IS NULL;
ALTER TABLE orders ALTER COLUMN status SET NOT NULL;
```

### 2. Renombrar en lugar de borrar y recrear

```sql
-- Menos riesgo que DROP + CREATE
ALTER TABLE products RENAME COLUMN prize TO price;
```

### 3. Probar siempre en un entorno de desarrollo antes

Las operaciones DDL en la mayoria de los motores **no se pueden deshacer con ROLLBACK** (son auto-commit). Hacerlas en dev primero es obligatorio.

### 4. Considerar migraciones con herramientas

En proyectos reales se usan herramientas como **Flyway**, **Liquibase** o **Alembic** para versionar y aplicar cambios de esquema de forma controlada.

---

## UNION y UNION ALL

`UNION` y `UNION ALL` permiten **combinar los resultados de dos o mas consultas SELECT** en un solo resultado.

**Reglas:**
- Ambas consultas deben tener el **mismo numero de columnas**
- Las columnas deben tener **tipos de datos compatibles**
- Los nombres de columna del resultado son los de la **primera consulta**

### UNION (sin duplicados)

Combina resultados y **elimina duplicados**:

```sql
SELECT first_name, last_name FROM employees_2023
UNION
SELECT first_name, last_name FROM employees_2024;
```

### UNION ALL (con duplicados)

Combina resultados **sin eliminar duplicados**. Es mas rapido porque no tiene que comparar filas:

```sql
SELECT product_id, amount FROM sales_q1
UNION ALL
SELECT product_id, amount FROM sales_q2;
```

### Cuando usar cada uno

| | `UNION` | `UNION ALL` |
|--|---------|------------|
| **Elimina duplicados** | Si | No |
| **Velocidad** | Mas lento (ordena para deduplicar) | Mas rapido |
| **Cuando usarlo** | Cuando los duplicados son un problema real | Cuando los duplicados son validos o no importan |

> **Buena practica:** Prefiere `UNION ALL` por defecto. Si necesitas eliminar duplicados, aplica `DISTINCT` o un `GROUP BY` luego, con mas control sobre el resultado.

### Combinando con ORDER BY

El `ORDER BY` va **al final**, aplica sobre el resultado completo:

```sql
SELECT name, 'activo' AS estado FROM clientes_activos
UNION ALL
SELECT name, 'inactivo' AS estado FROM clientes_inactivos
ORDER BY name;
```

---

## EXPLAIN y Rendimiento de UNION

`EXPLAIN` muestra el **plan de ejecucion** que la base de datos usa para resolver una consulta. Es la herramienta principal para detectar problemas de rendimiento.

```sql
EXPLAIN SELECT * FROM game WHERE name LIKE '%field%';
```

```sql
-- Con ANALYZE ejecuta la consulta y muestra tiempos reales (PostgreSQL):
EXPLAIN ANALYZE SELECT * FROM game WHERE name LIKE '%field%';
```

### Que mirar en un plan de ejecucion

| Termino | Significado | Señal de alarma |
|---------|------------|-----------------|
| `Seq Scan` | Escaneo secuencial (lee toda la tabla) | En tablas grandes sin indice |
| `Index Scan` | Uso de indice (rapido) | Esperado y bueno |
| `Hash Join` | Join usando tabla hash en memoria | Costoso si la tabla es enorme |
| `Nested Loop` | Join con bucle anidado | Lento en grandes volumenes sin indice |
| `cost=X..Y` | Costo estimado (menor = mejor) | Comparar antes y despues de optimizar |

### EXPLAIN con UNION

```sql
EXPLAIN
SELECT employee_id FROM employees_2023
UNION ALL
SELECT employee_id FROM employees_2024;
```

`UNION ALL` generalmente produce un plan mas simple (Append) que `UNION` (que agrega un paso de HashAggregate o Sort para deduplicar).

---

## Subconsultas

Una **subconsulta** (subquery) es una consulta SQL dentro de otra consulta. Permite usar el resultado de una consulta como insumo de otra.

### Subconsulta en WHERE

```sql
-- Empleados que ganan mas que el promedio
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

### Subconsulta en FROM (tabla derivada)

```sql
-- Promedio de ventas por vendedor, luego filtrar los que superan 1000
SELECT vendedor, promedio
FROM (
    SELECT vendedor, AVG(monto) AS promedio
    FROM ventas
    GROUP BY vendedor
) AS resumen
WHERE promedio > 1000;
```

### Subconsulta con IN

```sql
-- Empleados que lideran algun proyecto
SELECT first_name, last_name
FROM employees
WHERE employee_id IN (
    SELECT leader_employee_id FROM projects WHERE leader_employee_id IS NOT NULL
);
```

### Cuando usar subconsultas

| Situacion | Recomendacion |
|-----------|--------------|
| Resultado de agregacion como filtro | Subconsulta en `WHERE` |
| Tabla intermedia para simplificar logica | Subconsulta en `FROM` |
| Lista de valores dinamica | Subconsulta con `IN` |
| Logica compleja reutilizable | Usar CTE (`WITH`) en su lugar |

---

## Subconsultas Correlacionadas

Una subconsulta **correlacionada** hace referencia a columnas de la consulta exterior. Se ejecuta **una vez por cada fila** de la consulta exterior (puede ser lenta si la tabla es grande).

```sql
-- Para cada empleado, mostrar si su salario supera el promedio de su departamento
SELECT
    e.first_name,
    e.salary,
    e.department_id,
    (SELECT AVG(e2.salary)
     FROM employees e2
     WHERE e2.department_id = e.department_id) AS avg_dept_salary
FROM employees e;
```

En este ejemplo, la subconsulta interior usa `e.department_id` de la consulta exterior. Por eso se llama "correlacionada": esta atada a cada fila del exterior.

### Alternativa mas eficiente: JOIN con subconsulta

```sql
-- Equivalente pero mas eficiente (calcula el promedio una sola vez por depto)
SELECT
    e.first_name,
    e.salary,
    e.department_id,
    dept_avg.avg_salary
FROM employees e
JOIN (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) AS dept_avg ON e.department_id = dept_avg.department_id;
```

---

## CTE (WITH) y LATERAL

### CTE - Common Table Expressions

Una **CTE** es como darle un nombre a una subconsulta para reutilizarla. Mejora la legibilidad enormemente.

```sql
WITH empleados_senior AS (
    SELECT employee_id, first_name, salary, department_id
    FROM employees
    WHERE hire_date < '2020-01-01'
),
promedio_por_dept AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM empleados_senior
    GROUP BY department_id
)
SELECT
    e.first_name,
    e.salary,
    p.avg_salary
FROM empleados_senior e
JOIN promedio_por_dept p ON e.department_id = p.department_id
WHERE e.salary > p.avg_salary;
```

**Ventajas de CTE sobre subconsultas:**
- Mas legible: cada bloque tiene un nombre descriptivo
- Reutilizable: podes referenciar el mismo CTE varias veces en la consulta
- Facilita el debugging: podes probar cada bloque por separado

### CTEs Recursivos

Permiten hacer consultas sobre estructuras jerarquicas (organigramas, categorias anidadas):

```sql
WITH RECURSIVE jerarquia AS (
    -- Caso base: el CEO (sin jefe)
    SELECT employee_id, first_name, manager_id, 0 AS nivel
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Caso recursivo: los que reportan a alguien del nivel anterior
    SELECT e.employee_id, e.first_name, e.manager_id, j.nivel + 1
    FROM employees e
    JOIN jerarquia j ON e.manager_id = j.employee_id
)
SELECT * FROM jerarquia ORDER BY nivel, first_name;
```

### LATERAL (PostgreSQL)

`LATERAL` permite que una subconsulta en el `FROM` haga referencia a columnas de tablas anteriores de la misma clausula `FROM`. Es como un `JOIN` que puede ser una subconsulta correlacionada.

```sql
-- Para cada empleado, traer sus ultimas 3 evaluaciones
SELECT e.first_name, eval.eval_date, eval.score
FROM employees e,
LATERAL (
    SELECT eval_date, score
    FROM evaluations
    WHERE employee_id = e.employee_id
    ORDER BY eval_date DESC
    LIMIT 3
) AS eval;
```

Sin `LATERAL`, esta consulta no seria posible en un solo `FROM` porque la subconsulta necesita referenciar `e.employee_id`.

---

## Indices y Estrategias para Busquedas por Patron

Un **indice** es una estructura auxiliar que permite encontrar filas rapidamente sin escanear toda la tabla. Como el indice de un libro.

### Crear un indice basico

```sql
-- Indice en una columna
CREATE INDEX idx_employees_dept ON employees(department_id);

-- Indice en multiples columnas (compuesto)
CREATE INDEX idx_employees_dept_salary ON employees(department_id, salary);

-- Indice unico (equivale a un constraint UNIQUE)
CREATE UNIQUE INDEX idx_employees_email ON employees(email);
```

### Indices para busquedas con LIKE

El problema: `LIKE '%texto%'` (con `%` al inicio) **no puede usar indices** B-tree convencionales porque no sabe por donde empezar a buscar.

**Estrategia 1: Solo `%` al final (puede usar indice B-tree)**

```sql
-- Esto SI usa el indice:
SELECT * FROM game WHERE name LIKE 'Gran%';

-- Esto NO usa el indice:
SELECT * FROM game WHERE name LIKE '%field%';
```

**Estrategia 2: Indice de trigrama en PostgreSQL (`pg_trgm`)**

```sql
-- Habilitar la extension
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Crear indice GIN de trigrama
CREATE INDEX idx_game_name_trgm ON game USING gin(name gin_trgm_ops);

-- Ahora LIKE '%field%' e ILIKE '%field%' pueden usar el indice
SELECT * FROM game WHERE name ILIKE '%field%';
```

**Estrategia 3: Full Text Search**

Para busquedas de texto complejas en produccion, usar full text search en lugar de LIKE:

```sql
-- PostgreSQL
SELECT * FROM articles
WHERE to_tsvector('spanish', content) @@ to_tsquery('spanish', 'base & datos');
```

---

## Patrones y Anti-Patrones al Anidar Consultas

### Patrones recomendados

**1. CTE en lugar de subconsultas anidadas profundas**

```sql
-- DIFICIL de leer (anti-patron):
SELECT * FROM (SELECT * FROM (SELECT * FROM ventas WHERE monto > 100) t1 WHERE fecha > '2024-01-01') t2 WHERE vendedor = 'Ana';

-- MEJOR con CTE:
WITH ventas_filtradas AS (
    SELECT * FROM ventas WHERE monto > 100
),
ventas_recientes AS (
    SELECT * FROM ventas_filtradas WHERE fecha > '2024-01-01'
)
SELECT * FROM ventas_recientes WHERE vendedor = 'Ana';
```

**2. JOIN en lugar de subconsulta correlacionada**

```sql
-- LENTO (subconsulta correlacionada - se ejecuta por cada fila):
SELECT name FROM game g
WHERE (SELECT COUNT(*) FROM commentary c WHERE c.id_game = g.id_game) > 5;

-- RAPIDO (JOIN con GROUP BY - una sola pasada):
SELECT g.name
FROM game g
JOIN commentary c ON c.id_game = g.id_game
GROUP BY g.id_game, g.name
HAVING COUNT(*) > 5;
```

### Anti-Patrones a Evitar

| Anti-patron | Problema | Solucion |
|-------------|---------|---------|
| `SELECT *` en produccion | Trae columnas innecesarias, consume mas red y memoria | Especificar solo las columnas necesarias |
| Subconsulta correlacionada en SELECT | Se ejecuta N veces (una por fila) | Reemplazar con JOIN o CTE |
| `UNION` cuando los duplicados no importan | Agrega un paso de deduplicacion costoso | Usar `UNION ALL` |
| `LIKE '%texto%'` en columnas grandes sin indice de trigrama | Escaneo secuencial completo | Agregar indice `pg_trgm` o usar full text search |
| Anidar 3+ subconsultas | Ilegible y dificil de debuggear | Usar CTEs |
| `NOT IN` con subconsulta que puede devolver NULL | Resultado siempre vacio si hay un NULL | Usar `NOT EXISTS` en su lugar |

**El caso especial de NOT IN con NULL:**

```sql
-- Esto puede fallar silenciosamente si la subconsulta devuelve algún NULL:
SELECT * FROM employees
WHERE department_id NOT IN (SELECT department_id FROM departments_cerrados);

-- Mejor usar NOT EXISTS:
SELECT * FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM departments_cerrados d
    WHERE d.department_id = e.department_id
);
```

---

## Buenas Practicas al Combinar Resultados

1. **Verificar que las columnas sean compatibles** antes de hacer UNION. Un `INT` y un `VARCHAR` en la misma posicion puede causar errores o conversiones implicitas.

2. **Poner alias descriptivos en la primera query del UNION**, ya que son los que aparecen en el resultado final:

```sql
SELECT name AS nombre_juego, 'activo' AS estado FROM games_activos
UNION ALL
SELECT name, 'archivado' AS estado FROM games_archivados;
```

3. **Usar CTE para hacer el UNION legible** cuando son muchas fuentes:

```sql
WITH activos AS (SELECT id, name FROM games WHERE active = TRUE),
     archivados AS (SELECT id, name FROM games_archive)
SELECT * FROM activos
UNION ALL
SELECT * FROM archivados;
```

4. **Agregar una columna de origen** para saber de donde viene cada fila:

```sql
SELECT id, name, 'ventas_2023' AS origen FROM ventas_2023
UNION ALL
SELECT id, name, 'ventas_2024' AS origen FROM ventas_2024;
```

5. **Nunca asumir el orden de UNION sin ORDER BY.** El motor puede devolver las filas en cualquier orden.

---

## Resumen General

| Concepto | ¿Que es? | Clave |
|----------|---------|-------|
| **OLTP** | Esquema para transacciones en tiempo real | Normalizado, muchas tablas |
| **OLAP** | Esquema para analisis historico | Desnormalizado, esquema estrella |
| **Tipos de datos** | Clasificacion de cada columna | Elegir el tipo mas chico y preciso posible |
| **SELECT / FROM** | Consulta basica | `SELECT campos FROM tabla` |
| **DISTINCT** | Eliminar duplicados | Agregar antes de los campos |
| **WHERE** | Filtrar filas | Antes de GROUP BY |
| **LIKE / ILIKE** | Busqueda por patron | `%` = varios chars, `_` = uno |
| **DDL** | Crear/modificar estructura | CREATE, ALTER, DROP |
| **Constraints** | Reglas de integridad | PK, FK, UNIQUE, CHECK, NOT NULL |
| **UNION / UNION ALL** | Combinar resultados | ALL es mas rapido |
| **EXPLAIN** | Ver plan de ejecucion | Buscar Seq Scan en tablas grandes |
| **Subconsultas** | Query dentro de query | Preferir JOIN o CTE cuando sea posible |
| **CTE (WITH)** | Subconsulta con nombre | Mas legible y reutilizable |
| **LATERAL** | Subconsulta correlacionada en FROM | PostgreSQL, para top-N por grupo |
| **Indices** | Estructura para busqueda rapida | `pg_trgm` para LIKE con % al inicio |
