# Clase 01: ¿Que es SQL? Vision general y sublenguajes

## Introduccion

**SQL** significa **Structured Query Language**, que en espanol se traduce como **Lenguaje de Consulta Estructurada**.

Pero... ¿que significa eso en palabras simples?

Imagina que tenes una planilla de Excel gigante con miles de datos: clientes, productos, ventas, fechas... Ahora imagina que necesitas encontrar rapidamente todos los clientes que compraron en noviembre, o actualizar el precio de un producto. Hacer eso a mano seria imposible. **SQL es el idioma que usas para "hablarle" a una base de datos y pedirle exactamente lo que necesitas.**

SQL se divide en **4 sublenguajes** (es decir, 4 grupos de instrucciones), y cada grupo tiene un proposito distinto. A continuacion te los explico uno por uno, pero primero veamos las siglas:

| Sigla | Nombre completo | Traduccion al espanol | ¿Para que sirve? |
|-------|----------------|----------------------|-----------------|
| **DDL** | Data Definition Language | Lenguaje de Definicion de Datos | Crear y modificar la **estructura** (tablas, bases de datos) |
| **DML** | Data Manipulation Language | Lenguaje de Manipulacion de Datos | Trabajar con los **datos** en si (agregar, modificar, borrar, consultar) |
| **DCL** | Data Control Language | Lenguaje de Control de Datos | Controlar **quien puede hacer que** (permisos y seguridad) |
| **TCL** | Transaction Control Language | Lenguaje de Control de Transacciones | Asegurar que los **cambios se guarden correctamente** o se deshagan si algo falla |

---

## ¿Que es SQL?

### Definicion

SQL (Structured Query Language) es un **lenguaje de consulta declarativo** utilizado para gestionar y manipular bases de datos relacionales.

¿Que quiere decir "declarativo"? Que vos le decis **que** queres obtener, pero **no le decis como hacerlo paso a paso**. Es como ir a un restaurante y pedir "quiero una pizza de muzzarella" sin necesidad de explicar la receta. SQL funciona igual: vos le pedis los datos y la base de datos se encarga de buscarlos.

**No es un lenguaje de programacion completo** como Python o Java. Es un lenguaje **especializado** unicamente en operaciones sobre datos.

### ¿Por que SQL es tan popular?

SQL se ha mantenido como el estandar principal para trabajar con bases de datos por varias razones:

**1. Facilidad de Uso:** Su sintaxis (la forma en que se escriben las instrucciones) es bastante parecida al ingles comun. Por ejemplo, para buscar todos los clientes se escribe algo como `SELECT * FROM Clientes` (que literalmente significa "seleccionar todo de Clientes"). Hoy en dia, gracias a la IA generativa, incluso es posible traducir preguntas en lenguaje cotidiano a consultas SQL.

**2. Versatilidad:** Permite hacer de todo con los datos: crearlos, buscarlos, modificarlos, borrarlos, analizarlos e incluso integrarlos con algoritmos de machine learning (inteligencia artificial).

**3. Compatibilidad:** SQL funciona en muchisimos sistemas. Los mas conocidos son:
- **Clasicos:** MySQL, PostgreSQL, SQL Server, Oracle
- **En la nube:** Google BigQuery, Snowflake, Amazon Redshift, Databricks SQL

**4. Estandarizacion:** SQL esta estandarizado por **ANSI** (American National Standards Institute), lo que significa que lo que aprendas en un sistema te sirve para otro. Es como aprender a manejar: una vez que sabes, podes manejar cualquier auto aunque cambie un poco el tablero.

---

## ¿Que tareas permite realizar SQL?

| Tarea | Descripcion sencilla |
|-------|---------------------|
| **Crear bases de datos** | Crear el "contenedor" donde se guardara toda la informacion |
| **Crear tablas** | Definir las "planillas" dentro de la base de datos, con sus columnas y tipos de datos |
| **Crear procedimientos** | Guardar secuencias de instrucciones para reutilizarlas (como una receta guardada) |
| **Crear vistas** | Crear "ventanas" que muestran solo ciertos datos de las tablas, sin modificarlas |
| **Insertar registros** | Agregar nuevos datos (por ejemplo, un nuevo cliente) |
| **Actualizar registros** | Modificar datos existentes (por ejemplo, cambiar el precio de un producto) |
| **Eliminar registros** | Borrar datos que ya no se necesitan |
| **Ejecutar consultas** | Buscar y recuperar datos especificos |
| **Establecer permisos** | Decidir quien puede ver o modificar que datos |

---

## Objetos de una Base de Datos

Los **objetos** son los componentes que forman una base de datos. Pensalo como las piezas de un rompecabezas: cada una cumple una funcion distinta.

### 1. Tablas

Las tablas son **la estructura mas importante** de una base de datos. Funcionan igual que una planilla de calculo:

- **Filas** (tambien llamadas **registros** o **tuplas**): cada fila es un elemento. Por ejemplo, un cliente.
- **Columnas** (tambien llamadas **campos** o **atributos**): cada columna es una caracteristica. Por ejemplo, el nombre, el email, la fecha de registro.

**Ejemplo visual:**

| ID | Cliente | Producto | Cantidad | Fecha |
|----|---------|----------|----------|-------|
| 1 | Ana | Laptop | 1 | 2024-11-05 |
| 2 | Carlos | Mouse | 3 | 2024-11-12 |
| 3 | Maria | Teclado | 2 | 2024-11-20 |

### Relaciones entre tablas

Las bases de datos **relacionales** se llaman asi porque las tablas se pueden **relacionar entre si**. Esto se logra con **claves** (o llaves):

**Clave Primaria (PK - Primary Key):**
Es como el **DNI de cada fila**. Es un valor unico que identifica a cada registro de forma inequivoca. No se puede repetir ni estar vacio.

> Ejemplo: En una tabla de clientes, el campo `ID_Cliente` seria la clave primaria. No existen dos clientes con el mismo ID.

**Clave Foranea (FK - Foreign Key):**
Es un campo que **conecta una tabla con otra**. Apunta a la clave primaria de otra tabla, creando una relacion entre ambas.

> Ejemplo: En una tabla de Pedidos, el campo `ID_Cliente` seria una clave foranea que apunta a la tabla Clientes. Asi cada pedido queda vinculado al cliente que lo hizo. Si borras un cliente, no pueden quedar pedidos "huerfanos" sin dueno.

**Clave Unica (UK - Unique Key):**
Es un campo que **no se puede repetir**, pero que no es la clave primaria. Sirve para garantizar que cierto dato sea unico.

> Ejemplo: En una tabla de usuarios, la clave primaria puede ser `ID_Usuario`, pero el campo `Email` tambien deberia ser unico (no queres que dos personas tengan el mismo mail). Ahi usas una clave unica.

### 2. Vistas

Las vistas son como **"ventanas" a los datos**. Son tablas virtuales que se crean a partir de una consulta SQL. No guardan datos propios, sino que muestran datos que ya existen en otras tablas, filtrados o combinados de cierta manera.

**¿Para que sirven?**
- Simplificar consultas complejas
- Limitar lo que ciertos usuarios pueden ver (seguridad)
- Mantener consistencia en reportes

**Ejemplo:** Crear una vista que muestre solo las ventas de noviembre:

```sql
CREATE VIEW VentasNoviembre AS
SELECT Cliente, Producto, Cantidad, Fecha
FROM Ventas
WHERE Fecha BETWEEN '2024-11-01' AND '2024-11-30';
```

Ahora, cada vez que quieras ver las ventas de noviembre, simplemente consultas `VentasNoviembre` en lugar de escribir toda la consulta otra vez.

### 3. Funciones

Las funciones son **bloques de codigo reutilizables** que realizan un calculo y **devuelven un resultado**. Son como una calculadora personalizada.

**Ejemplo:** Una funcion que calcula el precio total de una venta:

```sql
CREATE FUNCTION CalcularTotal(precio DECIMAL, cantidad INT)
RETURNS DECIMAL
AS
BEGIN
    RETURN precio * cantidad;
END;
```

Le pasas el precio y la cantidad, y te devuelve el total. Simple.

### 4. Procedimientos almacenados

Son parecidos a las funciones, pero **mas poderosos**: pueden ejecutar varias operaciones (insertar, actualizar, borrar) y **no necesitan devolver un valor**. Son como una "receta automatizada" que realiza varias tareas de una sola vez.

**Ejemplo:** Un procedimiento para actualizar el estado de un pedido:

```sql
CREATE PROCEDURE ActualizarEstadoPedido(@IDPedido INT, @NuevoEstado VARCHAR(20))
AS
BEGIN
    UPDATE Pedidos
    SET Estado = @NuevoEstado
    WHERE ID = @IDPedido;
END;
```

---

## ¿Que son las Sentencias en SQL?

Las **sentencias** son las **instrucciones** que le das a la base de datos. Asi como en espanol usas oraciones para comunicarte con las personas, en SQL usas sentencias para comunicarte con la base de datos.

Estas sentencias se organizan en **4 sublenguajes** (los que vimos al principio). Ahora veamos cada uno en detalle:

---

### 1. DDL - Data Definition Language (Lenguaje de Definicion de Datos)

**¿Que hace?** Se encarga de **crear, modificar y eliminar la estructura** de la base de datos.

Pensalo asi: si la base de datos fuera una casa, DDL son las instrucciones para **construir las paredes, puertas y ventanas**. No pone los muebles adentro (eso lo hace DML), sino que construye la estructura.

**Sentencias principales:**

| Sentencia | ¿Que hace? | Analogia |
|-----------|-----------|---------|
| `CREATE` | Crea algo nuevo (tabla, base de datos, etc.) | Construir una habitacion nueva |
| `ALTER` | Modifica algo que ya existe | Tirar una pared para agrandar una habitacion |
| `DROP` | Elimina algo por completo | Demoler una habitacion entera |

**Ejemplo:** Crear una tabla de productos:

```sql
CREATE TABLE Productos (
    ID INT PRIMARY KEY,
    Nombre VARCHAR(100),
    Precio DECIMAL
);
```

Esto crea una tabla llamada "Productos" con 3 columnas: ID (numero entero, clave primaria), Nombre (texto de hasta 100 caracteres) y Precio (numero decimal).

---

### 2. DML - Data Manipulation Language (Lenguaje de Manipulacion de Datos)

**¿Que hace?** Se encarga de **trabajar con los datos** que estan dentro de las tablas: agregarlos, consultarlos, modificarlos o borrarlos.

Siguiendo con la analogia de la casa: si DDL construye la casa, **DML es lo que pone los muebles, los mueve de lugar o los saca**.

**Sentencias principales:**

| Sentencia | ¿Que hace? | Analogia |
|-----------|-----------|---------|
| `SELECT` | Busca y muestra datos | Mirar que muebles hay en la habitacion |
| `INSERT` | Agrega datos nuevos | Meter un mueble nuevo en la casa |
| `UPDATE` | Modifica datos existentes | Mover un mueble de lugar o pintarlo de otro color |
| `DELETE` | Elimina datos | Sacar un mueble de la casa |

**Ejemplo:** Insertar un producto:

```sql
INSERT INTO Productos (ID, Nombre, Precio)
VALUES (1, 'Laptop', 1200.00);
```

Esto agrega una Laptop con ID 1 y precio 1200.00 a la tabla Productos.

---

### 3. DCL - Data Control Language (Lenguaje de Control de Datos)

**¿Que hace?** Se encarga de **controlar los permisos**: quien puede ver, modificar o ejecutar cosas en la base de datos.

Analogia: es como el **sistema de llaves y cerraduras de la casa**. Vos decidis quien tiene llave de cada habitacion y que puede hacer adentro (solo mirar, o tambien mover cosas).

**Sentencias principales:**

| Sentencia | ¿Que hace? | Analogia |
|-----------|-----------|---------|
| `GRANT` | Otorga permisos a un usuario | Darle una llave a alguien |
| `REVOKE` | Quita permisos a un usuario | Sacarle la llave a alguien |

**Ejemplo:** Darle permisos de lectura e insercion a un usuario:

```sql
GRANT SELECT, INSERT ON Productos TO UsuarioAnalista;
```

Ahora "UsuarioAnalista" puede ver datos (`SELECT`) y agregar nuevos datos (`INSERT`) en la tabla Productos, pero NO puede modificar ni borrar.

---

### 4. TCL - Transaction Control Language (Lenguaje de Control de Transacciones)

**¿Que hace?** Se encarga de **asegurar que los cambios se apliquen correctamente** o, si algo sale mal, que se puedan **deshacer**.

Analogia: imagina que estas haciendo una transferencia bancaria. Primero se resta plata de tu cuenta y despues se suma en la otra. Pero... ¿que pasa si el sistema falla justo despues de restar de tu cuenta y antes de sumar en la otra? ¡Perdiste plata! **TCL evita eso**: si algo falla, todo se revierte como si nunca hubiera pasado.

**Sentencias principales:**

| Sentencia | ¿Que hace? | Analogia |
|-----------|-----------|---------|
| `COMMIT` | Confirma los cambios definitivamente | Firmar un contrato: ya no hay vuelta atras |
| `ROLLBACK` | Deshace los cambios si algo salio mal | Ctrl+Z: borra todo lo que hiciste y vuelve al estado anterior |
| `SAVEPOINT` | Crea un punto intermedio al que podes volver | Guardar la partida en un videojuego |

**Ejemplo:** Actualizar un precio con control de transaccion:

```sql
BEGIN TRANSACTION;
UPDATE Productos SET Precio = 1150.00 WHERE ID = 1;
COMMIT;
```

Si algo fallara antes del `COMMIT`, podrias usar `ROLLBACK` para cancelar el cambio.

---

## Resumen: Los 4 sublenguajes de SQL

| Sublenguaje | Nombre completo | Funcion principal | Sentencias principales |
|-------------|----------------|-------------------|----------------------|
| **DDL** | Data Definition Language | Definir y modificar **estructuras** | `CREATE`, `ALTER`, `DROP` |
| **DML** | Data Manipulation Language | Manipular **datos** | `SELECT`, `INSERT`, `UPDATE`, `DELETE` |
| **DCL** | Data Control Language | Controlar **permisos** y seguridad | `GRANT`, `REVOKE` |
| **TCL** | Transaction Control Language | Controlar **transacciones** | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

> **Tip para recordarlos:** Pensa en construir una casa:
> - **DDL** = Construir la casa (estructura)
> - **DML** = Poner y mover los muebles (datos)
> - **DCL** = Poner cerraduras y dar llaves (permisos)
> - **TCL** = Asegurarte de que las mudanzas se hagan bien o se cancelen si algo falla (transacciones)

---

## ¿Por que es importante aprender esto?

En la industria de ciencia y analisis de datos, desarrollo backend y QA (testing), **SQL es la base para acceder y manipular datos**. Algunos ejemplos:

- Un **analista de datos** usa DML todos los dias para extraer informacion con `SELECT`.
- Un **administrador de base de datos** usa DDL para crear o modificar tablas segun las necesidades del negocio.
- Un **ingeniero de seguridad** usa DCL para controlar quien accede a que datos (fundamental para cumplir normativas de proteccion de datos).
- Un **desarrollador backend** usa TCL para asegurar que las operaciones criticas (como pagos) no dejen datos inconsistentes.

Este conocimiento inicial te prepara para configurar entornos de trabajo y comenzar a construir consultas eficientes, que exploraremos en las siguientes clases.

---
---

# Tipos de Datos, Funciones de Agregacion y GROUP BY

## Introduccion

¿Alguna vez necesitaste resumir grandes cantidades de datos para obtener informacion clave, como el total de ventas o el promedio de calificaciones? Para eso existen las **funciones de agregacion** en SQL: herramientas que toman muchos datos y los resumen en un solo valor util.

Pero antes de hablar de funciones, necesitamos entender **que tipos de datos existen en SQL**, porque no es lo mismo sumar numeros que sumar textos (eso ni siquiera tiene sentido).

---

## Tipos de Datos en SQL

Cuando creas una tabla, cada columna necesita un **tipo de dato**. Esto le dice a la base de datos **que clase de informacion va a guardar** en esa columna. Es como etiquetar cajas al hacer una mudanza: en esta van numeros, en esta van textos, en esta van fechas.

### Tipos Numericos

| Tipo | ¿Que guarda? | Ejemplo de uso |
|------|-------------|---------------|
| `INT` | Numeros enteros (sin decimales) | Cantidad de productos: `150` |
| `DECIMAL` / `NUMERIC` | Numeros con decimales exactos | Precio de un producto: `1299.99` |
| `FLOAT` / `DOUBLE` | Numeros con muchos decimales (aproximados) | Coordenadas GPS: `34.6037` |

> **Ojo:** Para dinero o precios, siempre usa `DECIMAL` y no `FLOAT`. ¿Por que? Porque `FLOAT` puede tener pequeños errores de redondeo (por ejemplo, `10.00` podria guardarse como `9.999999998`). En un banco, eso seria un desastre.

### Tipos de Texto

| Tipo | ¿Que guarda? | Ejemplo de uso |
|------|-------------|---------------|
| `CHAR(n)` | Texto de longitud **fija** (siempre ocupa n caracteres) | Codigo de pais: `CHAR(2)` → `'AR'`, `'US'` |
| `VARCHAR(n)` | Texto de longitud **variable** (hasta n caracteres) | Nombre de persona: `VARCHAR(100)` → `'Ana'`, `'Carlos'` |
| `TEXT` | Texto largo sin limite practico | Descripcion de un producto, comentarios |

> **¿Cual es la diferencia entre CHAR y VARCHAR?** Si usas `CHAR(10)` y guardas `'Hola'` (4 letras), la base de datos rellena con espacios hasta completar 10. Con `VARCHAR(10)` solo guarda las 4 letras. Por eso `VARCHAR` es mas eficiente para textos que varian de largo.

### Tipos de Fecha y Hora

| Tipo | ¿Que guarda? | Ejemplo |
|------|-------------|---------|
| `DATE` | Solo la fecha | `'2024-11-15'` |
| `TIME` | Solo la hora | `'14:30:00'` |
| `DATETIME` | Fecha y hora juntas | `'2024-11-15 14:30:00'` |
| `TIMESTAMP` | Fecha y hora (ajusta zona horaria automaticamente) | `'2024-11-15 17:30:00+03:00'` |

> **¿Cuando usar DATETIME vs TIMESTAMP?** Si tu aplicacion se usa en un solo pais, `DATETIME` esta bien. Si se usa en varios paises con distintas zonas horarias, `TIMESTAMP` es mejor porque se ajusta solo.

### Otros Tipos

| Tipo | ¿Que guarda? | Ejemplo de uso |
|------|-------------|---------------|
| `BOOLEAN` | Verdadero o falso | ¿El usuario esta activo? `TRUE` / `FALSE` |
| `BINARY` / `VARBINARY` | Datos binarios (archivos) | Imagenes, PDFs |

### ¿Como elegir el tipo de dato correcto?

Elegir bien el tipo de dato importa por 3 razones:

1. **Espacio:** Un `INT` ocupa menos espacio que un `VARCHAR(100)`. Si tenes millones de filas, eso se nota.
2. **Rendimiento:** Las operaciones (buscar, ordenar, filtrar) son mas rapidas con el tipo correcto.
3. **Integridad:** Si una columna es `INT`, nadie puede meter texto ahi por error. La base de datos lo rechaza automaticamente.

> **Importante:** Cada motor de base de datos (MySQL, PostgreSQL, SQL Server, etc.) puede tener tipos de datos ligeramente diferentes. Antes de crear tablas, consulta la documentacion del motor que estes usando.

---

## Funciones de Agregacion en SQL

### ¿Que son?

Las funciones de agregacion son operaciones que **toman muchas filas y devuelven un solo valor**. Son como una licuadora: le metes muchas frutas (datos) y te devuelve un jugo (un resumen).

### Las 5 funciones principales

| Funcion | ¿Que hace? | Analogia |
|---------|-----------|---------|
| `SUM()` | Suma todos los valores de una columna | Sumar todo lo que gastaste en el mes |
| `COUNT()` | Cuenta cuantas filas hay | Contar cuantos alumnos hay en el aula |
| `AVG()` | Calcula el promedio (la media) | Sacar el promedio de notas de un examen |
| `MIN()` | Encuentra el valor mas chico | ¿Cual fue la venta mas baja? |
| `MAX()` | Encuentra el valor mas grande | ¿Cual fue la venta mas alta? |

### Ejemplos practicos

Imagina que tenes esta tabla `Ventas`:

| ID | Vendedor | Producto | Monto | Fecha |
|----|----------|----------|-------|-------|
| 1 | Ana | Laptop | 1200 | 2024-11-05 |
| 2 | Carlos | Mouse | 25 | 2024-11-06 |
| 3 | Ana | Teclado | 80 | 2024-11-07 |
| 4 | Maria | Monitor | 350 | 2024-11-08 |
| 5 | Carlos | Laptop | 1200 | 2024-11-10 |
| 6 | Ana | Mouse | 25 | 2024-11-12 |

**¿Cuanto se vendio en total?**

```sql
SELECT SUM(Monto) AS total_ventas
FROM Ventas;
```

Resultado: `2880` (la suma de todos los montos)

**¿Cuantas ventas se hicieron?**

```sql
SELECT COUNT(*) AS cantidad_ventas
FROM Ventas;
```

Resultado: `6` (hay 6 filas)

**¿Cual fue el monto promedio por venta?**

```sql
SELECT AVG(Monto) AS monto_promedio
FROM Ventas;
```

Resultado: `480` (2880 / 6)

**¿Cual fue la venta mas cara y la mas barata?**

```sql
SELECT MAX(Monto) AS venta_maxima, MIN(Monto) AS venta_minima
FROM Ventas;
```

Resultado: venta maxima `1200`, venta minima `25`

> **¿Que es ese `AS`?** Es un **alias**. Le pone un nombre temporal al resultado para que sea mas facil de leer. En lugar de ver una columna sin nombre, ves `total_ventas` o `monto_promedio`. No cambia nada en la base de datos, solo es para la presentacion del resultado.

---

## GROUP BY: Agrupar datos

### ¿Que es?

`GROUP BY` es como **separar en equipos** antes de hacer un calculo. En lugar de sumar TODO, podes sumar **por categoria**.

Sin GROUP BY: "¿Cuanto se vendio en total?" → Un solo numero.
Con GROUP BY: "¿Cuanto vendio **cada vendedor**?" → Un numero por vendedor.

### Sintaxis basica

```sql
SELECT columna, funcion_agregacion(otra_columna)
FROM tabla
GROUP BY columna;
```

### Ejemplo practico

Usando la misma tabla `Ventas`, queremos saber **cuanto vendio cada vendedor**:

```sql
SELECT Vendedor, SUM(Monto) AS total_vendido
FROM Ventas
GROUP BY Vendedor;
```

Resultado:

| Vendedor | total_vendido |
|----------|--------------|
| Ana | 1305 |
| Carlos | 1225 |
| Maria | 350 |

**¿Que paso?** SQL junto todas las filas de Ana, sumo sus montos (1200 + 80 + 25 = 1305), hizo lo mismo con Carlos (25 + 1200 = 1225) y con Maria (350). Cada vendedor se convirtio en un **grupo**.

### Otro ejemplo: contar ventas por vendedor

```sql
SELECT Vendedor, COUNT(*) AS cantidad_ventas
FROM Ventas
GROUP BY Vendedor;
```

Resultado:

| Vendedor | cantidad_ventas |
|----------|----------------|
| Ana | 3 |
| Carlos | 2 |
| Maria | 1 |

---

## WHERE vs HAVING: ¿Cual es la diferencia?

Esta es una de las confusiones mas comunes para principiantes. Ambos sirven para **filtrar**, pero se usan en momentos diferentes:

| | `WHERE` | `HAVING` |
|--|---------|----------|
| **¿Cuando filtra?** | **Antes** de agrupar | **Despues** de agrupar |
| **¿Que filtra?** | Filas individuales | Grupos ya formados |
| **¿Puede usar funciones de agregacion?** | No | Si |

### Analogia

Imagina que tenes una caja con bolitas de colores y queres contar cuantas hay de cada color:

- **WHERE** = Antes de contar, **sacas las bolitas rotas** (filtras filas individuales).
- **GROUP BY** = Separas las bolitas por color (agrupas).
- **HAVING** = Despues de contar, **te quedas solo con los colores que tienen mas de 5 bolitas** (filtras grupos).

### Ejemplo completo

Queremos saber que vendedores vendieron mas de $1000 **en total**, pero solo contando ventas mayores a $20:

```sql
SELECT Vendedor, SUM(Monto) AS total_vendido
FROM Ventas
WHERE Monto > 20
GROUP BY Vendedor
HAVING SUM(Monto) > 1000;
```

**Paso a paso de lo que hace SQL:**

1. **FROM Ventas** → Toma la tabla Ventas (6 filas)
2. **WHERE Monto > 20** → Filtra las filas con monto mayor a 20 (descarta las de $25... no, 25 > 20 asi que pasan todas en este caso. Si hubiera una de $15, se descartaria)
3. **GROUP BY Vendedor** → Agrupa por vendedor (3 grupos: Ana, Carlos, Maria)
4. **SUM(Monto)** → Suma los montos de cada grupo
5. **HAVING SUM(Monto) > 1000** → Muestra solo los grupos cuya suma sea mayor a 1000

Resultado:

| Vendedor | total_vendido |
|----------|--------------|
| Ana | 1305 |
| Carlos | 1225 |

Maria quedo afuera porque su total (350) no supera los 1000.

> **Regla de oro:** Si queres filtrar datos **antes** de agrupar, usa `WHERE`. Si queres filtrar **despues** de agrupar (sobre el resultado de funciones como SUM, COUNT, etc.), usa `HAVING`.

---

## Orden de ejecucion de una consulta SQL

Esto es clave para entender por que WHERE va antes que HAVING. SQL ejecuta las partes de una consulta en este orden:

| Paso | Clausula | ¿Que hace? |
|------|----------|-----------|
| 1 | `FROM` | Elige la tabla |
| 2 | `WHERE` | Filtra filas individuales |
| 3 | `GROUP BY` | Agrupa las filas que pasaron el filtro |
| 4 | `HAVING` | Filtra los grupos |
| 5 | `SELECT` | Elige que columnas mostrar |
| 6 | `ORDER BY` | Ordena el resultado final |

> **Atencion:** Aunque escribimos `SELECT` al principio de la consulta, SQL lo ejecuta casi al final. Por eso no podes usar un alias definido en `SELECT` dentro del `WHERE` (porque WHERE se ejecuta antes).

---

## Resumen

| Concepto | ¿Que es? | ¿Para que sirve? |
|----------|---------|-----------------|
| **Tipos de datos** | Las "etiquetas" de cada columna | Decirle a la base de datos que tipo de informacion guardar |
| **SUM()** | Funcion de agregacion | Sumar valores |
| **COUNT()** | Funcion de agregacion | Contar filas |
| **AVG()** | Funcion de agregacion | Calcular el promedio |
| **MIN()** | Funcion de agregacion | Encontrar el minimo |
| **MAX()** | Funcion de agregacion | Encontrar el maximo |
| **GROUP BY** | Clausula de agrupacion | Separar datos en grupos para aplicar funciones |
| **WHERE** | Filtro de filas | Filtrar **antes** de agrupar |
| **HAVING** | Filtro de grupos | Filtrar **despues** de agrupar |

> **Tip para recordar WHERE vs HAVING:**
> - **WHERE** = "Quiero solo estas filas" (antes de agrupar)
> - **HAVING** = "Quiero solo estos grupos" (despues de agrupar)

Este conocimiento es la base para manipular datos con sentencias mas avanzadas y optimizar consultas, habilidades que se desarrollaran en las siguientes clases.
