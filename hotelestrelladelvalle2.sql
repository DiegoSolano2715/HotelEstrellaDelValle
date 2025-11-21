USE Hotel_estrella_del_valle;
GO
-- **********************************************************************
-- 1. sp_RegistrarReserva
CREATE PROCEDURE sp_RegistrarReserva
    @IdCliente INT,
    @IdHabitacion INT,
    @FechaEntrada DATE,
    @FechaSalida DATE,
    @MetodoPago VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Noches INT = DATEDIFF(DAY, @FechaEntrada, @FechaSalida);
    DECLARE @PrecioNoche DECIMAL(10,2);
    DECLARE @MontoTotal DECIMAL(10,2);
    DECLARE @IdReserva INT;

    SELECT @PrecioNoche = PrecioPorNoche FROM Habitaciones WHERE IdHabitacion = @IdHabitacion;
    SET @MontoTotal = @PrecioNoche * @Noches;

    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida, CantidadNoches, MontoTotal)
        VALUES (@IdCliente, @IdHabitacion, @FechaEntrada, @FechaSalida, @Noches, @MontoTotal);

        SET @IdReserva = SCOPE_IDENTITY();

        INSERT INTO Pagos (IdReserva, Monto, FechaPago, MetodoPago)
        VALUES (@IdReserva, @MontoTotal, GETDATE(), @MetodoPago);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al registrar la reservación.';
    END CATCH
END;
GO

-- 2. sp_ActualizarDatosCliente
CREATE PROCEDURE sp_ActualizarDatosCliente
    @IdCliente INT,
    @Nombre VARCHAR(50) = NULL,
    @Apellidos VARCHAR(50) = NULL,
    @Telefono VARCHAR(20) = NULL,
    @Email VARCHAR(100) = NULL
AS
BEGIN
    UPDATE Clientes
    SET 
        Nombre = ISNULL(@Nombre, Nombre),
        Apellidos = ISNULL(@Apellidos, Apellidos),
        Telefono = ISNULL(@Telefono, Telefono),
        Email = ISNULL(@Email, Email)
    WHERE IdCliente = @IdCliente;
END;
GO

-- 3. sp_ReporteIngresosPorMes
CREATE PROCEDURE sp_ReporteIngresosPorMes
AS
BEGIN
    SELECT 
        YEAR(p.FechaPago) AS Año,
        MONTH(p.FechaPago) AS Mes,
        SUM(p.Monto) AS TotalIngresos
    FROM Pagos p
    GROUP BY YEAR(p.FechaPago), MONTH(p.FechaPago)
    ORDER BY Año, Mes;
END;
GO

-- 1. fn_CalcularNoches
CREATE FUNCTION fn_CalcularNoches(@FechaEntrada DATE, @FechaSalida DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @FechaEntrada, @FechaSalida);
END;
GO

-- 2. fn_CalcularMonto
CREATE FUNCTION fn_CalcularMonto(@PrecioNoche DECIMAL(10,2), @Noches INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @PrecioNoche * @Noches;
END;
GO

-- 1. vw_ReservasDetalle
CREATE VIEW vw_ReservasDetalle
AS
SELECT r.IdReserva, c.Nombre, c.Apellidos, h.Numero, h.Tipo, r.FechaEntrada, r.FechaSalida, r.CantidadNoches, r.MontoTotal
FROM Reservaciones r
JOIN Clientes c ON r.IdCliente = c.IdCliente
JOIN Habitaciones h ON r.IdHabitacion = h.IdHabitacion;
GO


-- 2. vw_PagosPorCliente
CREATE VIEW vw_PagosPorCliente
AS
SELECT c.IdCliente, c.Nombre, c.Apellidos, SUM(p.Monto) AS TotalPagos
FROM Pagos p
JOIN Reservaciones r ON p.IdReserva = r.IdReserva
JOIN Clientes c ON r.IdCliente = c.IdCliente
GROUP BY c.IdCliente, c.Nombre, c.Apellidos;
GO

-- 3. vw_IngresosHabitaciones
CREATE VIEW vw_IngresosHabitaciones
AS
SELECT h.IdHabitacion, h.Numero, h.Tipo, SUM(r.MontoTotal) AS Ingresos
FROM Reservaciones r
JOIN Habitaciones h ON r.IdHabitacion = h.IdHabitacion
GROUP BY h.IdHabitacion, h.Numero, h.Tipo;
GO

-- 1. Trigger que actualice CantidadNoches y MontoTotal después de insertar una reservación
CREATE TRIGGER trg_CalcularReserva
ON Reservaciones
AFTER INSERT
AS
BEGIN
    UPDATE r
    SET 
        CantidadNoches = DATEDIFF(DAY, i.FechaEntrada, i.FechaSalida),
        MontoTotal = DATEDIFF(DAY, i.FechaEntrada, i.FechaSalida) * h.PrecioPorNoche
    FROM Reservaciones r
    JOIN inserted i ON r.IdReserva = i.IdReserva
    JOIN Habitaciones h ON r.IdHabitacion = h.IdHabitacion;
END;
GO

-- 2. Trigger que registre en LogHabitaciones cada vez que se modifique una habitación
-- Crear tabla de log
CREATE TABLE LogHabitaciones (
    IdLog INT IDENTITY(1,1) PRIMARY KEY,
    IdHabitacion INT,
    Usuario VARCHAR(50),
    Fecha DATETIME,
    TipoCambio VARCHAR(50)
);
GO

CREATE TRIGGER trg_LogHabitaciones
ON Habitaciones
AFTER UPDATE
AS
BEGIN
    INSERT INTO LogHabitaciones (IdHabitacion, Usuario, Fecha, TipoCambio)
    SELECT i.IdHabitacion, SYSTEM_USER, GETDATE(), 'Modificación'
    FROM inserted i;
END;
GO
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- aca termina los proceminiento 
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

---------------------------------------------------------
-- VER CONTENIDO DE LOS PROCEDIMIENTOS ALMACENADOS
---------------------------------------------------------
EXEC sp_helptext 'sp_RegistrarReserva';
EXEC sp_helptext 'sp_ActualizarDatosCliente';
EXEC sp_helptext 'sp_ReporteIngresosPorMes';


---------------------------------------------------------
-- EJECUTAR PROCEDIMIENTOS ALMACENADOS
---------------------------------------------------------

-- 1. Ejecutar sp_RegistrarReserva
EXEC sp_RegistrarReserva 
    @IdCliente = 1,
    @IdHabitacion = 3,
    @FechaEntrada = '2025-01-10',
    @FechaSalida = '2025-01-15',
    @MetodoPago = 'Tarjeta';

-- 2. Ejecutar sp_ActualizarDatosCliente
EXEC sp_ActualizarDatosCliente
    @IdCliente = 1,
    @Nombre = 'Juan',
    @Apellidos = 'Pérez',
    @Telefono = NULL,
    @Email = NULL;

-- 3. Ejecutar sp_ReporteIngresosPorMes
EXEC sp_ReporteIngresosPorMes;


---------------------------------------------------------
-- VER FUNCIONES
---------------------------------------------------------
EXEC sp_helptext 'fn_CalcularNoches';
EXEC sp_helptext 'fn_CalcularMonto';


---------------------------------------------------------
-- USAR FUNCIONES
---------------------------------------------------------

-- Calcular noches
SELECT dbo.fn_CalcularNoches('2025-01-10','2025-01-15') AS Noches;

-- Calcular monto
SELECT dbo.fn_CalcularMonto(50, 5) AS Monto;


---------------------------------------------------------
-- CONSULTAR VISTAS
---------------------------------------------------------
SELECT * FROM vw_ReservasDetalle;
SELECT * FROM vw_PagosPorCliente;
SELECT * FROM vw_IngresosHabitaciones;


---------------------------------------------------------
-- VER TRIGGERS
---------------------------------------------------------
EXEC sp_helptext 'trg_CalcularReserva';
EXEC sp_helptext 'trg_LogHabitaciones';


---------------------------------------------------------
-- PROBAR TRIGGER trg_LogHabitaciones
---------------------------------------------------------

-- Actualizar una habitación (esto dispara el trigger)
UPDATE Habitaciones
SET Tipo = 'Suite'
WHERE IdHabitacion = 1;

-- Ver registro insertado por el trigger
SELECT * FROM LogHabitaciones;


---------------------------------------------------------
-- PROBAR EL TRIGGER trg_CalcularReserva
---------------------------------------------------------

-- Insertar una reserva para probar cálculo automático
INSERT INTO Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida)
VALUES (1, 1, '2025-02-01', '2025-02-05');

-- Ver los valores calculados por el trigger
SELECT * FROM Reservaciones;
