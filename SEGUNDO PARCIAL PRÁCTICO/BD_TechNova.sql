-- ========================================================================
-- BASE DE DATOS: BD_TechNova
-- Sistema de gestión para empresa desarrolladora de proyectos tecnológicos
-- ========================================================================

-- Crear la base de datos
DROP DATABASE IF EXISTS technova;
CREATE DATABASE technova;
USE technova;

-- =====================================================
-- CREACIÓN DE TABLAS
-- =====================================================

-- =====================================================
-- CREACIÓN TABLA DEPARTAMENTO
-- =====================================================

CREATE TABLE Departamento (
 id_departamento INT AUTO_INCREMENT PRIMARY KEY, 
 nombre VARCHAR(100) NOT NULL, 
 presupuesto DECIMAL(12,2) CHECK (presupuesto > 0) 
 );
 
 -- =====================================================
-- CREACIÓN TABLA EMPLEADO
-- =====================================================

CREATE TABLE Empleado (
id_empleado INT AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(100),
cargo VARCHAR(50),
salario DECIMAL(10,2) CHECK (salario > 0),
id_departamento INT,
fecha_ingreso DATE,
FOREIGN KEY (id_departamento) REFERENCES Departamento(id_departamento)
);

 -- =====================================================
-- CREACIÓN TABLA PROYECTO
-- =====================================================

CREATE TABLE Proyecto (
id_proyecto INT AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(100),
fecha_inicio DATE,
presupuesto DECIMAL(12,2),
id_departamento INT,
FOREIGN KEY (id_departamento) REFERENCES Departamento(id_departamento)
);

 -- =====================================================
-- CREACIÓN TABLA ASIGNACIÓN
-- =====================================================

CREATE TABLE Asignacion (
id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
id_empleado INT,
id_proyecto INT,
horas_trabajadas INT CHECK (horas_trabajadas >= 0),
FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id_proyecto)
);

-- ========================================================================
-- Promedio por departamento (< 50 h)
-- ========================================================================

 -- ====================================================
-- 0) INSERCIÓN DATOS DE EJEMPLO --
 -- =====================================================

-- Departamentos (≥ 3)
INSERT INTO Departamento (nombre, presupuesto) VALUES
('Desarrollo', 250000.00),
('Soporte', 120000.00),
('Ventas', 200000.00);

-- Empleados (≥ 5) asignados a departamentos
INSERT INTO Empleado (nombre, cargo, salario, id_departamento, fecha_ingreso) VALUES
('Ana Gómez', 'Desarrollador', 5200.00, 1, '2023-04-10'),
('Bruno Pérez', 'Soporte', 4000.00, 2, '2024-01-15'),
('Carla Ruiz', 'Vendedor', 6500.00, 1, '2022-09-01'),
('Diego León', 'Científico', 7800.00, 3, '2021-06-21'),
('Elena Torres', 'Programador', 6000.00, 2, '2023-11-03');

-- Proyectos (≥ 3) cada uno con un departamento 
INSERT INTO Proyecto (nombre, fecha_inicio, presupuesto, id_departamento) VALUES
('Plataforma Web', '2025-01-10', 80000.00, 1),
('Chatbot Soporte', '2025-02-01', 45000.00, 2),
('Visión IA', '2025-03-12', 90000.00, 3);

-- Asignaciones (≥ 5) horas trabajadas por el empleado en el proyecto
-- NOTA: el departamento para el promedio se toma del empleado que trabajó
INSERT INTO Asignacion (id_empleado, id_proyecto, horas_trabajadas) VALUES
(1, 1, 60), -- Desarrollo
(3, 1, 55), -- Desarrollo
(2, 2, 30), -- Soporte
(5, 2, 40), -- Soporte con promedio 35 (< 50)
(4, 3, 80); -- Ventas

-- =====================================================
-- 1) SUBCONSULTA: PROMEDIO DE HORAS POR DEPARTAMENTO --
-- Identifica departamentos cuyo promedio de horas (por empleado) es menor a 50 --
-- La subconsulta calcula el AVG para cada departamento --
 -- =====================================================
 
SELECT
    d.id_departamento,
    d.nombre,
    (
      SELECT AVG(a.horas_trabajadas)
      FROM Empleado e
      JOIN Asignacion a ON a.id_empleado = e.id_empleado
      WHERE e.id_departamento = d.id_departamento
    ) AS promedio_horas
FROM Departamento d
WHERE (
      SELECT AVG(a.horas_trabajadas)
      FROM Empleado e
      JOIN Asignacion a ON a.id_empleado = e.id_empleado
      WHERE e.id_departamento = d.id_departamento
     ) < 50;
     
 -- =====================================================
-- 2) FUNCIÓN: PromedioHorasDep(id_dep) --
-- esta función devuelve el promedio de horas trabajadas por departamento --
 -- =====================================================

DROP FUNCTION IF EXISTS PromedioHorasDep;
DELIMITER $$
CREATE FUNCTION PromedioHorasDep(p_id_dep INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE v_avg DECIMAL(10,2);
  SELECT IFNULL(AVG(a.horas_trabajadas),0)
    INTO v_avg
    FROM Empleado e
    LEFT JOIN Asignacion a ON a.id_empleado = e.id_empleado
   WHERE e.id_departamento = p_id_dep;
  RETURN v_avg;
END$$
DELIMITER ;

 -- =====================================================
-- 3) PROCEDIMIENTO: ListarDepartamentosBajos() --
-- Arroja la Lista departamentos cuyo promedio de horas es menor 50 usando la función--
 -- =====================================================

DROP PROCEDURE IF EXISTS ListarDepartamentosBajos;
DELIMITER $$
CREATE PROCEDURE ListarDepartamentosBajos()
BEGIN
  SELECT d.id_departamento,
         d.nombre,
         PromedioHorasDep(d.id_departamento) AS promedio_horas
    FROM Departamento d
   WHERE PromedioHorasDep(d.id_departamento) < 50
   ORDER BY promedio_horas ASC;
END$$
DELIMITER ;

-- =====================================================
-- 4) BITÁCORA PARA TRIGGER --
-- Este Trigger Registra el evento cuando un departamento cruza el umbral de 50 hacia abajo
 -- =====================================================

DROP TABLE IF EXISTS Departamento_Bajo_Log;
CREATE TABLE Departamento_Bajo_Log (
  id_log INT AUTO_INCREMENT PRIMARY KEY,
  id_departamento INT NOT NULL,
  promedio DECIMAL(10,2) NOT NULL,
  evento VARCHAR(30) NOT NULL,         
  causado_por ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_departamento) REFERENCES Departamento(id_departamento)
);

 -- =====================================================
-- 5) Transacción: revierte reducciones mal calculadas --
 -- =====================================================