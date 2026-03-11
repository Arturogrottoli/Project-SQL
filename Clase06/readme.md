# Clase 06 — Importación de Datos + Integridad Referencial

Base de datos: `tienda` (MySQL)
Tablas: `paises`, `ciudades`, `clientes`, `productos`, `pedidos`

---

## Repaso rápido

| Concepto       | Qué hace                                              |
|----------------|-------------------------------------------------------|
| `INSERT`       | Agrega nuevos registros                               |
| `UPDATE`       | Modifica registros existentes                         |
| `DELETE`       | Elimina registros (¡siempre con `WHERE`!)             |
| `FOREIGN KEY`  | Relaciona dos tablas por una columna en común         |
| `JOIN`         | Une tablas en una consulta                            |

---

## 1. Importación de datos

Hay dos formas principales de cargar datos masivos en MySQL:

| Método                         | Cómo funciona                                  |
|--------------------------------|------------------------------------------------|
| Asistente de MySQL Workbench   | GUI paso a paso, sin escribir SQL              |
| `LOAD DATA LOCAL INFILE`       | Comando SQL que lee un archivo CSV directamente|

### Proceso con el Asistente de Workbench

1. Exportar la planilla a formato `.csv` (Archivo → Descargar → CSV)
2. Abrir el Asistente de Importación en la tabla destino
3. Seleccionar si importar a tabla existente o crear una nueva
4. El asistente detecta el formato y mapea los campos
5. Validar la vista previa y presionar **Next**
6. Refrescar la tabla para confirmar los datos cargados

> Tip: usar **UTF-8** como encoding para evitar problemas con tildes y ñ.

### LOAD DATA LOCAL INFILE

```sql
LOAD DATA LOCAL INFILE 'C:/datos/productos.csv'
INTO TABLE productos
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS             -- saltea el encabezado del CSV
(nombre, precio, stock);
```

| Cláusula                    | Para qué sirve                              |
|-----------------------------|---------------------------------------------|
| `FIELDS TERMINATED BY ','`  | Separador de columnas (`,` en CSV)          |
| `OPTIONALLY ENCLOSED BY '"'`| Campos con texto entre comillas             |
| `LINES TERMINATED BY '\r\n'`| Fin de línea (Windows usa `\r\n`, Linux `\n`)|
| `IGNORE 1 ROWS`             | Salta la primera fila (encabezado)          |

### Exportar a CSV con SELECT INTO OUTFILE

```sql
SELECT id_producto, nombre, precio, stock
FROM productos
INTO OUTFILE 'C:/datos/exportados.csv'
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';
```

---

## 2. Integridad Referencial

La **integridad referencial** garantiza que las relaciones entre tablas sean consistentes. Se define en la `FOREIGN KEY` usando la cláusula `ON DELETE` y `ON UPDATE`.

```
┌─────────────────────────────────────────────────────────────┐
│  FOREIGN KEY (id_pais)                                      │
│  REFERENCES paises(id_pais)                                 │
│  ON DELETE CASCADE      ← qué hacer si se borra el padre   │
│  ON UPDATE CASCADE      ← qué hacer si cambia la PK padre  │
└─────────────────────────────────────────────────────────────┘
```

### Tipos de restricción

| Restricción      | Al borrar el padre…                                     |
|------------------|---------------------------------------------------------|
| `CASCADE`        | Se borran automáticamente todos los hijos               |
| `SET NULL`       | Los hijos quedan con `NULL` en la FK (columna nullable) |
| `RESTRICT`       | El padre **no se puede borrar** si tiene hijos (error)  |
| `NO ACTION`      | Igual que `RESTRICT` en MySQL                           |
| `SET DEFAULT`    | Pone el valor por defecto (no soportado en InnoDB)      |

---

## 3. ON DELETE CASCADE

El hijo se elimina automáticamente cuando se elimina el padre.

**Caso de uso:** tabla `ciudades` depende de `paises`.
Si se borra un país, no tiene sentido conservar las ciudades sin país.

```sql
CREATE TABLE ciudades (
    id_ciudad INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(100),
    id_pais   INT NOT NULL,
    CONSTRAINT fk_ciudad_pais
        FOREIGN KEY (id_pais) REFERENCES paises(id_pais)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

```sql
-- Al borrar Argentina, sus ciudades desaparecen solas:
DELETE FROM paises WHERE nombre = 'Argentina';
-- Buenos Aires, Rosario y Córdoba → eliminadas automáticamente
```

---

## 4. ON DELETE SET NULL

La FK del hijo pasa a `NULL` cuando se elimina el padre. El registro hijo **se conserva**.

**Caso de uso:** tabla `clientes` depende de `ciudades`.
Si se borra una ciudad, el cliente sigue existiendo pero sin ciudad asignada.

```sql
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(100),
    id_ciudad  INT,                   -- nullable para poder poner NULL
    CONSTRAINT fk_cliente_ciudad
        FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
```

```sql
-- Al borrar Buenos Aires, sus clientes quedan con id_ciudad = NULL:
DELETE FROM ciudades WHERE nombre = 'Buenos Aires';
-- Los clientes de Buenos Aires siguen existiendo, pero sin ciudad
```

> **Requisito:** la columna FK debe admitir `NULL`. Si está declarada `NOT NULL`, no se puede usar `SET NULL`.

---

## 5. ON DELETE RESTRICT

El padre **no se puede eliminar** si tiene hijos. MySQL lanza el error 1451.

**Caso de uso:** tabla `pedidos` depende de `clientes`.
No tiene sentido borrar un cliente si tiene pedidos registrados.

```sql
CREATE TABLE pedidos (
    id_pedido  INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    ...
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
        ON DELETE RESTRICT
);
```

```sql
-- Esto FALLA si el cliente tiene pedidos:
DELETE FROM clientes WHERE id_cliente = 4;
-- Error Code: 1451. Cannot delete or update a parent row:
-- a foreign key constraint fails

-- Solución: borrar primero los hijos, luego el padre
DELETE FROM pedidos  WHERE id_cliente = 4;
DELETE FROM clientes WHERE id_cliente = 4;
```

---

## 6. ON UPDATE CASCADE

Cuando cambia la **PK del padre**, la FK del hijo se actualiza automáticamente.

**Caso de uso:** si cambiamos el `id_pais` de un registro en `paises`, todas las ciudades asociadas actualizan su `id_pais` solas.

```sql
-- Cambiamos el id de Brasil de 2 a 20:
UPDATE paises SET id_pais = 20 WHERE nombre = 'Brasil';
-- Las ciudades brasileñas pasan automáticamente a id_pais = 20
```

> **Buena práctica:** en la mayoría de los diseños modernos se usan PKs `AUTO_INCREMENT` que nunca cambian, por lo que `ON UPDATE CASCADE` rara vez se necesita en producción. Es más útil cuando se trabaja con claves naturales (como códigos ISO de país).

---

## 7. Comparativa completa

```
┌──────────────────────────────────────────────────────────────────┐
│  Situación: queremos borrar "Electrónica" (id_categoria = 1)     │
│  Existen artículos vinculados a esa categoría                    │
├───────────────┬──────────────────────────────────────────────────┤
│  CASCADE      │ Los artículos se borran solos                    │
│  SET NULL     │ Los artículos quedan con id_categoria = NULL     │
│  RESTRICT     │ El DELETE falla → hay que borrar artículos antes │
│  NO ACTION    │ Igual que RESTRICT en MySQL                      │
└───────────────┴──────────────────────────────────────────────────┘
```

### ¿Cuándo usar cada una?

| Restricción | Usarla cuando…                                               |
|-------------|--------------------------------------------------------------|
| `CASCADE`   | Los hijos **no tienen sentido** sin el padre (ej: líneas de una factura) |
| `SET NULL`  | El hijo **puede existir** sin padre (ej: cliente sin ciudad asignada) |
| `RESTRICT`  | No querés perder datos accidentalmente (la más segura)      |
| `NO ACTION` | Igual a `RESTRICT`; se usa en otros motores (PostgreSQL)    |

---

## Resumen

| Tema                      | Concepto clave                                              |
|---------------------------|-------------------------------------------------------------|
| `LOAD DATA LOCAL INFILE`  | Importa un CSV directamente a una tabla MySQL               |
| `INTO OUTFILE`            | Exporta el resultado de un SELECT a un archivo CSV          |
| `ON DELETE CASCADE`       | Borra hijos automáticamente al borrar el padre              |
| `ON DELETE SET NULL`      | Pone NULL en la FK del hijo al borrar el padre              |
| `ON DELETE RESTRICT`      | Impide borrar el padre si tiene hijos (protección)          |
| `ON UPDATE CASCADE`       | Actualiza la FK del hijo si cambia la PK del padre          |

## Orden recomendado al diseñar FKs

```
1. Identificar la relación: ¿qué tabla es padre y cuál es hija?
2. Elegir ON DELETE según la regla de negocio:
   - ¿El hijo depende totalmente del padre?  → CASCADE
   - ¿El hijo puede vivir sin padre?         → SET NULL
   - ¿Necesitás máxima protección?           → RESTRICT
3. Definir ON UPDATE: casi siempre CASCADE si usás claves naturales
4. Asegurar que la columna FK es nullable si usás SET NULL
```
