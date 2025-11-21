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

