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