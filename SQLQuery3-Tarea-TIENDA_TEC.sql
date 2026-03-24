--Creacion de la Base de Datos
Create Database TIENDA_TEC

Use TIENDA_TEC
Go

--Creacion de tablas
Create Table PRODUCTOS (
ProductoID int identity primary key, --La llave primaria de la tabla
DescripcionART varchar(100) not null, --Descripcion y/o articulo
ValorMonetario float not null, --Precio del articulo, referencia en dolares
ExistenciasACT int not null,  --Cantidad de articulos por fila

Constraint CHK_ValorMonetario Check (ValorMonetario > 0), --Chequeo para que el valor monetario no pueda ser menor a cero
Constraint CHK_ExistenciasACT Check (ExistenciasACT >= 0) --Chequeo para saber si las existencias actuales son iguales o mayor a cero
)
Go

Create table VENTAS (
TransaccionID int identity primary key, --Llave primaria de la tabla
ProductoID int not null,  --Llave foranea de la tabla, siendo el enlace con la tabla PRODUCTOS
CantidadADQ int,  --Cantidad de articulos adquiridos en venta
FechaHora datetime, --Fecha exacta de la venta

Constraint CHK_CantidadADQ Check (CantidadADQ > 0), --Chequeo para que la cantidad vendida siempre sea un numero mayor a cero

Foreign Key (ProductoID) --Aqui declaramos la llave foranea, permitiendo el enlace o relacion con la otra tabla que utiliza el valor ProductoID como llave principal, siendo PRODUCTOS
References PRODUCTOS(ProductoID) --Aqui hace referencia a la llave foranea de PRODUCTOS
)
Go

--Ingreso de datos o valores a la tabla PRODUCTOS basado en el paso 2 de la tarea
Insert PRODUCTOS (DescripcionART, ValorMonetario,ExistenciasACT) 
Values ('Razer BlackWidow V4 Pro 75%', 120.00, 12)

Insert PRODUCTOS (DescripcionART, ValorMonetario,ExistenciasACT) 
Values ('Razer Viper V3 Pro', 95.50, 20)

Insert PRODUCTOS (DescripcionART, ValorMonetario,ExistenciasACT) 
Values ('Laptop Alienware m18 R2', 2700.00, 6)

Insert PRODUCTOS (DescripcionART, ValorMonetario,ExistenciasACT) 
Values ('ASUS ROG Zephyrus G14', 2200.00, 10)

Insert PRODUCTOS (DescripcionART, ValorMonetario,ExistenciasACT) 
Values ('Lenovo Legion Pro', 1800.00, 5)

--Actualizacion del ValorMonetario en PRODUCTOS, aumentado en 15%
Update PRODUCTOS
Set ValorMonetario = ValorMonetario * 1.15

Select * From PRODUCTOS
Where ExistenciasACT = 0 --Esto es para revisar que articulo va a ser borrado al llegar a cero y asi estar consciente de eso

Delete From PRODUCTOS --Aqui ya borrariamos del campo ExistenciasACT cualquier articulo que tenga un stock = 0
Where ExistenciasACT = 0
And ProductoID Not In (
	Select ProductoID From VENTAS --Para evitar un posible error con la llave foranea (ProductoID) en ventas
)
--Se usa el Delete de esta forma porque no podemos eliminar un producto que tenga ventas, ya que eso afecta a la referencia historica
--por lo que en la vida real no es correcto ya que si un articulo llega a 0 deberiamos rellenarlo, no eliminarlo

--Buscar productos que esten en el rango de 100 a 1000
Select * From PRODUCTOS
Where ValorMonetario Between 100 And 1000

--Buscar productos en un rango de 1500 a 3000 EXTRA
Select * From PRODUCTOS
Where ValorMonetario Between 1500 And 3000

--Mayor a 3000 EXTRA
Select * From PRODUCTOS
Where ValorMonetario > 3000

--Articulos que contengan "Pro" en su nombre
Select * From PRODUCTOS
Where DescripcionART Like '%Pro%'

--Aqui sacamos el valor total de nuestro inventario multiplicando el precio x la cantidad de articulos y luego se suma todo
Select SUM(ValorMonetario * ExistenciasACT) As ValorTotalInventario
From PRODUCTOS
Where ExistenciasACT > 0 --Esto seria un añadido, ya que si llega a 0 el stock del articulo para que no sea tomado en cuenta y pueda generar errores

--Promedio de los precios de los articulos, la funcion AVG() realiza el promedio del campo de numeros que necesitamos
Select AVG(ValorMonetario) As PromedioPrecio
From PRODUCTOS
Where ExistenciasACT > 0 --Aqui seria un añadido igual al anterior, para que solo tome en cuenta articulos con existencias
Go

--Aqui vendra la lista d articulos ordenados por precio descendente
Create or Alter Procedure sp_CatalogoOrdenado
As
Begin
	Select * From PRODUCTOS
	Order By ValorMonetario DESC
End
Go

--Declaracion del limite para la alerta de los articulos en existencias
Create or Alter Procedure sp_AlertaExistencias
@Limite int
As
Begin
	Select * From PRODUCTOS
	Where ExistenciasACT <= @Limite
End
Go


--Aqui registraremos la transaccion de las ventas
Create or Alter Procedure sp_RegistrarTransaccion
@ProductoID int,
@Cantidad int
As
Begin
	Declare @StockActual int  --Como necesidad para un funcionamiento mas realista, aqui necesitamos comprobar si el stock esta disponible
	Select @StockActual = ExistenciasACT
	From PRODUCTOS
	Where ProductoID = ProductoID

	If @StockActual Is Null --Para verificar si el producto existe
	Begin
		Print 'No existe este articulo'
		Return
	End

	If @Cantidad > @StockActual --Aqui si comprobamos para impedir la venta de X articulos mayores que el stock actual
	Begin
		Print 'No hay suficientes existencias de este articulo'
		Return
	End

	Insert Into VENTAS(ProductoID, CantidadADQ, FechaHora)
	Values (@ProductoID, @Cantidad, GetDate())
	Update PRODUCTOS --Esta parte seria para descontar el stock de los articulos vendidos
	Set ExistenciasACT = ExistenciasACT - @Cantidad
	Where ProductoID = @ProductoID
End
Go

--Aqui cambiaremos el coste de los productos cuando queramos actualizarles el valor
Create or Alter Procedure sp_CambiarCosto
@ProductoID int,
@NuevoValor float
As
Begin
	Update PRODUCTOS
	Set ValorMonetario = @NuevoValor
	Where ProductoID = @ProductoID
End
Go

--Aqui utilizaremos el Group By para ver la totalidad de unidades vendidas en grupos
Select
	p.DescripcionART, --Colocamos el alias de PRODUCTOS como p, esto seria para pedir el nombre del producto a vender
	SUM(v.CantidadADQ) As TotalVendidas --Aqui utilizamos el alias v de VENTAS , y la suma de la cantidad adquirida sera TotalVendidas
From VENTAS v  --Aqui declaramos el v como alias
Inner Join PRODUCTOS p --Utilizando el Inner Join me permite unir las 2 tablas
	On v.ProductoID = p.ProductoID --Siendo la v.ProductoID = p.ProductoID, teniendo el alias de ambas tablas, con el On, siendo algo asi como relacionar cada venta con su producto
Group By p.DescripcionART --Aqui nos ayuda a agrupar las ventas por productos por total
Go

Exec sp_CatalogoOrdenado --Prueba de catalogo ordenado
Select * From PRODUCTOS --Comparacion orden

Exec sp_AlertaExistencias 5 --Comprobacion de las existencias

Exec sp_RegistrarTransaccion 1, 2 --Prueba Transaccion
Select * From PRODUCTOS --Resultado transaccion en articulos
Select * From VENTAS  --Registro de la venta en VENTAS
Exec sp_RegistrarTransaccion 100, 1 --Comprobacion de la llave foranea si no existe el ID
Exec sp_RegistrarTransaccion 1, 100 --Comprobacion Check si es mas de las unidades actuales en stock

Exec sp_CambiarCosto 1, 140.00 --Cambio de precio a articulo
Update PRODUCTOS
Set ValorMonetario = ValorMonetario * 1.15 --Actualizacion con el coste del 15%
Where ProductoID = 1
Select * From PRODUCTOS 
Where ProductoID = 1 --Comprobacion del cambio final realizado
Exec sp_CambiarCosto 1, -10 --Comprobacion para error debido al Check, para que no existan montos negativos

/* La importancia de definir correctamente los tipos de datos, es porque estos son nuestras herramientas de trabajo, al definir bien
sus datos nos permite el poblar una tabla de la forma indicada, sin tener errores, esto con el fin de saber que si necesitamos utilizar
un campo con un tipo de dato especifico, el resultado aparte de ser un error, no nos va a saltar algo como "Descripcion Articulo   1".
Normalmente ocuparemos definir bien los datos para poder trabajar con las distintas funciones que tienen los lenguajes de programacion,
porque de no hacerlo simplemente no podremos avanzar sin errores, y aparte con datos como los int o float, en caso general seria mejor
utilizar los float por alguna situacion donde un resultado de alguna operacion sea con decimales, y si el resultado se almacena en alguna 
variable o lo tiene que mostrar algun campo, si el mismo no acepta mas que int pues no nos dara el monto correcto
En caso de las bases de datos se nota algo mas flexible, pero para lograr optimizar el almacenamiento y mejorar el rendimiento de las consultas
necesitaremos utilizar los datos adecuados, ademas el utilizar restricciones como Check o Not Null es una buena practica ya que nos permite
evitar inconsistencias en los datos, impidiendo que queden los conocidos datos huerfanos.