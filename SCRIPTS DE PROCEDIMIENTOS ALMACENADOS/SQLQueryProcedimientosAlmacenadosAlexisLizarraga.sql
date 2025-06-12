USE db_CorporativoValuCalderon
GO

-- Procedimiento para listar ventas
IF OBJECT_ID('spListarVentas') IS NOT NULL
    DROP PROC spListarVentas
GO
CREATE PROC spListarVentas
AS
BEGIN
    SELECT 
        v.IDVenta,
        v.venFecha,
        v.venEstado,
        v.venTotal,
        v.venIGV,
        v.DNI,
        c.cliNombres + ' ' + c.cliApellidoMaterno  + ' ' + c.cliApellidoPaterno AS Cliente,
        v.IDTrabajador,
        t.traNombres + ' ' + + traApellidoMaterno + ' ' + traApellidoMaterno AS Trabajador,
        v.IDMetodoPago,
        mp.metDescripcion AS MetodoPago
    FROM tblVenta v
    INNER JOIN tblCliente c ON v.DNI = c.DNI
    INNER JOIN tblTrabajador t ON v.IDTrabajador = t.IDTrabajador
    INNER JOIN tblMetodopago mp ON v.IDMetodopago = mp.IDMetodopago
    ORDER BY v.venFecha DESC
END
GO
exec spListarVentas
go


-- Procedimiento para agregar una venta
IF OBJECT_ID('spAgregarVenta') IS NOT NULL
    DROP PROC spAgregarVenta
GO
CREATE PROC spAgregarVenta
    @IDVenta VARCHAR(20),
    @venFecha DATE,
    @venTotal DECIMAL(10, 2),
    @venIGV DECIMAL(10, 2),
    @DNI VARCHAR(30), -- IMPORTANT: Ensure tblCliente.DNI has the same VARCHAR length (e.g., 8 or 30)
    @IDTrabajador VARCHAR(8),
    @IDMetodopago VARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON; -- Prevents the message showing the number of rows affected

    BEGIN TRY
        BEGIN TRANSACTION
            -- Verificar que el cliente existe
            IF NOT EXISTS (SELECT 1 FROM tblCliente WHERE DNI = @DNI)
            BEGIN
                SELECT 1 AS CodError, 'Error: El cliente con DNI ' + @DNI + ' no existe.' AS Mensaje
                ROLLBACK TRANSACTION -- Rollback in case of an early exit error
                RETURN
            END

            -- Verificar que el trabajador existe
            IF NOT EXISTS (SELECT 1 FROM tblTrabajador WHERE IDTrabajador = @IDTrabajador)
            BEGIN
                SELECT 1 AS CodError, 'Error: El trabajador con ID ' + @IDTrabajador + ' no existe.' AS Mensaje
                ROLLBACK TRANSACTION
                RETURN
            END

            -- Verificar que el método de pago existe
            -- Corrected table name to tblMetodoPago
            IF NOT EXISTS (SELECT 1 FROM tblMetodoPago WHERE IDMetodoPago = @IDMetodopago)
            BEGIN
                SELECT 1 AS CodError, 'Error: El método de pago con ID ' + @IDMetodopago + ' no existe.' AS Mensaje
                ROLLBACK TRANSACTION
                RETURN
            END

            -- Insertar la venta
            INSERT INTO tblVenta (
                IDVenta,
                venFecha,
                venEstado,       -- Explicitly include venEstado
                venTotal,
                venIGV,
                DNI,
                IDTrabajador,
                IDMetodoPago
            ) VALUES (
                @IDVenta,
                @venFecha,
                'Pendiente',     -- Value for venEstado (default)
                @venTotal,
                @venIGV,
                @DNI,
                @IDTrabajador,
                @IDMetodopago
            );

            SELECT 0 AS CodError, 'Venta registrada correctamente.' AS Mensaje;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 -- Check if a transaction is open
            ROLLBACK TRANSACTION;
        SELECT 1 AS CodError, 'Error al registrar la venta: ' + ERROR_MESSAGE() AS Mensaje;
    END CATCH;
END
GO
-- Example execution (ensure referenced IDs exist in your test data)
 EXEC spAgregarVenta 'VNT000037', '2025-06-12', 850.00, 153.00, '70000032', 'T0000032', 'MP032';
GO
 EXEC spListarVentas;
 GO


-- Procedimiento para actualizar estado de venta
IF OBJECT_ID('spActualizarEstadoVenta') IS NOT NULL
    DROP PROC spActualizarEstadoVenta
GO
CREATE PROC spActualizarEstadoVenta
    @IDVenta VARCHAR(20),
    @nuevoEstado VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF @nuevoEstado NOT IN ('Pendiente', 'Completado', 'Cancelado')
    BEGIN
        SELECT 1 AS CodError, 'Error: El estado proporcionado no es válido.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM tblVenta WHERE IDVenta = @IDVenta)
    BEGIN
        UPDATE tblVenta
        SET venEstado = @nuevoEstado
        WHERE IDVenta = @IDVenta;

       
        IF @@ROWCOUNT > 0
            SELECT 0 AS CodError, 'Estado de venta actualizado correctamente para IDVenta: ' + @IDVenta AS Mensaje;
        ELSE
          
            SELECT 1 AS CodError, 'Error: La venta con ID ' + @IDVenta + ' no pudo ser actualizada (posiblemente ya tenía ese estado).' AS Mensaje;
    END
    ELSE
        SELECT 1 AS CodError, 'Error: La venta con ID ' + @IDVenta + ' no existe.' AS Mensaje;
END
GO
-- Example Execution:
 EXEC spActualizarEstadoVenta 'VNT000035', 'Pendiente';
 EXEC spListarVentas;
 GO

 -- Procedimiento para eliminar una venta
IF OBJECT_ID('spEliminarVenta') IS NOT NULL
    DROP PROC spEliminarVenta
GO
CREATE PROC spEliminarVenta
    @IDVenta VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if the sale exists
        IF NOT EXISTS (SELECT 1 FROM tblVenta WHERE IDVenta = @IDVenta)
        BEGIN
            SELECT 1 AS CodError, 'Error: La venta con ID ' + @IDVenta + ' no existe.' AS Mensaje;
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Delete related detail records first (if ON DELETE CASCADE is not used)
        -- If tblDetalleVenta.IDVenta has ON DELETE CASCADE, you can remove this DELETE statement
        DELETE FROM tblDetalleVenta
        WHERE IDVenta = @IDVenta;

        -- Delete the sale record
        DELETE FROM tblVenta
        WHERE IDVenta = @IDVenta;

        SELECT 0 AS CodError, 'Venta eliminada correctamente.' AS Mensaje;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT 1 AS CodError, 'Error al eliminar la venta: ' + ERROR_MESSAGE() AS Mensaje;
    END CATCH;
END
GO
-- Example Execution:

 EXEC spEliminarVenta 'VNT000038';
 GO
  EXEC spListarVentas;
 GO


USE db_CorporativoValuCalderon
GO

-- Procedimiento para buscar ventas (Exacta y Sensitiva)
IF OBJECT_ID('spBuscarVentas', 'P') IS NOT NULL
    DROP PROCEDURE spBuscarVentas
GO

CREATE PROCEDURE spBuscarVentas
    @textoBusqueda VARCHAR(100), -- El texto o valor a buscar
    @criterio VARCHAR(20)        -- El criterio de búsqueda
AS
BEGIN
    SET NOCOUNT ON; -- Previene mensajes de conteo de filas afectadas.

    -- Criterio: IDVenta (BÚSQUEDA EXACTA)
    IF (@criterio = 'IDVenta')
    BEGIN
        SELECT
            v.IDVenta,
            v.venFecha,
            v.venEstado,
            v.venTotal,
            v.venIGV,
            v.DNI,
            c.cliNombres + ' ' + c.cliApellidoPaterno + ' ' + c.cliApellidoMaterno AS Cliente,
            v.IDTrabajador,
            t.traNombres + ' ' + t.traApellidoPaterno + ' ' + t.traApellidoMaterno AS Trabajador,
            v.IDMetodoPago,
            mp.metDescripcion AS MetodoPago
        FROM tblVenta v
        INNER JOIN tblCliente c ON v.DNI = c.DNI
        INNER JOIN tblTrabajador t ON v.IDTrabajador = t.IDTrabajador
        INNER JOIN tblMetodoPago mp ON v.IDMetodoPago = mp.IDMetodoPago
        WHERE v.IDVenta = @textoBusqueda; -- Búsqueda exacta
    END

    -- Criterio: DNI (BÚSQUEDA EXACTA)
    ELSE IF (@criterio = 'DNI')
    BEGIN
        SELECT
            v.IDVenta,
            v.venFecha,
            v.venEstado,
            v.venTotal,
            v.venIGV,
            v.DNI,
            c.cliNombres + ' ' + c.cliApellidoPaterno + ' ' + c.cliApellidoMaterno AS Cliente,
            v.IDTrabajador,
            t.traNombres + ' ' + t.traApellidoPaterno + ' ' + t.traApellidoMaterno AS Trabajador,
            v.IDMetodoPago,
            mp.metDescripcion AS MetodoPago
        FROM tblVenta v
        INNER JOIN tblCliente c ON v.DNI = c.DNI
        INNER JOIN tblTrabajador t ON v.IDTrabajador = t.IDTrabajador
        INNER JOIN tblMetodoPago mp ON v.IDMetodoPago = mp.IDMetodoPago
        WHERE v.DNI = @textoBusqueda; -- Búsqueda exacta
    END

    -- Criterio: Fecha (BÚSQUEDA EXACTA)
    ELSE IF (@criterio = 'Fecha')
    BEGIN
        SELECT
            v.IDVenta,
            v.venFecha,
            v.venEstado,
            v.venTotal,
            v.venIGV,
            v.DNI,
            c.cliNombres + ' ' + c.cliApellidoPaterno + ' ' + c.cliApellidoMaterno AS Cliente,
            v.IDTrabajador,
            t.traNombres + ' ' + t.traApellidoPaterno + ' ' + t.traApellidoMaterno AS Trabajador,
            v.IDMetodoPago,
            mp.metDescripcion AS MetodoPago
        FROM tblVenta v
        INNER JOIN tblCliente c ON v.DNI = c.DNI
        INNER JOIN tblTrabajador t ON v.IDTrabajador = t.IDTrabajador
        INNER JOIN tblMetodoPago mp ON v.IDMetodoPago = mp.IDMetodoPago
        WHERE v.venFecha = TRY_CAST(@textoBusqueda AS DATE); -- Búsqueda exacta con conversión segura
    END

    -- Criterio: Estado (BÚSQUEDA SENSITIVA con LIKE)
    ELSE IF (@criterio = 'Estado')
    BEGIN
        SELECT
            v.IDVenta,
            v.venFecha,
            v.venEstado,
            v.venTotal,
            v.venIGV,
            v.DNI,
            c.cliNombres + ' ' + c.cliApellidoPaterno + ' ' + c.cliApellidoMaterno AS Cliente,
            v.IDTrabajador,
            t.traNombres + ' ' + t.traApellidoPaterno + ' ' + t.traApellidoMaterno AS Trabajador,
            v.IDMetodoPago,
            mp.metDescripcion AS MetodoPago
        FROM tblVenta v
        INNER JOIN tblCliente c ON v.DNI = c.DNI
        INNER JOIN tblTrabajador t ON v.IDTrabajador = t.IDTrabajador
        INNER JOIN tblMetodoPago mp ON v.IDMetodoPago = mp.IDMetodoPago
        WHERE v.venEstado LIKE '%' + @textoBusqueda + '%'; -- Búsqueda sensitiva
    END

    -- Criterio: IDTrabajador (BÚSQUEDA EXACTA)
    ELSE IF (@criterio = 'IDTrabajador')
    BEGIN
        SELECT
            v.IDVenta,
            v.venFecha,
            v.venEstado,
            v.venTotal,
            v.venIGV,
            v.DNI,
            c.cliNombres + ' ' + c.cliApellidoPaterno + ' ' + c.cliApellidoMaterno AS Cliente,
            v.IDTrabajador,
            t.traNombres + ' ' + t.traApellidoPaterno + ' ' + t.traApellidoMaterno AS Trabajador,
            v.IDMetodoPago,
            mp.metDescripcion AS MetodoPago
        FROM tblVenta v
        INNER JOIN tblCliente c ON v.DNI = c.DNI
        INNER JOIN tblTrabajador t ON v.IDTrabajador = t.IDTrabajador
        INNER JOIN tblMetodoPago mp ON v.IDMetodoPago = mp.IDMetodoPago
        WHERE v.IDTrabajador = @textoBusqueda; -- Búsqueda exacta
    END

    -- Criterio: NombreCliente (BÚSQUEDA SENSITIVA con LIKE en Nombres y Apellidos)
    ELSE IF (@criterio = 'NombreCliente')
    BEGIN
        SELECT
            v.IDVenta,
            v.venFecha,
            v.venEstado,
            v.venTotal,
            v.venIGV,
            v.DNI,
            c.cliNombres + ' ' + c.cliApellidoPaterno + ' ' + c.cliApellidoMaterno AS Cliente,
            v.IDTrabajador,
            t.traNombres + ' ' + t.traApellidoPaterno + ' ' + t.traApellidoMaterno AS Trabajador,
            v.IDMetodoPago,
            mp.metDescripcion AS MetodoPago
        FROM tblVenta v
        INNER JOIN tblCliente c ON v.DNI = c.DNI
        INNER JOIN tblTrabajador t ON v.IDTrabajador = t.IDTrabajador
        INNER JOIN tblMetodoPago mp ON v.IDMetodoPago = mp.IDMetodoPago
        WHERE c.cliNombres LIKE '%' + @textoBusqueda + '%'
           OR c.cliApellidoPaterno LIKE '%' + @textoBusqueda + '%'
           OR c.cliApellidoMaterno LIKE '%' + @textoBusqueda + '%'; -- Búsqueda sensitiva en partes del nombre
    END

    -- Criterio: NombreTrabajador (BÚSQUEDA SENSITIVA con LIKE en Nombres y Apellidos)
    ELSE IF (@criterio = 'NombreTrabajador')
    BEGIN
        SELECT
            v.IDVenta,
            v.venFecha,
            v.venEstado,
            v.venTotal,
            v.venIGV,
            v.DNI,
            c.cliNombres + ' ' + c.cliApellidoPaterno + ' ' + c.cliApellidoMaterno AS Cliente,
            v.IDTrabajador,
            t.traNombres + ' ' + t.traApellidoPaterno + ' ' + t.traApellidoMaterno AS Trabajador,
            v.IDMetodoPago,
            mp.metDescripcion AS MetodoPago
        FROM tblVenta v
        INNER JOIN tblCliente c ON v.DNI = c.DNI
        INNER JOIN tblTrabajador t ON v.IDTrabajador = t.IDTrabajador
        INNER JOIN tblMetodoPago mp ON v.IDMetodoPago = mp.IDMetodoPago
        WHERE t.traNombres LIKE '%' + @textoBusqueda + '%'
           OR t.traApellidoPaterno LIKE '%' + @textoBusqueda + '%'
           OR t.traApellidoMaterno LIKE '%' + @textoBusqueda + '%'; -- Búsqueda sensitiva en partes del nombre
    END

    -- Criterio: IDMetodoPago (BÚSQUEDA EXACTA)
    ELSE IF (@criterio = 'IDMetodoPago')
    BEGIN
        SELECT
            v.IDVenta,
            v.venFecha,
            v.venEstado,
            v.venTotal,
            v.venIGV,
            v.DNI,
            c.cliNombres + ' ' + c.cliApellidoPaterno + ' ' + c.cliApellidoMaterno AS Cliente,
            v.IDTrabajador,
            t.traNombres + ' ' + t.traApellidoPaterno + ' ' + t.traApellidoMaterno AS Trabajador,
            v.IDMetodoPago,
            mp.metDescripcion AS MetodoPago
        FROM tblVenta v
        INNER JOIN tblCliente c ON v.DNI = c.DNI
        INNER JOIN tblTrabajador t ON v.IDTrabajador = t.IDTrabajador
        INNER JOIN tblMetodoPago mp ON v.IDMetodoPago = mp.IDMetodoPago
        WHERE v.IDMetodoPago = @textoBusqueda; -- Búsqueda exacta
    END

    -- Criterio: DescripcionMetodoPago (BÚSQUEDA SENSITIVA con LIKE)
    ELSE IF (@criterio = 'MetodoPago') -- Using 'MetodoPago' as criterion to search by description
    BEGIN
        SELECT
            v.IDVenta,
            v.venFecha,
            v.venEstado,
            v.venTotal,
            v.venIGV,
            v.DNI,
            c.cliNombres + ' ' + c.cliApellidoPaterno + ' ' + c.cliApellidoMaterno AS Cliente,
            v.IDTrabajador,
            t.traNombres + ' ' + t.traApellidoPaterno + ' ' + t.traApellidoMaterno AS Trabajador,
            v.IDMetodoPago,
            mp.metDescripcion AS MetodoPago
        FROM tblVenta v
        INNER JOIN tblCliente c ON v.DNI = c.DNI
        INNER JOIN tblTrabajador t ON v.IDTrabajador = t.IDTrabajador
        INNER JOIN tblMetodoPago mp ON v.IDMetodoPago = mp.IDMetodoPago
        WHERE mp.metDescripcion LIKE '%' + @textoBusqueda + '%'; -- Búsqueda sensitiva
    END

    -- Si el criterio de búsqueda no es válido
    ELSE
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: Criterio de búsqueda no válido. Criterios permitidos: IDVenta, DNI, Fecha, Estado, IDTrabajador, NombreCliente, NombreTrabajador, IDMetodoPago, MetodoPago.';
    END
END
GO

-- --- EJECUCIONES DE EJEMPLO BASADAS EN LA IMAGEN DE DATOS REALES ---

-- 1. BÚSQUEDA EXACTA por IDVenta: (Ej. VNT000037)
EXEC spBuscarVentas 'VNT000037', 'IDVenta';
GO

-- 2. BÚSQUEDA EXACTA por DNI de Cliente: (Ej. 70000032)
EXEC spBuscarVentas '70000032', 'DNI';
GO

-- 3. BÚSQUEDA EXACTA por Fecha: (Ej. 2025-05-13)
EXEC spBuscarVentas '2025-05-13', 'Fecha';
GO

-- 4. BÚSQUEDA SENSITIVA por Estado: (Ej. 'Pagado')
EXEC spBuscarVentas 'Pagado', 'Estado';
GO

-- 5. BÚSQUEDA EXACTA por IDTrabajador: (Ej. T000032)
EXEC spBuscarVentas 'T000032', 'IDTrabajador';
GO

-- 6. BÚSQUEDA SENSITIVA por Nombre de Cliente: (Ej. 'Jorge')
EXEC spBuscarVentas 'Jorge', 'NombreCliente';
GO
-- BÚSQUEDA SENSITIVA por Apellido de Cliente: (Ej. 'Wood')
EXEC spBuscarVentas 'Wood', 'NombreCliente';
GO

-- 7. BÚSQUEDA SENSITIVA por Nombre de Trabajador: (Ej. 'Beatriz')
EXEC spBuscarVentas 'Beatriz', 'NombreTrabajador';
GO
-- BÚSQUEDA SENSITIVA por Apellido de Trabajador: (Ej. 'Salinas')
EXEC spBuscarVentas 'Salinas', 'NombreTrabajador';
GO

-- 8. BÚSQUEDA EXACTA por IDMetodoPago: (Ej. MP032)
EXEC spBuscarVentas 'MP032', 'IDMetodoPago';
GO

-- 9. BÚSQUEDA SENSITIVA por Descripción de Método de Pago: (Ej. 'transferencia')
EXEC spBuscarVentas 'transferencia', 'MetodoPago';
GO

-- 10. Prueba con criterio no válido:
EXEC spBuscarVentas 'algún texto', 'CriterioNoExistente';
GO