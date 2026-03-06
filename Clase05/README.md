# Clase 05 — DML: INSERT, UPDATE, DELETE + Subconsultas

Base de datos: `musica` (MySQL)
Tablas: `artistas`, `canciones`, `listas`, `lista_canciones`

---

## Repaso rápido

Antes de arrancar con el tema nuevo, recordamos los conceptos clave de las clases anteriores:

| Concepto       | Qué hace                                              |
|----------------|-------------------------------------------------------|
| `SELECT`       | Consulta datos                                        |
| `WHERE`        | Filtra filas por condición                            |
| `JOIN`         | Une dos tablas por una columna en común               |
| `CREATE VIEW`  | Guarda una consulta con nombre (clase 04)             |
| `ORDER BY`     | Ordena el resultado                                   |
| `IS NULL`      | Filtra filas sin valor                                |

---

## 1. INSERT

`INSERT` agrega nuevos registros a una tabla. Tiene tres formas principales.

### 1a — INSERT completo (sin especificar columnas)

```sql
INSERT INTO artistas
VALUES (6, 'AC/DC', 'Australia', 'Hard Rock', 1973);
```

- El orden de los valores debe coincidir **exactamente** con la definición de la tabla.
- Si la tabla cambia de estructura, esta forma puede fallar o insertar datos en columnas equivocadas.

### 1b — INSERT parcial (especificando columnas)

```sql
INSERT INTO canciones (id_artista, titulo, reproducciones)
VALUES (6, 'Highway to Hell', 890000000);
```

- Solo llenamos las columnas que nos interesan.
- Las columnas omitidas quedan en `NULL` o toman su valor `DEFAULT`.
- Es la forma **más segura y recomendada**.

### 1c — INSERT de múltiples filas

```sql
INSERT INTO canciones (id_artista, titulo, duracion_seg, reproducciones, precio)
VALUES
    (6, 'Back in Black',  4*60+15, 1400000000, 1.29),
    (6, 'Thunderstruck',  4*60+52, 1600000000, 1.29),
    (6, 'T.N.T.',         3*60+35, 650000000,  1.29);
```

- Separamos cada fila con una coma.
- Mucho más eficiente que ejecutar un `INSERT` por cada fila.
- MySQL puede resolver expresiones como `4*60+15` directamente.

---

## 2. UPDATE

`UPDATE` modifica registros existentes.

```
UPDATE tabla
SET columna = nuevo_valor
WHERE condicion;
```

> **Regla de oro:** escribir siempre el `WHERE` primero. Un `UPDATE` sin `WHERE` modifica **todos** los registros de la tabla.

### UPDATE de un registro

```sql
UPDATE canciones
SET precio = 1.29
WHERE id_cancion = 21;
```

### UPDATE de múltiples columnas

```sql
UPDATE canciones
SET duracion_seg   = 3*60+28,
    reproducciones = 920000000
WHERE id_cancion = 21;
```

- Separamos cada columna con una coma dentro del `SET`.

### UPDATE masivo (afecta varios registros)

```sql
UPDATE canciones
SET precio = ROUND(precio * 0.80, 2)
WHERE precio > 1.00;
```

- El `WHERE` filtra qué filas se modifican.
- Se pueden usar expresiones y funciones dentro del `SET`.

---

## 3. DELETE

`DELETE` elimina registros de una tabla.

```
DELETE FROM tabla
WHERE condicion;
```

> **Atención:** un `DELETE` sin `WHERE` elimina **todos** los registros. Siempre escribir el `WHERE` antes de ejecutar.

### DELETE de un registro

```sql
DELETE FROM canciones
WHERE id_cancion = 24;
```

### DELETE con múltiples condiciones

```sql
DELETE FROM canciones
WHERE id_artista = 6
  AND precio IS NULL;
```

### Error por FOREIGN KEY

Si intentamos eliminar un registro que es referenciado por otra tabla a través de una `FOREIGN KEY`, MySQL lo rechaza:

```sql
-- Esto falla con Error 1451:
DELETE FROM artistas WHERE id_artista = 6;
```

```
Error Code: 1451. Cannot delete or update a parent row:
a foreign key constraint fails
```

**Solución:** primero eliminar los registros hijos, luego el padre.

```sql
DELETE FROM canciones WHERE id_artista = 6;  -- primero los hijos
DELETE FROM artistas  WHERE id_artista = 6;  -- luego el padre
```

---

## 4. TRUNCATE

`TRUNCATE` elimina **todos** los registros de una tabla de golpe.

```sql
TRUNCATE nombre_tabla;
```

| Característica         | `DELETE` sin WHERE         | `TRUNCATE`                   |
|------------------------|----------------------------|------------------------------|
| Velocidad              | Lento (fila por fila)      | Rápido (borra todo de una)   |
| `AUTO_INCREMENT`       | No se reinicia             | Se reinicia desde 1          |
| Se puede hacer rollback| Sí (si hay transacción)    | No en MySQL                  |
| Respeta FK             | Sí                         | No (puede fallar si hay FK)  |

```sql
TRUNCATE temp_log;
-- Luego de insertar, el id vuelve a empezar desde 1
```

---

## 5. DML con Subconsultas

Las subconsultas permiten usar el resultado de un `SELECT` como fuente de datos para un `INSERT`, `UPDATE` o `DELETE`.

```
┌──────────────────────────────────────────────┐
│  UPDATE canciones                            │
│  SET precio = 0.99                           │
│  WHERE id_artista IN (                       │
│      SELECT id_artista    ← subconsulta      │
│      FROM artistas                           │
│      WHERE pais = 'Reino Unido'              │
│  );                                          │
└──────────────────────────────────────────────┘
```

### INSERT + subconsulta

Poblar una tabla usando el resultado de un `SELECT`:

```sql
INSERT INTO lista_canciones (id_lista, id_cancion)
SELECT 3, id_cancion
FROM canciones
ORDER BY reproducciones DESC
LIMIT 5;
```

- No se usan `VALUES`: el `SELECT` reemplaza la lista de valores.
- Las columnas del `SELECT` deben coincidir en cantidad y tipo con las del `INSERT`.

### UPDATE + subconsulta

Actualizar filas usando una condición basada en otra tabla:

```sql
UPDATE canciones
SET precio = 0.99
WHERE id_artista IN (
    SELECT id_artista
    FROM artistas
    WHERE pais = 'Reino Unido'
);
```

- La subconsulta devuelve una lista de valores que el `IN` usa como filtro.

### DELETE + subconsulta

Eliminar filas cuya condición depende de otra tabla:

```sql
DELETE FROM lista_canciones
WHERE id_lista = 3
  AND id_cancion IN (
      SELECT id_cancion
      FROM canciones
      WHERE precio IS NULL
  );
```

- Combinamos `DELETE` con `IN` + subconsulta para filtrar dinámicamente qué filas borrar.
- Equivalente al `NOT IN` con subconsulta para excluir registros no relacionados.

---

## Resumen de sentencias DML

| Sentencia  | Para qué sirve              | Riesgo sin WHERE              |
|------------|-----------------------------|-------------------------------|
| `INSERT`   | Agregar registros           | N/A (no tiene WHERE)          |
| `UPDATE`   | Modificar registros         | Modifica **todos** los registros |
| `DELETE`   | Eliminar registros          | Elimina **todos** los registros  |
| `TRUNCATE` | Vaciar una tabla completa   | Siempre borra todo            |

## Orden de ejecución recomendado al escribir UPDATE / DELETE

```
1. Escribir el WHERE primero
2. Probar con SELECT para verificar qué filas afecta
3. Recién entonces ejecutar el UPDATE o DELETE
```

```sql
-- Antes de hacer el DELETE, verificar con SELECT:
SELECT * FROM canciones WHERE id_artista = 6 AND precio IS NULL;

-- Si el resultado es el esperado, ejecutar el DELETE:
DELETE FROM canciones WHERE id_artista = 6 AND precio IS NULL;
```
