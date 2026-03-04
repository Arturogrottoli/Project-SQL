# Clase 04 — Repaso + Vistas

Base de datos: `musica` (MySQL)
Tablas: `artistas`, `canciones`

---

## 1. Crear y seleccionar la base de datos

```sql
DROP DATABASE IF EXISTS musica;
CREATE DATABASE musica;
USE musica;
```

- `DROP DATABASE IF EXISTS` elimina la base si ya existe, para poder re-ejecutar el script sin errores.
- `CREATE DATABASE` crea la base.
- `USE` la selecciona como activa para todas las operaciones siguientes.

---

## 2. Crear tablas (DDL)

```sql
CREATE TABLE artistas (
    id_artista  INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    pais        VARCHAR(50),
    genero      VARCHAR(50),
    anio_debut  INT
);
```

Constraints usados:

| Constraint        | Significado                                      |
|-------------------|--------------------------------------------------|
| `PRIMARY KEY`     | Identifica cada fila de forma única              |
| `AUTO_INCREMENT`  | El valor se genera solo (1, 2, 3...)             |
| `NOT NULL`        | El campo no puede quedar vacío                   |
| `FOREIGN KEY`     | Conecta una columna con la PK de otra tabla      |

---

## 3. Insertar datos (DML)

### Forma 1 — especificando columnas (recomendada)

```sql
INSERT INTO artistas (nombre, pais, genero, anio_debut)
VALUES ('Nirvana', 'Estados Unidos', 'Grunge', 1987);
```

- Indicamos explícitamente qué columnas estamos llenando.
- El orden de los valores debe coincidir con el orden de las columnas declaradas.
- Si omitimos una columna con `DEFAULT` o nullable, toma ese valor automáticamente.

### Forma 2 — sin especificar columnas

```sql
INSERT INTO canciones
VALUES (1, 1, 'Smells Like Teen Spirit', 5*60+1, 1800000000, 1.29);
```

- El orden de valores debe coincidir exactamente con la definición de la tabla.
- Si la tabla cambia de estructura, esta forma puede fallar o insertar mal.
- Se puede escribir la duración como `5*60+1` y MySQL resuelve la expresión.

---

## 4. Ver el contenido

```sql
SELECT * FROM artistas;
SELECT * FROM canciones;
```

- `*` trae todas las columnas.
- Se ejecuta una query por tabla para ver qué se insertó.

---

## 5. Filtros (repaso)

### ORDER BY — ordenar resultados

```sql
SELECT titulo, reproducciones FROM canciones ORDER BY reproducciones DESC;
```

- `ASC` = ascendente (A→Z, menor→mayor) — es el valor por defecto.
- `DESC` = descendente (Z→A, mayor→menor).
- Se pueden ordenar por múltiples columnas: `ORDER BY col1 DESC, col2 ASC`.

---

### WHERE — filtrar filas

```sql
SELECT nombre FROM artistas WHERE anio_debut < 1990;
```

| Operador   | Significado       |
|------------|-------------------|
| `=`        | Igual             |
| `<>` / `!=`| Distinto          |
| `<` `>`    | Menor / Mayor     |
| `<=` `>=`  | Menor o igual / Mayor o igual |

---

### BETWEEN — rango de valores

```sql
SELECT titulo FROM canciones WHERE duracion_seg BETWEEN 180 AND 240;
```

- Equivale a `>= 180 AND <= 240` (incluye los extremos).
- Funciona con números, fechas y textos.
- Siempre poner el valor menor primero.

---

### IN — lista de valores posibles

```sql
SELECT nombre FROM artistas WHERE pais IN ('Argentina', 'Reino Unido');
```

- Es una forma más limpia de escribir múltiples `OR`.
- `NOT IN` excluye los valores de la lista.

---

### LIKE — búsqueda por patrón de texto

```sql
SELECT titulo FROM canciones WHERE titulo LIKE 'M%';
SELECT titulo FROM canciones WHERE titulo LIKE '%the%';
```

| Comodín | Significado                          |
|---------|--------------------------------------|
| `%`     | Cualquier cantidad de caracteres     |
| `_`     | Exactamente un carácter              |

- `NOT LIKE` excluye los que coincidan con el patrón.

---

### IS NULL / IS NOT NULL

```sql
SELECT titulo FROM canciones WHERE precio IS NULL;
SELECT titulo FROM canciones WHERE precio IS NOT NULL;
```

- `NULL` significa ausencia de valor (no es 0, no es texto vacío).
- **Nunca usar `= NULL`** — siempre usar `IS NULL`.

---

### DISTINCT — valores únicos

```sql
SELECT DISTINCT genero FROM artistas;
```

- Elimina filas duplicadas del resultado.
- Útil para ver qué valores distintos hay en una columna.

---

### Columnas calculadas

```sql
SELECT
    titulo,
    CONCAT(duracion_seg DIV 60, 'm ', duracion_seg MOD 60, 's') AS duracion,
    ROUND(reproducciones / 1000000, 1) AS reprod_millones,
    ROUND(precio * 1.21, 2)            AS precio_con_iva
FROM canciones;
```

- Las columnas calculadas no se guardan en la tabla, solo aparecen en el resultado.
- `AS` le da un nombre (alias) a la columna calculada.
- `DIV` = división entera. `MOD` = resto de la división.
- `ROUND(valor, decimales)` redondea.
- `CONCAT()` une texto.

---

## 6. Vistas (CREATE VIEW)

Una **vista** es una consulta guardada con nombre. No almacena datos: cada vez que la consultamos, ejecuta la query original sobre los datos actuales.

```
┌─────────────────────────────────────┐
│           CREATE VIEW               │
│                                     │
│  vista = nombre + SELECT guardado   │
│                                     │
│  SELECT * FROM vista                │
│       ↓ ejecuta internamente        │
│  SELECT ... FROM tabla WHERE ...    │
└─────────────────────────────────────┘
```

**Ventajas:**
- Simplifica consultas complejas
- Reutilizamos lógica sin repetir código
- Se puede dar acceso a una vista sin exponer la tabla completa

---

### CREATE VIEW — vista simple (filtro)

```sql
CREATE VIEW vista_bandas_argentinas AS
    SELECT nombre, genero, anio_debut
    FROM artistas
    WHERE pais = 'Argentina';

SELECT * FROM vista_bandas_argentinas;
```

- La vista se consulta igual que una tabla.
- El `WHERE` de la query original se aplica automáticamente.

---

### CREATE VIEW — con columna calculada

```sql
CREATE VIEW vista_canciones_detalle AS
    SELECT
        titulo,
        CONCAT(duracion_seg DIV 60, 'm ', duracion_seg MOD 60, 's') AS duracion,
        ROUND(reproducciones / 1000000, 1) AS reprod_millones,
        precio
    FROM canciones;
```

- La vista expone la columna calculada como si fuera una columna normal.
- Quien consulta la vista no necesita saber cómo se calcula.

---

### CREATE VIEW — combinando tablas (JOIN)

```sql
CREATE VIEW vista_catalogo AS
    SELECT
        c.titulo,
        a.nombre AS artista,
        a.genero,
        c.precio
    FROM canciones c
    JOIN artistas a ON c.id_artista = a.id_artista;
```

- `JOIN` une dos tablas por una columna en común.
- `c.` y `a.` son alias de tabla para distinguir columnas cuando hay dos tablas.
- La vista entrega los datos ya combinados; quien la consulta ve una sola tabla.

```sql
SELECT * FROM vista_catalogo WHERE artista = 'Metallica';
```

---

### CREATE OR REPLACE VIEW — modificar una vista

```sql
CREATE OR REPLACE VIEW vista_bandas_argentinas AS
    SELECT nombre, pais, genero, anio_debut
    FROM artistas
    WHERE pais = 'Argentina';
```

- Reemplaza la vista existente sin necesidad de borrarla primero.
- Útil para agregar o quitar columnas de una vista ya creada.

---

### Ver las vistas de la base de datos

```sql
SHOW FULL TABLES WHERE Table_type = 'VIEW';
```

- Lista todas las vistas (diferenciándolas de las tablas reales).

---

### DROP VIEW — eliminar una vista

```sql
DROP VIEW IF EXISTS vista_bandas_argentinas;
```

- Elimina la vista pero **no afecta las tablas ni los datos originales**.
- `IF EXISTS` evita error si la vista no existe.
