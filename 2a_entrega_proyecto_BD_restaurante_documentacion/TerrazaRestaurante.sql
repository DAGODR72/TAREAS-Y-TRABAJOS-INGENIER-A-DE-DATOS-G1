-- =====================================================
-- BASE DE DATOS: RESTAURANTE LA TERRAZA
-- Sistema de gestión para restaurante local
-- =====================================================

-- Crear la base de datos
DROP DATABASE IF EXISTS restaurante_la_terraza;
CREATE DATABASE restaurante_la_terraza;
USE restaurante_la_terraza;

-- =====================================================
-- CREACIÓN DE TABLAS
-- =====================================================

-- Tabla 1: CATEGORIAS
-- Clasifica los productos del menú (Plato, Bebida, Postre)
CREATE TABLE Categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    categoria VARCHAR(50) NOT NULL,
    UNIQUE(categoria)
) ENGINE=InnoDB;

-- Tabla 2: MENU
-- Almacena los productos disponibles en el restaurante
CREATE TABLE Menu (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    id_categoria INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id)
) ENGINE=InnoDB;

-- Tabla 3: INGREDIENTES
-- Lista de ingredientes utilizados en los platos
CREATE TABLE Ingredientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    UNIQUE(nombre)
) ENGINE=InnoDB;

-- Tabla 4: MENU_INGREDIENTES (Tabla puente)
-- Relaciona cada plato con sus ingredientes (relación N:M)
CREATE TABLE menu_ingredientes (
    id_menu INT NOT NULL,
    id_ingrediente INT NOT NULL,
    PRIMARY KEY (id_menu, id_ingrediente),
    FOREIGN KEY (id_menu) REFERENCES Menu(id) ON DELETE CASCADE,
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tabla 5: ESTATUS
-- Estados posibles de una orden (Abierto, Cerrado, Cancelado)
CREATE TABLE Estatus (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(20) NOT NULL,
    UNIQUE(estado)
) ENGINE=InnoDB;

-- Tabla 6: MESAS
-- Registro de las mesas del restaurante
CREATE TABLE Mesas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'Disponible', -- Disponible, Ocupada, Reservada
    UNIQUE(numero)
) ENGINE=InnoDB;

-- Tabla 7: TIPO_CLIENTE
-- Clasifica los clientes según su forma de pago
CREATE TABLE TipoCliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    UNIQUE(tipo)
) ENGINE=InnoDB;

-- Tabla 8: CLIENTES
-- Información de clientes frecuentes y mensuales
CREATE TABLE Clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    apodo VARCHAR(50),
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    id_tipo_cliente INT NOT NULL,
    tiene_deuda BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_tipo_cliente) REFERENCES TipoCliente(id)
) ENGINE=InnoDB;

-- Tabla 9: PERSONAL
-- Empleados del restaurante (cocineros, meseros, domiciliarios, etc.)
CREATE TABLE Personal (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    apodo VARCHAR(50),
    documento VARCHAR(20) NOT NULL,
    telefono VARCHAR(20),
    rol VARCHAR(50) NOT NULL, -- Cocinero, Mesero, Recepcionista, Operario WhatsApp, Domiciliario
    UNIQUE(documento)
) ENGINE=InnoDB;

-- Tabla 10: ORDENES
-- Registro de pedidos realizados por los clientes
CREATE TABLE Ordenes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    referencia VARCHAR(100), -- Número de mesa o nombre del cliente
    id_estatus INT NOT NULL,
    id_mesa INT,
    id_cliente INT,
    id_personal INT, -- Mesero o persona que atendió
    FOREIGN KEY (id_estatus) REFERENCES Estatus(id),
    FOREIGN KEY (id_mesa) REFERENCES Mesas(id),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id),
    FOREIGN KEY (id_personal) REFERENCES Personal(id)
) ENGINE=InnoDB;

-- Tabla 11: DETALLE_ORDENES
-- Detalle de cada producto incluido en una orden
CREATE TABLE detalle_ordenes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL,
    id_menu INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_orden) REFERENCES Ordenes(id) ON DELETE CASCADE,
    FOREIGN KEY (id_menu) REFERENCES Menu(id)
) ENGINE=InnoDB;

-- Tabla 12: VENTAS
-- Registro de transacciones de pago
CREATE TABLE Ventas (
    folio INT AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    metodo_pago VARCHAR(20), -- Efectivo, Nequi, Daviplata
    referencia_pago VARCHAR(50), -- Número de teléfono para Nequi/Daviplata
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_orden) REFERENCES Ordenes(id),
    UNIQUE(id_orden)
) ENGINE=InnoDB;

-- Tabla 13: DOMICILIOS
-- Información específica de pedidos a domicilio
CREATE TABLE Domicilios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL,
    id_domiciliario INT NOT NULL,
    tipo_billete VARCHAR(20), -- 50.000, 20.000, 10.000, etc.
    paga_completo BOOLEAN DEFAULT TRUE,
    distancia DECIMAL(5,2), -- En metros (máximo 400m)
    requiere_cubiertos BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_orden) REFERENCES Ordenes(id),
    FOREIGN KEY (id_domiciliario) REFERENCES Personal(id),
    UNIQUE(id_orden)
) ENGINE=InnoDB;

-- Tabla 14: CUENTAS_MENSUALIDAD
-- Control de deudas de clientes que pagan a fin de mes
CREATE TABLE CuentasMensualidad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    deuda_total DECIMAL(10,2) DEFAULT 0.00,
    fecha_corte DATE,
    ultimo_pago DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id)
) ENGINE=InnoDB;

-- =====================================================
-- INSERCIÓN DE DATOS MAESTROS
-- =====================================================

-- Insertar CATEGORIAS
INSERT INTO Categorias (categoria) VALUES 
    ('Plato'),
    ('Bebida'),
    ('Postre');

-- Insertar ESTATUS
INSERT INTO Estatus (estado) VALUES 
    ('Abierto'),
    ('Cerrado'),
    ('Cancelado');

-- Insertar TIPO_CLIENTE
INSERT INTO TipoCliente (tipo) VALUES 
    ('Mesa'),
    ('Domicilio'),
    ('Mensualidad');

-- =====================================================
-- INSERCIÓN DE MESAS (12 mesas)
-- =====================================================
INSERT INTO Mesas (numero, estado) VALUES 
    (1, 'Disponible'),
    (2, 'Disponible'),
    (3, 'Disponible'),
    (4, 'Disponible'),
    (5, 'Disponible'),
    (6, 'Disponible'),
    (7, 'Disponible'),
    (8, 'Disponible'),
    (9, 'Disponible'),
    (10, 'Disponible'),
    (11, 'Disponible'),
    (12, 'Disponible');

-- =====================================================
-- INSERCIÓN DE PERSONAL (9 empleados)
-- =====================================================

-- 3 Cocineros
INSERT INTO Personal (nombre, apellido, apodo, documento, telefono, rol) VALUES 
    ('Carlos', 'Mendoza', 'Carlitos', '52147852', '3201234567', 'Cocinero'),
    ('María', 'López', 'Mary', '1025698745', '3112345678', 'Cocinero'),
    ('Jorge', 'Ramírez', 'Jorgito', '80123456', '3158765432', 'Cocinero');

-- 2 Meseros (toman pedidos en las mesas)
INSERT INTO Personal (nombre, apellido, apodo, documento, telefono, rol) VALUES 
    ('Andrea', 'Gómez', 'Andy', '1023456789', '3209876543', 'Mesero'),
    ('Luis', 'Hernández', 'Lucho', '79852147', '3187654321', 'Mesero');

-- 1 Recepcionista (recibe los pagos)
INSERT INTO Personal (nombre, apellido, apodo, documento, telefono, rol) VALUES 
    ('Patricia', 'Rojas', 'Paty', '52369874', '3145678901', 'Recepcionista');

-- 1 Operario de WhatsApp (atiende pedidos por chat)
INSERT INTO Personal (nombre, apellido, apodo, documento, telefono, rol) VALUES 
    ('Mauricio', 'García', 'Mao', '1025566799', '3214568956', 'Operario WhatsApp');

-- 2 Domiciliarios (entregan pedidos a pie < 400m)
INSERT INTO Personal (nombre, apellido, apodo, documento, telefono, rol) VALUES 
    ('Diego', 'Vargas', 'Dieguito', '1015987654', '3176543210', 'Domiciliario'),
    ('Camila', 'Torres', 'Cami', '1032147896', '3198765432', 'Domiciliario');

-- =====================================================
-- INSERCIÓN DE CLIENTES - TIPO DOMICILIO (30 clientes)
-- =====================================================
INSERT INTO Clientes (nombre, apellido, apodo, direccion, telefono, id_tipo_cliente, tiene_deuda) VALUES 
    ('Sandra', 'Sánchez', 'Samy', 'Calle 68D sur 49F-70', '3214568956', 2, FALSE),
    ('Roberto', 'Pérez', 'Rober', 'Carrera 45 sur 67-89', '3125678901', 2, FALSE),
    ('Ana', 'Martínez', 'Anita', 'Calle 70 sur 48-12', '3156789012', 2, TRUE),
    ('Pedro', 'González', 'Pedrito', 'Carrera 50 sur 68-34', '3187890123', 2, FALSE),
    ('Laura', 'Rodríguez', 'Lau', 'Calle 69 sur 47-56', '3198901234', 2, FALSE),
    ('Miguel', 'Fernández', 'Migue', 'Carrera 46 sur 69-78', '3209012345', 2, TRUE),
    ('Diana', 'Castro', 'Diani', 'Calle 71 sur 49-90', '3210123456', 2, FALSE),
    ('Fernando', 'Morales', 'Fer', 'Carrera 48 sur 70-12', '3221234567', 2, FALSE),
    ('Carolina', 'Jiménez', 'Caro', 'Calle 67 sur 46-34', '3232345678', 2, FALSE),
    ('Andrés', 'Ruiz', 'Andy', 'Carrera 47 sur 68-56', '3243456789', 2, TRUE),
    ('Valentina', 'Ortiz', 'Vale', 'Calle 72 sur 50-78', '3254567890', 2, FALSE),
    ('Sebastián', 'Medina', 'Sebas', 'Carrera 49 sur 71-90', '3265678901', 2, FALSE),
    ('Juliana', 'Ramírez', 'Juli', 'Calle 66 sur 45-12', '3276789012', 2, FALSE),
    ('David', 'Gutiérrez', 'Davo', 'Carrera 44 sur 67-34', '3287890123', 2, TRUE),
    ('Natalia', 'Silva', 'Naty', 'Calle 73 sur 51-56', '3298901234', 2, FALSE),
    ('Alejandro', 'Vargas', 'Alejo', 'Carrera 51 sur 72-78', '3109012345', 2, FALSE),
    ('Daniela', 'Mendoza', 'Dani', 'Calle 65 sur 44-90', '3110123456', 2, FALSE),
    ('Camilo', 'Herrera', 'Cami', 'Carrera 43 sur 66-12', '3121234567', 2, TRUE),
    ('Isabella', 'Ríos', 'Isa', 'Calle 74 sur 52-34', '3132345678', 2, FALSE),
    ('Juan', 'Parra', 'Juancho', 'Carrera 52 sur 73-56', '3143456789', 2, FALSE),
    ('Sofía', 'Navarro', 'Sofi', 'Calle 64 sur 43-78', '3154567890', 2, FALSE),
    ('Mateo', 'Salazar', 'Mate', 'Carrera 42 sur 65-90', '3165678901', 2, TRUE),
    ('Mariana', 'Cruz', 'Mari', 'Calle 75 sur 53-12', '3176789012', 2, FALSE),
    ('Santiago', 'Ospina', 'Santi', 'Carrera 53 sur 74-34', '3187890124', 2, FALSE),
    ('Gabriela', 'Vega', 'Gaby', 'Calle 63 sur 42-56', '3198901235', 2, FALSE),
    ('Daniel', 'Muñoz', 'Dani', 'Carrera 41 sur 64-78', '3209012346', 2, TRUE),
    ('Valeria', 'Reyes', 'Vale', 'Calle 76 sur 54-90', '3210123457', 2, FALSE),
    ('Felipe', 'Cortés', 'Pipe', 'Carrera 54 sur 75-12', '3221234568', 2, FALSE),
    ('Camila', 'Aguilar', 'Cami', 'Calle 62 sur 41-34', '3232345679', 2, FALSE),
    ('Nicolás', 'Molina', 'Nico', 'Carrera 40 sur 63-56', '3243456780', 2, TRUE);

-- =====================================================
-- INSERCIÓN DE CLIENTES - TIPO MENSUALIDAD (30 clientes)
-- =====================================================
INSERT INTO Clientes (nombre, apellido, apodo, direccion, telefono, id_tipo_cliente, tiene_deuda) VALUES 
    ('Camilo', 'Torres', 'Camilito', 'Calle 66C sur 33H-15', '3114568950', 3, TRUE),
    ('Gloria', 'Pineda', 'Glori', 'Carrera 35 sur 65-20', '3125679011', 3, FALSE),
    ('Ricardo', 'Duarte', 'Ricky', 'Calle 67 sur 34-25', '3156780122', 3, TRUE),
    ('Martha', 'Campos', 'Marth', 'Carrera 36 sur 66-30', '3187891233', 3, TRUE),
    ('Eduardo', 'Lozano', 'Edu', 'Calle 68 sur 35-35', '3198902344', 3, FALSE),
    ('Beatriz', 'Suárez', 'Bea', 'Carrera 37 sur 67-40', '3209013455', 3, TRUE),
    ('Alfonso', 'Márquez', 'Poncho', 'Calle 69 sur 36-45', '3210124566', 3, TRUE),
    ('Cecilia', 'León', 'Ceci', 'Carrera 38 sur 68-50', '3221235677', 3, FALSE),
    ('Héctor', 'Carrillo', 'Tito', 'Calle 70 sur 37-55', '3232346788', 3, TRUE),
    ('Rosa', 'Fuentes', 'Rosita', 'Carrera 39 sur 69-60', '3243457899', 3, TRUE),
    ('Arturo', 'Soto', 'Artu', 'Calle 71 sur 38-65', '3254568900', 3, FALSE),
    ('Liliana', 'Peña', 'Lili', 'Carrera 40 sur 70-70', '3265679011', 3, TRUE),
    ('Germán', 'Ibarra', 'Ger', 'Calle 72 sur 39-75', '3276780122', 3, TRUE),
    ('Elena', 'Velasco', 'Ele', 'Carrera 41 sur 71-80', '3287891233', 3, FALSE),
    ('Raúl', 'Acosta', 'Raulito', 'Calle 73 sur 40-85', '3298902344', 3, TRUE),
    ('Adriana', 'Delgado', 'Adri', 'Carrera 42 sur 72-90', '3109013455', 3, TRUE),
    ('Rodrigo', 'Cabrera', 'Rodri', 'Calle 74 sur 41-95', '3110124566', 3, FALSE),
    ('Silvia', 'Bravo', 'Silvi', 'Carrera 43 sur 73-100', '3121235677', 3, TRUE),
    ('Enrique', 'Sandoval', 'Kike', 'Calle 75 sur 42-105', '3132346788', 3, TRUE),
    ('Teresa', 'Montoya', 'Tere', 'Carrera 44 sur 74-110', '3143457899', 3, FALSE),
    ('Guillermo', 'Escobar', 'Guille', 'Calle 76 sur 43-115', '3154568900', 3, TRUE),
    ('Claudia', 'Rubio', 'Clau', 'Carrera 45 sur 75-120', '3165679011', 3, TRUE),
    ('Francisco', 'Zamora', 'Paco', 'Calle 77 sur 44-125', '3176780122', 3, FALSE),
    ('Pilar', 'Cárdenas', 'Pili', 'Carrera 46 sur 76-130', '3187891234', 3, TRUE),
    ('Ignacio', 'Paredes', 'Nacho', 'Calle 78 sur 45-135', '3198902345', 3, TRUE),
    ('Victoria', 'Meza', 'Vicky', 'Carrera 47 sur 77-140', '3209013456', 3, FALSE),
    ('Manuel', 'Barrera', 'Manu', 'Calle 79 sur 46-145', '3210124567', 3, TRUE),
    ('Estela', 'Coronado', 'Este', 'Carrera 48 sur 78-150', '3221235678', 3, TRUE),
    ('Alberto', 'Gallego', 'Beto', 'Calle 80 sur 47-155', '3232346789', 3, FALSE),
    ('Miriam', 'Becerra', 'Miri', 'Carrera 49 sur 79-160', '3243457890', 3, TRUE);

-- =====================================================
-- INSERCIÓN DE MENU (Productos del restaurante)
-- =====================================================

-- PLATOS: Sopas
INSERT INTO Menu (nombre, precio, id_categoria) VALUES 
    ('Sopa de Cuchuco', 8000.00, 1),
    ('Ajiaco', 9000.00, 1),
    ('Sopa de Mute', 8500.00, 1),
    ('Sopa de Entero', 10000.00, 1),
    ('Crema de Verduras', 7500.00, 1),
    ('Huevo', 7000.00, 1);

-- PLATOS: Bandejas (Proteína + Principio + Arroz + Ensalada)
INSERT INTO Menu (nombre, precio, id_categoria) VALUES 
    ('Bandeja con Alitas', 12000.00, 1),
    ('Bandeja con Pollo', 11000.00, 1),
    ('Bandeja con Res', 13000.00, 1),
    ('Bandeja con Albóndigas', 11500.00, 1),
    ('Bandeja con Cerdo', 12500.00, 1);

-- PLATOS ESPECIALES
INSERT INTO Menu (nombre, precio, id_categoria) VALUES 
    ('Arroz Chino', 15000.00, 1),
    ('Bandeja Paisa', 18000.00, 1),
    ('Sopa Especial', 12000.00, 1);

-- BEBIDAS
INSERT INTO Menu (nombre, precio, id_categoria) VALUES 
    ('Jugo', 3000.00, 2),
    ('Limonada', 2500.00, 2);

-- POSTRES
INSERT INTO Menu (nombre, precio, id_categoria) VALUES 
    ('Caramelo del Día', 4000.00, 3);

-- =====================================================
-- INSERCIÓN DE INGREDIENTES
-- =====================================================
INSERT INTO Ingredientes (nombre) VALUES 
    ('Res'),
    ('Cerdo'),
    ('Pollo'),
    ('Arroz'),
    ('Lenteja'),
    ('Frijol'),
    ('Garbanzo'),
    ('Arveja'),
    ('Verduras'),
    ('Ensalada'),
    ('Papa'),
    ('Yuca'),
    ('Plátano'),
    ('Huevo'),
    ('Cebolla'),
    ('Tomate'),
    ('Cilantro'),
    ('Ajo');

-- =====================================================
-- RELACIÓN MENU-INGREDIENTES (Ejemplos)
-- =====================================================

-- Sopa de Cuchuco lleva: Res, Verduras, Papa
INSERT INTO menu_ingredientes (id_menu, id_ingrediente) VALUES 
    (1, 1), (1, 9), (1, 11);

-- Ajiaco lleva: Pollo, Papa, Verduras
INSERT INTO menu_ingredientes (id_menu, id_ingrediente) VALUES 
    (2, 3), (2, 11), (2, 9);

-- Bandeja con Alitas lleva: Pollo, Arroz, Ensalada, Lenteja
INSERT INTO menu_ingredientes (id_menu, id_ingrediente) VALUES 
    (7, 3), (7, 4), (7, 10), (7, 5);

-- Bandeja con Res lleva: Res, Arroz, Ensalada, Frijol
INSERT INTO menu_ingredientes (id_menu, id_ingrediente) VALUES 
    (9, 1), (9, 4), (9, 10), (9, 6);

-- Bandeja Paisa lleva: Res, Cerdo, Arroz, Frijol, Huevo, Plátano
INSERT INTO menu_ingredientes (id_menu, id_ingrediente) VALUES 
    (13, 1), (13, 2), (13, 4), (13, 6), (13, 14), (13, 13);

-- =====================================================
-- CREACIÓN DE CUENTAS DE MENSUALIDAD 
-- (Para clientes que tienen deuda pendiente)
-- =====================================================

-- Crear cuentas para clientes de mensualidad que tienen deuda
INSERT INTO CuentasMensualidad (id_cliente, deuda_total, fecha_corte)
SELECT 
    id, 
    ROUND(RAND() * 200000 + 50000, 2), -- Deuda aleatoria entre 50,000 y 250,000
    LAST_DAY(CURDATE()) -- Último día del mes actual
FROM Clientes 
WHERE id_tipo_cliente = 3 AND tiene_deuda = TRUE;

-- =====================================================
-- CONSULTAS DE VERIFICACIÓN
-- =====================================================

-- Ver todas las mesas
SELECT * FROM Mesas;

-- Ver todo el personal con sus roles
SELECT CONCAT(nombre, ' ', apellido) AS nombre_completo, apodo, rol, telefono 
FROM Personal 
ORDER BY rol;

-- Ver clientes de domicilio
SELECT CONCAT(nombre, ' ', apellido) AS nombre_completo, apodo, direccion, telefono, tiene_deuda 
FROM Clientes 
WHERE id_tipo_cliente = 2;

-- Ver clientes de mensualidad
SELECT CONCAT(nombre, ' ', apellido) AS nombre_completo, apodo, direccion, telefono, tiene_deuda 
FROM Clientes 
WHERE id_tipo_cliente = 3;

-- Ver el menú completo con categorías
SELECT m.nombre AS producto, m.precio, c.categoria 
FROM Menu m 
INNER JOIN Categorias c ON m.id_categoria = c.id 
ORDER BY c.categoria, m.nombre;

-- Ver ingredientes de cada plato
SELECT m.nombre AS plato, GROUP_CONCAT(i.nombre SEPARATOR ', ') AS ingredientes
FROM Menu m
INNER JOIN menu_ingredientes mi ON m.id = mi.id_menu
INNER JOIN Ingredientes i ON mi.id_ingrediente = i.id
GROUP BY m.nombre;

-- Ver deudas de clientes mensuales
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    c.apodo,
    cm.deuda_total,
    cm.fecha_corte
FROM CuentasMensualidad cm
INNER JOIN Clientes c ON cm.id_cliente = c.id
ORDER BY cm.deuda_total DESC;

-- =====================================================
-- EJEMPLO: INSERTAR UNA ORDEN COMPLETA
-- =====================================================

-- Orden en Mesa 5, atendida por mesero Andrea Gómez
INSERT INTO Ordenes (fecha, referencia, id_estatus, id_mesa, id_personal) 
VALUES (NOW(), 'Mesa 5', 1, 5, 4);

-- Obtener el ID de la orden recién creada
SET @orden_id = LAST_INSERT_ID();

-- Agregar productos a la orden
INSERT INTO detalle_ordenes (id_orden, id_menu, cantidad) VALUES 
    (@orden_id, 2, 2),  -- 2 Ajiacos
    (@orden_id, 7, 1),  -- 1 Bandeja con Alitas
    (@orden_id, 15, 3); -- 3 Jugos

-- Calcular el total de la orden
SELECT SUM(m.precio * d.cantidad) AS total
FROM detalle_ordenes d
INNER JOIN Menu m ON d.id_menu = m.id
WHERE d.id_orden = @orden_id;

-- Cerrar la orden
UPDATE Ordenes SET id_estatus = 2 WHERE id = @orden_id;

-- Registrar la venta (pago en efectivo)
INSERT INTO Ventas (id_orden, metodo_pago, total) 
VALUES (@orden_id, 'Efectivo', 
    (SELECT SUM(m.precio * d.cantidad) 
     FROM detalle_ordenes d
     INNER JOIN Menu m ON d.id_menu = m.id
     WHERE d.id_orden = @orden_id)
);

-- =====================================================
-- VISTA: RF026 - Listar Clientes por Tipo
-- Descripción: Muestra clientes filtrados por tipo
-- (Domicilio o Mensualidad)
-- =====================================================

CREATE OR REPLACE VIEW vista_clientes_tipo AS
SELECT 
    c.id,
    CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
    c.apodo,
    c.direccion,
    c.telefono,
    tc.tipo AS tipo_cliente,
    c.tiene_deuda,
    c.id_tipo_cliente
FROM 
    Clientes c
INNER JOIN 
    TipoCliente tc ON c.id_tipo_cliente = tc.id
WHERE 
    c.id_tipo_cliente IN (2, 3)  -- Filtra solo Domicilio(2) y Mensualidad(3)
ORDER BY 
    tc.tipo, c.apellido, c.nombre;

-- =====================================================
-- CONSULTAS DE EJEMPLO PARA USAR LA VISTA RF026
-- =====================================================

-- Ver todos los clientes (Domicilio y Mensualidad)
SELECT * FROM vista_clientes_tipo;

-- Filtrar solo clientes de Domicilio
SELECT * FROM vista_clientes_tipo WHERE tipo_cliente = 'Domicilio';

-- Filtrar solo clientes de Mensualidad
SELECT * FROM vista_clientes_tipo WHERE tipo_cliente = 'Mensualidad';

-- Filtrar clientes con deuda
SELECT * FROM vista_clientes_tipo WHERE tiene_deuda = TRUE;

-- Contar clientes por tipo
SELECT tipo_cliente, COUNT(*) AS total_clientes 
FROM vista_clientes_tipo 
GROUP BY tipo_cliente;

-- =====================================================
-- VISTA: RF004 - Consultar Ingredientes
-- Descripción: Muestra los ingredientes de cada plato
-- del menú
-- =====================================================

CREATE OR REPLACE VIEW vista_ingredientes_plato AS
SELECT 
    m.id AS id_plato,
    m.nombre AS plato,
    m.precio,
    c.categoria,
    i.id AS id_ingrediente,
    i.nombre AS ingrediente
FROM 
    Menu m
INNER JOIN 
    menu_ingredientes mi ON m.id = mi.id_menu
INNER JOIN 
    Ingredientes i ON mi.id_ingrediente = i.id
INNER JOIN 
    Categorias c ON m.id_categoria = c.id
ORDER BY 
    m.nombre, i.nombre;

-- =====================================================
-- CONSULTAS DE EJEMPLO PARA USAR LA VISTA RF004
-- =====================================================

-- Ver todos los platos con sus ingredientes
SELECT * FROM vista_ingredientes_plato;

-- Consultar ingredientes de un plato específico por ID (ejemplo: ID = 1)
SELECT plato, precio, ingrediente 
FROM vista_ingredientes_plato 
WHERE id_plato = 1;

-- Consultar ingredientes de un plato específico por nombre (ejemplo: Ajiaco)
SELECT plato, precio, ingrediente 
FROM vista_ingredientes_plato 
WHERE plato = 'Ajiaco';

-- Ver ingredientes agrupados para cada plato
SELECT 
    id_plato, 
    plato, 
    precio, 
    categoria,
    GROUP_CONCAT(ingrediente ORDER BY ingrediente SEPARATOR ', ') AS ingredientes
FROM vista_ingredientes_plato
GROUP BY id_plato, plato, precio, categoria
ORDER BY plato;

-- Buscar platos que contengan un ingrediente específico (ejemplo: Pollo)
SELECT DISTINCT plato, precio, categoria
FROM vista_ingredientes_plato
WHERE ingrediente = 'Pollo';

-- =====================================================
-- FUNCIÓN: RF037 - Listar Deudores
-- Descripción: Retorna el número total de clientes de
-- mensualidad que tienen deuda pendiente
-- =====================================================

DELIMITER //

CREATE FUNCTION contar_deudores()
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_deudores INT;
    
    SELECT COUNT(*) INTO total_deudores
    FROM Clientes
    WHERE id_tipo_cliente = 3 AND tiene_deuda = TRUE;
    
    RETURN total_deudores;
END//

DELIMITER ;

-- =====================================================
-- CONSULTAS DE EJEMPLO PARA USAR LA FUNCIÓN RF037
-- =====================================================

-- Consultar el número total de deudores
SELECT contar_deudores() AS total_deudores;

-- Ver listado completo de deudores
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    c.apodo,
    c.telefono,
    cm.deuda_total,
    cm.fecha_corte
FROM Clientes c
INNER JOIN CuentasMensualidad cm ON c.id = cm.id_cliente
WHERE c.id_tipo_cliente = 3 AND c.tiene_deuda = TRUE
ORDER BY cm.deuda_total DESC;

-- =====================================================
-- PROCEDIMIENTO: RF004 - Consultar Ingredientes
-- Descripción: Muestra los ingredientes de un plato específico del menú
-- Entrada: ID del producto del menú
-- =====================================================

DELIMITER //

CREATE PROCEDURE consultar_ingredientes(IN p_id_plato INT)
BEGIN
    SELECT 
        m.id AS id_plato,
        m.nombre AS plato,
        m.precio,
        c.categoria,
        i.nombre AS ingrediente
    FROM 
        Menu m
    INNER JOIN 
        menu_ingredientes mi ON m.id = mi.id_menu
    INNER JOIN 
        Ingredientes i ON mi.id_ingrediente = i.id
    INNER JOIN 
        Categorias c ON m.id_categoria = c.id
    WHERE 
        m.id = p_id_plato
    ORDER BY 
        i.nombre;
END//

DELIMITER ;

-- =====================================================
-- EJEMPLOS DE USO DEL PROCEDIMIENTO RF004
-- =====================================================

-- Consultar ingredientes del plato con ID 1 (Sopa de Cuchuco)
CALL consultar_ingredientes(1);

-- Consultar ingredientes del plato con ID 2 (Ajiaco)
CALL consultar_ingredientes(2);

-- Consultar ingredientes del plato con ID 13 (Bandeja Paisa)
CALL consultar_ingredientes(13);

-- =====================================================
-- PROCEDIMIENTO: RF021 - Generar Reporte Diario
-- Descripción: Genera un reporte con todas las ventas realizadas en un día específico
-- Entrada: Fecha del reporte (formato: 'YYYY-MM-DD')
-- =====================================================

DELIMITER //

CREATE PROCEDURE generar_reporte_diario(IN p_fecha DATE)
BEGIN
    SELECT 
        v.folio,
        v.id_orden,
        v.fecha AS fecha_venta,
        o.referencia,
        v.metodo_pago,
        v.referencia_pago,
        v.total,
        CONCAT(p.nombre, ' ', p.apellido) AS atendido_por
    FROM 
        Ventas v
    INNER JOIN 
        Ordenes o ON v.id_orden = o.id
    LEFT JOIN 
        Personal p ON o.id_personal = p.id
    WHERE 
        DATE(v.fecha) = p_fecha
    ORDER BY 
        v.fecha;
        
    -- Resumen del día
    SELECT 
        COUNT(*) AS total_ventas,
        SUM(total) AS total_ingresos,
        AVG(total) AS promedio_venta,
        MIN(total) AS venta_minima,
        MAX(total) AS venta_maxima
    FROM 
        Ventas
    WHERE 
        DATE(fecha) = p_fecha;
END//

DELIMITER ;

-- =====================================================
-- EJEMPLOS DE USO DEL PROCEDIMIENTO RF021
-- =====================================================

-- Generar reporte del día de hoy
CALL generar_reporte_diario(CURDATE());

-- Generar reporte de una fecha específica
CALL generar_reporte_diario('2025-10-24');

-- Generar reporte de ayer
CALL generar_reporte_diario(DATE_SUB(CURDATE(), INTERVAL 1 DAY));

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

-- Mensaje de confirmación
SELECT '¡Base de datos Restaurante La Terraza creada exitosamente!' AS Mensaje;