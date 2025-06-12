----=========================CATEGORIA DE REPUESTOS=============
----=============================================================================================================
USE dbCorporativoValuCalderon;
GO

-- 1. Procedimiento para Listar Categor�as de Motos con B�squeda
IF OBJECT_ID('spListarCategoriasMotos') IS NOT NULL
    DROP PROC spListarCategoriasMotos
GO
CREATE PROC spListarCategoriasMotos
    @busqueda VARCHAR(100) = NULL
AS
BEGIN
    SELECT 
        IDCategoria,
        catNombre AS [Nombre Categor�a],
        catDescripcion AS Descripci�n,
        (SELECT COUNT(*) FROM tblMotos WHERE IDCategoria = cm.IDCategoria) AS [Total Motos]
    FROM tblCategoriaMotos cm
    WHERE 
        @busqueda IS NULL OR
        catNombre LIKE '%' + @busqueda + '%' OR
        catDescripcion LIKE '%' + @busqueda + '%'
    ORDER BY catNombre;
END
GO

-- Listar todas las categor�as
EXEC spListarCategoriasMotos;
GO

-- Buscar categor�as que contengan "sport"
EXEC spListarCategoriasMotos 'sport';
GO

-- Buscar categor�as que contengan "urban"
EXEC spListarCategoriasMotos 'urban';
GO

---==========================2. Procedimiento para Agregar Categor�as de Motos con Visualizaci�n=======================
---========================================================================================================

IF OBJECT_ID('spAgregarCategoriaMotos') IS NOT NULL
    DROP PROC spAgregarCategoriaMotos
GO
CREATE PROC spAgregarCategoriaMotos
    @IDCategoria VARCHAR(5),
    @catNombre VARCHAR(50),
    @catDescripcion VARCHAR(100) = NULL
AS
BEGIN
    -- Validar formato de ID (5 caracteres)
    IF LEN(@IDCategoria) <> 5
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El ID debe tener exactamente 5 caracteres';
        RETURN;
    END
    -- Verificar si el ID ya existe
    IF EXISTS (SELECT 1 FROM tblCategoriaMotos WHERE IDCategoria = @IDCategoria)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El ID de categor�a ya existe';
        RETURN;
    END
    -- Verificar si el nombre ya existe
    IF EXISTS (SELECT 1 FROM tblCategoriaMotos WHERE catNombre = @catNombre)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre de categor�a ya existe';
        RETURN;
    END
    -- Validar longitud del nombre
    IF LEN(@catNombre) < 3 OR LEN(@catNombre) > 50
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre debe tener entre 3 y 50 caracteres';
        RETURN;
    END
    -- Insertar la nueva categor�a
    INSERT INTO tblCategoriaMotos (
        IDCategoria,
        catNombre,
        catDescripcion
    ) VALUES (
        @IDCategoria,
        @catNombre,
        @catDescripcion
    );
    
    -- Mostrar mensaje de �xito y los datos insertados
    SELECT CodError = 0, Mensaje = 'Categor�a de motos agregada correctamente';
    
    -- Devolver los datos de la categor�a reci�n agregada
    SELECT 
        IDCategoria AS [ID Categor�a],
        catNombre AS [Nombre Categor�a],
        catDescripcion AS Descripci�n,
        'Registro exitoso' AS Estado
    FROM tblCategoriaMotos 
    WHERE IDCategoria = @IDCategoria;
END
GO

-- Ejemplo de agregar categor�a con visualizaci�n del resultado
EXEC spAgregarCategoriaMotos 'CM078', 'Trial Urbano0', 'Motos para competici�n de trial en entornos urbanos';
GO

-- Ejemplo de error (ID ya existe)
EXEC spAgregarCategoriaMotos 'CM089', 'Nueva Categoria', 'Descripci�n de prueba';
GO

-- Ejemplo de error (nombre muy corto)
EXEC spAgregarCategoriaMotos 'CM037', 'AB', 'Nombre demasiado corto';
GO

------===============================================================
--======================================3. Procedimiento para Eliminar Categor�as de Motos con Visualizaci�n
IF OBJECT_ID('spEliminarCategoriaMotos') IS NOT NULL
    DROP PROC spEliminarCategoriaMotos
GO
CREATE PROC spEliminarCategoriaMotos
    @IDCategoria VARCHAR(5)
AS
BEGIN
    -- Declarar variables para almacenar los datos antes de eliminar
    DECLARE @catNombre VARCHAR(50), @catDescripcion VARCHAR(100);
    
    -- Verificar si la categor�a existe y obtener sus datos
    SELECT 
        @catNombre = catNombre,
        @catDescripcion = catDescripcion
    FROM tblCategoriaMotos 
    WHERE IDCategoria = @IDCategoria;
    
    IF @catNombre IS NULL
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: La categor�a no existe';
        RETURN;
    END
    
    -- Verificar si hay motos asociadas a esta categor�a
    IF EXISTS (SELECT 1 FROM tblMotos WHERE IDCategoria = @IDCategoria)
    BEGIN
        SELECT 
            CodError = 1, 
            Mensaje = 'Error: No se puede eliminar, existen motos asociadas a esta categor�a',
            Categoria = @IDCategoria,
            Nombre = @catNombre;
        RETURN;
    END
    
    -- Eliminar la categor�a
    DELETE FROM tblCategoriaMotos WHERE IDCategoria = @IDCategoria;
    
    -- Mostrar mensaje de �xito y los datos eliminados
    SELECT CodError = 0, Mensaje = 'Categor�a de motos eliminada correctamente';
    
    SELECT 
        IDCategoria AS [ID Categor�a Eliminada],
        @catNombre AS [Nombre Categor�a],
        @catDescripcion AS Descripci�n,
        'Eliminaci�n exitosa' AS Estado
    FROM (SELECT @IDCategoria AS IDCategoria) AS Temp;
END
GO

-- Ejemplo de eliminar categor�a (exitosa)
EXEC spEliminarCategoriaMotos 'CM036';
GO

-- Ejemplo de error (categor�a no existe)
EXEC spEliminarCategoriaMotos 'CM999';
GO

-- Ejemplo de error (tiene motos asociadas)
EXEC spEliminarCategoriaMotos 'CM001';
GO

-- 4. Procedimiento para Actualizar Categor�as de Motos
IF OBJECT_ID('spActualizarCategoriaMotos') IS NOT NULL
    DROP PROC spActualizarCategoriaMotos
GO
CREATE PROC spActualizarCategoriaMotos
    @IDCategoria VARCHAR(5),
    @catNombre VARCHAR(50),
    @catDescripcion VARCHAR(100) = NULL
AS
BEGIN
    -- Verificar si la categor�a existe
    IF NOT EXISTS (SELECT 1 FROM tblCategoriaMotos WHERE IDCategoria = @IDCategoria)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: La categor�a no existe';
        RETURN;
    END
    
    -- Verificar si el nuevo nombre ya existe (en otra categor�a)
    IF EXISTS (SELECT 1 FROM tblCategoriaMotos WHERE catNombre = @catNombre AND IDCategoria <> @IDCategoria)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre de categor�a ya est� en uso por otra categor�a';
        RETURN;
    END
    
    -- Validar longitud del nombre
    IF LEN(@catNombre) < 3 OR LEN(@catNombre) > 50
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre debe tener entre 3 y 50 caracteres';
        RETURN;
    END
    
    -- Actualizar la categor�a
    UPDATE tblCategoriaMotos SET
        catNombre = @catNombre,
        catDescripcion = @catDescripcion
    WHERE IDCategoria = @IDCategoria;
    
    SELECT CodError = 0, Mensaje = 'Categor�a de motos actualizada correctamente';
END
GO

-- Ejemplo de actualizar categor�a
EXEC spActualizarCategoriaMotos 'CM001', 'Deportiva', 'Motos de alta velocidad y competici�n';
GO

-- 5. Procedimiento para Buscar Categor�as de Motos (b�squeda sensitiva)
IF OBJECT_ID('spBuscarCategoriasMotos') IS NOT NULL
    DROP PROC spBuscarCategoriasMotos
GO
CREATE PROC spBuscarCategoriasMotos
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'IDCategoria'
        SELECT 
            IDCategoria,
            catNombre AS [Nombre Categor�a],
            catDescripcion AS Descripci�n,
            (SELECT COUNT(*) FROM tblMotos WHERE IDCategoria = cm.IDCategoria) AS [Total Motos]
        FROM tblCategoriaMotos cm
        WHERE IDCategoria LIKE '%' + @Texto + '%';
        
    ELSE IF @Criterio = 'Nombre'
        SELECT 
            IDCategoria,
            catNombre AS [Nombre Categor�a],
            catDescripcion AS Descripci�n,
            (SELECT COUNT(*) FROM tblMotos WHERE IDCategoria = cm.IDCategoria) AS [Total Motos]
        FROM tblCategoriaMotos cm
        WHERE catNombre LIKE '%' + @Texto + '%';
        
    ELSE IF @Criterio = 'Descripcion'
        SELECT 
            IDCategoria,
            catNombre AS [Nombre Categor�a],
            catDescripcion AS Descripci�n,
            (SELECT COUNT(*) FROM tblMotos WHERE IDCategoria = cm.IDCategoria) AS [Total Motos]
        FROM tblCategoriaMotos cm
        WHERE catDescripcion LIKE '%' + @Texto + '%';
        
    ELSE
        SELECT CodError = 1, Mensaje = 'Criterio de b�squeda no v�lido';
END
GO

-- Ejemplos de b�squeda
EXEC spBuscarCategoriasMotos 'Deport', 'Nombre';  -- Buscar por nombre
EXEC spBuscarCategoriasMotos 'CM00', 'IDCategoria';  -- Buscar por ID
EXEC spBuscarCategoriasMotos 'competici�n', 'Descripcion';  -- Buscar por descripci�n
GO



-----=================CATEGORIA DE REPUESTOS===============
---================================================================================
USE dbCorporativoValuCalderon;
GO

-- 1. Procedimiento para Listar Categor�as de Repuestos
IF OBJECT_ID('spListarCategoriasRepuestos') IS NOT NULL
    DROP PROC spListarCategoriasRepuestos
GO
CREATE PROC spListarCategoriasRepuestos
AS
BEGIN
    SELECT 
        cr.IDCategoriaRepuesto,
        cr.catNombre AS [Nombre Categor�a],
        cr.catDescripcion AS Descripci�n,
        (SELECT COUNT(*) FROM tblRepuestos WHERE IDCategoriaRepuesto = cr.IDCategoriaRepuesto) AS [Total Repuestos],
        (SELECT COUNT(DISTINCT RUC) FROM tblRepuestos WHERE IDCategoriaRepuesto = cr.IDCategoriaRepuesto) AS [Proveedores Asociados]
    FROM tblCategoriaRepuestos cr
    ORDER BY cr.catNombre;
END
GO

-- Ejecutar listado
EXEC spListarCategoriasRepuestos;
GO

-- 2. Procedimiento para Agregar Categor�as de Repuestos
IF OBJECT_ID('spAgregarCategoriaRepuestos') IS NOT NULL
    DROP PROC spAgregarCategoriaRepuestos
GO
CREATE PROC spAgregarCategoriaRepuestos
    @IDCategoriaRepuesto VARCHAR(5),
    @catNombre VARCHAR(50),
    @catDescripcion VARCHAR(100) = NULL
AS
BEGIN
    -- Validar formato de ID (5 caracteres)
    IF LEN(@IDCategoriaRepuesto) <> 5
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El ID debe tener exactamente 5 caracteres';
        RETURN;
    END
    -- Verificar si el ID ya existe
    IF EXISTS (SELECT 1 FROM tblCategoriaRepuestos WHERE IDCategoriaRepuesto = @IDCategoriaRepuesto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El ID de categor�a ya existe';
        RETURN;
    END
    -- Verificar si el nombre ya existe
    IF EXISTS (SELECT 1 FROM tblCategoriaRepuestos WHERE catNombre = @catNombre)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre de categor�a ya existe';
        RETURN;
    END
    -- Validar longitud del nombre (3-50 caracteres)
    IF LEN(@catNombre) < 3 OR LEN(@catNombre) > 50
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre debe tener entre 3 y 50 caracteres';
        RETURN;
    END
    -- Insertar la nueva categor�a
    INSERT INTO tblCategoriaRepuestos (
        IDCategoriaRepuesto,
        catNombre,
        catDescripcion
    ) VALUES (
        @IDCategoriaRepuesto,
        @catNombre,
        @catDescripcion
    );
    SELECT CodError = 0, Mensaje = 'Categor�a de repuestos agregada correctamente';
END
GO
-- Ejemplo de agregar categor�a
EXEC spAgregarCategoriaRepuestos 'CR090', 'Sistemas de Direcci�n', 'Componentes relacionados con la direcci�n de la moto';
GO

-- 3. Procedimiento para Eliminar Categor�as de Repuestos
IF OBJECT_ID('spEliminarCategoriaRepuestos') IS NOT NULL
    DROP PROC spEliminarCategoriaRepuestos
GO
CREATE PROC spEliminarCategoriaRepuestos
    @IDCategoriaRepuesto VARCHAR(5)
AS
BEGIN
    -- Verificar si la categor�a existe
    IF NOT EXISTS (SELECT 1 FROM tblCategoriaRepuestos WHERE IDCategoriaRepuesto = @IDCategoriaRepuesto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: La categor�a no existe';
        RETURN;
    END
    
    -- Verificar si hay repuestos asociados a esta categor�a
    IF EXISTS (SELECT 1 FROM tblRepuestos WHERE IDCategoriaRepuesto = @IDCategoriaRepuesto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: No se puede eliminar, existen repuestos asociados a esta categor�a';
        RETURN;
    END
    
    -- Eliminar la categor�a
    DELETE FROM tblCategoriaRepuestos WHERE IDCategoriaRepuesto = @IDCategoriaRepuesto;
    
    SELECT CodError = 0, Mensaje = 'Categor�a de repuestos eliminada correctamente';
END
GO

-- Ejemplo de eliminar categor�a (solo si no tiene repuestos asociados)
EXEC spEliminarCategoriaRepuestos 'CR036';
GO

--=================================4. Procedimiento para Actualizar Categor�as de Repuestos======================
---=============================================================================================================
IF OBJECT_ID('spActualizarCategoriaRepuestos') IS NOT NULL
    DROP PROC spActualizarCategoriaRepuestos
GO
CREATE PROC spActualizarCategoriaRepuestos
    @IDCategoriaRepuesto VARCHAR(5),
    @catNombre VARCHAR(50),
    @catDescripcion VARCHAR(100) = NULL
AS
BEGIN
    -- Verificar si la categor�a existe
    IF NOT EXISTS (SELECT 1 FROM tblCategoriaRepuestos WHERE IDCategoriaRepuesto = @IDCategoriaRepuesto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: La categor�a no existe';
        RETURN;
    END
    
    -- Verificar si el nuevo nombre ya existe (en otra categor�a)
    IF EXISTS (SELECT 1 FROM tblCategoriaRepuestos WHERE catNombre = @catNombre AND IDCategoriaRepuesto <> @IDCategoriaRepuesto)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre de categor�a ya est� en uso por otra categor�a';
        RETURN;
    END
    
    -- Validar longitud del nombre
    IF LEN(@catNombre) < 3 OR LEN(@catNombre) > 50
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre debe tener entre 3 y 50 caracteres';
        RETURN;
    END
    
    -- Actualizar la categor�a
    UPDATE tblCategoriaRepuestos SET
        catNombre = @catNombre,
        catDescripcion = @catDescripcion
    WHERE IDCategoriaRepuesto = @IDCategoriaRepuesto;
    
    SELECT CodError = 0, Mensaje = 'Categor�a de repuestos actualizada correctamente';
END
GO

-- Ejemplo de actualizar categor�a
EXEC spActualizarCategoriaRepuestos 'CR001', 'Sistema de Frenos', 'Componentes completos del sistema de frenado';
GO

-- 5. Procedimiento para Buscar Categor�as de Repuestos (b�squeda sensitiva)
IF OBJECT_ID('spBuscarCategoriasRepuestos') IS NOT NULL
    DROP PROC spBuscarCategoriasRepuestos
GO
CREATE PROC spBuscarCategoriasRepuestos
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'IDCategoria'
        SELECT 
            IDCategoriaRepuesto,
            catNombre AS [Nombre Categor�a],
            catDescripcion AS Descripci�n,
            (SELECT COUNT(*) FROM tblRepuestos WHERE IDCategoriaRepuesto = cr.IDCategoriaRepuesto) AS [Total Repuestos]
        FROM tblCategoriaRepuestos cr
        WHERE IDCategoriaRepuesto LIKE '%' + @Texto + '%';
        
    ELSE IF @Criterio = 'Nombre'
        SELECT 
            IDCategoriaRepuesto,
            catNombre AS [Nombre Categor�a],
            catDescripcion AS Descripci�n,
            (SELECT COUNT(*) FROM tblRepuestos WHERE IDCategoriaRepuesto = cr.IDCategoriaRepuesto) AS [Total Repuestos]
        FROM tblCategoriaRepuestos cr
        WHERE catNombre LIKE '%' + @Texto + '%';
        
    ELSE IF @Criterio = 'Descripcion'
        SELECT 
            IDCategoriaRepuesto,
            catNombre AS [Nombre Categor�a],
            catDescripcion AS Descripci�n,
            (SELECT COUNT(*) FROM tblRepuestos WHERE IDCategoriaRepuesto = cr.IDCategoriaRepuesto) AS [Total Repuestos]
        FROM tblCategoriaRepuestos cr
        WHERE catDescripcion LIKE '%' + @Texto + '%';
        
    ELSE
        SELECT CodError = 1, Mensaje = 'Criterio de b�squeda no v�lido';
END
GO

-- Ejemplos de b�squeda
EXEC spBuscarCategoriasRepuestos 'Frenos', 'Nombre';  -- Buscar por nombre
EXEC spBuscarCategoriasRepuestos 'CR00', 'IDCategoria';  -- Buscar por ID
EXEC spBuscarCategoriasRepuestos 'motor', 'Descripcion';  -- Buscar por descripci�n
GO

-- 6. Procedimiento para Obtener Estad�sticas de Categor�as de Repuestos
IF OBJECT_ID('spEstadisticasCategoriasRepuestos') IS NOT NULL
    DROP PROC spEstadisticasCategoriasRepuestos
GO
CREATE PROC spEstadisticasCategoriasRepuestos
AS
BEGIN
    SELECT 
        cr.IDCategoriaRepuesto,
        cr.catNombre AS Categoria,
        COUNT(r.IDRepuesto) AS [Total Repuestos],
        ISNULL(SUM(r.repStock), 0) AS [Stock Total],
        ISNULL(AVG(r.repPrecio), 0) AS [Precio Promedio],
        MIN(r.repPrecio) AS [Precio M�nimo],
        MAX(r.repPrecio) AS [Precio M�ximo],
        COUNT(DISTINCT r.RUC) AS [Proveedores Diferentes]
    FROM tblCategoriaRepuestos cr
    LEFT JOIN tblRepuestos r ON cr.IDCategoriaRepuesto = r.IDCategoriaRepuesto
    GROUP BY cr.IDCategoriaRepuesto, cr.catNombre
    ORDER BY [Total Repuestos] DESC;
END
GO

-- Ejecutar estad�sticas
EXEC spEstadisticasCategoriasRepuestos;
GO


---========METODO DE PAGO========================================================
------=======================================================================
USE dbCorporativoValuCalderon;
GO

-- 1. Procedimiento para Listar M�todos de Pago
IF OBJECT_ID('spListarMetodosPago') IS NOT NULL
    DROP PROC spListarMetodosPago
GO
CREATE PROC spListarMetodosPago
AS
BEGIN
    SELECT 
        IDMetodoPago,
        metNombre AS [M�todo de Pago],
        metDescripcion AS Descripci�n,
        (SELECT COUNT(*) FROM tblVenta WHERE IDMetodoPago = mp.IDMetodoPago) AS [Ventas Asociadas]
    FROM tblMetodoPago mp
    ORDER BY metNombre;
END
GO

-- Ejecutar listado
EXEC spListarMetodosPago;
GO

-- 2. Procedimiento para Agregar M�todos de Pago
IF OBJECT_ID('spAgregarMetodoPago') IS NOT NULL
    DROP PROC spAgregarMetodoPago
GO
CREATE PROC spAgregarMetodoPago
    @IDMetodoPago VARCHAR(5),
    @metNombre VARCHAR(30),
    @metDescripcion VARCHAR(100) = NULL
AS
BEGIN
    -- Validar formato de ID (5 caracteres)
    IF LEN(@IDMetodoPago) <> 5
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El ID debe tener exactamente 5 caracteres';
        RETURN;
    END
    -- Verificar si el ID ya existe
    IF EXISTS (SELECT 1 FROM tblMetodoPago WHERE IDMetodoPago = @IDMetodoPago)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El ID de m�todo de pago ya existe';
        RETURN;
    END 
    -- Verificar si el nombre ya existe
    IF EXISTS (SELECT 1 FROM tblMetodoPago WHERE metNombre = @metNombre)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre de m�todo de pago ya existe';
        RETURN;
    END
    -- Validar longitud del nombre (2-30 caracteres)
    IF LEN(@metNombre) < 2 OR LEN(@metNombre) > 30
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre debe tener entre 2 y 30 caracteres';
        RETURN;
    END
    -- Insertar el nuevo m�todo de pago
    INSERT INTO tblMetodoPago (
        IDMetodoPago,
        metNombre,
        metDescripcion
    ) VALUES (
        @IDMetodoPago,
        @metNombre,
        @metDescripcion
    );
    
    SELECT CodError = 0, Mensaje = 'M�todo de pago agregado correctamente';
END
GO
-- Ejemplo de agregar m�todo de pago
EXEC spAgregarMetodoPago 'MP036', 'Pago con QR', 'Pago mediante c�digo QR de la aplicaci�n m�vil';
GO

-- 3. Procedimiento para Eliminar M�todos de Pago
IF OBJECT_ID('spEliminarMetodoPago') IS NOT NULL
    DROP PROC spEliminarMetodoPago
GO
CREATE PROC spEliminarMetodoPago
    @IDMetodoPago VARCHAR(5)
AS
BEGIN
    -- Verificar si el m�todo de pago existe
    IF NOT EXISTS (SELECT 1 FROM tblMetodoPago WHERE IDMetodoPago = @IDMetodoPago)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El m�todo de pago no existe';
        RETURN;
    END
    
    -- Verificar si hay ventas asociadas a este m�todo
    IF EXISTS (SELECT 1 FROM tblVenta WHERE IDMetodoPago = @IDMetodoPago)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: No se puede eliminar, existen ventas asociadas a este m�todo de pago';
        RETURN;
    END
    
    -- Eliminar el m�todo de pago
    DELETE FROM tblMetodoPago WHERE IDMetodoPago = @IDMetodoPago;
    
    SELECT CodError = 0, Mensaje = 'M�todo de pago eliminado correctamente';
END
GO

-- Ejemplo de eliminar m�todo de pago (solo si no tiene ventas asociadas)
EXEC spEliminarMetodoPago 'MP036';
GO

-- 4. Procedimiento para Actualizar M�todos de Pago
IF OBJECT_ID('spActualizarMetodoPago') IS NOT NULL
    DROP PROC spActualizarMetodoPago
GO
CREATE PROC spActualizarMetodoPago
    @IDMetodoPago VARCHAR(5),
    @metNombre VARCHAR(30),
    @metDescripcion VARCHAR(100) = NULL
AS
BEGIN
    -- Verificar si el m�todo de pago existe
    IF NOT EXISTS (SELECT 1 FROM tblMetodoPago WHERE IDMetodoPago = @IDMetodoPago)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El m�todo de pago no existe';
        RETURN;
    END
    
    -- Verificar si el nuevo nombre ya existe (en otro m�todo)
    IF EXISTS (SELECT 1 FROM tblMetodoPago WHERE metNombre = @metNombre AND IDMetodoPago <> @IDMetodoPago)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre de m�todo de pago ya est� en uso por otro m�todo';
        RETURN;
    END
    
    -- Validar longitud del nombre
    IF LEN(@metNombre) < 2 OR LEN(@metNombre) > 30
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nombre debe tener entre 2 y 30 caracteres';
        RETURN;
    END
    
    -- Actualizar el m�todo de pago
    UPDATE tblMetodoPago SET
        metNombre = @metNombre,
        metDescripcion = @metDescripcion
    WHERE IDMetodoPago = @IDMetodoPago;
    
    SELECT CodError = 0, Mensaje = 'M�todo de pago actualizado correctamente';
END
GO

-- Ejemplo de actualizar m�todo de pago
EXEC spActualizarMetodoPago 'MP001', 'Efectivo', 'Pago en efectivo en caja o punto de venta';
GO

-- 5. Procedimiento para Buscar M�todos de Pago (b�squeda sensitiva)
IF OBJECT_ID('spBuscarMetodosPago') IS NOT NULL
    DROP PROC spBuscarMetodosPago
GO
CREATE PROC spBuscarMetodosPago
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'IDMetodoPago'
        SELECT 
            IDMetodoPago,
            metNombre AS [M�todo de Pago],
            metDescripcion AS Descripci�n,
            (SELECT COUNT(*) FROM tblVenta WHERE IDMetodoPago = mp.IDMetodoPago) AS [Ventas Asociadas]
        FROM tblMetodoPago mp
        WHERE IDMetodoPago LIKE '%' + @Texto + '%';
        
    ELSE IF @Criterio = 'Nombre'
        SELECT 
            IDMetodoPago,
            metNombre AS [M�todo de Pago],
            metDescripcion AS Descripci�n,
            (SELECT COUNT(*) FROM tblVenta WHERE IDMetodoPago = mp.IDMetodoPago) AS [Ventas Asociadas]
        FROM tblMetodoPago mp
        WHERE metNombre LIKE '%' + @Texto + '%';
        
    ELSE IF @Criterio = 'Descripcion'
        SELECT 
            IDMetodoPago,
            metNombre AS [M�todo de Pago],
            metDescripcion AS Descripci�n,
            (SELECT COUNT(*) FROM tblVenta WHERE IDMetodoPago = mp.IDMetodoPago) AS [Ventas Asociadas]
        FROM tblMetodoPago mp
        WHERE metDescripcion LIKE '%' + @Texto + '%';
        
    ELSE
        SELECT CodError = 1, Mensaje = 'Criterio de b�squeda no v�lido';
END
GO

-- Ejemplos de b�squeda
EXEC spBuscarMetodosPago 'Tarjeta', 'Nombre';  -- Buscar por nombre
EXEC spBuscarMetodosPago 'MP00', 'IDMetodoPago';  -- Buscar por ID
EXEC spBuscarMetodosPago 'digital', 'Descripcion';  -- Buscar por descripci�n
GO

-- 6. Procedimiento para Obtener M�todos de Pago M�s Utilizados
IF OBJECT_ID('spMetodosPagoMasUtilizados') IS NOT NULL
    DROP PROC spMetodosPagoMasUtilizados
GO
CREATE PROC spMetodosPagoMasUtilizados
    @Top INT = 5,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL
AS
BEGIN
    -- Si no se especifican fechas, considerar todos los registros
    IF @FechaInicio IS NULL SET @FechaInicio = '1900-01-01'
    IF @FechaFin IS NULL SET @FechaFin = GETDATE()
    
    SELECT TOP (@Top)
        mp.IDMetodoPago,
        mp.metNombre AS [M�todo de Pago],
        COUNT(v.IDVenta) AS [Total Ventas],
        SUM(v.venTotal) AS [Monto Total],
        FORMAT(COUNT(v.IDVenta) * 100.0 / (SELECT COUNT(*) FROM tblVenta 
                                        WHERE venFecha BETWEEN @FechaInicio AND @FechaFin), 'N2') + '%' AS [Porcentaje]
    FROM tblMetodoPago mp
    LEFT JOIN tblVenta v ON mp.IDMetodoPago = v.IDMetodoPago
    WHERE v.venFecha BETWEEN @FechaInicio AND @FechaFin
    GROUP BY mp.IDMetodoPago, mp.metNombre
    ORDER BY [Total Ventas] DESC;
END
GO

-- Ejemplos de uso
EXEC spMetodosPagoMasUtilizados;  -- Top 5 m�todos m�s usados (todos los tiempos)
EXEC spMetodosPagoMasUtilizados 3, '2024-01-01', '2024-12-31';  -- Top 3 m�todos en 2024
GO
