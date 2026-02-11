-- seleccionar la base
use negocio;

-- muestra las tablas de la base actual
show tables;

-- muestra la estructura de la tabla clientes
describe clientes;

-- muestra todos los campos de la tabla clientes
select * from clientes;-- * : todos los campos

-- muestra algunos campos de la tabla clientes
select 		telefono 
			,nombre 
			,apellido 
			-- direccion 
from 		clientes
-- order by	apellido;-- orden alfabetico --> tambien lo hago con asc = ascendente
-- order by	telefono asc;-- ordena de menor a mayor
order by	apellido desc;-- orden analfabetico --> de la z a la a
-- orden analfabetico x apellido y alfabetico por nombre
-- cuando empatan en el apellido, desempata el nombre en forma alfabetica
-- order by	apellido desc, nombre asc;

describe productos;

-- uso de columnas agregadas(solo valido para la consulta, no se agrega nada de esto a la tabla)
select 	articulo
		,precio
		,round(precio * 1.21)-- columna agregada a la consulta --> precio con IVA --> LE SACO LOS DECIMALES
		,truncate(precio * 1.21,3) as 'precio con IVA'-- uso de alias o titulo de la columna
		, 'esto es un comentario'-- columna agregada
		,now() as hora -- alias de columna --> now es una funcion de mySQL q me da la hora cuando se hizo la consulta
		,marca

from 	productos;

-- 12,367 --> round a 2 decimales -> 12,37
-- 12,367 --> truncate a 2 decimales -> 12,36

select now() from productos;

select now() as 'fecha de consulta' from dual;-- tabla virtual dual que se crea 
-- junto a la base de datos. La uso cuando traigo columnas al select q no esten en la tabla


describe facturas;-- muestra todos los registros de la tabla clientes

/*
	operadores aritmeticos: + - * /
	operadores relacionales: < > <=  >= =  <> o !=
	operadores logicos: and  or  not
*/
-- filtro de registros --> se hace con la clausula where(significa DONDE)
-- listar los productos entre 100 y 150 pesos
select 		* 
from 		productos
-- where		precio >= 100 and precio <= 150 -- intervalo cerrado
 where		precio between 100 and 150 -- between(significa ENTRE) incluye extremos!
--   where		precio between 150 and 100 -- no colocar el valor mayor primero!!
order by	precio desc,idproducto asc;

-- listar las facturas del año 2017
-- Para campos de tipo date(fecha) usar formato japones
select 	* 
from 	facturas
-- where	fecha between '2017-01-01' and '2017-12-31';-- primero fecha mas antigua
-- not between NO incluye extremos!
-- where	fecha not between '2017-01-01' and '2017-12-31';-- facturas q no sean del año 2017
-- where	year(fecha) = 2017;-- es una variante al between para todo un año
where	not year(fecha) = 2017;-- facturas q no sean del 2017
-- year es una funcion mySQL q extrae solo el año de un valor de tipo date
-- para extraer mes --> month(fecha) y el dia --> day(fecha)

-- listar las facturas del segundo semestre del 2017
select 	* 
from 	facturas 
where 	fecha between '2017-07-01' and '2017-12-31';
-- poner la fecha mas antigua primero! con el operador de rango between

-- variante(traer la factura de una unica fecha)
select 	* 
from 	facturas 
where 	year(fecha) = 2017 and month(fecha) = 8 and day(fecha) = 21;

-- listar las prendas cuyo talle sea 1, 2 o 5

select 	* 
from 	productos
where	talle = 1 or talle = 2 or talle = 5;
-- where	talle in (1 , 2 , 5);-- in: operador de lista
-- where	talle not in (1 , 2 , 5);-- q no sean ni 1 ni 2 ni el 5

-- listar las facturas a o b
select 	* 
from 	facturas
where	tipo in ('a' , 'b');

-- listar las prendas que empiecen en p(usamos el operador de similitud LIKE)
select 	*
from	productos
 -- where	articulo like 'p%';-- %: comodin q indica cualquier cantidad de caracteres
 where	articulo not like 'p%';-- q NO empiecen con p

-- listar las prendas que terminen en o
select 	*
from	productos
where	articulo like '%o';

-- listar las prendas que empiecen con c y terminen en a
select 	*
from	productos
where	articulo like 'c%a';

-- listar los nombres de clientes q empiecen con m, el 2do caracter sea cualquiera,
-- el tercer caracter sea una r y no importe como termine

/*
maria
martin
marta
miranda
mirtha
moria
miriam
martina
mirko
marco
marcos
mirna
morena
*/

select	*
from	clientes
where	nombre like 'm_r%';-- _ (guion bajo) es comodin de un solo caracter en esa posicion

-- selecciono la base pubs por defecto
use pubs;

-- listo todos los empleados de la base pubs
select * from employee;

-- listar los empleados que ingresaron a trabajar en 1992
select 	* 
from 	employee 
 -- where	year(hire_date) = 1992;-- hire_data: fecha de ingreso
 where	hire_date like '%1992%';-- forma alternativa con like


-- operador rlike: expresion regular
-- listar los nombres de los empleados q empiecen con a
select		*
from		employee
where		fname rlike '^a';-- acento circunflejo o frances ^ --> alt + 94
-- where		fname like 'a%';-- forma alternativa con el operador like


-- listar los nombres de los empleados q terminen con n
select		*
from		employee
 where		fname rlike 'n$';
-- where		fname like '%n';-- forma alternativa con like

-- listar los nombres de los empleados q empiece con s y termine con n
select		*
from		employee
where		fname rlike '^s.*n$';-- :   .* es equivalente al comodin % del like


-- listar los primeros 5 titulos
select 	* 
from 	titles
limit	5;-- clausula limit

-- listar los 5 titulos mas caros
select 		* 
from 		titles
order by	price desc -- ordeno por precio en forma descendente
limit		5;-- luego, corto en los 5 mas caros

-- listar los 5 titulos mas baratos cuyo precio no sea nulo
-- operador is null y operador is not null
-- null: es ausencia de valor
select 		* 
from 		titles
-- where		price is not null
 where		price is null
order by	price asc -- orden ascendente: del mas barato al mas caro
limit		5;

-- clausula distinct: devuelve los diferentes valores de una columna(sin repeticiones)
-- listar los diferentes paises en los que reside los autores sin repeticiones
select state from authors;-- este es con repeticion(se repite CA CALIFORNIA)
select distinct(state) from authors;-- este es sin repeticion

select 	*
from 	publishers
limit	5,2;-- offset: 5(se corre 5 registros) y luego muestra los 2 siguientes

-- Ejercitacion base pubs
-- 18.Listar todos los autores cuya dirección termine con un número 
-- y que la segunda letra de su apellido sea R. 
select 	*
from 	authors
where	address rlike '[0-9]$' and au_lname like '_r%';


-- 19.Mostrar todos los empleados cuyo nombre empiece con la 
-- letra P ó A. La segunda letra no sea A y la última letra esté 
-- entre la H y la Z. 
select	*
from	employee
where	fname rlike '^[a,p][^a].*[h-z]$';-- .* equivale a % en like
-- where	fname rlike '^[a,p]';-- lista: empieza con a o con p
-- where	fname rlike '^[a-p]';-- q empiece con el rango a-p
-- where	fname rlike '[a-h]$';--nombre que termine entre a y h
-- where	fname rlike '[^a]$';-- nombre q no termine en a
-- where	fname rlike '[^a-h]$';-- nombre q no termine en ese rango






















