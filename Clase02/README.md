# Clase 02 - Sentencias y Sublenguajes SQL

## ¿Que es SQL?

SQL (Structured Query Language) es un lenguaje de consultas estructuradas que permite **acceder y manipular bases de datos**. Es popular por su facilidad de uso y efectividad para convertir grandes volumenes de datos en informacion util.

A diferencia de lenguajes de programacion como Python o Java, SQL es **declarativo**: le dices *que* queres obtener, no *como* obtenerlo paso a paso.

---

## ¿Que podemos hacer con SQL?

| Accion | Descripcion |
|--------|-------------|
| **Consultar datos** | Ejecutar consultas para recuperar informacion especifica |
| **Modificar registros** | Insertar, actualizar y eliminar datos |
| **Crear objetos** | Crear bases de datos, tablas, procedimientos o vistas |
| **Controlar accesos** | Establecer permisos en tablas, procedimientos y vistas |

---

## Mapa de Conceptos - Lenguaje SQL

| Componente | Descripcion | Ejemplos |
|------------|-------------|---------|
| **Sentencias** | Instrucciones que se le dan a la base de datos | `SELECT`, `FROM`, `DISTINCT`, `WHERE` |
| **Tipos de datos** | Clasificacion del tipo de informacion en cada columna | String, Boolean, Numeric |
| **Operadores** | Simbolos para comparar o combinar condiciones | `=`, `<`, `>`, `IN`, `LIKE` |

---

## Aclaraciones sobre la Sintaxis

- Las sentencias SQL **no son sensibles a mayusculas y minusculas**, aunque se recomienda respetar el nombre exacto de campos y tablas.
- Cada sistema de bases de datos puede tener **particularidades sintacticas** (MySQL, PostgreSQL, SQL Server, etc.), pero la base es la misma.
- Cada consulta finaliza con **punto y coma** (`;`).

---

## Consulta de Seleccion: SELECT y FROM

### ¿Para que sirven?

- **SELECT**: selecciona los campos (columnas) que queres visualizar en el resultado.
- **FROM**: declara la tabla desde la cual se extrae la informacion.

### Sintaxis basica

```sql
SELECT campo1, campo2
FROM nombre_tabla;
```

### Variantes principales

**Seleccionar campos especificos:**

```sql
SELECT id_class, description
FROM class;
```

El orden de los campos en el `SELECT` define el orden en que apareceran en el resultado, independientemente de como esten definidos en la tabla.

**Seleccionar todos los campos:**

```sql
SELECT *
FROM system_user;
```

El asterisco (`*`) es un comodin que representa "todos los campos" de la tabla.

**Seleccionar sin repetidos (DISTINCT):**

```sql
SELECT DISTINCT id_user_type
FROM system_user;
```

`DISTINCT` elimina los valores duplicados del resultado. Si diez usuarios tienen el mismo tipo, solo aparece una vez.

---

## Sentencia WHERE

`WHERE` es el **filtro** de SQL. Sin el, la consulta devuelve todas las filas de la tabla. Con `WHERE`, solo se muestran las filas que cumplen la condicion indicada.

### Sintaxis basica

```sql
SELECT columnas
FROM tabla
WHERE condicion;
```

### Ejemplos practicos (tabla `system_user`)

```sql
-- Usuarios con un nombre especifico
SELECT * FROM system_user WHERE first_name = 'Gillie';

-- Nombre y apellido de usuarios de un tipo especifico
SELECT first_name, last_name FROM system_user WHERE id_user_type = 334;

-- Un usuario especifico por su ID
SELECT first_name, last_name FROM system_user WHERE id_system_user = 56;
```

---

## Operadores de Comparacion

Son los simbolos que se usan para comparar valores dentro de un `WHERE`:

| Operador | Significado | Ejemplo |
|----------|------------|---------|
| `=` | Igual a | `WHERE first_name = 'Ana'` |
| `!=` o `<>` | Distinto de | `WHERE estado <> 'inactivo'` |
| `<` | Menor a | `WHERE precio < 100` |
| `>` | Mayor a | `WHERE salario > 50000` |
| `<=` | Menor o igual a | `WHERE edad <= 18` |
| `>=` o `=>` | Mayor o igual a | `WHERE nivel >= 14` |

---

## Operadores Especiales

### BETWEEN (entre dos valores)

Filtra valores dentro de un rango **inclusivo** (incluye ambos extremos):

```sql
-- Juegos de nivel entre 5 y 10 (incluidos)
SELECT * FROM game WHERE level BETWEEN 5 AND 10;

-- Comentarios desde 2019 en adelante
SELECT * FROM commentary WHERE year >= 2019;
```

### LIKE (patron de texto)

Busca patrones dentro de textos. Usa dos comodines:

| Comodin | Significado | Ejemplo |
|---------|------------|---------|
| `%` | Cualquier cantidad de caracteres | `'Gran%'` encuentra "Gran Turismo", "Grand Theft Auto" |
| `_` | Exactamente un caracter | `'_uan'` encuentra "Juan", "Luan" |

```sql
-- Juegos cuyo nombre empiece con 'Gran'
SELECT * FROM game WHERE name LIKE 'Gran%';

-- Juegos cuyo nombre contenga 'field'
SELECT * FROM game WHERE name LIKE '%field%';
```

### IN (pertenece a una lista)

Filtra filas que coinciden con **cualquiera de los valores** de una lista:

```sql
-- Juegos de nombre especifico
SELECT * FROM game
WHERE name IN ('Riders Republic', 'The Dark Pictures: House Of Ashes');
```

Es equivalente a usar varios `OR`, pero mas limpio:

```sql
-- Esto es lo mismo, pero mas verboso:
WHERE name = 'Riders Republic' OR name = 'The Dark Pictures: House Of Ashes'
```

### IS NULL / IS NOT NULL (valores vacios)

`NULL` significa **ausencia de dato** (no es cero ni texto vacio). Para comparar con `NULL` **no se puede usar `=`**:

```sql
-- INCORRECTO:
SELECT * FROM game WHERE description = NULL;

-- CORRECTO:
SELECT * FROM game WHERE description IS NULL;
SELECT * FROM game WHERE description IS NOT NULL;
```

---

## Operadores Logicos: AND, OR, NOT

Permiten combinar multiples condiciones en un mismo `WHERE`:

| Operador | Significado | Descripcion |
|----------|------------|-------------|
| `AND` | Y logico | Ambas condiciones deben cumplirse |
| `OR` | O logico | Al menos una condicion debe cumplirse |
| `NOT` | Negacion | Invierte el resultado de la condicion |

```sql
-- Comentarios de juegos con id_game = 73
SELECT user, text FROM commentary WHERE id_game = 73;

-- Comentarios de juegos que NO son id_game = 73
SELECT user, text FROM commentary WHERE id_game != 73;

-- Juegos de nivel 1
SELECT * FROM game WHERE level = 1;

-- Juegos de nivel 14 o superior
SELECT * FROM game WHERE level >= 14;
```

> **Tip:** Cuando combines `AND` y `OR` en la misma consulta, usa **parentesis** para dejar claro el orden de evaluacion. `AND` se evalua antes que `OR` si no usas parentesis.

```sql
SELECT * FROM game
WHERE (level = 1 OR level = 14)
  AND name LIKE 'Gran%';
```

---

## Tabla de Operadores - Resumen Completo

| Operador | Uso | Ejemplo |
|----------|-----|---------|
| `=` | Igualdad exacta | `WHERE name = 'Ana'` |
| `!=` o `<>` | Diferente | `WHERE level <> 0` |
| `<`, `>`, `<=`, `>=` | Comparacion numerica o de fecha | `WHERE year >= 2019` |
| `BETWEEN` | Rango inclusivo | `WHERE level BETWEEN 5 AND 10` |
| `LIKE` | Patron de texto | `WHERE name LIKE 'Gran%'` |
| `IN` | Inclusion en lista | `WHERE name IN ('Juego A', 'Juego B')` |
| `IS NULL` | Campo sin valor | `WHERE description IS NULL` |
| `IS NOT NULL` | Campo con valor | `WHERE description IS NOT NULL` |
| `AND` | Ambas condiciones | `WHERE level = 1 AND active = 1` |
| `OR` | Al menos una | `WHERE level = 1 OR level = 14` |
| `NOT` | Negacion | `WHERE NOT level = 0` |

---

## Para Pensar

> Si necesitas guardar el **DNI o Cedula de identidad** de una persona, ¿que tipo de dato usarias: numerico o string?
>
> **Respuesta:** String (`VARCHAR`). Aunque el DNI parezca un numero, no se hacen operaciones matematicas con el (no se suma ni se promedia). Ademas, en algunos paises los DNI pueden tener letras o ceros a la izquierda que un tipo numerico descartaria. Cuando algo "parece" un numero pero no se opera matematicamente, se guarda como texto.
