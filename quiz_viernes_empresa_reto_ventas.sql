-- =========================================================
--  EMPRESA DEMO - Reto: Fuerza de Ventas
--  Objetivo: consulta que entregue el nombre de los empleados
--            que pertenecen al departamento de 'Ventas'.
--  Basado en el contexto "La Gran Empresa de los Datos".
-- =========================================================

DROP DATABASE IF EXISTS empresa_demo;
CREATE DATABASE empresa_demo CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE empresa_demo;

-- -------------------------
-- TABLA: empleado
-- -------------------------
CREATE TABLE empleado (
  id_empleado        INT AUTO_INCREMENT PRIMARY KEY,
  nombres            VARCHAR(60)  NOT NULL,
  apellidos          VARCHAR(60)  NOT NULL,
  documento          VARCHAR(20)  NOT NULL UNIQUE,
  fecha_nacimiento   DATE         NOT NULL,
  fecha_contratacion DATE         NOT NULL,
  salario            DECIMAL(12,2) NOT NULL CHECK (salario >= 0),
  email              VARCHAR(100)  NULL
) ENGINE=InnoDB;

-- -------------------------
-- TABLA: departamento
-- Relación de jefatura: jefe_empleado_id -> empleado.id_empleado
-- -------------------------
CREATE TABLE departamento (
  id_departamento    INT AUTO_INCREMENT PRIMARY KEY,
  nombre             VARCHAR(60) NOT NULL UNIQUE,
  ubicacion          VARCHAR(60) NULL,
  jefe_empleado_id   INT NULL,
  CONSTRAINT fk_departamento_jefe
    FOREIGN KEY (jefe_empleado_id)
    REFERENCES empleado(id_empleado)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- -------------------------
-- TABLA: empleado_departamento (asignación)
-- Permite responder "¿quiénes trabajan en Ventas?"
-- Se asume 1 departamento activo por empleado (UNIQUE).
-- -------------------------
CREATE TABLE empleado_departamento (
  id_asignacion    INT AUTO_INCREMENT PRIMARY KEY,
  empleado_id      INT NOT NULL,
  departamento_id  INT NOT NULL,
  fecha_asignacion DATE NOT NULL DEFAULT (CURDATE()),
  CONSTRAINT fk_ed_empleado
    FOREIGN KEY (empleado_id) REFERENCES empleado(id_empleado)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ed_departamento
    FOREIGN KEY (departamento_id) REFERENCES departamento(id_departamento)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_empleado_un_departamento UNIQUE (empleado_id)
) ENGINE=InnoDB;

-- -------------------------
-- FUNCIÓN: edad(fecha_nac) -> INT (para otros retos del PDF)
-- -------------------------
DROP FUNCTION IF EXISTS edad;
DELIMITER $$
CREATE FUNCTION edad(fecha_nac DATE)
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE());
END $$
DELIMITER ;

-- -------------------------
-- INSERTS: empleado (ejemplo: 6 registros)
-- -------------------------
INSERT INTO empleado (nombres, apellidos, documento, fecha_nacimiento, fecha_contratacion, salario, email) VALUES
('Ana María',   'González', 'CC1001', '1995-03-14', '2022-01-10', 4200000.00, 'ana.gonzalez@empresa.com'),
('Carlos',      'Pérez',    'CC1002', '1988-07-02', '2021-08-01', 5800000.00, 'carlos.perez@empresa.com'),
('Luisa',       'Ramírez',  'CC1003', '1999-12-20', '2023-03-15', 3500000.00, 'luisa.ramirez@empresa.com'),
('Jorge',       'Martínez', 'CC1004', '1992-11-05', '2020-05-20', 5100000.00, 'jorge.martinez@empresa.com'),
('Diana',       'Suárez',   'CC1005', '2001-06-11', '2024-02-01', 3200000.00, 'diana.suarez@empresa.com'),
('Andrés',      'Cano',     'CC1006', '1997-09-23', '2021-02-17', 3900000.00, 'andres.cano@empresa.com');

-- -------------------------
-- INSERTS: departamento (incluye 'Ventas')
-- -------------------------
-- Primero insertamos sin jefe (NULL) y luego actualizamos jefes si se desea
INSERT INTO departamento (nombre, ubicacion, jefe_empleado_id) VALUES
('Finanzas',        'Sede Norte',  NULL),
('Recursos Humanos','Sede Norte',  NULL),
('Operaciones',     'Sede Centro', NULL),
('Ventas',          'Sede Centro', NULL),
('IT',              'Sede Norte',  NULL);

-- (Opcional) Asignar jefes por id (consultar SELECT id_empleado FROM empleado)
UPDATE departamento SET jefe_empleado_id = 2 WHERE nombre = 'Finanzas'; -- Carlos
UPDATE departamento SET jefe_empleado_id = 1 WHERE nombre = 'Recursos Humanos'; -- Ana
UPDATE departamento SET jefe_empleado_id = 4 WHERE nombre = 'Operaciones'; -- Jorge
UPDATE departamento SET jefe_empleado_id = 3 WHERE nombre = 'Ventas'; -- Luisa
UPDATE departamento SET jefe_empleado_id = 5 WHERE nombre = 'IT'; -- Diana

-- -------------------------
-- INSERTS: asignaciones empleado_departamento
-- (Al menos dos empleados en 'Ventas' para ilustrar la consulta)
-- -------------------------
-- Obtener IDs (referencia): SELECT id_departamento, nombre FROM departamento;
--                           SELECT id_empleado, nombres FROM empleado;
INSERT INTO empleado_departamento (empleado_id, departamento_id, fecha_asignacion) VALUES
(3, (SELECT id_departamento FROM departamento WHERE nombre='Ventas'), '2023-03-20'), -- Luisa
(6, (SELECT id_departamento FROM departamento WHERE nombre='Ventas'), '2021-02-20'), -- Andrés
(1, (SELECT id_departamento FROM departamento WHERE nombre='Recursos Humanos'), '2022-01-15'),
(2, (SELECT id_departamento FROM departamento WHERE nombre='Finanzas'), '2021-08-05'),
(4, (SELECT id_departamento FROM departamento WHERE nombre='Operaciones'), '2020-05-25'),
(5, (SELECT id_departamento FROM departamento WHERE nombre='IT'), '2024-02-05');

-- =========================================================
-- CONSULTA solicitada (Fuerza de Ventas)
-- Entregar el nombre (completo) de los empleados de 'Ventas'
-- =========================================================
-- Opción 1: nombres y apellidos concatenados
SELECT CONCAT(e.nombres, ' ', e.apellidos) AS empleado
FROM empleado e
JOIN empleado_departamento ed ON ed.empleado_id = e.id_empleado
JOIN departamento d ON d.id_departamento = ed.departamento_id
WHERE d.nombre = 'Ventas'
ORDER BY empleado;

-- Opción 2: columnas separadas (si se prefiere)
-- SELECT e.nombres, e.apellidos
-- FROM empleado e
-- JOIN empleado_departamento ed ON ed.empleado_id = e.id_empleado
-- JOIN departamento d ON d.id_departamento = ed.departamento_id
-- WHERE d.nombre = 'Ventas'
-- ORDER BY e.apellidos, e.nombres;
