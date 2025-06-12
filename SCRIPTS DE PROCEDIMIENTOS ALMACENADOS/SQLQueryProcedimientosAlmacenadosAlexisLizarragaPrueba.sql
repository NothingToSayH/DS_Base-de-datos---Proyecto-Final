USE db_CorporativoValuCalderon
GO

-- Procedimiento para listar detalles de ventas
IF OBJECT_ID('spListarDetalleVentas') IS NOT NULL
    DROP PROC spListarDetalleVentas
GO
CREATE PROC spListarDetalleVentas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        dv.IDVenta,
        dv.IDProducto,
        dv.TipoProducto,
        dv.detCantidad,
        dv.detPrecioUnitario,
        dv.detDescuento,
        dv.detSubTotal
    FROM tblDetalleVenta dv
    ORDER BY dv.IDVenta, dv.IDProducto;
END
GO
EXEC spListarDetalleVentas;
 GO


-- Procedimiento para agregar un detalle de venta
IF OBJECT_ID('spAgregarDetalleVenta') IS NOT NULL
    DROP PROC spAgregarDetalleVenta
GO
CREATE PROC spAgregarDetalleVenta
    @IDVenta VARCHAR(20),
    @IDProducto VARCHAR(20),
    @TipoProducto VARCHAR(10),
    @detCantidad INT,
    @detPrecioUnitario DECIMAL(10, 2),
    @detDescuento DECIMAL(10, 2) = 0 -- Default value matches table
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @calculatedSubTotal DECIMAL(10, 2);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Validar que IDVenta existe en tblVenta
        IF NOT EXISTS (SELECT 1 FROM tblVenta WHERE IDVenta = @IDVenta)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 1 AS CodError, 'Error: La venta con ID ' + @IDVenta + ' no existe.' AS Mensaje;
            RETURN;
        END;

        -- 2. Validar que IDProducto existe (assuming a tblProducto table)
        -- *** IMPORTANT: You need a tblProducto table for this check.
        -- If you don't have tblProducto, you might need to remove or adjust this check.
        IF NOT EXISTS (SELECT 1 FROM tblDetalleVenta WHERE IDProducto = @IDProducto)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 1 AS CodError, 'Error: El producto con ID ' + @IDProducto + ' no existe.' AS Mensaje;
            RETURN;
        END;

        -- 3. Validar TipoProducto
        IF @TipoProducto NOT IN ('Moto', 'Repuesto')
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 1 AS CodError, 'Error: Tipo de Producto inválido. Debe ser ''Moto'' o ''Repuesto''.' AS Mensaje;
            RETURN;
        END;

        -- 4. Validar cantidades y precios
        IF @detCantidad <= 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 1 AS CodError, 'Error: La cantidad debe ser mayor a cero.' AS Mensaje;
            RETURN;
        END;

        IF @detPrecioUnitario <= 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 1 AS CodError, 'Error: El precio unitario debe ser mayor a cero.' AS Mensaje;
            RETURN;
        END;

        IF @detDescuento < 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 1 AS CodError, 'Error: El descuento no puede ser negativo.' AS Mensaje;
            RETURN;
        END;

        -- Calcular detSubTotal
        SET @calculatedSubTotal = (@detCantidad * @detPrecioUnitario) - @detDescuento;
        IF @calculatedSubTotal < 0
        BEGIN
             ROLLBACK TRANSACTION;
             SELECT 1 AS CodError, 'Error: El subtotal calculado es negativo. Verifique cantidad, precio y descuento.' AS Mensaje;
             RETURN;
        END;

        -- 5. Insertar el detalle de venta
        INSERT INTO tblDetalleVenta (
            IDVenta,
            IDProducto,
            TipoProducto,
            detCantidad,
            detPrecioUnitario,
            detDescuento,
            detSubTotal
        ) VALUES (
            @IDVenta,
            @IDProducto,
            @TipoProducto,
            @detCantidad,
            @detPrecioUnitario,
            @detDescuento,
            @calculatedSubTotal
        );

        SELECT 0 AS CodError, 'Detalle de venta agregado correctamente.' AS Mensaje;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT 1 AS CodError, 'Error al agregar detalle de venta: ' + ERROR_MESSAGE() AS Mensaje;
    END CATCH;
END
GO
-- Asegúrate que 'VNT000037' exista en tblVenta y 'REP00020' exista en tblProducto (si tienes esa tabla).
EXEC spAgregarDetalleVenta 'VNT000037', 'REP00020', 'Repuesto', 2, 150.00, 10.00;
GO
EXEC spListarDetalleVentas;
 GO


-- Procedimiento para actualizar un detalle de venta
IF OBJECT_ID('spActualizarDetalleVenta') IS NOT NULL
    DROP PROC spActualizarDetalleVenta
GO
CREATE PROC spActualizarDetalleVenta
    @IDVenta VARCHAR(20),
    @IDProducto VARCHAR(20),
    @nuevaCantidad INT,
    @nuevoPrecioUnitario DECIMAL(10, 2),
    @nuevoDescuento DECIMAL(10, 2) = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @calculatedSubTotal DECIMAL(10, 2);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Validar que el detalle de venta existe
        IF NOT EXISTS (SELECT 1 FROM tblDetalleVenta WHERE IDVenta = @IDVenta AND IDProducto = @IDProducto)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 1 AS CodError, 'Error: Detalle de venta para Venta ID ' + @IDVenta + ' y Producto ID ' + @IDProducto + ' no encontrado.' AS Mensaje;
            RETURN;
        END;

        -- 2. Validar nuevas cantidades, precios y descuentos
        IF @nuevaCantidad <= 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 1 AS CodError, 'Error: La nueva cantidad debe ser mayor a cero.' AS Mensaje;
            RETURN;
        END;

        IF @nuevoPrecioUnitario <= 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 1 AS CodError, 'Error: El nuevo precio unitario debe ser mayor a cero.' AS Mensaje;
            RETURN;
        END;

        IF @nuevoDescuento < 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 1 AS CodError, 'Error: El nuevo descuento no puede ser negativo.' AS Mensaje;
            RETURN;
        END;

        -- Calcular nuevo detSubTotal
        SET @calculatedSubTotal = (@nuevaCantidad * @nuevoPrecioUnitario) - @nuevoDescuento;
        IF @calculatedSubTotal < 0
        BEGIN
             ROLLBACK TRANSACTION;
             SELECT 1 AS CodError, 'Error: El subtotal calculado es negativo. Verifique nueva cantidad, precio y descuento.' AS Mensaje;
             RETURN;
        END;

        -- 3. Actualizar el detalle de venta
        UPDATE tblDetalleVenta
        SET
            detCantidad = @nuevaCantidad,
            detPrecioUnitario = @nuevoPrecioUnitario,
            detDescuento = @nuevoDescuento,
            detSubTotal = @calculatedSubTotal
        WHERE
            IDVenta = @IDVenta AND IDProducto = @IDProducto;

        SELECT 0 AS CodError, 'Detalle de venta actualizado correctamente.' AS Mensaje;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT 1 AS CodError, 'Error al actualizar detalle de venta: ' + ERROR_MESSAGE() AS Mensaje;
    END CATCH;
END
GO

 EXEC spActualizarDetalleVenta 'VNT000001', 'MOTO0001', 3, 14500.00, 90.00;
 GO
 EXEC spListarDetalleVentas;
 GO
 EXEC spActualizarDetalleVenta 'VNT999999', 'MOTO0001', 1, 100.00, 0; -- Detalle no existe
 GO
EXEC spListarDetalleVentas;
 GO


-- Procedimiento para eliminar un detalle de venta
IF OBJECT_ID('spEliminarDetalleVenta') IS NOT NULL
    DROP PROC spEliminarDetalleVenta
GO
CREATE PROC spEliminarDetalleVenta
    @IDVenta VARCHAR(20),
    @IDProducto VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Validar que el detalle de venta existe
        IF NOT EXISTS (SELECT 1 FROM tblDetalleVenta WHERE IDVenta = @IDVenta AND IDProducto = @IDProducto)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 1 AS CodError, 'Error: Detalle de venta para Venta ID ' + @IDVenta + ' y Producto ID ' + @IDProducto + ' no encontrado.' AS Mensaje;
            RETURN;
        END;

        -- 2. Eliminar el detalle de venta
        DELETE FROM tblDetalleVenta
        WHERE IDVenta = @IDVenta AND IDProducto = @IDProducto;

        SELECT 0 AS CodError, 'Detalle de venta eliminado correctamente.' AS Mensaje;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT 1 AS CodError, 'Error al eliminar detalle de venta: ' + ERROR_MESSAGE() AS Mensaje;
    END CATCH;
END
GO


EXEC spEliminarDetalleVenta 'VNT000019', 'REP00019';
GO
EXEC spListarDetalleVentas;
 GO
-- Ejemplo de error:
EXEC spEliminarDetalleVenta 'VNT999999', 'PROD999'; -- Detalle no existe
 GO
EXEC spListarDetalleVentas;
 GO


-- Procedimiento para buscar detalles de ventas (Exacta y Sensitiva)
USE db_CorporativoValuCalderon
GO

-- Procedimiento para buscar detalles de ventas (Exacta y Sensitiva)
IF OBJECT_ID('spBuscarDetalleVentas', 'P') IS NOT NULL
    DROP PROCEDURE spBuscarDetalleVentas
GO

CREATE PROCEDURE spBuscarDetalleVentas
    @textoBusqueda VARCHAR(100), -- El texto o valor a buscar
    @criterio VARCHAR(30)        -- El criterio de búsqueda
AS
BEGIN
    SET NOCOUNT ON; -- Previene mensajes de conteo de filas afectadas.

    -- Criterio: IDVenta (BÚSQUEDA EXACTA)
    IF (@criterio = 'IDVenta')
    BEGIN
        SELECT
            dv.IDVenta,
            dv.IDProducto,
            -- pr.prodNombre AS NombreProducto, -- Uncomment if you have tblProducto and prodNombre
            dv.TipoProducto,
            dv.detCantidad,
            dv.detPrecioUnitario,
            dv.detDescuento,
            dv.detSubTotal
        FROM tblDetalleVenta dv
        -- LEFT JOIN tblProducto pr ON dv.IDProducto = pr.IDProducto -- Uncomment if you have tblProducto
        WHERE dv.IDVenta = @textoBusqueda; -- Búsqueda exacta
    END

    -- Criterio: IDProducto (BÚSQUEDA EXACTA)
    ELSE IF (@criterio = 'IDProducto')
    BEGIN
        SELECT
            dv.IDVenta,
            dv.IDProducto,
            -- pr.prodNombre AS NombreProducto,
            dv.TipoProducto,
            dv.detCantidad,
            dv.detPrecioUnitario,
            dv.detDescuento,
            dv.detSubTotal
        FROM tblDetalleVenta dv
        -- LEFT JOIN tblProducto pr ON dv.IDProducto = pr.IDProducto
        WHERE dv.IDProducto = @textoBusqueda; -- Búsqueda exacta
    END

    -- Criterio: NombreProducto (BÚSQUEDA SENSITIVA con LIKE)
    -- *** CORRECCIÓN APLICADA AQUÍ ***
    ELSE IF (@criterio = 'NombreProducto')
    BEGIN
        -- This block needs to be a complete SELECT statement as it has a specific JOIN
        -- and WHERE clause. It should NOT use EXEC(@baseSelect + ...)
        -- It directly performs the SELECT.
        SELECT
            dv.IDVenta,
            dv.IDProducto,
            pr.prodNombre AS NombreProducto, -- Assuming prodNombre exists in tblProducto
            dv.TipoProducto,
            dv.detCantidad,
            dv.detPrecioUnitario,
            dv.detDescuento,
            dv.detSubTotal
        FROM tblDetalleVenta dv
        INNER JOIN tblProducto pr ON dv.IDProducto = pr.IDProducto -- INNER JOIN for product name search
        WHERE pr.prodNombre LIKE '%' + @textoBusqueda + '%';
    END

    -- Criterio: TipoProducto (BÚSQUEDA EXACTA o SENSITIVA según necesidad, aquí exacta)
    ELSE IF (@criterio = 'TipoProducto')
    BEGIN
        SELECT
            dv.IDVenta,
            dv.IDProducto,
            -- pr.prodNombre AS NombreProducto,
            dv.TipoProducto,
            dv.detCantidad,
            dv.detPrecioUnitario,
            dv.detDescuento,
            dv.detSubTotal
        FROM tblDetalleVenta dv
        -- LEFT JOIN tblProducto pr ON dv.IDProducto = pr.IDProducto
        WHERE dv.TipoProducto = @textoBusqueda; -- Búsqueda exacta (ajusta a LIKE si necesitas sensitiva)
    END

    -- Criterio: Cantidad (BÚSQUEDA EXACTA)
    ELSE IF (@criterio = 'Cantidad')
    BEGIN
        SELECT
            dv.IDVenta,
            dv.IDProducto,
            -- pr.prodNombre AS NombreProducto,
            dv.TipoProducto,
            dv.detCantidad,
            dv.detPrecioUnitario,
            dv.detDescuento,
            dv.detSubTotal
        FROM tblDetalleVenta dv
        -- LEFT JOIN tblProducto pr ON dv.IDProducto = pr.IDProducto
        WHERE dv.detCantidad = TRY_CAST(@textoBusqueda AS INT);
    END

    -- Criterio: PrecioUnitario (BÚSQUEDA EXACTA)
    ELSE IF (@criterio = 'PrecioUnitario')
    BEGIN
        SELECT
            dv.IDVenta,
            dv.IDProducto,
            -- pr.prodNombre AS NombreProducto,
            dv.TipoProducto,
            dv.detCantidad,
            dv.detPrecioUnitario,
            dv.detDescuento,
            dv.detSubTotal
        FROM tblDetalleVenta dv
        -- LEFT JOIN tblProducto pr ON dv.IDProducto = pr.IDProducto
        WHERE dv.detPrecioUnitario = TRY_CAST(@textoBusqueda AS DECIMAL(10, 2));
    END

    -- Criterio: SubTotal (BÚSQUEDA EXACTA)
    ELSE IF (@criterio = 'SubTotal')
    BEGIN
        SELECT
            dv.IDVenta,
            dv.IDProducto,
            -- pr.prodNombre AS NombreProducto,
            dv.TipoProducto,
            dv.detCantidad,
            dv.detPrecioUnitario,
            dv.detDescuento,
            dv.detSubTotal
        FROM tblDetalleVenta dv
        -- LEFT JOIN tblProducto pr ON dv.IDProducto = pr.IDProducto
        WHERE dv.detSubTotal = TRY_CAST(@textoBusqueda AS DECIMAL(10, 2));
    END

    -- Si el criterio de búsqueda no es válido
    ELSE
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: Criterio de búsqueda no válido. Criterios permitidos: IDVenta, IDProducto, NombreProducto, TipoProducto, Cantidad, PrecioUnitario, SubTotal.';
    END
END
GO

-- --- EJECUCIONES DE EJEMPLO PARA spBuscarDetalleVentas ---
-- Reemplaza 'VNT000001', 'PROD001', etc., con datos existentes en tu base de datos para probar.

-- 1. BÚSQUEDA EXACTA por IDVenta:
EXEC spBuscarDetalleVentas 'VNT000003', 'IDVenta';
GO

-- 2. BÚSQUEDA EXACTA por IDProducto:
EXEC spBuscarDetalleVentas 'MOTO0002', 'IDProducto';
GO

-- 3. BÚSQUEDA SENSITIVA por NombreProducto (REQUIERE tblProducto y prodNombre):

EXEC spBuscarDetalleVentas 'Moto XYZ', 'NombreProducto';
 GO

-- 4. BÚSQUEDA EXACTA por TipoProducto:
EXEC spBuscarDetalleVentas 'Moto', 'TipoProducto';
GO

-- 5. BÚSQUEDA EXACTA por Cantidad:
EXEC spBuscarDetalleVentas '1', 'Cantidad';
GO

-- 6. BÚSQUEDA EXACTA por Precio Unitario:
EXEC spBuscarDetalleVentas '14500.00', 'PrecioUnitario';
GO

-- 7. BÚSQUEDA EXACTA por SubTotal:
EXEC spBuscarDetalleVentas '32500.00', 'SubTotal';
GO

-- 8. Prueba con criterio no válido:
EXEC spBuscarDetalleVentas 'invalid', 'InvalidCriterion';
GO