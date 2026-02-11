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

---
---

# DDL y DML seguro: INSERT, UPDATE y DELETE

## Introduccion

¿Alguna vez te preguntaste que pasa si alguien ejecuta un `DELETE` sin querer y borra **todos** los datos de una tabla en produccion? Spoiler: pasa, y es un desastre.

En esta seccion vamos a ver como usar las sentencias que **modifican datos** (INSERT, UPDATE, DELETE) de forma **segura**, para que nunca te pase eso. Tambien repasaremos DDL (las sentencias que crean y modifican la estructura de la base de datos) y aprenderemos buenas practicas que se usan en el mundo real.

---

## Repaso: ¿Que es DDL?

**DDL** = **Data Definition Language** (Lenguaje de Definicion de Datos)

Son las sentencias que definen la **estructura** de la base de datos: crear tablas, modificarlas o eliminarlas. No tocan los datos en si, sino el "esqueleto" donde se guardan.

### Las 3 sentencias principales de DDL

| Sentencia | ¿Que hace? | Analogia |
|-----------|-----------|---------|
| `CREATE` | Crea algo nuevo (tabla, base de datos, indice, etc.) | Construir una habitacion nueva en la casa |
| `ALTER` | Modifica algo que ya existe | Agrandar una habitacion o agregarle una ventana |
| `DROP` | Elimina algo **por completo** (estructura + datos) | Demoler la habitacion entera |

### Ejemplos de DDL

**Crear una tabla:**

```sql
CREATE TABLE Employees (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),
    HireDate DATE
);
```

Esto crea una tabla con 3 columnas: un ID numerico (clave primaria), un nombre de hasta 100 caracteres y una fecha de contratacion.

**Agregar una columna a una tabla existente:**

```sql
ALTER TABLE Employees ADD Email VARCHAR(255);
```

Esto le agrega una columna "Email" a la tabla que ya existia. No borra nada de lo que habia, solo agrega.

**Eliminar una tabla completa:**

```sql
DROP TABLE Employees;
```

> **Cuidado:** `DROP` elimina la tabla Y todos sus datos. No hay vuelta atras (a menos que tengas un backup). Por eso es una operacion que se usa con mucha precaucion.

### Consideraciones importantes sobre DDL

1. **Impacto permanente:** Las operaciones DDL modifican la estructura de forma definitiva. Un `DROP TABLE` no se puede deshacer con `ROLLBACK` en la mayoria de los motores.
2. **Permisos restringidos:** En entornos reales, solo los administradores de base de datos (DBA) tienen permisos para ejecutar DDL. No cualquiera deberia poder borrar tablas.
3. **Probar antes en desarrollo:** Nunca ejecutes DDL directamente en produccion. Siempre proba primero en un entorno de desarrollo o testing.
4. **Cada motor es diferente:** MySQL, PostgreSQL y SQL Server tienen pequenas variaciones en la sintaxis DDL. Siempre consulta la documentacion del motor que uses.

---

## Sentencias DML: INSERT, UPDATE y DELETE

**DML** = **Data Manipulation Language** (Lenguaje de Manipulacion de Datos)

Ahora si entramos a las sentencias que **tocan los datos**: agregar, modificar y borrar registros.

### INSERT: Agregar datos nuevos

`INSERT` mete filas nuevas en una tabla. Es como agregar una fila nueva en una planilla de Excel.

**Sintaxis basica:**

```sql
INSERT INTO nombre_tabla (columna1, columna2, columna3)
VALUES (valor1, valor2, valor3);
```

**Ejemplo:**

```sql
INSERT INTO Employees (ID, Name, HireDate)
VALUES (1, 'Ana Garcia', '2024-03-15');
```

Esto agrega un nuevo empleado con ID 1, nombre "Ana Garcia" y fecha de contratacion 15 de marzo de 2024.

**Insertar varias filas de una vez:**

```sql
INSERT INTO Employees (ID, Name, HireDate)
VALUES
    (2, 'Carlos Lopez', '2024-04-01'),
    (3, 'Maria Fernandez', '2024-05-10'),
    (4, 'Juan Perez', '2024-06-20');
```

> **Tip:** Siempre especifica las columnas en el INSERT (`INSERT INTO tabla (col1, col2)`). No uses `INSERT INTO tabla VALUES (...)` sin nombrar columnas, porque si alguien agrega una columna nueva a la tabla, tu INSERT se rompe.

---

### UPDATE: Modificar datos existentes

`UPDATE` cambia valores que ya estan en la tabla. Es como editar una celda en Excel.

**Sintaxis basica:**

```sql
UPDATE nombre_tabla
SET columna = nuevo_valor
WHERE condicion;
```

**Ejemplo:**

```sql
UPDATE Employees
SET Name = 'Ana M. Garcia'
WHERE ID = 1;
```

Esto cambia el nombre del empleado con ID 1 a "Ana M. Garcia".

### ¡PELIGRO! UPDATE sin WHERE

```sql
-- NUNCA hagas esto en produccion:
UPDATE Employees
SET Name = 'Error';
```

**¿Que pasa?** Como no hay `WHERE`, SQL cambia el nombre de **TODOS** los empleados a "Error". Todos. Sin excepcion. Si tenes 100.000 empleados, los 100.000 ahora se llaman "Error".

> **Regla de oro #1:** SIEMPRE usa `WHERE` en un `UPDATE`. Si no pones WHERE, afectas TODAS las filas.

---

### DELETE: Eliminar datos

`DELETE` borra filas de una tabla. Es como borrar filas en Excel.

**Sintaxis basica:**

```sql
DELETE FROM nombre_tabla
WHERE condicion;
```

**Ejemplo:**

```sql
DELETE FROM Employees
WHERE ID = 4;
```

Esto elimina al empleado con ID 4.

### ¡PELIGRO! DELETE sin WHERE

```sql
-- NUNCA hagas esto en produccion:
DELETE FROM Employees;
```

**¿Que pasa?** Borra **TODOS** los registros de la tabla. Todos. La tabla queda vacia (pero sigue existiendo, a diferencia de `DROP` que elimina la tabla entera).

> **Regla de oro #2:** SIEMPRE usa `WHERE` en un `DELETE`. Si no pones WHERE, borras TODO.

---

## Buenas Practicas: Como usar UPDATE y DELETE de forma segura

Estas son las practicas que usan los profesionales en el mundo real para no cometer errores:

### 1. Siempre verifica con SELECT antes

Antes de ejecutar un UPDATE o DELETE, hace un SELECT con el mismo WHERE para ver que filas vas a afectar:

```sql
-- Paso 1: Ver que vas a modificar
SELECT * FROM Employees WHERE ID = 1;

-- Paso 2: Si el resultado es correcto, ejecuta el cambio
UPDATE Employees SET Name = 'Ana M. Garcia' WHERE ID = 1;
```

Es como mirar antes de cruzar la calle.

### 2. Usa transacciones

Las transacciones te permiten **deshacer cambios** si algo salio mal. Pensalo como un "Ctrl+Z" para la base de datos:

```sql
BEGIN TRANSACTION;

UPDATE Employees SET Salary = 50000 WHERE ID = 1;

-- Si todo esta bien:
COMMIT;

-- Si algo salio mal:
-- ROLLBACK;
```

**¿Que paso aca?**
- `BEGIN TRANSACTION` le dice a la base de datos: "voy a hacer cambios, pero no los confirmes todavia"
- Ejecutas tu UPDATE
- Si revisas y esta todo bien, haces `COMMIT` (confirmar)
- Si algo esta mal, haces `ROLLBACK` (deshacer todo)

### 3. Ejemplo completo de transferencia segura

Imagina que queres transferir $100 de una cuenta a otra:

```sql
BEGIN TRANSACTION;

-- Restar de la cuenta origen
UPDATE cuentas SET saldo = saldo - 100 WHERE id_cuenta = 1;

-- Sumar en la cuenta destino
UPDATE cuentas SET saldo = saldo + 100 WHERE id_cuenta = 2;

-- Si ambas operaciones salieron bien:
COMMIT;
```

Si la base de datos se cae justo entre el primer UPDATE y el segundo, la transaccion se revierte automaticamente. Nadie pierde plata.

### 4. Checklist de seguridad para DML

| Practica | ¿Por que? |
|----------|----------|
| Verificar con `SELECT` antes | Para confirmar que vas a afectar las filas correctas |
| Usar transacciones (`BEGIN`, `COMMIT`, `ROLLBACK`) | Para poder deshacer si algo sale mal |
| Hacer backups antes de cambios grandes | Para tener una copia de seguridad por si todo falla |
| Limitar permisos de usuario | Para que no cualquiera pueda modificar o borrar datos |
| Registrar cambios (logs/auditoria) | Para saber quien cambio que y cuando |

---

## Diferencia entre DROP, DELETE y TRUNCATE

Estas tres instrucciones "borran cosas", pero de formas muy diferentes:

| Sentencia | ¿Que borra? | ¿Se puede deshacer? | ¿Que queda? |
|-----------|------------|--------------------|----|
| `DELETE FROM tabla WHERE ...` | Filas especificas | Si (con transaccion) | La tabla con las demas filas |
| `DELETE FROM tabla` (sin WHERE) | Todas las filas | Si (con transaccion) | La tabla vacia (estructura intacta) |
| `TRUNCATE TABLE tabla` | Todas las filas (mas rapido) | No en la mayoria de motores | La tabla vacia (estructura intacta) |
| `DROP TABLE tabla` | La tabla completa | No | Nada. La tabla deja de existir |

> **Analogia:**
> - `DELETE` = Borrar filas de una planilla de Excel
> - `TRUNCATE` = Seleccionar todo y apretar "Suprimir" (mas rapido, pero sin Ctrl+Z)
> - `DROP` = Borrar el archivo de Excel completo del disco

---

## Seguridad y permisos (DCL)

Recordemos que **DCL** (Data Control Language) es el sublenguaje que controla **quien puede hacer que** en la base de datos.

Para proteger los datos, es fundamental que no todos los usuarios tengan permisos para modificar o borrar:

```sql
-- Dar permiso de solo lectura a un analista
GRANT SELECT ON Employees TO UsuarioAnalista;

-- Dar permiso de insercion (pero NO de borrado)
GRANT INSERT ON Employees TO UsuarioAnalista;

-- Quitar permiso de borrado a un usuario
REVOKE DELETE ON Employees FROM UsuarioJunior;
```

> **Buena practica:** En produccion, la mayoria de los usuarios deberian tener solo permisos de `SELECT` (lectura). Solo usuarios especificos y autorizados deberian poder hacer INSERT, UPDATE o DELETE.

---

## Ejercicio practico

### Instrucciones

1. **Verificar antes de modificar:** Hace un `SELECT` para identificar las filas que queres cambiar en la tabla `Employees`.
2. **UPDATE seguro:** Escribi un `UPDATE` que cambie el campo `DepartmentID` para un grupo especifico de empleados, usando un `WHERE` adecuado.
3. **Validar:** Antes de ejecutar, verifica con `SELECT` que solo las filas correctas seran afectadas.
4. **Usar transaccion:** Ejecuta el UPDATE dentro de un `BEGIN TRANSACTION` y confirma con `COMMIT`.
5. **DELETE seguro:** Escribi un `DELETE` para eliminar registros antiguos, aplicando las mismas buenas practicas.
6. **Revisar permisos:** Verifica que tu usuario tiene los privilegios necesarios.

> **Recorda:** Siempre valida y proba tus sentencias en un entorno controlado antes de aplicarlas en produccion.

### Script para crear la base de datos de practica

```sql
----------------------------------------------------
-- 0. CREAR BASE (si no existe) Y USARLA
----------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'PracticeJoinSubqueries')
BEGIN
    CREATE DATABASE PracticeJoinSubqueries;
END
GO
USE PracticeJoinSubqueries;
GO

----------------------------------------------------
-- 1. ELIMINAR FOREIGN KEYS SI EXISTEN
----------------------------------------------------
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Employees_Departments')
    ALTER TABLE dbo.Employees DROP CONSTRAINT FK_Employees_Departments;
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Projects_Employees')
    ALTER TABLE dbo.Projects DROP CONSTRAINT FK_Projects_Employees;
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Evaluations_Employees')
    ALTER TABLE dbo.Evaluations DROP CONSTRAINT FK_Evaluations_Employees;

----------------------------------------------------
-- 2. ELIMINAR INDICES SI EXISTEN
----------------------------------------------------
IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Employees_DepartmentID')
    DROP INDEX IX_Employees_DepartmentID ON dbo.Employees;
IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Projects_LeaderEmployeeID')
    DROP INDEX IX_Projects_LeaderEmployeeID ON dbo.Projects;
IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Evaluations_EmployeeID')
    DROP INDEX IX_Evaluations_EmployeeID ON dbo.Evaluations;

----------------------------------------------------
-- 3. ELIMINAR TABLAS SI EXISTEN
----------------------------------------------------
IF OBJECT_ID('dbo.Evaluations', 'U') IS NOT NULL DROP TABLE dbo.Evaluations;
IF OBJECT_ID('dbo.Projects', 'U') IS NOT NULL DROP TABLE dbo.Projects;
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.Departments', 'U') IS NOT NULL DROP TABLE dbo.Departments;
GO

----------------------------------------------------
-- 4. CREACION DE TABLAS
----------------------------------------------------
CREATE TABLE dbo.Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(100)
);
GO

CREATE TABLE dbo.Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(200) NOT NULL,
    HireDate DATE NOT NULL,
    Salary INT NOT NULL,
    DepartmentID INT NULL
);
GO

CREATE TABLE dbo.Projects (
    ProjectID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectName NVARCHAR(150) NOT NULL,
    StartDate DATE NULL,
    EndDate DATE NULL,
    LeaderEmployeeID INT NULL
);
GO

CREATE TABLE dbo.Evaluations (
    EvalID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    EvalDate DATE NOT NULL,
    Score TINYINT NOT NULL CHECK (Score BETWEEN 1 AND 5),
    Comments NVARCHAR(400)
);
GO

----------------------------------------------------
-- 5. FOREIGN KEYS
----------------------------------------------------
ALTER TABLE dbo.Employees
ADD CONSTRAINT FK_Employees_Departments
FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID);

ALTER TABLE dbo.Projects
ADD CONSTRAINT FK_Projects_Employees
FOREIGN KEY (LeaderEmployeeID) REFERENCES dbo.Employees(EmployeeID);

ALTER TABLE dbo.Evaluations
ADD CONSTRAINT FK_Evaluations_Employees
FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees(EmployeeID);
GO

----------------------------------------------------
-- 6. INDICES
----------------------------------------------------
CREATE INDEX IX_Employees_DepartmentID ON dbo.Employees(DepartmentID);
CREATE INDEX IX_Projects_LeaderEmployeeID ON dbo.Projects(LeaderEmployeeID);
CREATE INDEX IX_Evaluations_EmployeeID ON dbo.Evaluations(EmployeeID);
GO

----------------------------------------------------
-- 7. INSERTAR DATOS
----------------------------------------------------

-- DEPARTAMENTOS
INSERT INTO dbo.Departments (DepartmentName, Location)
VALUES
('Recursos Humanos','Buenos Aires'),
('Desarrollo','CABA'),
('Ventas','Rosario'),
('Marketing','CABA'),
('Soporte','Mendoza'),
('Finanzas','Buenos Aires'),
('Operaciones','Cordoba'),
('Investigacion','La Plata');
GO

-- 100 EMPLEADOS
;WITH tally AS (
    SELECT TOP (100) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO dbo.Employees (FirstName, LastName, Email, HireDate, Salary, DepartmentID)
SELECT
    'Emp' + RIGHT('000' + CAST(n AS VARCHAR(3)),3),
    'Apellido' + CAST(n AS VARCHAR(3)),
    'emp' + CAST(n AS VARCHAR(3)) + '@example.com',
    DATEADD(day, -(n * 10), CAST(GETDATE() AS DATE)),
    30000 + (ABS(CHECKSUM(NEWID())) % 70000),
    CASE WHEN n % 10 = 0 THEN NULL ELSE (n % 8) + 1 END
FROM tally;
GO

-- 20 PROYECTOS
;WITH p AS (
    SELECT TOP (20) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO dbo.Projects (ProjectName, StartDate, EndDate, LeaderEmployeeID)
SELECT
    'Project ' + RIGHT('00' + CAST(n AS VARCHAR(2)),2),
    DATEADD(day, - (n * 20), GETDATE()),
    DATEADD(day, (n * 20), GETDATE()),
    CASE WHEN n % 4 = 0 THEN NULL
         ELSE (SELECT TOP 1 EmployeeID FROM dbo.Employees ORDER BY NEWID()) END
FROM p;
GO

-- 200 EVALUACIONES RANDOM
INSERT INTO dbo.Evaluations (EmployeeID, EvalDate, Score, Comments)
SELECT TOP (200)
    E.EmployeeID,
    DATEADD(month, -(ROW_NUMBER() OVER(ORDER BY E.EmployeeID) % 12), GETDATE()),
    (ABS(CHECKSUM(NEWID())) % 5) + 1,
    'Evaluacion para empleado ' + CAST(E.EmployeeID AS VARCHAR(10))
FROM dbo.Employees E
ORDER BY NEWID();
GO
```

### Entregable

Documento en Google Docs que contenga:

1. **Introduccion:** Breve explicacion del proposito del ejercicio.
2. **Desarrollo del ejercicio:** Las sentencias SQL utilizadas (SELECT, UPDATE, DELETE, transacciones) con una explicacion de cada paso.
3. **Conclusiones:** Reflexion sobre la importancia de cada patron seguro aplicado y capturas de pantalla de los resultados.

---
---

# WHERE y operadores: sintaxis y ejemplos

## Introduccion

¿Alguna vez necesitaste buscar algo especifico en una tabla con miles de datos? Por ejemplo: "mostrame solo los empleados que ganan mas de $50.000" o "busca los clientes de Buenos Aires". Para eso existe la clausula **WHERE** en SQL.

`WHERE` es el **filtro** de SQL. Sin el, cada consulta te devuelve **todo** el contenido de la tabla. Con `WHERE`, le decis a la base de datos: "solo quiero las filas que cumplan esta condicion".

---

## La clausula WHERE

### Sintaxis basica

```sql
SELECT columnas
FROM tabla
WHERE condicion;
```

**Ejemplo simple:**

```sql
SELECT * FROM empleados WHERE salario > 3000;
```

Esto devuelve solo los empleados cuyo salario es mayor a 3000. Los demas no aparecen.

---

## Operadores comparativos basicos

Son los simbolos que usas para **comparar valores**. Son iguales a los que usas en matematica:

| Operador | Significado | Ejemplo | ¿Que devuelve? |
|----------|------------|---------|----------------|
| `=` | Igual a | `WHERE edad = 30` | Personas con exactamente 30 anos |
| `<>` o `!=` | Diferente de | `WHERE estado <> 'activo'` | Personas que NO estan activas |
| `<` | Menor que | `WHERE precio < 100` | Productos mas baratos que $100 |
| `>` | Mayor que | `WHERE salario > 50000` | Empleados que ganan mas de $50.000 |
| `<=` | Menor o igual | `WHERE edad <= 18` | Menores de 18 o con exactamente 18 |
| `>=` | Mayor o igual | `WHERE stock >= 10` | Productos con 10 o mas unidades |

**Ejemplo:**

```sql
SELECT FirstName, LastName, Salary
FROM Employees
WHERE Salary >= 50000;
```

Esto muestra nombre, apellido y salario de todos los empleados que ganan $50.000 o mas.

---

## Operador BETWEEN (entre dos valores)

`BETWEEN` filtra valores que estan **dentro de un rango**, incluyendo ambos extremos.

**Sintaxis:**

```sql
WHERE columna BETWEEN valor_minimo AND valor_maximo;
```

**Ejemplo:**

```sql
SELECT * FROM Employees
WHERE Salary BETWEEN 40000 AND 60000;
```

Esto devuelve empleados que ganan entre $40.000 y $60.000 (incluidos ambos valores).

Es lo mismo que escribir:

```sql
WHERE Salary >= 40000 AND Salary <= 60000
```

Pero `BETWEEN` es mas corto y facil de leer.

> **Muy util con fechas:**
> ```sql
> SELECT * FROM Ventas
> WHERE Fecha BETWEEN '2024-01-01' AND '2024-01-31';
> ```
> Esto devuelve todas las ventas de enero 2024.

---

## Operador LIKE (buscar patrones en texto)

`LIKE` sirve para buscar **patrones** dentro de textos. Usa dos comodines especiales:

| Comodin | Significado | Ejemplo |
|---------|------------|---------|
| `%` | Cualquier cantidad de caracteres (0 o mas) | `'Mar%'` encuentra "Maria", "Marcos", "Mar" |
| `_` | Exactamente **un** caracter | `'_uan'` encuentra "Juan", "Luan", pero NO "Quan" si tiene mas letras |

### Ejemplos practicos

**Nombres que empiezan con "Mar":**

```sql
SELECT * FROM Employees WHERE FirstName LIKE 'Mar%';
```

Encuentra: Maria, Marcos, Martina, Mariano...

**Nombres que terminan con "ez":**

```sql
SELECT * FROM Employees WHERE LastName LIKE '%ez';
```

Encuentra: Lopez, Perez, Fernandez, Gomez...

**Nombres que contienen "car" en cualquier parte:**

```sql
SELECT * FROM Employees WHERE FirstName LIKE '%car%';
```

Encuentra: Carlos, Oscar, Ricardo...

**Emails de un dominio especifico:**

```sql
SELECT * FROM Employees WHERE Email LIKE '%@example.com';
```

Encuentra todos los empleados cuyo email termina en "@example.com".

**Nombres de exactamente 3 letras:**

```sql
SELECT * FROM Employees WHERE FirstName LIKE '___';
```

Tres guiones bajos = exactamente 3 caracteres. Encuentra: Ana, Leo, Max...

---

## Operador IN (esta en una lista)

`IN` filtra filas que coinciden con **cualquiera de los valores** de una lista. Es como preguntar: "¿esta en este grupo?"

**Sintaxis:**

```sql
WHERE columna IN (valor1, valor2, valor3);
```

**Ejemplo:**

```sql
SELECT * FROM Departments
WHERE Location IN ('Buenos Aires', 'CABA', 'Rosario');
```

Esto devuelve los departamentos ubicados en Buenos Aires, CABA o Rosario.

Es lo mismo que escribir:

```sql
WHERE Location = 'Buenos Aires'
   OR Location = 'CABA'
   OR Location = 'Rosario'
```

Pero `IN` es mucho mas limpio y facil de leer, especialmente cuando tenes muchos valores.

---

## NULL: El valor que no es un valor

### ¿Que es NULL?

`NULL` es uno de los conceptos mas confusos para principiantes. Significa **"no hay dato"**, **"desconocido"** o **"no se informo"**.

**NULL NO es:**
- No es cero (`0`)
- No es texto vacio (`''`)
- No es la palabra "null"

Es simplemente la **ausencia de valor**. Como una celda vacia en Excel.

### ¿Como filtrar por NULL?

Aca viene lo importante: **NO podes usar `=` ni `<>` para comparar con NULL**. Si lo haces, no funciona como esperas.

```sql
-- INCORRECTO (no funciona como esperas):
SELECT * FROM Employees WHERE DepartmentID = NULL;

-- CORRECTO:
SELECT * FROM Employees WHERE DepartmentID IS NULL;
```

```sql
-- INCORRECTO:
SELECT * FROM Employees WHERE DepartmentID <> NULL;

-- CORRECTO:
SELECT * FROM Employees WHERE DepartmentID IS NOT NULL;
```

### ¿Por que no funciona con `=`?

Porque NULL significa "desconocido". Si le preguntas a SQL "¿es NULL igual a NULL?", la respuesta es **"no se"** (ni verdadero ni falso). Por eso siempre usa `IS NULL` o `IS NOT NULL`.

### Ejemplo practico

En nuestra tabla de empleados, algunos no tienen departamento asignado (su DepartmentID es NULL):

```sql
-- Empleados SIN departamento asignado
SELECT FirstName, LastName
FROM Employees
WHERE DepartmentID IS NULL;

-- Empleados CON departamento asignado
SELECT FirstName, LastName
FROM Employees
WHERE DepartmentID IS NOT NULL;
```

---

## Combinando operadores con AND y OR

Podes combinar varias condiciones en un solo WHERE:

- **AND** = ambas condiciones deben cumplirse
- **OR** = al menos una condicion debe cumplirse

**Ejemplo con AND:**

```sql
SELECT * FROM Employees
WHERE Salary > 50000
  AND DepartmentID = 2;
```

Empleados que ganan mas de $50.000 **Y** pertenecen al departamento 2.

**Ejemplo con OR:**

```sql
SELECT * FROM Employees
WHERE DepartmentID = 1
   OR DepartmentID = 3;
```

Empleados del departamento 1 **O** del departamento 3.

**Ejemplo combinado (usa parentesis para claridad):**

```sql
SELECT * FROM Employees
WHERE (DepartmentID = 1 OR DepartmentID = 2)
  AND Salary > 40000;
```

Empleados de los departamentos 1 o 2, pero solo los que ganan mas de $40.000.

> **Tip:** Siempre usa **parentesis** cuando combines AND y OR, para que quede claro el orden de evaluacion. Sin parentesis, AND se evalua antes que OR y podes obtener resultados inesperados.

---

## Resumen de operadores

| Operador | Uso | Ejemplo |
|----------|-----|---------|
| `=` | Igualdad | `WHERE edad = 30` |
| `<>` o `!=` | Diferente | `WHERE estado != 'activo'` |
| `>`, `<`, `>=`, `<=` | Comparacion | `WHERE salario > 50000` |
| `BETWEEN` | Rango inclusivo | `WHERE fecha BETWEEN '2024-01-01' AND '2024-01-31'` |
| `LIKE` | Patron de texto | `WHERE nombre LIKE 'J%'` |
| `IN` | Inclusion en lista | `WHERE categoria IN ('A', 'B', 'C')` |
| `IS NULL` | Valor nulo | `WHERE fecha IS NULL` |
| `IS NOT NULL` | Valor no nulo | `WHERE fecha IS NOT NULL` |
| `AND` | Ambas condiciones | `WHERE edad > 18 AND activo = 1` |
| `OR` | Al menos una condicion | `WHERE ciudad = 'CABA' OR ciudad = 'Rosario'` |

> **Tip final:** Filtrar datos correctamente es una de las habilidades mas importantes en SQL. Un filtro mal escrito puede devolverte datos incorrectos o incompletos, y eso puede llevar a decisiones equivocadas. Siempre verifica tus resultados.
