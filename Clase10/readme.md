# Clase 10 — Transacciones y Backup

Base de datos: `tienda` (MySQL)
Tablas: `paises`, `ciudades`, `clientes`, `productos`, `pedidos`, `movimientos`

---

## Repaso rápido

| Concepto            | Qué hace                                                      |
|---------------------|---------------------------------------------------------------|
| `CREATE TRIGGER`    | Dispara código automáticamente ante INSERT/UPDATE/DELETE      |
| `BEFORE / AFTER`    | Momento del trigger respecto al evento                        |
| `NEW / OLD`         | Acceso a los valores nuevos/anteriores dentro del trigger     |
| `SIGNAL`            | Lanza un error personalizado y cancela la operación           |
| `GRANT / REVOKE`    | Otorga/quita permisos a usuarios en DCL                       |

---

## El problema que resuelven las transacciones

Imagina que querés transferir $500 del saldo de Lucas al de Maria. La operación requiere dos pasos:

```
Paso 1: UPDATE clientes SET saldo = saldo - 500 WHERE id_cliente = 1;
Paso 2: UPDATE clientes SET saldo = saldo + 500 WHERE id_cliente = 2;
```

Si la base de datos falla o hay un error **entre** el paso 1 y el paso 2:
- Lucas ya perdió los $500
- Maria no los recibió
- La plata desapareció

**Las transacciones garantizan que o los dos pasos ocurren juntos, o ninguno ocurre.**

---

## Propiedades ACID

Toda transacción debe cumplir cuatro propiedades:

```
A — Atomicidad    Todo o nada. No puede haber resultados parciales.
C — Consistencia  La base pasa de un estado válido a otro estado válido.
I — Isolation     Dos transacciones simultáneas no se "ven" entre sí
                  hasta que cada una hace COMMIT.
D — Durabilidad   Una vez hecho el COMMIT, el cambio persiste aunque
                  haya un corte de luz o fallo del servidor.
```

---

## AUTOCOMMIT — el modo por defecto

MySQL tiene `autocommit = 1` por defecto. Esto significa que **cada sentencia es su propia transacción**: se confirma sola en cuanto se ejecuta, y no se puede deshacer.

```sql
SELECT @@autocommit;   -- devuelve 1 (ON)

-- Con autocommit ON, este UPDATE es inmediato e irreversible:
UPDATE clientes SET saldo = saldo - 100 WHERE id_cliente = 1;
```

Para controlar las transacciones manualmente usamos `START TRANSACTION`, que **suspende el autocommit** para ese bloque.

---

## 1. START TRANSACTION + COMMIT

`START TRANSACTION` abre un bloque transaccional. Los cambios son **temporales** hasta que llega el `COMMIT`, que los hace permanentes de golpe.

```sql
START TRANSACTION;

    UPDATE clientes SET saldo = saldo - 200 WHERE id_cliente = 1;
    UPDATE clientes SET saldo = saldo + 200 WHERE id_cliente = 2;

    INSERT INTO movimientos (id_cliente, tipo, monto)
    VALUES (1, 'debito', 200);

    INSERT INTO movimientos (id_cliente, tipo, monto)
    VALUES (2, 'credito', 200);

COMMIT;   -- ← todos los cambios quedan confirmados de golpe
```

**Flujo:**
```
START TRANSACTION
      │
   UPDATE ...  (temporal)
   UPDATE ...  (temporal)
   INSERT ...  (temporal)
      │
   COMMIT  ──►  todos los cambios pasan a ser permanentes
```

---

## 2. START TRANSACTION + ROLLBACK

Si algo sale mal, `ROLLBACK` deshace **todos** los cambios desde el `START TRANSACTION`, como si nunca hubieran ocurrido.

```sql
START TRANSACTION;

    UPDATE clientes SET saldo = saldo - 500 WHERE id_cliente = 1;
    UPDATE clientes SET saldo = saldo + 500 WHERE id_cliente = 3;

    -- detectamos que algo está mal...

ROLLBACK;   -- ← los dos UPDATE se anulan completamente
```

**Flujo:**
```
START TRANSACTION
      │
   UPDATE ...  (temporal)
   UPDATE ...  (temporal)
      │
   ROLLBACK  ──►  todo vuelve al estado previo al START TRANSACTION
```

> `ROLLBACK` funciona para `INSERT`, `UPDATE` y `DELETE`. **No funciona** para sentencias DDL como `CREATE TABLE` o `DROP TABLE` — esas son irreversibles.

---

## 3. SAVEPOINT — puntos de control intermedios

`SAVEPOINT` permite crear puntos de control dentro de una transacción. Con `ROLLBACK TO SAVEPOINT` se puede deshacer **solo hasta ese punto**, sin cancelar toda la transacción.

```sql
START TRANSACTION;

    UPDATE pedidos SET estado = 'enviado' WHERE id_cliente = 1;

    SAVEPOINT sp_pedidos_ok;        -- punto de control guardado

    UPDATE clientes SET saldo = saldo - 300 WHERE id_cliente = 1;

    -- nos arrepentimos del descuento de saldo, pero NO de los pedidos
    ROLLBACK TO SAVEPOINT sp_pedidos_ok;

    -- los pedidos siguen en 'enviado', pero el saldo volvió a su valor anterior

COMMIT;   -- confirmamos lo que quedó (solo el UPDATE de pedidos)
```

**Flujo con SAVEPOINT:**
```
START TRANSACTION
      │
   UPDATE pedidos (estado=enviado)
      │
   SAVEPOINT sp_pedidos_ok  ◄── punto A
      │
   UPDATE clientes (saldo -300)
      │
   ROLLBACK TO sp_pedidos_ok  ──►  deshace solo desde punto A hasta acá
      │                            el UPDATE de pedidos se mantiene
   COMMIT  ──►  confirma el UPDATE de pedidos
```

### Los tres comandos de SAVEPOINT

| Comando                           | Qué hace                                              |
|-----------------------------------|-------------------------------------------------------|
| `SAVEPOINT nombre`                | Crea un punto de control                              |
| `ROLLBACK TO SAVEPOINT nombre`    | Deshace hasta ese punto (la transacción sigue abierta)|
| `RELEASE SAVEPOINT nombre`        | Elimina el savepoint (no deshace nada)                |

---

## 4. ROLLBACK TO SAVEPOINT en detalle

```sql
START TRANSACTION;

    INSERT INTO pedidos ...;      SAVEPOINT sp1;
    INSERT INTO pedidos ...;      SAVEPOINT sp2;
    INSERT INTO pedidos ...;      SAVEPOINT sp3;

    -- opción A: deshacer solo el último INSERT
    ROLLBACK TO SAVEPOINT sp2;   -- deshace lo hecho después de sp2

    -- opción B: deshacer los dos últimos
    ROLLBACK TO SAVEPOINT sp1;   -- deshace lo hecho después de sp1

    -- al volver a sp1, sp2 y sp3 ya no existen

COMMIT;   -- o ROLLBACK completo
```

---

## 5. SET autocommit = 0 — transacciones implícitas

Una alternativa a `START TRANSACTION` es desactivar el autocommit globalmente para la sesión. A partir de ese momento, **cada sentencia requiere COMMIT para confirmarse**.

```sql
SET autocommit = 0;   -- desactivamos el autocommit

UPDATE clientes SET saldo = saldo + 999 WHERE id_cliente = 1;
-- el cambio es temporal hasta el COMMIT

COMMIT;               -- confirmamos

SET autocommit = 1;   -- volvemos al modo por defecto
```

> **Recomendación:** usar `START TRANSACTION` explícito es más claro y menos propenso a errores que manipular `autocommit`. Cuando `autocommit = 0` y te olvidás de hacer `COMMIT`, los cambios quedan pendientes hasta que se cierra la sesión (y pueden perderse).

---

## Resumen de comandos de transacción

```sql
START TRANSACTION;          -- abre una transacción (o BEGIN;)
COMMIT;                     -- confirma todos los cambios
ROLLBACK;                   -- deshace todos los cambios

SAVEPOINT nombre;           -- crea un punto de control
ROLLBACK TO SAVEPOINT nombre; -- deshace hasta ese punto
RELEASE SAVEPOINT nombre;   -- elimina el punto de control

SET autocommit = 0;         -- desactiva autocommit
SET autocommit = 1;         -- activa autocommit (por defecto)
SELECT @@autocommit;        -- ver el estado actual
```

---

## ¿Cuándo usar COMMIT y cuándo ROLLBACK?

```
¿Todas las operaciones del bloque se completaron sin error?
        │
       SÍ  ──►  COMMIT
        │
        NO  ──►  ROLLBACK
```

En la práctica, esto se maneja con lógica condicional en el lenguaje de programación que usa la base de datos (PHP, Python, Java, etc.), o dentro de un stored procedure con `DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK`.

---

## Backup — ¿por qué hacerlo?

Un backup (copia de seguridad) protege los datos ante:
- Fallos de hardware
- Errores humanos (DELETE sin WHERE, DROP TABLE accidental)
- Corrupción de datos
- Ataques o ransomware

**Regla 3-2-1:** 3 copias, en 2 medios distintos, 1 fuera del sitio.

---

## mysqldump — backup desde la terminal

`mysqldump` es la herramienta oficial de MySQL para exportar bases de datos. **Se ejecuta en la terminal del sistema operativo**, no dentro de MySQL Workbench.

> Los comandos de backup se ejecutan desde **PowerShell**, **CMD** o la **terminal de Mac/Linux**, no desde el editor SQL.

### Backup completo de una base

```bash
# Windows
mysqldump -u root -p tienda > C:\backups\tienda_backup.sql

# Mac / Linux
mysqldump -u root -p tienda > ~/backups/tienda_backup.sql
```

El archivo `.sql` generado contiene todos los `CREATE TABLE` y todos los `INSERT` de la base.

### Backup con fecha en el nombre (buena práctica)

```bash
# Windows
mysqldump -u root -p tienda > C:\backups\tienda_2025-03-10.sql

# Mac / Linux (la fecha se genera automáticamente)
mysqldump -u root -p tienda > ~/backups/tienda_$(date +%Y-%m-%d).sql
```

### Variantes útiles

```bash
# Solo algunas tablas (clientes y pedidos)
mysqldump -u root -p tienda clientes pedidos > backup_parcial.sql

# Solo la estructura (sin datos) — para documentar el esquema
mysqldump -u root -p --no-data tienda > tienda_estructura.sql

# Solo los datos (sin CREATE TABLE) — para migrar a otra base
mysqldump -u root -p --no-create-info tienda > tienda_datos.sql

# Todas las bases del servidor
mysqldump -u root -p --all-databases > todas_las_bases.sql
```

### Opciones de mysqldump más usadas

| Opción              | Qué hace                                      |
|---------------------|-----------------------------------------------|
| `-u root`           | Usuario de MySQL                              |
| `-p`                | Pide la contraseña (no escribirla en el comando) |
| `--no-data`         | Solo exporta la estructura, sin filas         |
| `--no-create-info`  | Solo exporta los datos, sin CREATE TABLE      |
| `--all-databases`   | Exporta todas las bases del servidor          |
| `--single-transaction` | Backup consistente sin bloquear tablas (InnoDB) |

---

## Restaurar desde un backup

```bash
# Si la base ya existe
mysql -u root -p tienda < C:\backups\tienda_backup.sql

# Si la base NO existe todavía
mysql -u root -p -e "CREATE DATABASE tienda;"
mysql -u root -p tienda < C:\backups\tienda_backup.sql
```

**Flujo de restauración:**
```
archivo .sql
    │
    ▼
mysql lee el archivo
    │
    ├──► ejecuta los CREATE TABLE
    └──► ejecuta los INSERT
    │
    ▼
base de datos reconstruida
```

---

## Backup desde MySQL Workbench (sin terminal)

Para quienes prefieren interfaz gráfica, Workbench tiene herramientas integradas.

### Exportar (backup)

```
Server → Data Export
    ├── Seleccionar base de datos: tienda
    ├── Seleccionar tablas (o todas)
    ├── Opción: "Export to Self-Contained File"
    ├── Elegir carpeta y nombre del archivo (.sql)
    └── Click en "Start Export"
```

### Importar (restaurar)

```
Server → Data Import
    ├── Opción: "Import from Self-Contained File"
    ├── Seleccionar el archivo .sql
    ├── Seleccionar el schema destino (o crear uno nuevo)
    └── Click en "Start Import"
```

---

## Comparativa: mysqldump vs Workbench

| Aspecto             | mysqldump (terminal)           | Workbench (GUI)               |
|---------------------|--------------------------------|-------------------------------|
| Velocidad           | Más rápido en bases grandes    | Más lento                     |
| Automatización      | Se puede incluir en scripts    | Solo manual                   |
| Facilidad           | Requiere saber la terminal     | Muy visual y sencillo         |
| Backups parciales   | Muy flexible con opciones      | Opciones limitadas            |
| Recomendado para    | Producción, scripts automáticos| Aprendizaje, uso ocasional    |

---

## Resumen de la clase

| Concepto                      | Sintaxis clave                                        |
|-------------------------------|-------------------------------------------------------|
| Iniciar transacción           | `START TRANSACTION;` o `BEGIN;`                       |
| Confirmar                     | `COMMIT;`                                             |
| Deshacer todo                 | `ROLLBACK;`                                           |
| Punto de control              | `SAVEPOINT nombre;`                                   |
| Deshacer hasta punto          | `ROLLBACK TO SAVEPOINT nombre;`                       |
| Liberar punto de control      | `RELEASE SAVEPOINT nombre;`                           |
| Ver autocommit                | `SELECT @@autocommit;`                                |
| Desactivar autocommit         | `SET autocommit = 0;`                                 |
| Backup completo (terminal)    | `mysqldump -u root -p base > archivo.sql`             |
| Backup estructura sola        | `mysqldump -u root -p --no-data base > archivo.sql`   |
| Backup datos solos            | `mysqldump -u root -p --no-create-info base > archivo.sql` |
| Restaurar backup              | `mysql -u root -p base < archivo.sql`                 |

## Flujo recomendado para una operación crítica

```
1. START TRANSACTION
2. Ejecutar todas las sentencias necesarias
3. Verificar que no hubo errores
        ├── Sin errores  →  COMMIT
        └── Con errores  →  ROLLBACK
4. Volver a autocommit normal
```
