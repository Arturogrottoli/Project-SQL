# Clase 01 - Introduccion a SQL

## Que es SQL?

SQL (Structured Query Language) es el idioma que usamos para hablarle a una base de datos. Le pedis datos y te los devuelve. Asi como usas Google para buscar en internet, usas SQL para buscar en una base de datos. No es un lenguaje de programacion como Python o Java, es un lenguaje especializado solo en manejar datos.

---

## Que es una Base de Datos Relacional?

Es una base de datos que organiza la informacion en **tablas** (como planillas de Excel) que se **relacionan entre si** mediante campos en comun.

**Ejemplo:** Una tienda de ropa tiene dos tablas:

| idcliente | nombre | telefono |
|-----------|--------|----------|
| 1 | Ana | 1155001234 |
| 2 | Carlos | 1155005678 |

| idfactura | idcliente | total |
|-----------|-----------|-------|
| 101 | 1 | 1200 |
| 102 | 2 | 850 |

La columna `idcliente` conecta ambas tablas. Asi sabemos que la factura 101 es de Ana y la 102 es de Carlos. Esa conexion es la **relacion**. Ejemplos de motores: MySQL, PostgreSQL, SQL Server, Oracle.

---

## Que es una Base de Datos No Relacional (NoSQL)?

Es una base de datos que **no usa tablas ni relaciones**. Guarda los datos en otros formatos como documentos JSON, pares clave-valor o grafos. Es mas flexible: cada registro puede tener campos distintos.

**Ejemplo:** La misma tienda pero en un documento JSON (como lo guardaria MongoDB):

```json
{
  "nombre": "Ana",
  "telefono": "1155001234",
  "facturas": [
    { "idfactura": 101, "total": 1200 },
    { "idfactura": 102, "total": 300 }
  ]
}
```

Aca todo esta junto en un solo "documento", no hay tablas separadas ni relaciones. Ejemplos de motores: MongoDB, Redis, Firebase, Cassandra.

---

## Cual es la diferencia clave?

| | Relacional (SQL) | No Relacional (NoSQL) |
|--|---|---|
| **Estructura** | Tablas con filas y columnas | Documentos, clave-valor, grafos |
| **Relaciones** | Las tablas se conectan entre si | Los datos se guardan juntos, sin relaciones |
| **Rigidez** | Todas las filas tienen las mismas columnas | Cada documento puede tener campos distintos |
| **Ideal para** | Datos estructurados (ventas, contabilidad, stock) | Datos flexibles (redes sociales, logs, IoT) |

> **Analogia rapida:** Una base relacional es como un archivo de Excel con varias hojas conectadas. Una base no relacional es como una carpeta llena de post-its donde cada uno puede tener informacion diferente.

---

## Mapa de Conceptos - Base de Datos

### Que son
Una base de datos es un conjunto organizado de datos almacenados y accesibles de forma estructurada. Permite guardar, consultar y manipular informacion de manera eficiente y segura.

### Historia
Surgieron en los anios 60 con modelos jerarquicos y de red. En 1970, Edgar F. Codd propuso el modelo relacional, que se convirtio en el estandar. Desde los 2000, aparecieron las bases NoSQL para manejar grandes volumenes de datos no estructurados.

### Tipos
**Relacionales** (MySQL, PostgreSQL, SQL Server): organizan datos en tablas con filas y columnas.
**No relacionales** (MongoDB, Redis, Cassandra): usan documentos, clave-valor, grafos o columnas segun la necesidad.

### Que podemos hacer
Crear, leer, actualizar y eliminar datos (operaciones CRUD). Tambien podemos definir estructuras, establecer relaciones entre datos, controlar accesos y generar reportes o consultas complejas.

### SQL vs NoSQL
**SQL**: esquema rigido, relaciones entre tablas, ideal para datos estructurados y consistencia (ej: sistemas bancarios).
**NoSQL**: esquema flexible, escala horizontalmente, ideal para grandes volumenes de datos variables (ej: redes sociales, IoT).

---

## Mapa de Conceptos - Base de Datos Relacionales

### Conceptos Basicos
Una base de datos relacional organiza la informacion en tablas compuestas por filas (registros) y columnas (campos). Cada tabla representa una entidad (clientes, productos, ventas) y cada fila es una instancia de esa entidad.

### Modelo Relacional
Propuesto por Edgar F. Codd en 1970, se basa en la teoria de conjuntos y la logica de predicados. Los datos se organizan en relaciones (tablas) donde cada fila es unica gracias a una clave primaria, y las tablas se conectan entre si mediante claves foraneas.

### Modelo Entidad-Relacion (ER)
Es un diagrama que permite disenar la estructura de una base de datos antes de crearla. Se compone de **entidades** (tablas), **atributos** (columnas) y **relaciones** (conexiones entre tablas como 1:1, 1:N, N:M). Se implementa traduciendo cada entidad a una tabla, cada atributo a una columna y cada relacion a una clave foranea o tabla intermedia.

### SGBD (Sistema de Gestion de Base de Datos)
Es el software que permite crear, administrar y consultar bases de datos. Se encarga de la seguridad, integridad, concurrencia y respaldo de los datos. Ejemplos: MySQL, PostgreSQL, SQL Server, Oracle.

### SQL - Componentes
**DDL** (Data Definition Language): crear y modificar estructuras (CREATE, ALTER, DROP).
**DML** (Data Manipulation Language): manipular datos (SELECT, INSERT, UPDATE, DELETE).
**DCL** (Data Control Language): controlar permisos y accesos (GRANT, REVOKE).

