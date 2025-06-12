CREATE DATABASE dbCorporativoValuCalderon;
GO

USE dbCorporativoValuCalderon;
GO

-- ========================================
-- Creación de tablas
-- ========================================

CREATE TABLE tblCategoriaMotos (
    IDCategoria VARCHAR(5) NOT NULL PRIMARY KEY,
    catNombre VARCHAR(50) NOT NULL,
    catDescripcion VARCHAR(100)
);
GO

CREATE TABLE tblCategoriaRepuestos (
    IDCategoriaRepuesto VARCHAR(5) NOT NULL PRIMARY KEY,
    catNombre VARCHAR(50) NOT NULL,
    catDescripcion VARCHAR(100)
);
GO

CREATE TABLE tblMetodoPago (
    IDMetodoPago VARCHAR(5) NOT NULL PRIMARY KEY,
    metNombre VARCHAR(30) NOT NULL,
    metDescripcion VARCHAR(100)
);
GO

CREATE TABLE tblProveedor (
    RUC VARCHAR(11) NOT NULL PRIMARY KEY,
    provNombre VARCHAR(100) NOT NULL,
    provRazonSocial VARCHAR(100) NOT NULL,
    provDireccion VARCHAR(100) NOT NULL,
    provTelefono VARCHAR(9) NOT NULL,
    provEmail VARCHAR(100),
    provEstado VARCHAR(10) NOT NULL DEFAULT 'Activo'
);
GO

CREATE TABLE tblTrabajador (
    IDTrabajador VARCHAR(8) NOT NULL PRIMARY KEY,
    traApellidoPaterno VARCHAR(30) NOT NULL,
    traApellidoMaterno VARCHAR(30) NOT NULL,
    traNombres VARCHAR(50) NOT NULL,
    traSexo CHAR(1) NOT NULL,
    traCargo VARCHAR(30) NOT NULL,
    traTelefono VARCHAR(9) NOT NULL,
    traEmail VARCHAR(100),
    traSueldo DECIMAL(10, 2) NOT NULL,
    traFechaContratacion DATE NOT NULL,
    traEstado VARCHAR(10) NOT NULL DEFAULT 'Activo'
);
GO

CREATE TABLE tblPedidos (
    IDPedido VARCHAR(20) NOT NULL PRIMARY KEY,
    IDTrabajador VARCHAR(8) NOT NULL,
    RUC VARCHAR(11) NOT NULL,
    pedFecha DATE NOT NULL,
    pedEstado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    FOREIGN KEY (IDTrabajador) REFERENCES tblTrabajador(IDTrabajador),
    FOREIGN KEY (RUC) REFERENCES tblProveedor(RUC)
);
GO

CREATE TABLE tblMotos (
    IDMoto VARCHAR(20) NOT NULL PRIMARY KEY,
    IDCategoria VARCHAR(5) NOT NULL,
    motoMarca VARCHAR(50) NOT NULL,
    motoModelo VARCHAR(50) NOT NULL,
    motoAño INT NOT NULL,
    motoColor VARCHAR(30) NOT NULL,
    motoCilindrada VARCHAR(20) NOT NULL,
    motoStock INT NOT NULL,
    motoPrecio DECIMAL(10, 2) NOT NULL,
    RUC VARCHAR(11) NOT NULL,
    FOREIGN KEY (IDCategoria) REFERENCES tblCategoriaMotos(IDCategoria),
    FOREIGN KEY (RUC) REFERENCES tblProveedor(RUC)
);
GO

CREATE TABLE tblRepuestos (
    IDRepuesto VARCHAR(20) NOT NULL PRIMARY KEY,
    IDCategoriaRepuesto VARCHAR(5) NOT NULL,
    repNombre VARCHAR(100) NOT NULL,
    repMarca VARCHAR(50) NOT NULL,
    repCompatibilidad VARCHAR(100) NOT NULL,
    repStock INT NOT NULL,
    repPrecio DECIMAL(10, 2) NOT NULL,
    RUC VARCHAR(11) NOT NULL,
    FOREIGN KEY (IDCategoriaRepuesto) REFERENCES tblCategoriaRepuestos(IDCategoriaRepuesto),
    FOREIGN KEY (RUC) REFERENCES tblProveedor(RUC)
);
GO

CREATE TABLE tblCliente (
    DNI VARCHAR(8) NOT NULL PRIMARY KEY,
    cliApellidoPaterno VARCHAR(30) NOT NULL,
    cliApellidoMaterno VARCHAR(30) NOT NULL,
    cliNombres VARCHAR(50) NOT NULL,
    cliSexo CHAR(1) NOT NULL,
    cliFechaNacimiento DATE NOT NULL,
    cliDireccion VARCHAR(100) NOT NULL,
    cliTelefono VARCHAR(9),
    cliEmail VARCHAR(100),
    cliTipo VARCHAR(20) NOT NULL DEFAULT 'Local',
    cliFechaRegistro DATE NOT NULL,
    cliEstado VARCHAR(10) NOT NULL DEFAULT 'Activo'
);
GO

CREATE TABLE tblVenta (
    IDVenta VARCHAR(20) NOT NULL PRIMARY KEY,
    venFecha DATE NOT NULL,
    venEstado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    venTotal DECIMAL(10, 2) NOT NULL,
    venIGV DECIMAL(10, 2) NOT NULL,
    DNI VARCHAR(8) NOT NULL,
    IDTrabajador VARCHAR(8) NOT NULL,
	IDMetodoPago VARCHAR(5) NOT NULL,
    FOREIGN KEY (DNI) REFERENCES tblCliente(DNI),
	FOREIGN KEY (IDMetodoPago) REFERENCES tblMetodoPago(IDMetodoPago),
    FOREIGN KEY (IDTrabajador) REFERENCES tblTrabajador(IDTrabajador)
);
GO

CREATE TABLE tblDetalleVenta (
    IDVenta VARCHAR(20) NOT NULL,
    IDProducto VARCHAR(20) NOT NULL,
    TipoProducto VARCHAR(10) NOT NULL CHECK (TipoProducto IN ('Moto', 'Repuesto')),
    detCantidad INT NOT NULL,
    detPrecioUnitario DECIMAL(10, 2) NOT NULL,
    detDescuento DECIMAL(10, 2) NOT NULL DEFAULT 0,
    detSubTotal DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (IDVenta, IDProducto),
    FOREIGN KEY (IDVenta) REFERENCES tblVenta(IDVenta)
);
GO

-- ========================================
-- INSERTANDO DATOS DE PRUEBA
-- ========================================

-- 1. Categoría Motos
INSERT INTO tblCategoriaMotos VALUES
('CM001', 'Deportiva', 'Motos de alta velocidad'),
('CM002', 'Enduro', 'Motos para campo y terrenos difíciles'),
('CM003', 'Scooter', 'Motos urbanas de baja cilindrada'),
('CM004', 'Chopper', 'Motos de estilo custom'),
('CM005', 'Naked', 'Motos sin carenado, versátiles'),
('CM006', 'Touring', 'Motos para viajes largos y cómodos'),
('CM007', 'Cruiser', 'Motos estilo clásico para paseo'),
('CM008', 'Adventure', 'Motos para aventura en todo terreno'),
('CM009', 'SuperSport', 'Motos deportivas de alto rendimiento'),
('CM010', 'Cafe Racer', 'Motos estilo retro deportivo'),
('CM011', 'Bobber', 'Motos custom minimalistas'),
('CM012', 'Trial', 'Motos para competición de trial'),
('CM013', 'Motocross', 'Motos para competencia en tierra'),
('CM014', 'Street', 'Motos urbanas versátiles'),
('CM015', 'Doble Propósito', 'Motos para asfalto y tierra'),
('CM016', 'Maxi Scooter', 'Scooters de gran cilindrada'),
('CM017', 'Custom', 'Motos personalizadas'),
('CM018', 'Vintage', 'Motos clásicas restauradas'),
('CM019', 'Electricas', 'Motos con motor eléctrico'),
('CM020', 'Mini', 'Motos de pequeña cilindrada'),
('CM021', 'Trail', 'Motos para caminos mixtos'),
('CM022', 'Gran Turismo', 'Motos turísticas de lujo'),
('CM023', 'Supermoto', 'Motos mixtas carretera/tierra'),
('CM024', 'Chopper', 'Motos con horquilla delantera larga'),
('CM025', 'Drag', 'Motos para carreras de aceleración'),
('CM026', 'Endurance', 'Motos para resistencia'),
('CM027', 'Pistera', 'Motos para circuitos urbanos'),
('CM028', 'Big Trail', 'Motos trail de gran cilindrada'),
('CM029', 'Naked Sport', 'Motos deportivas sin carenado'),
('CM030', 'Classic', 'Motos de estilo clásico moderno'),
('CM031', 'Urban', 'Motos para uso exclusivo urbano'),
('CM032', 'Rally', 'Motos preparadas para rally'),
('CM033', 'Track', 'Motos exclusivas para pista'),
('CM034', 'Concept', 'Motos conceptuales/prototipos'),
('CM035', 'Limited', 'Ediciones limitadas especiales');

-- 2. Categoría Repuestos
INSERT INTO tblCategoriaRepuestos VALUES
('CR001', 'Frenos', 'Componentes de frenado'),
('CR002', 'Suspensión', 'Componentes de suspensión'),
('CR003', 'Motor', 'Partes internas de motor'),
('CR004', 'Eléctrico', 'Sistema eléctrico y luces'),
('CR005', 'Accesorios', 'Accesorios y extras'),
('CR006', 'Transmisión', 'Cadena, piñones y embrague'),
('CR007', 'Neumáticos', 'Llantas y cámaras de aire'),
('CR008', 'Carrocería', 'Piezas plásticas y carenados'),
('CR009', 'Escape', 'Sistemas de escape completos'),
('CR010', 'Aceites', 'Lubricantes y fluidos'),
('CR011', 'Filtros', 'Filtros de aire, aceite y combustible'),
('CR012', 'Manillares', 'Manillares y controles'),
('CR013', 'Asientos', 'Asientos y tapizados'),
('CR014', 'Instrumentos', 'Cuadros de instrumentos'),
('CR015', 'Refrigeración', 'Sistema de refrigeración líquida'),
('CR016', 'Chasis', 'Estructura y subchasis'),
('CR017', 'Dirección', 'Rodamientos y componentes de dirección'),
('CR018', 'Bujías', 'Bujías y cables'),
('CR019', 'Kit Arrastre', 'Kits de arrastre completos'),
('CR020', 'Faros', 'Sistemas de iluminación delantera'),
('CR021', 'Piloteros', 'Luces traseras y direccionales'),
('CR022', 'Baterías', 'Baterías y componentes eléctricos'),
('CR023', 'Centralita', 'Unidad de control electrónico'),
('CR024', 'Inyección', 'Componentes de inyección electrónica'),
('CR025', 'Carburación', 'Componentes de carburador'),
('CR026', 'Frenos ABS', 'Componentes de frenos ABS'),
('CR027', 'Amortiguación', 'Sistemas de suspensión completa'),
('CR028', 'Sillines', 'Asientos y accesorios para piloto'),
('CR029', 'Protecciones', 'Protecciones para motor y chasis'),
('CR030', 'Kit Cadena', 'Kit completo cadena y piñones'),
('CR031', 'Radiador', 'Radiadores y componentes'),
('CR032', 'Termostato', 'Control de temperatura'),
('CR033', 'Bomba Agua', 'Bombas de refrigerante'),
('CR034', 'Alternador', 'Sistema de carga eléctrica'),
('CR035', 'Arranque', 'Motor de arranque y componentes');

-- 3. Método de Pago
INSERT INTO tblMetodoPago VALUES
('MP001', 'Efectivo', 'Pago directo en efectivo'),
('MP002', 'Tarjeta Crédito', 'Pago con tarjeta de crédito'),
('MP003', 'Tarjeta Débito', 'Pago con tarjeta de débito'),
('MP004', 'Transferencia', 'Transferencia bancaria'),
('MP005', 'Yape/Plin', 'Pago con billetera digital'),
('MP006', 'PayPal', 'Pago mediante PayPal'),
('MP007', 'Bitcoin', 'Pago con criptomonedas'),
('MP008', 'Cheque', 'Pago con cheque certificado'),
('MP009', 'Depósito Bancario', 'Depósito directo en cuenta'),
('MP010', 'Pago Contra Entrega', 'Pago al recibir el producto'),
('MP011', 'Financiamiento', 'Pago a plazos con intereses'),
('MP012', 'Mercado Pago', 'Pago con cuenta Mercado Pago'),
('MP013', 'Pago Móvil', 'Pago con aplicación bancaria'),
('MP014', 'Cripto Wallet', 'Pago con billetera cripto'),
('MP015', 'Western Union', 'Pago mediante giro internacional'),
('MP016', 'MoneyGram', 'Transferencia internacional'),
('MP017', 'Pago en Cuotas', 'Pago fraccionado sin intereses'),
('MP018', 'Vale de Descuento', 'Pago con vale promocional'),
('MP019', 'Pago Mixto', 'Combinación de métodos de pago'),
('MP020', 'Pago en Dólares', 'Pago en moneda extranjera'),
('MP021', 'Pago con Puntos', 'Pago con puntos acumulados'),
('MP022', 'Pago con Garantía', 'Pago con garantía extendida'),
('MP023', 'Pago Diferido', 'Pago posterior a la entrega'),
('MP024', 'Pago en Tienda', 'Pago físico en tienda'),
('MP025', 'Pago por App', 'Pago con aplicación propia'),
('MP026', 'Pago QR', 'Pago mediante código QR'),
('MP027', 'Pago NFC', 'Pago con tecnología contactless'),
('MP028', 'Pago Recurrente', 'Pago automático periódico'),
('MP029', 'Pago en Especies', 'Pago con bienes equivalentes'),
('MP030', 'Pago con Crédito', 'Pago con línea de crédito'),
('MP031', 'Pago en Oferta', 'Pago con descuento especial'),
('MP032', 'Pago por Partes', 'Pago parcial antes de entrega'),
('MP033', 'Pago con Bonos', 'Pago con bonos de compra'),
('MP034', 'Pago en Cripto', 'Pago con diversas criptomonedas'),
('MP035', 'Pago por Transferencia', 'Pago por transferencia inmediata');

-- 4. Proveedor
INSERT INTO tblProveedor VALUES
('20100000001', 'MotoParts SAC', 'MotoParts S.A.C.', 'Av. Principal 123', '987654321', 'ventas@motoparts.com', 'Activo'),
('20100000002', 'Repuestos Perú', 'Repuestos Perú S.A.C.', 'Calle Falsa 456', '912345678', 'info@repuestosperu.com', 'Activo'),
('20100000003', 'Distribuidora Racing', 'Distribuidora Racing EIRL', 'Av. Velocidad 789', '934567890', 'contacto@racing.com', 'Activo'),
('20100000004', 'Mundo Moto', 'Mundo Moto S.A.', 'Jr. Motores 321', '976543210', 'mundo@moto.com', 'Activo'),
('20100000005', 'Todo Repuestos', 'Todo Repuestos S.R.L.', 'Calle Repuestos 987', '965432187', 'ventas@todorepuestos.com', 'Activo'),
('20100000006', 'MotoExpert', 'MotoExpert S.A.C.', 'Av. Industrial 234', '912345600', 'contacto@motoexpert.com', 'Activo'),
('20100000007', 'Speed Parts', 'Speed Parts E.I.R.L.', 'Calle Veloz 567', '923456711', 'info@speedparts.com', 'Activo'),
('20100000008', 'MotoTech', 'MotoTech Perú S.A.', 'Jr. Tecnología 890', '934567822', 'ventas@mototech.pe', 'Activo'),
('20100000009', 'Elite Motos', 'Elite Motos S.R.L.', 'Av. Elite 123', '945678933', 'elite@motoscorp.com', 'Activo'),
('20100000010', 'Racing Parts', 'Racing Parts S.A.C.', 'Calle Carrera 456', '956789044', 'racing@partes.com', 'Activo'),
('20100000011', 'MotoWorld', 'MotoWorld Internacional', 'Av. Global 789', '967890155', 'world@moto.com', 'Activo'),
('20100000012', 'Bike Masters', 'Bike Masters E.I.R.L.', 'Jr. Maestros 012', '978901266', 'master@bikes.com', 'Activo'),
('20100000013', 'Power Motors', 'Power Motors S.A.', 'Av. Potencia 345', '989012377', 'power@motors.pe', 'Activo'),
('20100000014', 'Urban Bikes', 'Urban Bikes S.R.L.', 'Calle Ciudad 678', '990123488', 'urban@bikes.com', 'Activo'),
('20100000015', 'Xtreme Parts', 'Xtreme Parts S.A.C.', 'Av. Extremo 901', '901234599', 'xtreme@parts.com', 'Activo'),
('20100000016', 'MotoLider', 'MotoLider Perú', 'Jr. Liderazgo 234', '912345610', 'lider@moto.com', 'Activo'),
('20100000017', 'Bike Pro', 'Bike Professional S.A.C.', 'Av. Profesional 567', '923456721', 'pro@bike.com', 'Activo'),
('20100000018', 'MotoSolutions', 'MotoSolutions E.I.R.L.', 'Calle Solución 890', '934567832', 'solutions@moto.com', 'Activo'),
('20100000019', 'Fast Track', 'Fast Track Motors', 'Jr. Velocidad 123', '945678943', 'fast@track.com', 'Activo'),
('20100000020', 'MotoGear', 'MotoGear Perú S.A.', 'Av. Equipo 456', '956789054', 'gear@moto.com', 'Activo'),
('20100000021', 'Bike Nation', 'Bike Nation S.R.L.', 'Calle Nacional 789', '967890165', 'nation@bike.com', 'Activo'),
('20100000022', 'MotoPlus', 'MotoPlus S.A.C.', 'Av. Adicional 012', '978901276', 'plus@moto.com', 'Activo'),
('20100000023', 'Power Bike', 'Power Bike E.I.R.L.', 'Jr. Energía 345', '989012387', 'power@bike.com', 'Activo'),
('20100000024', 'Urban Riders', 'Urban Riders S.A.', 'Av. Piloto 678', '990123498', 'riders@urban.com', 'Activo'),
('20100000025', 'MotoXtreme', 'MotoXtreme Perú', 'Calle Aventura 901', '901234509', 'xtreme@moto.com', 'Activo'),
('20100000026', 'Bike Masters Pro', 'Bike Masters Pro S.A.C.', 'Av. Maestro 234', '912345620', 'masterpro@bike.com', 'Activo'),
('20100000027', 'MotoElite', 'MotoElite S.R.L.', 'Jr. Elite 567', '923456731', 'elite@moto.com', 'Activo'),
('20100000028', 'Speed Masters', 'Speed Masters E.I.R.L.', 'Calle Rapidez 890', '934567842', 'speed@masters.com', 'Activo'),
('20100000029', 'Bike Solutions', 'Bike Solutions S.A.', 'Av. Respuesta 123', '945678953', 'solution@bike.com', 'Activo'),
('20100000030', 'MotoNation', 'MotoNation Perú', 'Jr. Nacional 456', '956789064', 'nation@moto.com', 'Activo'),
('20100000031', 'Pro Bike', 'Pro Bike S.A.C.', 'Av. Profesional 789', '967890175', 'pro@probike.com', 'Activo'),
('20100000032', 'MotoGear Pro', 'MotoGear Pro E.I.R.L.', 'Calle Equipo 012', '978901286', 'gearpro@moto.com', 'Activo'),
('20100000033', 'Bike Power', 'Bike Power S.A.', 'Jr. Fuerza 345', '989012397', 'power@bikepower.com', 'Activo'),
('20100000034', 'Urban Moto', 'Urban Moto S.R.L.', 'Av. Ciudad 678', '990123408', 'urban@motourban.com', 'Activo'),
('20100000035', 'MotoPro', 'MotoPro Perú S.A.C.', 'Calle Profesional 901', '901234519', 'pro@motopro.com', 'Activo');

-- 5. Trabajador
INSERT INTO tblTrabajador VALUES
('T0000001', 'Gonzales', 'Perez', 'Juan Carlos', 'M', 'Vendedor', '912345678', 'juan@empresa.com', 1500.00, '2023-01-15', 'Activo'),
('T0000002', 'Ramirez', 'Lopez', 'Maria Fernanda', 'F', 'Administrador', '923456789', 'maria@empresa.com', 2000.00, '2022-05-20', 'Activo'),
('T0000003', 'Vargas', 'Cruz', 'Luis Alberto', 'M', 'Mecánico', '934567890', 'luis@empresa.com', 1700.00, '2021-10-10', 'Activo'),
('T0000004', 'Soto', 'Castillo', 'Ana Sofia', 'F', 'Recepcionista', '945678901', 'ana@empresa.com', 1200.00, '2024-03-01', 'Activo'),
('T0000005', 'Flores', 'Salazar', 'Carlos Eduardo', 'M', 'Jefe Ventas', '956789012', 'carlos@empresa.com', 2500.00, '2020-07-07', 'Activo'),
('T0000006', 'Martinez', 'Gutierrez', 'Roberto Carlos', 'M', 'Vendedor', '967890123', 'roberto@empresa.com', 1550.00, '2023-02-10', 'Activo'),
('T0000007', 'Diaz', 'Mendoza', 'Laura Patricia', 'F', 'Contadora', '978901234', 'laura@empresa.com', 2200.00, '2022-06-15', 'Activo'),
('T0000008', 'Silva', 'Rojas', 'Jorge Luis', 'M', 'Mecánico', '989012345', 'jorge@empresa.com', 1750.00, '2021-11-20', 'Activo'),
('T0000009', 'Torres', 'Vega', 'Sofia Alejandra', 'F', 'Asistente', '990123456', 'sofia@empresa.com', 1250.00, '2024-01-05', 'Activo'),
('T0000010', 'Castro', 'Paredes', 'Miguel Angel', 'M', 'Jefe Taller', '901234567', 'miguel@empresa.com', 2600.00, '2020-08-12', 'Activo'),
('T0000011', 'Romero', 'Quispe', 'Elena Beatriz', 'F', 'Vendedora', '912345678', 'elena@empresa.com', 1600.00, '2023-03-25', 'Activo'),
('T0000012', 'Chavez', 'Salas', 'Ricardo Augusto', 'M', 'Marketing', '923456789', 'ricardo@empresa.com', 2300.00, '2022-07-30', 'Activo'),
('T0000013', 'Rios', 'Cabrera', 'Patricia Carmen', 'F', 'Recepcionista', '934567890', 'patricia@empresa.com', 1300.00, '2021-12-10', 'Activo'),
('T0000014', 'Medina', 'Leon', 'Fernando Jose', 'M', 'Mecánico', '945678901', 'fernando@empresa.com', 1800.00, '2024-02-15', 'Activo'),
('T0000015', 'Valdez', 'Herrera', 'Gabriela Maria', 'F', 'Asistente', '956789012', 'gabriela@empresa.com', 1400.00, '2020-09-20', 'Activo'),
('T0000016', 'Luna', 'Cordova', 'Oscar Daniel', 'M', 'Vendedor', '967890123', 'oscar@empresa.com', 1650.00, '2023-04-05', 'Activo'),
('T0000017', 'Soria', 'Espinoza', 'Claudia Andrea', 'F', 'Contadora', '978901234', 'claudia@empresa.com', 2250.00, '2022-08-10', 'Activo'),
('T0000018', 'Paredes', 'Ruiz', 'Javier Eduardo', 'M', 'Mecánico', '989012345', 'javier@empresa.com', 1850.00, '2021-12-25', 'Activo'),
('T0000019', 'Alvarez', 'Gomez', 'Carolina Isabel', 'F', 'Asistente', '990123456', 'carolina@empresa.com', 1350.00, '2024-03-10', 'Activo'),
('T0000020', 'Benites', 'Campos', 'Raul Antonio', 'M', 'Jefe Logística', '901234567', 'raul@empresa.com', 2700.00, '2020-10-15', 'Activo'),
('T0000021', 'Cordero', 'Vasquez', 'Lucia Elena', 'F', 'Vendedora', '912345678', 'lucia@empresa.com', 1700.00, '2023-05-20', 'Activo'),
('T0000022', 'Delgado', 'Llanos', 'Hector Manuel', 'M', 'IT', '923456789', 'hector@empresa.com', 2400.00, '2022-09-25', 'Activo'),
('T0000023', 'Escobar', 'Peña', 'Rosa Amelia', 'F', 'Recepcionista', '934567890', 'rosa@empresa.com', 1400.00, '2022-01-10', 'Activo'),
('T0000024', 'Fuentes', 'Reyes', 'Alberto Carlos', 'M', 'Mecánico', '945678901', 'alberto@empresa.com', 1900.00, '2024-04-15', 'Activo'),
('T0000025', 'Guzman', 'Santos', 'Silvia Patricia', 'F', 'Asistente', '956789012', 'silvia@empresa.com', 1450.00, '2020-11-20', 'Activo'),
('T0000026', 'Huaman', 'Tello', 'Enrique Jose', 'M', 'Vendedor', '967890123', 'enrique@empresa.com', 1750.00, '2023-06-05', 'Activo'),
('T0000027', 'Iglesias', 'Marquez', 'Ana Cecilia', 'F', 'Contadora', '978901234', 'ana@empresa.com', 2300.00, '2022-10-10', 'Activo'),
('T0000028', 'Jauregui', 'Nunez', 'Pedro Pablo', 'M', 'Mecánico', '989012345', 'pedro@empresa.com', 1950.00, '2022-02-15', 'Activo'),
('T0000029', 'Kouri', 'Olivos', 'Maria Fernanda', 'F', 'Asistente', '990123456', 'mariaf@empresa.com', 1500.00, '2024-05-20', 'Activo'),
('T0000030', 'Lozano', 'Paz', 'Luis Miguel', 'M', 'Jefe Marketing', '901234567', 'luism@empresa.com', 2800.00, '2020-12-25', 'Activo'),
('T0000031', 'Mendoza', 'Quiroz', 'Sandra Elizabeth', 'F', 'Vendedora', '912345678', 'sandra@empresa.com', 1800.00, '2023-07-10', 'Activo'),
('T0000032', 'Navarro', 'Ramos', 'Jorge Alberto', 'M', 'IT', '923456789', 'jorgea@empresa.com', 2500.00, '2022-11-15', 'Activo'),
('T0000033', 'Ocampo', 'Salinas', 'Teresa Margarita', 'F', 'Recepcionista', '934567890', 'teresa@empresa.com', 1550.00, '2022-03-20', 'Activo'),
('T0000034', 'Peralta', 'Tapia', 'Victor Hugo', 'M', 'Mecánico', '945678901', 'victor@empresa.com', 2000.00, '2024-06-25', 'Activo'),
('T0000035', 'Quispe', 'Uriarte', 'Beatriz Rosa', 'F', 'Asistente', '956789012', 'beatriz@empresa.com', 1600.00, '2021-01-10', 'Activo');

-- 6. Cliente
INSERT INTO tblCliente VALUES
('70000001', 'Rojas', 'Vargas', 'Pedro Luis', 'M', '1990-05-14', 'Av. Libertad 123', '987654321', 'pedro@gmail.com', 'Local', '2024-04-01', 'Activo'),
('70000002', 'Lopez', 'Sanchez', 'Andrea Milagros', 'F', '1988-12-22', 'Calle Sol 456', '976543210', 'andrea@hotmail.com', 'Local', '2024-04-05', 'Activo'),
('70000003', 'Castillo', 'Gomez', 'Juan Diego', 'M', '1995-07-09', 'Jr. Luna 789', '965432198', 'juan@hotmail.com', 'Local', '2024-04-10', 'Activo'),
('70000004', 'Vega', 'Ramos', 'Lucia Camila', 'F', '1992-03-30', 'Av. Estrella 321', '954321987', 'lucia@gmail.com', 'Local', '2024-04-15', 'Activo'),
('70000005', 'Morales', 'Torres', 'Sergio Antonio', 'M', '1985-11-25', 'Calle Mar 654', '943210976', 'sergio@yahoo.com', 'Local', '2024-04-20', 'Activo'),
('70000006', 'Gutierrez', 'Mendoza', 'Carlos Alberto', 'M', '1991-06-15', 'Av. Primavera 234', '987654322', 'carlos@yahoo.com', 'Local', '2024-04-25', 'Activo'),
('70000007', 'Hernandez', 'Silva', 'María José', 'F', '1989-01-23', 'Calle Luna 567', '976543211', 'mariaj@hotmail.com', 'Local', '2024-04-30', 'Activo'),
('70000008', 'Jimenez', 'Torres', 'Luis Fernando', 'M', '1996-08-10', 'Jr. Sol 890', '965432199', 'luisf@gmail.com', 'Local', '2024-05-05', 'Activo'),
('70000009', 'Klein', 'Vargas', 'Ana Patricia', 'F', '1993-04-01', 'Av. Estrella 432', '954321988', 'anap@outlook.com', 'Local', '2024-05-10', 'Activo'),
('70000010', 'Lopez', 'Williams', 'Roberto Carlos', 'M', '1986-12-26', 'Calle Mar 765', '943210977', 'robertoc@gmail.com', 'Local', '2024-05-15', 'Activo'),
('70000011', 'Mendez', 'Young', 'Sofia Alejandra', 'F', '1992-07-11', 'Av. Jardín 098', '932109866', 'sofiaa@hotmail.com', 'Local', '2024-05-20', 'Activo'),
('70000012', 'Nunez', 'Zambrano', 'Javier Eduardo', 'M', '1997-02-28', 'Calle Bosque 321', '921098755', 'javiere@yahoo.com', 'Local', '2024-05-25', 'Activo'),
('70000013', 'Ortiz', 'Adams', 'Patricia Beatriz', 'F', '1994-09-15', 'Jr. Río 654', '910987644', 'patriciab@gmail.com', 'Local', '2024-05-30', 'Activo'),
('70000014', 'Perez', 'Brown', 'Fernando Jose', 'M', '1987-05-02', 'Av. Montaña 987', '999876533', 'fernandoj@outlook.com', 'Local', '2024-06-05', 'Activo'),
('70000015', 'Quiroz', 'Clark', 'Gabriela Maria', 'F', '1995-10-19', 'Calle Valle 210', '988765422', 'gabrielam@hotmail.com', 'Local', '2024-06-10', 'Activo'),
('70000016', 'Rivas', 'Davis', 'Oscar Daniel', 'M', '1990-03-07', 'Av. Prado 543', '977654311', 'oscard@yahoo.com', 'Local', '2024-06-15', 'Activo'),
('70000017', 'Sanchez', 'Evans', 'Claudia Andrea', 'F', '1988-11-24', 'Jr. Lago 876', '966543200', 'claudiaa@gmail.com', 'Local', '2024-06-20', 'Activo'),
('70000018', 'Torres', 'Ford', 'Javier Eduardo', 'M', '1996-06-11', 'Calle Océano 109', '955432199', 'javiered@outlook.com', 'Local', '2024-06-25', 'Activo'),
('70000019', 'Uribe', 'Green', 'Carolina Isabel', 'F', '1993-01-28', 'Av. Cielo 432', '944321088', 'carolinai@hotmail.com', 'Local', '2024-06-30', 'Activo'),
('70000020', 'Valdez', 'Harris', 'Raul Antonio', 'M', '1985-08-15', 'Jr. Tierra 765', '933210977', 'raula@yahoo.com', 'Local', '2024-07-05', 'Activo'),
('70000021', 'Williams', 'Irwin', 'Lucia Elena', 'F', '1991-04-02', 'Av. Aire 098', '922109866', 'luciae@gmail.com', 'Local', '2024-07-10', 'Activo'),
('70000022', 'Xavier', 'Jones', 'Hector Manuel', 'M', '1998-10-19', 'Calle Fuego 321', '911098755', 'hectorm@outlook.com', 'Local', '2024-07-15', 'Activo'),
('70000023', 'Yanez', 'King', 'Rosa Amelia', 'F', '1995-05-06', 'Jr. Agua 654', '900987644', 'rosaa@hotmail.com', 'Local', '2024-07-20', 'Activo'),
('70000024', 'Zambrano', 'Lee', 'Alberto Carlos', 'M', '1988-12-23', 'Av. Viento 987', '989876533', 'albertoc@yahoo.com', 'Local', '2024-07-25', 'Activo'),
('70000025', 'Acosta', 'Miller', 'Silvia Patricia', 'F', '1996-07-10', 'Calle Relámpago 210', '978765422', 'silviap@gmail.com', 'Local', '2024-07-30', 'Activo'),
('70000026', 'Bermudez', 'Nelson', 'Enrique Jose', 'M', '1992-02-26', 'Av. Trueno 543', '967654311', 'enriquej@outlook.com', 'Local', '2024-08-05', 'Activo'),
('70000027', 'Cortez', 'Owens', 'Ana Cecilia', 'F', '1989-09-13', 'Jr. Arcoiris 876', '956543200', 'anac@hotmail.com', 'Local', '2024-08-10', 'Activo'),
('70000028', 'Duran', 'Parker', 'Pedro Pablo', 'M', '1997-04-30', 'Calle Nube 109', '945432199', 'pedrop@yahoo.com', 'Local', '2024-08-15', 'Activo'),
('70000029', 'Escobar', 'Quinn', 'Maria Fernanda', 'F', '1994-11-17', 'Av. Tormenta 432', '934321088', 'mariaf@gmail.com', 'Local', '2024-08-20', 'Activo'),
('70000030', 'Fuentes', 'Reed', 'Luis Miguel', 'M', '1986-06-04', 'Jr. Huracán 765', '923210977', 'luism@outlook.com', 'Local', '2024-08-25', 'Activo'),
('70000031', 'Garcia', 'Scott', 'Sandra Elizabeth', 'F', '1993-01-21', 'Calle Tifón 098', '912109866', 'sandrae@hotmail.com', 'Local', '2024-08-30', 'Activo'),
('70000032', 'Herrera', 'Taylor', 'Jorge Alberto', 'M', '1999-08-08', 'Av. Monzón 321', '901098755', 'jorgea@yahoo.com', 'Local', '2024-09-05', 'Activo'),
('70000033', 'Ibarra', 'Underwood', 'Teresa Margarita', 'F', '1996-03-26', 'Jr. Ciclón 654', '990987644', 'teresam@gmail.com', 'Local', '2024-09-10', 'Activo'),
('70000034', 'Juarez', 'Vaughn', 'Victor Hugo', 'M', '1989-10-13', 'Calle Precipicio 987', '979876533', 'victorh@outlook.com', 'Local', '2024-09-15', 'Activo'),
('70000035', 'Klein', 'Wood', 'Beatriz Rosa', 'F', '1995-05-30', 'Av. Abismo 210', '968765422', 'beatrizr@hotmail.com', 'Local', '2024-09-20', 'Activo');

-- 7. Motos
INSERT INTO tblMotos VALUES
('MOTO0001', 'CM001', 'Yamaha', 'R15', 2023, 'Rojo', '155cc', 5, 14500.00, '20100000001'),
('MOTO0002', 'CM002', 'KTM', 'EXC 250', 2022, 'Naranja', '250cc', 3, 32500.00, '20100000002'),
('MOTO0003', 'CM003', 'Honda', 'Elite 125', 2023, 'Negro', '125cc', 8, 9500.00, '20100000003'),
('MOTO0004', 'CM004', 'Harley-Davidson', 'Street 750', 2021, 'Gris', '749cc', 2, 45000.00, '20100000004'),
('MOTO0005', 'CM005', 'Kawasaki', 'Z400', 2022, 'Verde', '400cc', 4, 28000.00, '20100000005'),
('MOTO0006', 'CM006', 'Honda', 'Gold Wing', 2023, 'Negro', '1833cc', 2, 85000.00, '20100000006'),
('MOTO0007', 'CM007', 'Indian', 'Scout', 2022, 'Rojo', '1133cc', 4, 45000.00, '20100000007'),
('MOTO0008', 'CM008', 'BMW', 'R 1250 GS', 2023, 'Azul', '1254cc', 3, 55000.00, '20100000008'),
('MOTO0009', 'CM009', 'Ducati', 'Panigale V4', 2023, 'Rojo', '1103cc', 1, 65000.00, '20100000009'),
('MOTO0010', 'CM010', 'Triumph', 'Thruxton', 2022, 'Verde', '1200cc', 2, 38000.00, '20100000010'),
('MOTO0011', 'CM011', 'Harley-Davidson', 'Softail', 2023, 'Negro', '1868cc', 3, 48000.00, '20100000011'),
('MOTO0012', 'CM012', 'GasGas', 'TXT Racing', 2023, 'Rojo', '300cc', 5, 32000.00, '20100000012'),
('MOTO0013', 'CM013', 'Husqvarna', 'FC 450', 2023, 'Azul', '450cc', 4, 36000.00, '20100000013'),
('MOTO0014', 'CM014', 'Yamaha', 'MT-07', 2023, 'Azul', '689cc', 6, 22000.00, '20100000014'),
('MOTO0015', 'CM015', 'Suzuki', 'DR-Z400', 2022, 'Amarillo', '398cc', 5, 18000.00, '20100000015'),
('MOTO0016', 'CM016', 'Honda', 'X-ADV', 2023, 'Rojo', '745cc', 3, 28000.00, '20100000016'),
('MOTO0017', 'CM017', 'Custom', 'Chopper 1', 2023, 'Negro', '1200cc', 1, 42000.00, '20100000017'),
('MOTO0018', 'CM018', 'Royal Enfield', 'Interceptor', 2023, 'Crem', '648cc', 4, 15000.00, '20100000018'),
('MOTO0019', 'CM019', 'Zero', 'SR/F', 2023, 'Gris', 'Electrico', 2, 38000.00, '20100000019'),
('MOTO0020', 'CM020', 'Honda', 'Monkey', 2023, 'Amarillo', '125cc', 7, 8500.00, '20100000020'),
('MOTO0021', 'CM021', 'KTM', '390 Adventure', 2023, 'Naranja', '373cc', 5, 24000.00, '20100000021'),
('MOTO0022', 'CM022', 'BMW', 'K 1600 GT', 2023, 'Blanco', '1649cc', 2, 58000.00, '20100000022'),
('MOTO0023', 'CM023', 'Husqvarna', '701 Supermoto', 2023, 'Blanco', '693cc', 3, 32000.00, '20100000023'),
('MOTO0024', 'CM024', 'Custom', 'Chopper 2', 2023, 'Negro', '1800cc', 1, 45000.00, '20100000024'),
('MOTO0025', 'CM025', 'Suzuki', 'Hayabusa', 2023, 'Negro', '1340cc', 2, 52000.00, '20100000025'),
('MOTO0026', 'CM026', 'Kawasaki', 'Ninja H2', 2023, 'Verde', '998cc', 1, 68000.00, '20100000026'),
('MOTO0027', 'CM027', 'Yamaha', 'R7', 2023, 'Azul', '689cc', 4, 25000.00, '20100000027'),
('MOTO0028', 'CM028', 'Honda', 'Africa Twin', 2023, 'Rojo', '1084cc', 3, 32000.00, '20100000028'),
('MOTO0029', 'CM029', 'Triumph', 'Street Triple', 2023, 'Negro', '765cc', 4, 28000.00, '20100000029'),
('MOTO0030', 'CM030', 'Royal Enfield', 'Continental GT', 2023, 'Rojo', '648cc', 5, 16000.00, '20100000030'),
('MOTO0031', 'CM031', 'Vespa', 'Primavera', 2023, 'Celeste', '150cc', 8, 12000.00, '20100000031'),
('MOTO0032', 'CM032', 'KTM', 'Rally 450', 2023, 'Naranja', '450cc', 2, 38000.00, '20100000032');

-- 8. Repuestos
INSERT INTO tblRepuestos VALUES
('REP00001', 'CR001', 'Disco de freno delantero', 'Brembo', 'Yamaha R15, KTM 250', 15, 350.00, '20100000001'),
('REP00002', 'CR002', 'Amortiguador trasero', 'Showa', 'Honda Elite, Yamaha R15', 10, 450.00, '20100000002'),
('REP00003', 'CR003', 'Pistón 250cc', 'Wiseco', 'KTM EXC 250', 7, 850.00, '20100000003'),
('REP00004', 'CR004', 'Batería 12V', 'Yuasa', 'Honda Elite, Kawasaki Z400', 12, 400.00, '20100000004'),
('REP00005', 'CR005', 'Casco integral', 'LS2', 'Universal', 20, 600.00, '20100000005'),
('REP00006', 'CR006', 'Cadena de transmisión', 'DID', 'Honda CBR600RR, Yamaha R6', 8, 280.00, '20100000006'),
('REP00007', 'CR007', 'Filtro de aire', 'K&N', 'Kawasaki Ninja 650, Suzuki GSX-R750', 15, 320.00, '20100000007'),
('REP00008', 'CR008', 'Pastillas de freno', 'EBC', 'Yamaha MT-07, Honda CB500F', 20, 180.00, '20100000008'),
('REP00009', 'CR009', 'Neumático trasero', 'Michelin', 'Ducati Monster 821, Triumph Street Triple', 6, 1200.00, '20100000009'),
('REP00010', 'CR010', 'Aceite sintético 10W-40', 'Motul', 'Universal', 30, 150.00, '20100000010'),
('REP00011', 'CR011', 'Retrovisor izquierdo', 'OEM', 'Honda Rebel 500, Kawasaki Vulcan S', 12, 220.00, '20100000011'),
('REP00012', 'CR012', 'Kit de embrague', 'Barnett', 'Harley Davidson Sportster', 5, 950.00, '20100000012'),
('REP00013', 'CR013', 'Luz delantera LED', 'Phillips', 'Yamaha MT-09, Suzuki SV650', 10, 420.00, '20100000013'),
('REP00014', 'CR014', 'Manubrio deportivo', 'Renthal', 'KTM Duke 390, BMW G310R', 7, 380.00, '20100000014'),
('REP00015', 'CR015', 'Sistema de escape completo', 'Akrapovic', 'Ducati Panigale V4', 3, 8500.00, '20100000015'),
('REP00016', 'CR016', 'Asiento de cuero', 'Corbin', 'Harley Davidson Road King', 4, 2200.00, '20100000016'),
('REP00017', 'CR017', 'Kit de cadena y piñones', 'RK', 'Kawasaki Z900, Yamaha XSR900', 6, 750.00, '20100000017'),
('REP00018', 'CR018', 'Faro principal', 'JW Speaker', 'BMW R1250GS, Triumph Tiger 800', 5, 980.00, '20100000018'),
('REP00019', 'CR019', 'Suspensión delantera', 'Öhlins', 'Ducati Multistrada, Aprilia Tuono', 3, 4500.00, '20100000019'),
('REP00020', 'CR020', 'Bomba de combustible', 'Bosch', 'Suzuki Hayabusa, Kawasaki H2', 8, 650.00, '20100000020'),
('REP00021', 'CR001', 'Disco de freno trasero', 'Brembo', 'Yamaha R1, Kawasaki ZX-10R', 9, 420.00, '20100000021'),
('REP00022', 'CR002', 'Amortiguador delantero', 'Showa', 'Honda CBR1000RR, Suzuki GSX-R1000', 6, 520.00, '20100000022'),
('REP00023', 'CR003', 'Kit de junta de motor', 'Cometic', 'KTM 390 Duke, Husqvarna Vitpilen', 7, 320.00, '20100000023'),
('REP00024', 'CR004', 'Alternador', 'Denso', 'Harley Davidson Softail', 5, 1100.00, '20100000024'),
('REP00025', 'CR005', 'Guantes de cuero', 'Alpinestars', 'Universal', 25, 350.00, '20100000025'),
('REP00026', 'CR006', 'Piñón de ataque', 'JT Sprockets', 'Yamaha MT-03, Kawasaki Z400', 12, 120.00, '20100000026'),
('REP00027', 'CR007', 'Filtro de aceite', 'HiFlo', 'Honda CB650R, Yamaha Tracer 700', 18, 90.00, '20100000027'),
('REP00028', 'CR008', 'Líquido de frenos DOT4', 'Castrol', 'Universal', 20, 70.00, '20100000028'),
('REP00029', 'CR009', 'Neumático delantero', 'Pirelli', 'Ducati Scrambler, Triumph Bonneville', 8, 1100.00, '20100000029'),
('REP00030', 'CR010', 'Aceite mineral 20W-50', 'Repsol', 'Motos clásicas', 15, 100.00, '20100000030'),
('REP00031', 'CR011', 'Retrovisor derecho', 'OEM', 'Honda Goldwing, BMW K1600', 10, 240.00, '20100000031'),
('REP00032', 'CR012', 'Embrague hidráulico', 'Magura', 'KTM Super Duke, MV Agusta Brutale', 4, 780.00, '20100000032'),
('REP00033', 'CR013', 'Luces LED auxiliares', 'Rigid', 'Adventure touring', 8, 650.00, '20100000033'),
('REP00034', 'CR014', 'Manillar cruiser', 'Biltwell', 'Harley Davidson, Indian Scout', 6, 290.00, '20100000034'),
('REP00035', 'CR015', 'Silenciador de escape', 'Arrow', 'Triumph Street Triple, Yamaha MT-07', 5, 1200.00, '20100000035');

-- 9. Pedidos
INSERT INTO tblPedidos VALUES
('PED000001', 'T0000001', '20100000001', '2025-04-01', 'Pendiente'),
('PED000002', 'T0000002', '20100000002', '2025-04-02', 'Recibido'),
('PED000003', 'T0000003', '20100000003', '2025-04-03', 'Pendiente'),
('PED000004', 'T0000004', '20100000004', '2025-04-04', 'Recibido'),
('PED000005', 'T0000005', '20100000005', '2025-04-05', 'Pendiente'),
('PED000006', 'T0000006', '20100000006', '2025-04-06', 'Recibido'),
('PED000007', 'T0000007', '20100000007', '2025-04-07', 'Pendiente'),
('PED000008', 'T0000008', '20100000008', '2025-04-08', 'Recibido'),
('PED000009', 'T0000009', '20100000009', '2025-04-09', 'Pendiente'),
('PED000010', 'T0000010', '20100000010', '2025-04-10', 'Recibido'),
('PED000011', 'T0000011', '20100000011', '2025-04-11', 'Pendiente'),
('PED000012', 'T0000012', '20100000012', '2025-04-12', 'Recibido'),
('PED000013', 'T0000013', '20100000013', '2025-04-13', 'Pendiente'),
('PED000014', 'T0000014', '20100000014', '2025-04-14', 'Recibido'),
('PED000015', 'T0000015', '20100000015', '2025-04-15', 'Pendiente'),
('PED000016', 'T0000016', '20100000016', '2025-04-16', 'Recibido'),
('PED000017', 'T0000017', '20100000017', '2025-04-17', 'Pendiente'),
('PED000018', 'T0000018', '20100000018', '2025-04-18', 'Recibido'),
('PED000019', 'T0000019', '20100000019', '2025-04-19', 'Pendiente'),
('PED000020', 'T0000020', '20100000020', '2025-04-20', 'Recibido'),
('PED000021', 'T0000021', '20100000021', '2025-04-21', 'Pendiente'),
('PED000022', 'T0000022', '20100000022', '2025-04-22', 'Recibido'),
('PED000023', 'T0000023', '20100000023', '2025-04-23', 'Pendiente'),
('PED000024', 'T0000024', '20100000024', '2025-04-24', 'Recibido'),
('PED000025', 'T0000025', '20100000025', '2025-04-25', 'Pendiente'),
('PED000026', 'T0000026', '20100000026', '2025-04-26', 'Recibido'),
('PED000027', 'T0000027', '20100000027', '2025-04-27', 'Pendiente'),
('PED000028', 'T0000028', '20100000028', '2025-04-28', 'Recibido'),
('PED000029', 'T0000029', '20100000029', '2025-04-29', 'Pendiente'),
('PED000030', 'T0000030', '20100000030', '2025-04-30', 'Recibido'),
('PED000031', 'T0000031', '20100000031', '2025-05-01', 'Pendiente'),
('PED000032', 'T0000032', '20100000032', '2025-05-02', 'Recibido'),
('PED000033', 'T0000033', '20100000033', '2025-05-03', 'Pendiente'),
('PED000034', 'T0000034', '20100000034', '2025-05-04', 'Recibido'),
('PED000035', 'T0000035', '20100000035', '2025-05-05', 'Pendiente');


-- 10. Venta
INSERT INTO tblVenta VALUES
('VNT000001', '2025-04-10', 'Pendiente', 14500.00, 2610.00, '70000001', 'T0000001', 'MP001'),
('VNT000002', '2025-04-11', 'Pagado', 9500.00, 1710.00, '70000002', 'T0000002', 'MP002'),
('VNT000003', '2025-04-12', 'Pendiente', 32500.00, 5850.00, '70000003', 'T0000003', 'MP003'),
('VNT000004', '2025-04-13', 'Pagado', 600.00, 108.00, '70000004', 'T0000004', 'MP004'),
('VNT000005', '2025-04-14', 'Pendiente', 400.00, 72.00, '70000005', 'T0000005', 'MP005'),
('VNT000006', '2025-04-15', 'Pagado', 2800.00, 504.00, '70000006', 'T0000006', 'MP006'),
('VNT000007', '2025-04-16', 'Pendiente', 3200.00, 576.00, '70000007', 'T0000007', 'MP007'),
('VNT000008', '2025-04-17', 'Pagado', 1800.00, 324.00, '70000008', 'T0000008', 'MP008'),
('VNT000009', '2025-04-18', 'Pendiente', 12000.00, 2160.00, '70000009', 'T0000009', 'MP009'),
('VNT000010', '2025-04-19', 'Pagado', 1500.00, 270.00, '70000010', 'T0000010', 'MP010'),
('VNT000011', '2025-04-20', 'Pendiente', 2200.00, 396.00, '70000011', 'T0000011', 'MP011'),
('VNT000012', '2025-04-21', 'Pagado', 9500.00, 1710.00, '70000012', 'T0000012', 'MP012'),
('VNT000013', '2025-04-22', 'Pendiente', 4200.00, 756.00, '70000013', 'T0000013', 'MP013'),
('VNT000014', '2025-04-23', 'Pagado', 3800.00, 684.00, '70000014', 'T0000014', 'MP014'),
('VNT000015', '2025-04-24', 'Pendiente', 85000.00, 15300.00, '70000015', 'T0000015', 'MP015'),
('VNT000016', '2025-04-25', 'Pagado', 22000.00, 3960.00, '70000016', 'T0000016', 'MP016'),
('VNT000017', '2025-04-26', 'Pendiente', 7500.00, 1350.00, '70000017', 'T0000017', 'MP017'),
('VNT000018', '2025-04-27', 'Pagado', 9800.00, 1764.00, '70000018', 'T0000018', 'MP018'),
('VNT000019', '2025-04-28', 'Pendiente', 45000.00, 8100.00, '70000019', 'T0000019', 'MP019'),
('VNT000020', '2025-04-29', 'Pagado', 6500.00, 1170.00, '70000020', 'T0000020', 'MP020'),
('VNT000021', '2025-04-30', 'Pendiente', 4200.00, 756.00, '70000021', 'T0000021', 'MP021'),
('VNT000022', '2025-05-01', 'Pagado', 5200.00, 936.00, '70000022', 'T0000022', 'MP022'),
('VNT000023', '2025-05-02', 'Pendiente', 3200.00, 576.00, '70000023', 'T0000023', 'MP023'),
('VNT000024', '2025-05-03', 'Pagado', 11000.00, 1980.00, '70000024', 'T0000024', 'MP024'),
('VNT000025', '2025-05-04', 'Pendiente', 3500.00, 630.00, '70000025', 'T0000025', 'MP025'),
('VNT000026', '2025-05-05', 'Pagado', 1200.00, 216.00, '70000026', 'T0000026', 'MP026'),
('VNT000027', '2025-05-06', 'Pendiente', 900.00, 162.00, '70000027', 'T0000027', 'MP027'),
('VNT000028', '2025-05-07', 'Pagado', 700.00, 126.00, '70000028', 'T0000028', 'MP028'),
('VNT000029', '2025-05-08', 'Pendiente', 11000.00, 1980.00, '70000029', 'T0000029', 'MP029'),
('VNT000030', '2025-05-09', 'Pagado', 1000.00, 180.00, '70000030', 'T0000030', 'MP030'),
('VNT000031', '2025-05-10', 'Pendiente', 2400.00, 432.00, '70000031', 'T0000031', 'MP031'),
('VNT000032', '2025-05-11', 'Pagado', 7800.00, 1404.00, '70000032', 'T0000032', 'MP032'),
('VNT000033', '2025-05-12', 'Pendiente', 6500.00, 1170.00, '70000033', 'T0000033', 'MP033'),
('VNT000034', '2025-05-13', 'Pagado', 2900.00, 522.00, '70000034', 'T0000034', 'MP034'),
('VNT000035', '2025-05-14', 'Pendiente', 12000.00, 2160.00, '70000035', 'T0000035', 'MP035');

-- 11. DetalleVenta
INSERT INTO tblDetalleVenta VALUES
('VNT000001', 'MOTO0001', 'Moto', 1, 14500.00, 0, 14500.00),
('VNT000002', 'MOTO0003', 'Moto', 1, 9500.00, 0, 9500.00),
('VNT000003', 'MOTO0002', 'Moto', 1, 32500.00, 0, 32500.00),
('VNT000004', 'REP00005', 'Repuesto', 1, 600.00, 0, 600.00),
('VNT000005', 'REP00004', 'Repuesto', 1, 400.00, 0, 400.00),
('VNT000006', 'REP00006', 'Repuesto', 1, 2800.00, 0, 2800.00),
('VNT000007', 'REP00007', 'Repuesto', 1, 3200.00, 0, 3200.00),
('VNT000008', 'REP00008', 'Repuesto', 1, 1800.00, 0, 1800.00),
('VNT000009', 'REP00009', 'Repuesto', 1, 12000.00, 0, 12000.00),
('VNT000010', 'REP00010', 'Repuesto', 10, 1500.00, 0, 1500.00),
('VNT000011', 'REP00011', 'Repuesto', 1, 2200.00, 0, 2200.00),
('VNT000012', 'REP00012', 'Repuesto', 1, 9500.00, 0, 9500.00),
('VNT000013', 'REP00013', 'Repuesto', 1, 4200.00, 0, 4200.00),
('VNT000014', 'REP00014', 'Repuesto', 1, 3800.00, 0, 3800.00),
('VNT000015', 'REP00015', 'Repuesto', 1, 85000.00, 0, 85000.00),
('VNT000016', 'REP00016', 'Repuesto', 1, 22000.00, 0, 22000.00),
('VNT000017', 'REP00017', 'Repuesto', 1, 7500.00, 0, 7500.00),
('VNT000018', 'REP00018', 'Repuesto', 1, 9800.00, 0, 9800.00),
('VNT000019', 'REP00019', 'Repuesto', 1, 45000.00, 0, 45000.00),
('VNT000020', 'REP00020', 'Repuesto', 1, 6500.00, 0, 6500.00),
('VNT000021', 'REP00021', 'Repuesto', 1, 4200.00, 0, 4200.00),
('VNT000022', 'REP00022', 'Repuesto', 1, 5200.00, 0, 5200.00),
('VNT000023', 'REP00023', 'Repuesto', 1, 3200.00, 0, 3200.00),
('VNT000024', 'REP00024', 'Repuesto', 1, 11000.00, 0, 11000.00),
('VNT000025', 'REP00025', 'Repuesto', 1, 3500.00, 0, 3500.00),
('VNT000026', 'REP00026', 'Repuesto', 1, 1200.00, 0, 1200.00),
('VNT000027', 'REP00027', 'Repuesto', 1, 900.00, 0, 900.00),
('VNT000028', 'REP00028', 'Repuesto', 1, 700.00, 0, 700.00),
('VNT000029', 'REP00029', 'Repuesto', 1, 11000.00, 0, 11000.00),
('VNT000030', 'REP00030', 'Repuesto', 1, 1000.00, 0, 1000.00),
('VNT000031', 'REP00031', 'Repuesto', 1, 2400.00, 0, 2400.00),
('VNT000032', 'REP00032', 'Repuesto', 1, 7800.00, 0, 7800.00),
('VNT000033', 'REP00033', 'Repuesto', 1, 6500.00, 0, 6500.00),
('VNT000034', 'REP00034', 'Repuesto', 1, 2900.00, 0, 2900.00),
('VNT000035', 'REP00035', 'Repuesto', 1, 12000.00, 0, 12000.00);

SELECT 
    m.IDMoto, 
    m.motoMarca, 
    m.motoModelo, 
    m.motoAño, 
    cm.catNombre AS Categoria,
    p.provNombre AS Proveedor,
    m.motoStock,
    m.motoPrecio
FROM tblMotos m
INNER JOIN tblCategoriaMotos cm ON m.IDCategoria = cm.IDCategoria
INNER JOIN tblProveedor p ON m.RUC = p.RUC
WHERE m.motoStock > 0
ORDER BY m.motoMarca, m.motoModelo;


SELECT 
    v.IDVenta,
    v.venFecha,
    c.cliNombres + ' ' + c.cliApellidoPaterno AS Cliente,
    t.traNombres + ' ' + t.traApellidoPaterno AS Vendedor,
    mp.metNombre AS MetodoPago,
    dv.TipoProducto,
    CASE 
        WHEN dv.TipoProducto = 'Moto' THEN m.motoMarca + ' ' + m.motoModelo
        ELSE r.repNombre
    END AS Producto,
    dv.detCantidad,
    dv.detPrecioUnitario,
    v.venTotal
FROM tblVenta v
INNER JOIN tblDetalleVenta dv ON v.IDVenta = dv.IDVenta
INNER JOIN tblCliente c ON v.DNI = c.DNI
INNER JOIN tblTrabajador t ON v.IDTrabajador = t.IDTrabajador
INNER JOIN tblMetodoPago mp ON v.IDMetodoPago = mp.IDMetodoPago
LEFT JOIN tblMotos m ON dv.IDProducto = m.IDMoto AND dv.TipoProducto = 'Moto'
LEFT JOIN tblRepuestos r ON dv.IDProducto = r.IDRepuesto AND dv.TipoProducto = 'Repuesto'
ORDER BY v.venFecha DESC;

-- Motos con stock bajo
SELECT IDMoto, motoMarca, motoModelo, motoStock 
FROM tblMotos 
WHERE motoStock < 5



-- Repuestos con stock bajo
SELECT IDRepuesto, repNombre AS motoMarca, repMarca AS motoModelo, repStock AS motoStock
FROM tblRepuestos
WHERE repStock < 5;


SELECT 
    YEAR(venFecha) AS Año,
    MONTH(venFecha) AS Mes,
    COUNT(*) AS TotalVentas,
    SUM(venTotal) AS MontoTotal
FROM tblVenta
WHERE venEstado = 'Pagado'
GROUP BY YEAR(venFecha), MONTH(venFecha)
ORDER BY Año, Mes;

SELECT 
    dv.IDProducto,
    CASE 
        WHEN dv.TipoProducto = 'Moto' THEN m.motoMarca + ' ' + m.motoModelo
        ELSE r.repNombre
    END AS Producto,
    dv.TipoProducto,
    SUM(dv.detCantidad) AS TotalVendido,
    SUM(dv.detSubTotal) AS IngresosGenerados
FROM tblDetalleVenta dv
LEFT JOIN tblMotos m ON dv.IDProducto = m.IDMoto AND dv.TipoProducto = 'Moto'
LEFT JOIN tblRepuestos r ON dv.IDProducto = r.IDRepuesto AND dv.TipoProducto = 'Repuesto'
GROUP BY dv.IDProducto, dv.TipoProducto, m.motoMarca, m.motoModelo, r.repNombre
ORDER BY TotalVendido DESC;
