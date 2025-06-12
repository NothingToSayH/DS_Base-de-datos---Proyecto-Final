USE dbCorporativoValuCalderon;
GO
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------

--TABLA Motos Listar--

IF OBJECT_ID('sp_Lista_Motos', 'P') IS NOT NULL
    DROP PROCEDURE sp_Lista_Motos
GO

CREATE PROCEDURE sp_Lista_Motos (
    @IDMoto VARCHAR(20) = NULL,
    @IDCategoria VARCHAR(5) = NULL,
    @motoMarca VARCHAR(50) = NULL,
    @motoModelo VARCHAR(50) = NULL,
    @motoAño INT = NULL,
    @motoColor VARCHAR(30) = NULL,
    @motoCilindrada VARCHAR(20) = NULL,
    @motoStock INT = NULL,
    @motoPrecio DECIMAL(10, 2) = NULL,
    @RUC VARCHAR(11) = NULL
)
AS
BEGIN
    SELECT *
    FROM tblMotos
    WHERE (@IDMoto IS NULL OR IDMoto LIKE '%' + @IDMoto + '%')
      AND (@IDCategoria IS NULL OR IDCategoria LIKE '%' + @IDCategoria + '%')
      AND (@motoMarca IS NULL OR motoMarca LIKE '%' + @motoMarca + '%')
      AND (@motoModelo IS NULL OR motoModelo LIKE '%' + @motoModelo + '%')
      AND (@motoAño IS NULL OR motoAño = @motoAño)
      AND (@motoColor IS NULL OR motoColor LIKE '%' + @motoColor + '%')
      AND (@motoCilindrada IS NULL OR motoCilindrada LIKE '%' + @motoCilindrada + '%')
      AND (@motoStock IS NULL OR motoStock = @motoStock)
      AND (@motoPrecio IS NULL OR motoPrecio = @motoPrecio)
      AND (@RUC IS NULL OR RUC LIKE '%' + @RUC + '%');
END
GO
select * from tblMotos
EXEC sp_Lista_Motos @IDMoto = '3';
go


--TABLA Motos Agregar--

IF OBJECT_ID('sp_Agregar_Motos', 'P') IS NOT NULL
    DROP PROCEDURE sp_Agregar_Motos
GO

CREATE PROCEDURE sp_Agregar_Motos (
    @IDMoto VARCHAR(20),
    @IDCategoria VARCHAR(5),
    @motoMarca VARCHAR(50),
    @motoModelo VARCHAR(50),
    @motoAño INT,
    @motoColor VARCHAR(30),
    @motoCilindrada VARCHAR(20),
    @motoStock INT,
    @motoPrecio DECIMAL(10, 2),
    @RUC VARCHAR(11))
AS
BEGIN
    IF EXISTS (SELECT 1 FROM tblMotos WHERE IDMoto = @IDMoto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: Dato Existente';
    END
    ELSE
    BEGIN
        INSERT INTO tblMotos (IDMoto, IDCategoria, motoMarca, motoModelo, motoAño, motoColor, motoCilindrada, motoStock, motoPrecio, RUC)
        VALUES (@IDMoto, @IDCategoria, @motoMarca, @motoModelo, @motoAño, @motoColor, @motoCilindrada, @motoStock, @motoPrecio, @RUC);
        SELECT CodError = 0, Mensaje = 'Dato agregado correctamente';
    END
END
GO
select * from tblMotos

EXEC sp_Agregar_Motos @IDMoto = 'MOTO0033',@IDCategoria = 'CM005', @motoMarca = 'Yamaha', @motoModelo = 'FZ-S', @motoAño = 2022, @motoColor = 'Rojo',  @motoCilindrada = '150cc', @motoStock = 10, @motoPrecio = 12000.50, @RUC = '20100000001';
go

--TABLA Motos Actualizar--

IF OBJECT_ID('sp_Actualizar_Motos', 'P') IS NOT NULL
    DROP PROCEDURE sp_Actualizar_Motos
GO

CREATE PROCEDURE sp_Actualizar_Motos (
    @IDMoto VARCHAR(20),
    @IDCategoria VARCHAR(5),
    @motoMarca VARCHAR(50),
    @motoModelo VARCHAR(50),
    @motoAño INT,
    @motoColor VARCHAR(30),
    @motoCilindrada VARCHAR(20),
    @motoStock INT,
    @motoPrecio DECIMAL(10, 2),
    @RUC VARCHAR(11)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblMotos WHERE IDMoto = @IDMoto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: No existe el dato que desea actualizar';
    END
    ELSE
    BEGIN
        UPDATE tblMotos
        SET
            IDCategoria = @IDCategoria,
            motoMarca = @motoMarca,
            motoModelo = @motoModelo,
            motoAño = @motoAño,
            motoColor = @motoColor,
            motoCilindrada = @motoCilindrada,
            motoStock = @motoStock,
            motoPrecio = @motoPrecio,
            RUC = @RUC
        WHERE IDMoto = @IDMoto;
        SELECT CodError = 0, Mensaje = 'Dato actualizado correctamente';
    END
END
GO

select * from tblMotos

EXEC sp_Actualizar_Motos
    @IDMoto = 'MOTO0033', @IDCategoria = 'CM005', 
    @motoMarca = 'Yamaha', @motoModelo = 'FZ-S',  @motoAño = 2022,  @motoColor = 'Azul Metálico',  @motoCilindrada = '150cc',   @motoStock = 10,  @motoPrecio = 12500.00, @RUC = '20100000001';
GO

--TABLA Motos Eliminar--

IF OBJECT_ID('sp_Eliminar_Motos', 'P') IS NOT NULL
    DROP PROCEDURE sp_Eliminar_Motos
GO

CREATE PROCEDURE sp_Eliminar_Motos (
    @IDMoto VARCHAR(20)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblMotos WHERE IDMoto = @IDMoto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: No existe el dato que desea eliminar';
    END
    ELSE
    BEGIN
        DELETE FROM tblMotos WHERE IDMoto = @IDMoto;
        SELECT CodError = 0, Mensaje = 'Dato eliminado correctamente';
    END
END
GO

select * from tblMotos

EXEC sp_Eliminar_Motos @IDMoto = 'MOTO0033';
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--TABLA Repuestos Listar--

IF OBJECT_ID('sp_Lista_Repuestos', 'P') IS NOT NULL
    DROP PROCEDURE sp_Lista_Repuestos
GO

CREATE PROCEDURE sp_Lista_Repuestos (
    @IDRepuesto VARCHAR(20) = NULL,
    @IDCategoriaRepuesto VARCHAR(5) = NULL,
    @repNombre VARCHAR(100) = NULL,
    @repMarca VARCHAR(50) = NULL,
    @repCompatibilidad VARCHAR(100) = NULL,
    @repStock INT = NULL,
    @repPrecio DECIMAL(10, 2) = NULL,
    @RUC VARCHAR(11) = NULL
)
AS
BEGIN
    SELECT *
    FROM tblRepuestos
    WHERE (@IDRepuesto IS NULL OR IDRepuesto LIKE '%' + @IDRepuesto + '%')
      AND (@IDCategoriaRepuesto IS NULL OR IDCategoriaRepuesto LIKE '%' + @IDCategoriaRepuesto + '%')
      AND (@repNombre IS NULL OR repNombre LIKE '%' + @repNombre + '%')
      AND (@repMarca IS NULL OR repMarca LIKE '%' + @repMarca + '%')
      AND (@repCompatibilidad IS NULL OR repCompatibilidad LIKE '%' + @repCompatibilidad + '%')
      AND (@repStock IS NULL OR repStock = @repStock)
      AND (@repPrecio IS NULL OR repPrecio = @repPrecio)
      AND (@RUC IS NULL OR RUC LIKE '%' + @RUC + '%');
END
GO

select * from tblRepuestos

EXEC sp_Lista_Repuestos @IDRepuesto = '2';
go

--TABLA Repuestos Agregar--

IF OBJECT_ID('sp_Agregar_Repuestos', 'P') IS NOT NULL
    DROP PROCEDURE sp_Agregar_Repuestos
GO

CREATE PROCEDURE sp_Agregar_Repuestos (
    @IDRepuesto VARCHAR(20),
    @IDCategoriaRepuesto VARCHAR(5),
    @repNombre VARCHAR(100),
    @repMarca VARCHAR(50),
    @repCompatibilidad VARCHAR(100),
    @repStock INT,
    @repPrecio DECIMAL(10, 2),
    @RUC VARCHAR(11)
)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM tblRepuestos WHERE IDRepuesto = @IDRepuesto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: Dato Existente';
    END
    ELSE
    BEGIN
        INSERT INTO tblRepuestos (IDRepuesto, IDCategoriaRepuesto, repNombre, repMarca, repCompatibilidad, repStock, repPrecio, RUC)
        VALUES (@IDRepuesto, @IDCategoriaRepuesto, @repNombre, @repMarca, @repCompatibilidad, @repStock, @repPrecio, @RUC);
        SELECT CodError = 0, Mensaje = 'Dato agregado correctamente';
    END
END
GO

select * from tblRepuestos

EXEC sp_Agregar_Repuestos 
    @IDRepuesto = 'REP00036', 
    @IDCategoriaRepuesto = 'CR001', 
    @repNombre = 'Pastillas de Freno Traseras', 
    @repMarca = 'Brembo', 
    @repCompatibilidad = 'Universal para motos 150cc', 
    @repStock = 25, 
    @repPrecio = 150.00, 
    @RUC = '20100000002';
GO

--TABLA Repuestos Actualizar--

IF OBJECT_ID('sp_Actualizar_Repuestos', 'P') IS NOT NULL
    DROP PROCEDURE sp_Actualizar_Repuestos
GO

CREATE PROCEDURE sp_Actualizar_Repuestos (
    @IDRepuesto VARCHAR(20),
    @IDCategoriaRepuesto VARCHAR(5),
    @repNombre VARCHAR(100),
    @repMarca VARCHAR(50),
    @repCompatibilidad VARCHAR(100),
    @repStock INT,
    @repPrecio DECIMAL(10, 2),
    @RUC VARCHAR(11)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblRepuestos WHERE IDRepuesto = @IDRepuesto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: No existe el dato que desea actualizar';
    END
    ELSE
    BEGIN
        UPDATE tblRepuestos
        SET
            IDCategoriaRepuesto = @IDCategoriaRepuesto,
            repNombre = @repNombre,
            repMarca = @repMarca,
            repCompatibilidad = @repCompatibilidad,
            repStock = @repStock,
            repPrecio = @repPrecio,
            RUC = @RUC
        WHERE IDRepuesto = @IDRepuesto;
        SELECT CodError = 0, Mensaje = 'Dato actualizado correctamente';
    END
END
GO

select * from tblRepuestos
EXEC sp_Actualizar_Repuestos
    @IDRepuesto = 'REP00036', 
    @IDCategoriaRepuesto = 'CR001', 
    @repNombre = 'Pastillas de Freno Traseras', 
    @repMarca = 'Brembo', 
    @repCompatibilidad = 'Universal para motos 150cc', 
    @repStock = 30, 
    @repPrecio = 155.00,
    @RUC = '20100000002';
GO


--TABLA Repuestos Eliminar--

IF OBJECT_ID('sp_Eliminar_Repuestos', 'P') IS NOT NULL
    DROP PROCEDURE sp_Eliminar_Repuestos
GO

CREATE PROCEDURE sp_Eliminar_Repuestos (
    @IDRepuesto VARCHAR(20)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblRepuestos WHERE IDRepuesto = @IDRepuesto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: No existe el dato que desea eliminar';
    END
    ELSE
    BEGIN
        DELETE FROM tblRepuestos WHERE IDRepuesto = @IDRepuesto;
        SELECT CodError = 0, Mensaje = 'Dato eliminado correctamente';
    END
END
GO

select * from tblRepuestos

EXEC sp_Eliminar_Repuestos @IDRepuesto = 'REP00036';
GO

------------------------------------------------------------------------------------------------------------------------------------------------------------

--TABLA DetalleVenta Listar--

IF OBJECT_ID('sp_Listar_DetalleVenta', 'P') IS NOT NULL
    DROP PROCEDURE sp_Listar_DetalleVenta
GO

CREATE PROCEDURE sp_Listar_DetalleVenta (
    @IDVenta VARCHAR(20) = NULL,
    @IDProducto VARCHAR(20) = NULL,
    @TipoProducto VARCHAR(10) = NULL,
    @detCantidad INT = NULL,
    @detPrecioUnitario DECIMAL(10, 2) = NULL,
    @detDescuento DECIMAL(10, 2) = NULL,
    @detSubTotal DECIMAL(10, 2) = NULL
)
AS
BEGIN
    SELECT *
    FROM tblDetalleVenta
    WHERE (@IDVenta IS NULL OR IDVenta LIKE '%' + @IDVenta + '%')
      AND (@IDProducto IS NULL OR IDProducto LIKE '%' + @IDProducto + '%')
      AND (@TipoProducto IS NULL OR TipoProducto LIKE '%' + @TipoProducto + '%')
      AND (@detCantidad IS NULL OR detCantidad = @detCantidad)
      AND (@detPrecioUnitario IS NULL OR detPrecioUnitario = @detPrecioUnitario)
      AND (@detDescuento IS NULL OR detDescuento = @detDescuento)
      AND (@detSubTotal IS NULL OR detSubTotal = @detSubTotal);
END
GO

select * from tblRepuestos

EXEC sp_Listar_DetalleVenta @IDVenta = '2';
go

--TABLA DetalleVenta Agregar--

IF OBJECT_ID('sp_Agregar_DetalleVenta', 'P') IS NOT NULL
    DROP PROCEDURE sp_Agregar_DetalleVenta
GO

CREATE PROCEDURE sp_Agregar_DetalleVenta (
    @IDVenta VARCHAR(20),
    @IDProducto VARCHAR(20),
    @TipoProducto VARCHAR(10),
    @detCantidad INT,
    @detPrecioUnitario DECIMAL(10, 2),
    @detDescuento DECIMAL(10, 2),
    @detSubTotal DECIMAL(10, 2)
)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM tblDetalleVenta WHERE IDVenta = @IDVenta AND IDProducto = @IDProducto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: Dato Existente';
    END
    ELSE
    BEGIN
        INSERT INTO tblDetalleVenta (IDVenta, IDProducto, TipoProducto, detCantidad, detPrecioUnitario, detDescuento, detSubTotal)
        VALUES (@IDVenta, @IDProducto, @TipoProducto, @detCantidad, @detPrecioUnitario, @detDescuento, @detSubTotal);
        SELECT CodError = 0, Mensaje = 'Dato agregado correctamente';
    END
END
GO

select * from tblDetalleVenta

EXEC sp_Agregar_DetalleVenta
    @IDVenta = 'VNT000001',
    @IDProducto = 'REP00001',
    @TipoProducto = 'Repuesto',
    @detCantidad = 2,
    @detPrecioUnitario = 350.00,
    @detDescuento = 0,
    @detSubTotal = 700.00;
GO

--TABLA DetalleVenta Actualizar--

IF OBJECT_ID('sp_Actualizar_DetalleVenta', 'P') IS NOT NULL
    DROP PROCEDURE sp_Actualizar_DetalleVenta
GO

CREATE PROCEDURE sp_Actualizar_DetalleVenta (
    @IDVenta VARCHAR(20),
    @IDProducto VARCHAR(20),
    @TipoProducto VARCHAR(10),
    @detCantidad INT,
    @detPrecioUnitario DECIMAL(10, 2),
    @detDescuento DECIMAL(10, 2),
    @detSubTotal DECIMAL(10, 2)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblDetalleVenta WHERE IDVenta = @IDVenta AND IDProducto = @IDProducto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: No existe el dato que desea actualizar';
    END
    ELSE
    BEGIN
        UPDATE tblDetalleVenta
        SET TipoProducto = @TipoProducto,
            detCantidad = @detCantidad,
            detPrecioUnitario = @detPrecioUnitario,
            detDescuento = @detDescuento,
            detSubTotal = @detSubTotal
        WHERE IDVenta = @IDVenta AND IDProducto = @IDProducto;
        SELECT CodError = 0, Mensaje = 'Dato actualizado correctamente';
    END
END
GO

select * from tblDetalleVenta
EXEC sp_Actualizar_DetalleVenta
    @IDVenta = 'VNT000001',
    @IDProducto = 'REP00001',
    @TipoProducto = 'Repuesto',
    @detCantidad = 3, 
    @detPrecioUnitario = 350.00,
    @detDescuento = 25.00,
    @detSubTotal = 1025.00; 
GO

--TABLA DetalleVenta Eliminar--

IF OBJECT_ID('sp_Eliminar_DetalleVenta', 'P') IS NOT NULL
    DROP PROCEDURE sp_Eliminar_DetalleVenta
GO

CREATE PROCEDURE sp_Eliminar_DetalleVenta (
    @IDVenta VARCHAR(20),
    @IDProducto VARCHAR(20)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblDetalleVenta WHERE IDVenta = @IDVenta AND IDProducto = @IDProducto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: No existe el dato que desea eliminar';
    END
    ELSE
    BEGIN
        DELETE FROM tblDetalleVenta
        WHERE IDVenta = @IDVenta AND IDProducto = @IDProducto;
        SELECT CodError = 0, Mensaje = 'Dato eliminado correctamente';
    END
END
GO

select * from tblRepuestos

EXEC sp_Eliminar_DetalleVenta @IDVenta = 'VNT000001', @IDProducto = 'REP00001';
GO