-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA PROVEEDOR//--
--FUNCION DE AGREGAR PROVEEDOR NUEVO--
IF OBJECT_ID('spInsertarProveedor', 'P') IS NOT NULL
    DROP PROCEDURE spInsertarProveedor
GO

CREATE PROCEDURE spInsertarProveedor
    @RUC VARCHAR(11),
    @provNombre VARCHAR(100),
    @provRazonSocial VARCHAR(100),
    @provDireccion VARCHAR(100),
    @provTelefono VARCHAR(9),
    @provEmail VARCHAR(100) = NULL, 
    @provEstado VARCHAR(10) = 'Activo' 
AS
BEGIN
    -- COMPROBAMOS SI EL RUC NO SE REPITE
    IF EXISTS (SELECT 1 FROM tblProveedor WHERE RUC = @RUC)
    BEGIN
        -- SI EXISTE DEVOLVEMOS ERROR
        SELECT CodError = 1, Mensaje = 'Error: El RUC ya está registrado y no se puede duplicar.'
        RETURN
    END

    -- SI NO EXISTE, INSERTAMOS NUEVO REGISTRO
    INSERT INTO tblProveedor (RUC, provNombre, provRazonSocial, provDireccion, provTelefono, provEmail, provEstado)
    VALUES (@RUC, @provNombre, @provRazonSocial, @provDireccion, @provTelefono, @provEmail, @provEstado)
--
    SELECT CodError = 0, Mensaje = 'Proveedor insertado correctamente.'
END
GO
-- EJECUCIÓN
-- INSERT DEL NUEVO PROVEEDOR
EXEC spInsertarProveedor 
    @RUC = '20100000036', 
    @provNombre = 'RepuestosVeloces SRL', 
    @provRazonSocial = 'Repuestos Veloces S.R.L.', 
    @provDireccion = 'Calle Industrial 456', 
    @provTelefono = '912345678', 
    @provEmail = 'contacto@repuestosveloces.com'
GO
-- SELECT AL NUEVO REGISTRO COMO PRUEBA
SELECT * FROM tblProveedor
WHERE RUC = '20100000036'
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA CLIENTE//--
--FUNCION DE AGREGAR UN NUEVO CLIENTE--
IF OBJECT_ID('spInsertarCliente', 'P') IS NOT NULL
    DROP PROCEDURE spInsertarCliente
GO

CREATE PROCEDURE spInsertarCliente
    @DNI VARCHAR(8),
    @cliApellidoPaterno VARCHAR(30),
    @cliApellidoMaterno VARCHAR(30),
    @cliNombres VARCHAR(50),
    @cliSexo CHAR(1),
    @cliFechaNacimiento DATE,
    @cliDireccion VARCHAR(100),
    @cliFechaRegistro DATE,
    @cliTelefono VARCHAR(9) = NULL, 
    @cliEmail VARCHAR(100) = NULL, 
    @cliTipo VARCHAR(20) = 'Local', 
    @cliEstado VARCHAR(10) = 'Activo' 
AS
BEGIN
    -- COMPROBAMOS SI EL DNI SE REPITE
    IF EXISTS (SELECT 1 FROM tblCliente WHERE DNI = @DNI)
    BEGIN
        -- SI EXISTE DEVOLVEMOS ERROR
        SELECT CodError = 1, Mensaje = 'Error: El DNI ya está registrado y no se puede duplicar.'
        RETURN
    END
    
    -- VALIDAD SEXO
    IF (@cliSexo NOT IN ('M', 'F'))
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El valor para sexo debe ser ''M'' o ''F''.'
        RETURN
    END

    -- SI VALIDAMOS, PROCEDEMOS A INSERTAR
    INSERT INTO tblCliente (DNI, cliApellidoPaterno, cliApellidoMaterno, cliNombres, cliSexo, cliFechaNacimiento, 
	cliDireccion, cliTelefono, cliEmail, cliTipo, cliFechaRegistro, cliEstado)
    VALUES (@DNI, @cliApellidoPaterno, @cliApellidoMaterno, @cliNombres, @cliSexo, @cliFechaNacimiento, 
	@cliDireccion, @cliTelefono, @cliEmail, @cliTipo, @cliFechaRegistro, @cliEstado)
--
    SELECT CodError = 0, Mensaje = 'Cliente insertado correctamente.'
END
GO

-- PRUEBA
-- INSERTAMOS UN NUEVO CLIENTE
EXEC spInsertarCliente 
    @DNI = '70000036',
    @cliApellidoPaterno = 'Zavala',
    @cliApellidoMaterno = 'Huacarpuma',
    @cliNombres = 'Juan Aldair',
    @cliSexo = 'M',
    @cliFechaNacimiento = '2002-05-19',
    @cliDireccion = 'Plaza de Armas 456',
    @cliFechaRegistro = '2024-05-21',
    @cliTelefono = '987123456',
    @cliEmail = 'zavala.alda@email.com'
GO
-- SELECT AL NUEVO REGISTRO COMO PRUEBA
SELECT * FROM tblCliente
WHERE DNI = '70000036'
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA PEDIDO//--
--FUNCION DE AGREGAR UN NUEVO PEDIDO--
IF OBJECT_ID('spInsertarPedido', 'P') IS NOT NULL
    DROP PROCEDURE spInsertarPedido
GO

CREATE PROCEDURE spInsertarPedido
    @IDPedido VARCHAR(20),
    @IDTrabajador VARCHAR(8),
    @RUC VARCHAR(11),
    @pedFecha DATE,
    @pedEstado VARCHAR(20) = 'Pendiente' 
AS
BEGIN
    -- COMPROBAMOS SI EXISTE UN PEDIDO IGUAL
    IF EXISTS (SELECT 1 FROM tblPedidos WHERE IDPedido = @IDPedido)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El ID de pedido ya está registrado.'
        RETURN
    END

    -- VALIDAMOS QUIEN HACE EL PEDIDO (TRABAJADOR)
    IF NOT EXISTS (SELECT 1 FROM tblTrabajador WHERE IDTrabajador = @IDTrabajador)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El ID de trabajador no existe.'
        RETURN
    END

    -- VALIDAMOS SI EL PROVEEDOR EXISTE
    IF NOT EXISTS (SELECT 1 FROM tblProveedor WHERE RUC = @RUC)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El RUC del proveedor no existe.'
        RETURN
    END

    -- INSERTAMOS NUEVO PEDIDO
    INSERT INTO tblPedidos (IDPedido, IDTrabajador, RUC, pedFecha, pedEstado)
    VALUES (@IDPedido, @IDTrabajador, @RUC, @pedFecha, @pedEstado)
--
    SELECT CodError = 0, Mensaje = 'Pedido insertado correctamente.'
END
GO

-- EJECUCIÓN
-- INSERTAMOS NUEVO PEDIDO
EXEC spInsertarPedido
    @IDPedido = 'PED000035',
    @IDTrabajador = 'T0000036',
    @RUC = '20100000037',
    @pedFecha = '2025-06-12'
GO
-- SELECT AL NUEVO REGISTRO COMO PRUEBA
SELECT * FROM tblPedidos
WHERE IDPedido = 'PED000035'
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA PEDIDO//--
--FUNCION DE SELECCION (SELECT/GET)--
IF OBJECT_ID('spBuscarPedido', 'P') IS NOT NULL
    DROP PROCEDURE spBuscarPedido
GO

CREATE PROCEDURE spBuscarPedido
    @Texto VARCHAR(50),
    @Criterio VARCHAR(20)
AS
BEGIN
    -- BUSQUEDA DEL IDPEDIDO (parcial/sensitiva)
    IF (@Criterio = 'IDPedido')
    BEGIN
        SELECT IDPedido, IDTrabajador, RUC, pedFecha, pedEstado
        FROM tblPedidos
        WHERE IDPedido LIKE '%' + @Texto + '%';
    END
    -- BUSQUEDA DEL IDTRABAJADOR (parcial/sensitiva)
    ELSE IF (@Criterio = 'IDTrabajador')
    BEGIN
        SELECT IDPedido, IDTrabajador, RUC, pedFecha, pedEstado
        FROM tblPedidos
        WHERE IDTrabajador LIKE '%' + @Texto + '%';
    END
    -- BUSQUEDA DEL IDPROVEEDOR (parcial/sensitiva)
    ELSE IF (@Criterio = 'RUC')
    BEGIN
        SELECT IDPedido, IDTrabajador, RUC, pedFecha, pedEstado
        FROM tblPedidos
        WHERE RUC LIKE '%' + @Texto + '%';
    END
    -- BUSQUEDA DE FECHA (exacta)
    ELSE IF (@Criterio = 'Fecha')
    BEGIN
        SELECT IDPedido, IDTrabajador, RUC, pedFecha, pedEstado
        FROM tblPedidos
        WHERE pedFecha = TRY_CAST(@Texto AS DATE);
    END
    -- BUSQUEDA DEL ESTADO (exacta)
    ELSE IF (@Criterio = 'Estado')
    BEGIN
        SELECT IDPedido, IDTrabajador, RUC, pedFecha, pedEstado
        FROM tblPedidos
        WHERE pedEstado = @Texto;
    END
    ELSE
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: Criterio de búsqueda no válido para Pedidos.';
    END
END
GO
-- Ejemplos de ejecución
EXEC spBuscarPedido 'PED', 'IDPedido'
GO
EXEC spBuscarPedido 'T0000001', 'IDTrabajador'
GO
EXEC spBuscarPedido 'Pendiente', 'Estado'
GO
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA TRABAJADOR//--
--FUNCION DE SELECCION (SELECT/GET)--
IF OBJECT_ID('spBuscarTrabajador', 'P') IS NOT NULL
    DROP PROCEDURE spBuscarTrabajador
GO

CREATE PROCEDURE spBuscarTrabajador
    @Texto VARCHAR(50),
    @Criterio VARCHAR(30)
AS
BEGIN
    IF (@Criterio = 'IDTrabajador')
    BEGIN
        SELECT IDTrabajador, traApellidoPaterno, traApellidoMaterno, traNombres, traCargo, traEstado
        FROM tblTrabajador
        WHERE IDTrabajador LIKE '%' + @Texto + '%';
    END
    ELSE IF (@Criterio = 'Apellidos')
    BEGIN
        SELECT IDTrabajador, traApellidoPaterno, traApellidoMaterno, traNombres, traCargo, traEstado
        FROM tblTrabajador
        WHERE traApellidoPaterno LIKE '%' + @Texto + '%' OR traApellidoMaterno LIKE '%' + @Texto + '%';
    END
    ELSE IF (@Criterio = 'Nombres')
    BEGIN
        SELECT IDTrabajador, traApellidoPaterno, traApellidoMaterno, traNombres, traCargo, traEstado
        FROM tblTrabajador
        WHERE traNombres LIKE '%' + @Texto + '%';
    END
    ELSE IF (@Criterio = 'Cargo')
    BEGIN
        SELECT IDTrabajador, traApellidoPaterno, traApellidoMaterno, traNombres, traCargo, traEstado
        FROM tblTrabajador
        WHERE traCargo LIKE '%' + @Texto + '%';
    END
    ELSE
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: Criterio de búsqueda no válido para Trabajador.';
    END
END
GO

-- EJECUCION
EXEC spBuscarTrabajador 'T00', 'IDTrabajador'
GO
EXEC spBuscarTrabajador 'Gonzales', 'Apellidos'
GO
EXEC spBuscarTrabajador 'Juan', 'Nombres'
GO
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA CLIENTE//--
--FUNCION DE SELECCION (SELECT/GET)--
IF OBJECT_ID('spBuscarCliente', 'P') IS NOT NULL
    DROP PROCEDURE spBuscarCliente
GO

CREATE PROCEDURE spBuscarCliente
    @Texto VARCHAR(50),
    @Criterio VARCHAR(30)
AS
BEGIN
    IF (@Criterio = 'DNI')
    BEGIN
        SELECT DNI, cliApellidoPaterno, cliApellidoMaterno, cliNombres, cliTipo, cliEstado
        FROM tblCliente
        WHERE DNI LIKE '%' + @Texto + '%';
    END
    ELSE IF (@Criterio = 'Apellidos')
    BEGIN
        SELECT DNI, cliApellidoPaterno, cliApellidoMaterno, cliNombres, cliTipo, cliEstado
        FROM tblCliente
        WHERE cliApellidoPaterno LIKE '%' + @Texto + '%' OR cliApellidoMaterno LIKE '%' + @Texto + '%';
    END
    ELSE IF (@Criterio = 'Nombres')
    BEGIN
        SELECT DNI, cliApellidoPaterno, cliApellidoMaterno, cliNombres, cliTipo, cliEstado
        FROM tblCliente
        WHERE cliNombres LIKE '%' + @Texto + '%';
    END
     ELSE IF (@Criterio = 'Tipo')
    BEGIN
        SELECT DNI, cliApellidoPaterno, cliApellidoMaterno, cliNombres, cliTipo, cliEstado
        FROM tblCliente
        WHERE cliTipo = @Texto;
    END
    ELSE
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: Criterio de búsqueda no válido para Cliente.';
    END
END
GO
-- PRUEBA 
EXEC spBuscarCliente '7000', 'DNI'
GO
EXEC spBuscarCliente 'Rojas', 'Apellidos'
GO
EXEC spBuscarCliente 'Pedro', 'Nombres'
GO
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA PEDIDO//--
--FUNCION DE ACTUALIZAR (UPDATE)--
IF OBJECT_ID('spActualizarPedido', 'P') IS NOT NULL
    DROP PROCEDURE spActualizarPedido
GO

CREATE PROCEDURE spActualizarPedido
    @IDPedido VARCHAR(20),
    @IDTrabajador VARCHAR(8),
    @RUC VARCHAR(11),
    @pedFecha DATE,
    @pedEstado VARCHAR(20)
AS
BEGIN
    -- COMPROBAMOS SI EXISTE EL PEDIDO
    IF NOT EXISTS (SELECT 1 FROM tblPedidos WHERE IDPedido = @IDPedido)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El pedido no existe y no se puede actualizar.'
        RETURN
    END

    -- VALIDAMOS QUE EL TRBAJADOR EXISTA
    IF NOT EXISTS (SELECT 1 FROM tblTrabajador WHERE IDTrabajador = @IDTrabajador)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nuevo ID de trabajador no es válido.'
        RETURN
    END

    -- VALIDAMOS QUE EL NUEVO PROVEEDOR EXISTA
    IF NOT EXISTS (SELECT 1 FROM tblProveedor WHERE RUC = @RUC)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El nuevo RUC de proveedor no es válido.'
        RETURN
    END
    -- 
    UPDATE tblPedidos
    SET 
        IDTrabajador = @IDTrabajador,
        RUC = @RUC,
        pedFecha = @pedFecha,
        pedEstado = @pedEstado
    WHERE IDPedido = @IDPedido;

    SELECT CodError = 0, Mensaje = 'Pedido actualizado correctamente.'
END
GO
-- EJECUCION
EXEC spActualizarPedido 
    @IDPedido = 'PED000001', 
    @IDTrabajador = 'T0000001', 
    @RUC = '20100000001', 
    @pedFecha = '2025-04-01', 
    @pedEstado = 'Completado'
GO
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA TRABAJADOR//--
--FUNCION DE ACTUALIZAR (UPDATE)--
IF OBJECT_ID('spActualizarTrabajador', 'P') IS NOT NULL
    DROP PROCEDURE spActualizarTrabajador
GO

CREATE PROCEDURE spActualizarTrabajador
    @IDTrabajador VARCHAR(8),
    @traApellidoPaterno VARCHAR(30),
    @traApellidoMaterno VARCHAR(30),
    @traNombres VARCHAR(50),
    @traSexo CHAR(1),
    @traCargo VARCHAR(30),
    @traTelefono VARCHAR(9),
    @traSueldo DECIMAL(10, 2),
    @traFechaContratacion DATE,
    @traEmail VARCHAR(100),
    @traEstado VARCHAR(10)
AS
BEGIN
    -- COMPROBAMOS SI EL TRABAJADOR EXISTE
    IF NOT EXISTS (SELECT 1 FROM tblTrabajador WHERE IDTrabajador = @IDTrabajador)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El trabajador no existe y no se puede actualizar.'
        RETURN
    END

    -- VALIDAMOS SU SEXO
    IF (@traSexo NOT IN ('M', 'F'))
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El valor para sexo debe ser ''M'' o ''F''.'
        RETURN
    END
--
    UPDATE tblTrabajador
    SET
        traApellidoPaterno = @traApellidoPaterno,
        traApellidoMaterno = @traApellidoMaterno,
        traNombres = @traNombres,
        traSexo = @traSexo,
        traCargo = @traCargo,
        traTelefono = @traTelefono,
        traSueldo = @traSueldo,
        traFechaContratacion = @traFechaContratacion,
        traEmail = @traEmail,
        traEstado = @traEstado
    WHERE IDTrabajador = @IDTrabajador;

    SELECT CodError = 0, Mensaje = 'Trabajador actualizado correctamente.'
END
GO
-- ACTUALIZAMOS EL ESTADO DEL TRABAJADOR T0000001 A INACTIVO
EXEC spActualizarTrabajador
    @IDTrabajador = 'T0000001',
    @traApellidoPaterno = 'Gonzales',
    @traApellidoMaterno = 'Perez',
    @traNombres = 'Juan Carlos',
    @traSexo = 'M',
    @traCargo = 'Vendedor',
    @traTelefono = '912345678',
    @traEmail = 'juan@empresa.com',
    @traSueldo = 1500.00,
    @traFechaContratacion = '2023-01-15',
    @traEstado = 'Inactivo'
GO
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA CLIENTE//--
--FUNCION DE ACTUALIZAR (UPDATE)--
IF OBJECT_ID('spActualizarCliente', 'P') IS NOT NULL
    DROP PROCEDURE spActualizarCliente
GO

CREATE PROCEDURE spActualizarCliente
    @DNI VARCHAR(8),
    @cliApellidoPaterno VARCHAR(30),
    @cliApellidoMaterno VARCHAR(30),
    @cliNombres VARCHAR(50),
    @cliSexo CHAR(1),
    @cliFechaNacimiento DATE,
    @cliDireccion VARCHAR(100),
    @cliTelefono VARCHAR(9),
    @cliEmail VARCHAR(100),
    @cliTipo VARCHAR(20),
    @cliFechaRegistro DATE,
    @cliEstado VARCHAR(10)
AS
BEGIN
    -- COMPROBAMOS SI EL CLIENTE EXISTE
    IF NOT EXISTS (SELECT 1 FROM tblCliente WHERE DNI = @DNI)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El cliente no existe y no se puede actualizar.'
        RETURN
    END
    -- VALIDAMOS SU SEXO
    IF (@cliSexo NOT IN ('M', 'F'))
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El valor para sexo debe ser ''M'' o ''F''.'
        RETURN
    END
--
    UPDATE tblCliente
    SET
        cliApellidoPaterno = @cliApellidoPaterno,
        cliApellidoMaterno = @cliApellidoMaterno,
        cliNombres = @cliNombres,
        cliSexo = @cliSexo,
        cliFechaNacimiento = @cliFechaNacimiento,
        cliDireccion = @cliDireccion,
        cliTelefono = @cliTelefono,
        cliEmail = @cliEmail,
        cliTipo = @cliTipo,
        cliFechaRegistro = @cliFechaRegistro,
        cliEstado = @cliEstado
    WHERE DNI = @DNI;

    SELECT CodError = 0, Mensaje = 'Cliente actualizado correctamente.'
END
GO

-- ACTUALIZAMOS AL CLIENTE 70000001 CON NUEVOS DATOS
EXEC spActualizarCliente
    @DNI = '70000001',
    @cliApellidoPaterno = 'Rojas',
    @cliApellidoMaterno = 'Vargas',
    @cliNombres = 'Pedro Luis',
    @cliSexo = 'M',
    @cliFechaNacimiento = '1990-05-14',
    @cliDireccion = 'Calle Nueva 789',
    @cliTelefono = '999888777',
    @cliEmail = 'pedro.nuevo@gmail.com',
    @cliTipo = 'Local',
    @cliFechaRegistro = '2024-04-01',
    @cliEstado = 'Activo'
GO
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA PEDIDO//--
--PROCEDIMIENTO DE ELIMINAR (DELETE)--
IF OBJECT_ID('spEliminarPedido', 'P') IS NOT NULL
    DROP PROCEDURE spEliminarPedido
GO

CREATE PROCEDURE spEliminarPedido
    @IDPedido VARCHAR(20)
AS
BEGIN
    -- COMPROBAMOS SI EL PEDIDO EXISTE
    IF NOT EXISTS (SELECT 1 FROM tblPedidos WHERE IDPedido = @IDPedido)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El pedido no existe y no se puede eliminar.'
        RETURN
    END
    -- SI EXISTE, SE ELIMINA
    DELETE FROM tblPedidos
    WHERE IDPedido = @IDPedido;

    SELECT CodError = 0, Mensaje = 'Pedido eliminado correctamente.'
END
GO
-- Eliminamos un pedido existente
EXEC spInsertarPedido 'PED000035', 'T0000001', '20100000001', '2025-12-31';
GO
-- COMPLETAMOS LA ELIMINACION
EXEC spEliminarPedido @IDPedido = 'PED000035';
GO
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA TRABAJADOR//--
--PROCEDIMIENTO DE ELIMINAR (DELETE)--
IF OBJECT_ID('spEliminarTrabajador', 'P') IS NOT NULL
    DROP PROCEDURE spEliminarTrabajador
GO

CREATE PROCEDURE spEliminarTrabajador
    @IDTrabajador VARCHAR(8)
AS
BEGIN
    -- COMPROBAMOS SI EL TRABAJADOR EXISTE
    IF NOT EXISTS (SELECT 1 FROM tblTrabajador WHERE IDTrabajador = @IDTrabajador)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El trabajador no existe y no se puede eliminar.'
        RETURN
    END

    BEGIN TRY
        -- ELIMINAMOS REGISTRO
        DELETE FROM tblTrabajador
        WHERE IDTrabajador = @IDTrabajador;

        SELECT CodError = 0, Mensaje = 'Trabajador eliminado físicamente de la base de datos.'
    END TRY
    BEGIN CATCH
	--
        SELECT 
            CodError = ERROR_NUMBER(), 
            Mensaje = 'Error: No se pudo eliminar el trabajador. Probablemente tiene ventas o pedidos asociados. Considere cambiar su estado a "Inactivo".';
    END CATCH
END
GO
-- EJECUCION
EXEC spEliminarTrabajador @IDTrabajador = 'T0000036';
GO
------------------------------------------------------
--PROCEDIMIENTO DE AGREGAR UN TRABAJADOR NUEVO--
IF OBJECT_ID('spInsertarTrabajador', 'P') IS NOT NULL
    DROP PROCEDURE spInsertarTrabajador
GO
--
CREATE PROCEDURE spInsertarTrabajador
    @IDTrabajador VARCHAR(8),
    @traApellidoPaterno VARCHAR(30),
    @traApellidoMaterno VARCHAR(30),
    @traNombres VARCHAR(50),
    @traSexo CHAR(1),
    @traCargo VARCHAR(30),
    @traTelefono VARCHAR(9),
    @traEmail VARCHAR(100),
    @traSueldo DECIMAL(10, 2),
    @traFechaContratacion DATE,
    @traEstado VARCHAR(10) = 'Activo'
AS
BEGIN
    -- COMPROBAMOS SI EL ID NO SE REPITE
    IF EXISTS (SELECT 1 FROM tblTrabajador WHERE IDTrabajador = @IDTrabajador)
    BEGIN
        -- SI EXISTE DEVOLVEMOS ERROR
        SELECT CodError = 1, Mensaje = 'Error: El IDTrabajador ya está registrado y no se puede duplicar.'
        RETURN
    END

    -- SI NO EXISTE, INSERTAMOS NUEVO REGISTRO
    INSERT INTO tblTrabajador(IDTrabajador, traApellidoPaterno, traApellidoMaterno, traNombres, traSexo, traCargo, 
				traTelefono, traEmail, traSueldo, traFechaContratacion, traEstado)
    VALUES (@IDTrabajador, @traApellidoPaterno, @traApellidoMaterno, @traNombres, @traSexo, @traCargo, @traTelefono,     
			@traEmail, @traSueldo, @traFechaContratacion, @traEstado)
--
    SELECT CodError = 0, Mensaje = 'Proveedor insertado correctamente.'
END
GO
-- EJECUCIÓN
-- INSERT DEL NUEVO PROVEEDOR
EXEC spInsertarTrabajador 
	@IDTrabajador = 'T0000036',     
	@traApellidoMaterno = 'Zavala',  
	@traApellidoPaterno = 'Huacarpuma',
	@traNombres = 'Juan Aldair',
	@traSexo = 'M',
	@traCargo = 'Gerente',
	@traTelefono = '917328247',
	@traEmail = '76195593',
	@traSueldo = '4000.00',
	@traFechaContratacion = '2002-05-19',   
	@traEstado = 'Activo'
GO
-- SELECT AL NUEVO REGISTRO COMO PRUEBA
SELECT * FROM tblTrabajador
WHERE IDTrabajador = 'T0000036'
-----------------------------------
--PROCEDIMIENTOS ALMACENADOS CRUD--
-----------------------------------
--//TABLA CLIENTE//--
--PROCEDIMIENTO DE ELIMINAR (DELETE)--
IF OBJECT_ID('spEliminarCliente', 'P') IS NOT NULL
    DROP PROCEDURE spEliminarCliente
GO

CREATE PROCEDURE spEliminarCliente
    @DNI VARCHAR(8)
AS
BEGIN
    -- COMPROBAMOS SI EL CLIENTE EXISTE
    IF NOT EXISTS (SELECT 1 FROM tblCliente WHERE DNI = @DNI)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El cliente no existe y no se puede eliminar.'
        RETURN
    END

    BEGIN TRY
        -- ELIMINAR EL REGISTRO DEL CLIENTE/SI ESTA ASOCIADO A OTROS REGISTROS NO SE PUEDE
        DELETE FROM tblCliente
        WHERE DNI = @DNI;
        
        SELECT CodError = 0, Mensaje = 'Cliente eliminado físicamente de la base de datos.'
    END TRY
    BEGIN CATCH
        -- SI HAY REGISTROS ASOCIADOS SE NOTIFICA POR FK
        SELECT 
            CodError = ERROR_NUMBER(), 
            Mensaje = 'Error: No se pudo eliminar el cliente. Probablemente tiene ventas asociadas. Considere cambiar su estado a "Inactivo".';
    END CATCH
END
GO
-- EJECUCION
EXEC spEliminarCliente @DNI = '70000036';
GO