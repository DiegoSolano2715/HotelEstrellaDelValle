create database Hotel_estrella_del_valle;
Go
use  Hotel_estrella_del_valle;
Go

CREATE TABLE Clientes (
    IdCliente INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50),
    Apellidos VARCHAR(50),
    Telefono VARCHAR(20),
    Email VARCHAR(100)
);

INSERT INTO Clientes (Nombre, Apellidos, Telefono, Email) VALUES
('Juan', 'Pérez López', '5551234567', 'juanp@example.com'),
('María', 'Gómez Ruiz', '5559876543', 'mariag@example.com'),
('Carlos', 'Ramírez Díaz', '5551112222', 'carlosr@example.com'),
('Luisa', 'Fernández Soto', '5553334444', 'luisaf@example.com'),
('Pedro', 'Luna Torres', '5552223333', 'pedrol@example.com'),
('Ana', 'Martínez Vega', '5554445555', 'anam@example.com'),
('Jorge', 'Santos Mora', '5556667777', 'jorgesm@example.com'),
('Laura', 'Hernández Gil', '5558889999', 'laurah@example.com'),
('Ricardo', 'Ortiz Peña', '5550001111', 'ricardoo@example.com'),
('Sofía', 'Castro León', '5551122334', 'sofiac@example.com');

Select * From Clientes;

CREATE TABLE Habitaciones (
    IdHabitacion INT IDENTITY(1,1) PRIMARY KEY,
    Numero INT NOT NULL,
    Tipo VARCHAR(20) CHECK (Tipo IN ('Sencilla', 'Doble', 'Suite')),
    PrecioPorNoche DECIMAL(10,2)
);

INSERT INTO Habitaciones (Numero, Tipo, PrecioPorNoche) VALUES
(101, 'Sencilla', 800),
(102, 'Sencilla', 800),
(201, 'Doble', 1200),
(202, 'Doble', 1200),
(203, 'Doble', 1250),
(301, 'Suite', 2000),
(302, 'Suite', 2200),
(303, 'Suite', 2300),
(401, 'Sencilla', 850),
(402, 'Doble', 1300);

Select * from Habitaciones;

CREATE TABLE Reservaciones (
    IdReserva INT IDENTITY(1,1) PRIMARY KEY,
    IdCliente INT FOREIGN KEY REFERENCES Clientes(IdCliente),
    IdHabitacion INT FOREIGN KEY REFERENCES Habitaciones(IdHabitacion),
    FechaEntrada DATE,
    FechaSalida DATE,
    CantidadNoches INT,
    MontoTotal DECIMAL(10,2)
);

INSERT INTO Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida, CantidadNoches, MontoTotal) VALUES
(1, 1, '2025-01-02', '2025-01-05', 3, 2400),
(2, 3, '2025-02-10', '2025-02-12', 2, 2400),
(3, 6, '2025-03-01', '2025-03-04', 3, 6000),
(4, 2, '2025-03-05', '2025-03-07', 2, 1600),
(5, 4, '2025-03-10', '2025-03-15', 5, 6000),
(6, 7, '2025-04-01', '2025-04-03', 2, 4400),
(7, 8, '2025-04-10', '2025-04-13', 3, 6900),
(8, 5, '2025-05-01', '2025-05-02', 1, 1250),
(9, 9, '2025-05-05', '2025-05-08', 3, 2550),
(10, 10, '2025-05-10', '2025-05-14', 4, 5200),
(3, 1, '2025-06-01', '2025-06-02', 1, 800),
(4, 2, '2025-06-05', '2025-06-07', 2, 1600),
(6, 3, '2025-06-10', '2025-06-11', 1, 1200),
(8, 4, '2025-06-15', '2025-06-17', 2, 2400),
(9, 6, '2025-06-20', '2025-06-22', 2, 4000);

Select * From Reservaciones;


CREATE TABLE Pagos (
    IdPago INT IDENTITY(1,1) PRIMARY KEY,
    IdReserva INT FOREIGN KEY REFERENCES Reservaciones(IdReserva),
    Monto DECIMAL(10,2),
    FechaPago DATE,
    MetodoPago VARCHAR(50)
);


INSERT INTO Pagos (IdReserva, Monto, FechaPago, MetodoPago) VALUES
(1, 2400, '2025-01-05', 'Tarjeta'),
(2, 2400, '2025-02-12', 'Efectivo'),
(3, 6000, '2025-03-04', 'Tarjeta'),
(4, 1600, '2025-03-07', 'Efectivo'),
(5, 6000, '2025-03-15', 'Transferencia'),
(6, 4400, '2025-04-03', 'Tarjeta'),
(7, 6900, '2025-04-13', 'Tarjeta'),
(8, 1250, '2025-05-02', 'Efectivo'),
(9, 2550, '2025-05-08', 'Tarjeta'),
(10, 5200, '2025-05-14', 'Transferencia'),
(11, 800, '2025-06-02', 'Tarjeta'),
(12, 1600, '2025-06-07', 'Tarjeta'),
(13, 1200, '2025-06-11', 'Efectivo'),
(14, 2400, '2025-06-17', 'Tarjeta'),
(15, 4000, '2025-06-22', 'Tarjeta');

Select * from Pagos;

-- consultas Basicas y avanzadas

-- 1. Listar todos los clientes ordenados por apellido
SELECT * 
FROM Clientes
ORDER BY Apellidos;

-- 2. Listar habitaciones de mayor a menor precio
SELECT * 
FROM Habitaciones
ORDER BY PrecioPorNoche DESC;

-- 3. Mostrar reservaciones realizadas en un rango de fechas
SELECT * 
FROM Reservaciones
WHERE FechaEntrada BETWEEN '2025-03-01' AND '2025-03-31';

-- 1. JOIN entre Reservaciones, Habitaciones y Clientes
SELECT r.IdReserva, c.Nombre, c.Apellidos, h.Numero, h.Tipo, r.FechaEntrada, r.FechaSalida, r.MontoTotal
FROM Reservaciones r
JOIN Clientes c ON r.IdCliente = c.IdCliente
JOIN Habitaciones h ON r.IdHabitacion = h.IdHabitacion;

-- 2. JOIN para pagos por cliente
SELECT c.Nombre, c.Apellidos, p.Monto, p.FechaPago, p.MetodoPago
FROM Pagos p
JOIN Reservaciones r ON p.IdReserva = r.IdReserva
JOIN Clientes c ON r.IdCliente = c.IdCliente;

-- 3. Subconsulta que liste clientes que han hecho más de una reserva
SELECT Nombre, Apellidos
FROM Clientes
WHERE IdCliente IN (
    SELECT IdCliente
    FROM Reservaciones
    GROUP BY IdCliente
    HAVING COUNT(*) > 1
);

-- 4. Consultas con lógica condicional WHERE
-- Reservaciones con monto mayor a 4000
SELECT * 
FROM Reservaciones
WHERE MontoTotal > 4000;

-- Reservaciones con menos de 3 noches
SELECT * 
FROM Reservaciones
WHERE CantidadNoches < 3;

-- Clientes cuyo nombre contiene 'a'
SELECT * 
FROM Clientes
WHERE Nombre LIKE '%c%';

-- Reservaciones en mayo
SELECT * 
FROM Reservaciones
WHERE FechaEntrada BETWEEN '2025-05-01' AND '2025-05-31';

-- 1. Agregamos columna Estado para ejemplo
ALTER TABLE Clientes ADD Estado VARCHAR(10) DEFAULT 'Activo';
GO

-- 2. UNION entre clientes activos e inactivos (inventando algunos inactivos)
UPDATE Clientes SET Estado = 'Inactivo' WHERE IdCliente IN (2, 5);

SELECT IdCliente, Nombre, Estado FROM Clientes WHERE Estado='Activo'
UNION
SELECT IdCliente, Nombre, Estado FROM Clientes WHERE Estado='Inactivo';

-- 3. INTERSECT: clientes con reservaciones y pagos
SELECT DISTINCT r.IdCliente FROM Reservaciones r
INTERSECT
SELECT DISTINCT r.IdCliente FROM Reservaciones r
JOIN Pagos p ON r.IdReserva = p.IdReserva;

-- 4. EXCEPT: habitaciones que no tienen reservación
SELECT IdHabitacion FROM Habitaciones
EXCEPT
SELECT IdHabitacion FROM Reservaciones;

INSERT INTO Habitaciones (Numero, Tipo, PrecioPorNoche)
VALUES (999, 'Sencilla', 1000);


-- 5. Transacción: registrar reservación + pago
BEGIN TRANSACTION;

BEGIN TRY
    DECLARE @NuevoIdReserva INT;

    -- Insertar nueva reservación
    INSERT INTO Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida, CantidadNoches, MontoTotal)
    VALUES (1, 3, '2025-11-25', '2025-11-28', 3, 1200*3);

    SET @NuevoIdReserva = SCOPE_IDENTITY();

    -- Insertar pago correspondiente
    INSERT INTO Pagos (IdReserva, Monto, FechaPago, MetodoPago)
    VALUES (@NuevoIdReserva, 1200*3, GETDATE(), 'Tarjeta');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Ocurrió un error. La transacción fue revertida.';
END CATCH;

-- Aqui podemos ver la nueva reservacion creada y ver el pago generado
SELECT * 
FROM Reservaciones
ORDER BY IdReserva DESC;

SELECT * 
FROM Pagos
ORDER BY IdPago DESC;


-- 1. Actualizar precio de una habitación según el tipo
UPDATE Habitaciones
SET PrecioPorNoche = CASE 
    WHEN Tipo='Sencilla' THEN 900
    WHEN Tipo='Doble' THEN 1400
    WHEN Tipo='Suite' THEN 2500
END;

-- 2. Eliminar pagos de una reserva cancelada (ejemplo IdReserva = 2)
DELETE FROM Pagos WHERE IdReserva = 2;

-- 3. Insertar una reserva nueva con cálculo dinámico del monto total
DECLARE @Cliente INT = 3;
DECLARE @Habitacion INT = 4;
DECLARE @FechaEntrada DATE = '2025-12-01';
DECLARE @FechaSalida DATE = '2025-12-05';
DECLARE @Noches INT = DATEDIFF(DAY, @FechaEntrada, @FechaSalida);
DECLARE @Precio DECIMAL(10,2);

SELECT @Precio = PrecioPorNoche 
FROM Habitaciones 
WHERE IdHabitacion = @Habitacion;

INSERT INTO Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida, CantidadNoches, MontoTotal)
VALUES (@Cliente, @Habitacion, @FechaEntrada, @FechaSalida, @Noches, @Precio * @Noches);

SELECT * FROM Reservaciones ORDER BY IdReserva DESC;
