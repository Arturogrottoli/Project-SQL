# Ejercicio Clase 06 — Solución

Base de datos: `ejercicio06` (MySQL)
Tablas: `cliente`, `producto`, `pedido`, `detalle_pedido`, `detalle_pedidos_2`

---

## Esquema de tablas

```
cliente ──────────────────────────────────────────────────────────┐
   │                                                              │
   │  ON DELETE CASCADE                                           │
   ▼                                                              │
pedido ────────────────────────────────┐                          │
   │                                   │                          │
   │  ON DELETE CASCADE                │ ON UPDATE CASCADE        │
   ▼                                   ▼                          │
detalle_pedido ◄──── producto     (se propaga                     │
                        │          si cambia la PK)               │
                        │  ON DELETE RESTRICT                     │
                        └─────────────────────────────────────────┘
```

---

## Parte 1 — Agregar FKs con CASCADE usando ALTER TABLE

Las tablas se crean primero **sin FKs** para que puedan recibir datos sin restricciones. Luego se agregan las claves foráneas con `ALTER TABLE`.

### Sintaxis general

```sql
ALTER TABLE tabla_hija
ADD CONSTRAINT nombre_constraint
    FOREIGN KEY (columna_fk) REFERENCES tabla_padre(columna_pk)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
```

### FK 1 — `pedido → cliente`

```sql
ALTER TABLE pedido
ADD CONSTRAINT fk_pedido_cliente
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
```

- Si se borra un cliente → sus pedidos se borran solos.
- Si cambia el `id_cliente` → los pedidos se actualizan solos.

### FK 2 — `detalle_pedido → pedido`

```sql
ALTER TABLE detalle_pedido
ADD CONSTRAINT fk_detalle_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
```

- Si se borra un pedido → sus líneas de detalle se borran solas.
- Tiene sentido: sin pedido no hay detalle.

### FK 3 — `detalle_pedido → producto`

```sql
ALTER TABLE detalle_pedido
ADD CONSTRAINT fk_detalle_producto
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
```

- Se usa `RESTRICT` porque no queremos perder el historial si alguien intenta borrar un producto que ya fue vendido.

---

## Parte 2 — ¿Qué pasa al borrar un pedido?

### Lo que ocurre en cascada

```
DELETE FROM pedido WHERE id_pedido = 4;
         │
         ├──► pedido 4 → ELIMINADO
         │
         └──► detalle_pedido WHERE id_pedido = 4 → ELIMINADO automáticamente
                                                    (gracias a ON DELETE CASCADE)
```

### Lo que ocurre si borramos el cliente

```
DELETE FROM cliente WHERE id_cliente = 2;
         │
         ├──► cliente 2 → ELIMINADO
         │
         └──► pedidos WHERE id_cliente = 2 → ELIMINADOS (CASCADE cliente→pedido)
                   │
                   └──► detalle_pedido de esos pedidos → ELIMINADOS (CASCADE pedido→detalle)
```

> Con las FKs en cascada, un solo `DELETE` en la tabla raíz limpia toda la cadena automáticamente.

### Verificar antes y después

```sql
-- Antes: ver qué hay en detalle_pedido para ese pedido
SELECT * FROM detalle_pedido WHERE id_pedido = 4;

-- Ejecutar el DELETE
DELETE FROM pedido WHERE id_pedido = 4;

-- Después: confirmar que el CASCADE funcionó
SELECT * FROM detalle_pedido WHERE id_pedido = 4;  -- → 0 filas
```

---

## Parte 3 — Consulta: cliente + qué compró

Requiere hacer JOIN entre 4 tablas:

```
detalle_pedido → pedido → cliente
detalle_pedido → producto
```

### Consulta principal

```sql
SELECT
    c.nombre                                    AS cliente,
    pr.nombre                                   AS producto,
    dp.cantidad,
    dp.precio_unitario,
    ROUND(dp.cantidad * dp.precio_unitario, 2)  AS subtotal,
    p.fecha,
    p.estado
FROM detalle_pedido dp
JOIN pedido   p  ON dp.id_pedido    = p.id_pedido
JOIN cliente  c  ON p.id_cliente    = c.id_cliente
JOIN producto pr ON dp.id_producto  = pr.id_producto
ORDER BY c.nombre, p.fecha;
```

### Explicación del JOIN paso a paso

```
detalle_pedido  →  pedido          (por id_pedido)
                       │
                       └──► cliente   (por id_cliente)

detalle_pedido  →  producto        (por id_producto)
```

Cada línea del detalle sabe a qué pedido pertenece → el pedido sabe quién es el cliente → el detalle también sabe qué producto es.

### Variante agrupada — total gastado por cliente

```sql
SELECT
    c.nombre                              AS cliente,
    COUNT(dp.id_detalle)                  AS lineas_compradas,
    SUM(dp.cantidad * dp.precio_unitario) AS total_gastado
FROM detalle_pedido dp
JOIN pedido  p  ON dp.id_pedido    = p.id_pedido
JOIN cliente c  ON p.id_cliente    = c.id_cliente
WHERE p.estado = 'entregado'
GROUP BY c.id_cliente, c.nombre
ORDER BY total_gastado DESC;
```

---

## Parte 4 — Reemplazar detalle_pedido con INSERT INTO SELECT

El objetivo es vaciar `detalle_pedido` y luego rellenarla con los datos de `detalle_pedidos_2`.

### Paso 1 — Vaciar la tabla

```sql
DELETE FROM detalle_pedido;
```

> Se usa `DELETE` en lugar de `TRUNCATE` porque `TRUNCATE` en MySQL no puede usarse en tablas referenciadas por FKs activas.

### Paso 2 — INSERT INTO SELECT

```sql
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
SELECT id_pedido, id_producto, cantidad, precio_unitario
FROM detalle_pedidos_2;
```

#### ¿Cómo funciona?

```
INSERT INTO detalle_pedido (col1, col2, col3, col4)
                │
                └──► en vez de VALUES (...), usamos un SELECT
                     que devuelve exactamente las mismas columnas

SELECT id_pedido, id_producto, cantidad, precio_unitario
FROM detalle_pedidos_2;
```

- El `SELECT` actúa como fuente de datos en lugar de `VALUES`.
- **No copiamos `id_detalle`** porque es `AUTO_INCREMENT` y se genera solo.
- Las columnas del `SELECT` deben coincidir en **cantidad y tipo** con las del `INSERT`.

### Paso 3 — Validar

```sql
SELECT COUNT(*) AS filas_origen  FROM detalle_pedidos_2;
SELECT COUNT(*) AS filas_destino FROM detalle_pedido;
-- Ambas deben devolver el mismo número
```

---

## Resumen

| Parte | Qué hace                                       | Comando clave                     |
|-------|------------------------------------------------|-----------------------------------|
| 1     | Agregar FK con CASCADE a tabla existente       | `ALTER TABLE ... ADD CONSTRAINT`  |
| 2     | Probar eliminación en cascada                  | `DELETE FROM pedido`              |
| 3     | Traer nombre del cliente y sus compras         | `JOIN` entre 4 tablas             |
| 4     | Reemplazar datos de una tabla desde otra       | `DELETE` + `INSERT INTO SELECT`   |

## Diagrama de la cadena CASCADE

```
Borrar un CLIENTE
    └──► Se borran sus PEDIDOS      (CASCADE cliente → pedido)
              └──► Se borra el DETALLE de esos pedidos
                                    (CASCADE pedido → detalle_pedido)

Borrar un PEDIDO
    └──► Se borra su DETALLE        (CASCADE pedido → detalle_pedido)

Borrar un PRODUCTO con ventas
    └──► ERROR 1451 — RESTRICT      (protege el historial)
```
