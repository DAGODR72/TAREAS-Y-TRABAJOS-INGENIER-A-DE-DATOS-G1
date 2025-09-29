-- =========================================================
--  ESQUEMA BÁSICO: EMPLEADOS y DEPARTAMENTOS (MySQL 8+)
--  Relación en la tabla DEPARTAMENTO (jefe_empleado_id -> empleado.id_empleado)
--  Incluye función edad(fecha_nac) y consultas DML de ejemplo
-- =========================================================

-- Limpieza opcional para rehacer el script sin errores
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
-- Relación queda en esta tabla: jefe_empleado_id -> empleado.id_empleado
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
-- FUNCIÓN: edad(fecha_nac) -> INT
-- -------------------------
DROP FUNCTION IF EXISTS edad;
DELIMITER $$
CREATE FUNCTION edad(fecha_nac DATE)
RETURNS INT
DETERMINISTIC
BEGIN
  -- TIMESTAMPDIFF(YEAR, ...) calcula años completos transcurridos
  RETURN TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE());
END $$
DELIMITER ;

-- -------------------------
-- INSERTS: empleado (5 registros)
-- -------------------------
INSERT INTO empleado (nombres, apellidos, documento, fecha_nacimiento, fecha_contratacion, salario, email) VALUES
('Ana María',   'González', 'CC1001', '1995-03-14', '2022-01-10', 4200000.00, 'ana.gonzalez@empresa.com'),
('Carlos',      'Pérez',    'CC1002', '1988-07-02', '2021-08-01', 5800000.00, 'carlos.perez@empresa.com'),
('Luisa',       'Ramírez',  'CC1003', '1999-12-20', '2023-03-15', 3500000.00, 'luisa.ramirez@empresa.com'),
('Jorge',       'Martínez', 'CC1004', '1992-11-05', '2020-05-20', 5100000.00, 'jorge.martinez@empresa.com'),
('Diana',       'Suárez',   'CC1005', '2001-06-11', '2024-02-01', 3200000.00, 'diana.suarez@empresa.com');

-- -------------------------
-- INSERTS: departamento (5 registros)
-- Nota: la relación se materializa aquí con jefe_empleado_id
--       (empleado que actúa como jefe del departamento)
-- -------------------------
INSERT INTO departamento (nombre, ubicacion, jefe_empleado_id) VALUES
('Finanzas',        'Sede Norte', 2),  -- Carlos como jefe
('Recursos Humanos','Sede Norte', 1),  -- Ana María como jefe
('Operaciones',     'Sede Centro', 4), -- Jorge como jefe
('Comercial',       'Sede Centro', 3), -- Luisa como jefa
('Tecnología',      'Sede Norte',  5); -- Diana como jefa

-- =========================================================
-- CONSULTAS DE EJEMPLO (DML / SELECT)
-- =========================================================

-- 1) Listar empleados con su edad (usando la función edad)
SELECT 
  e.id_empleado,
  e.nombres,
  e.apellidos,
  e.fecha_nacimiento,
  edad(e.fecha_nacimiento) AS edad_actual
FROM empleado AS e
ORDER BY e.id_empleado;

-- 2) ¿Cuál es el/los empleado(s) más joven(es)?
--    (a) Simple: orden ascendente por edad y tomar 1
SELECT 
  e.id_empleado,
  CONCAT(e.nombres, ' ', e.apellidos) AS empleado,
  edad(e.fecha_nacimiento) AS edad_actual
FROM empleado AS e
ORDER BY edad_actual ASC
LIMIT 1;

--    (b) Versión que devuelve todos los empates de menor edad
WITH edades AS (
  SELECT e.*, edad(e.fecha_nacimiento) AS edad_actual
  FROM empleado e
)
SELECT id_empleado,
       CONCAT(nombres, ' ', apellidos) AS empleado,
       edad_actual
FROM edades
WHERE edad_actual = (SELECT MIN(edad_actual) FROM edades);

-- 3) Departamentos con el nombre del jefe (relación en DEPARTAMENTO)
SELECT 
  d.id_departamento,
  d.nombre      AS departamento,
  d.ubicacion,
  d.jefe_empleado_id,
  CONCAT(e.nombres, ' ', e.apellidos) AS jefe
FROM departamento d
LEFT JOIN empleado e
  ON e.id_empleado = d.jefe_empleado_id
ORDER BY d.id_departamento;

-- 4) Ejemplo general de SELECT * FROM nombre_tabla
SELECT * FROM empleado;
SELECT * FROM departamento;

-- 5) Otros ejemplos útiles
--    a) Empleados ordenados por edad descendente (mayor a menor)
SELECT 
  e.id_empleado,
  CONCAT(e.nombres, ' ', e.apellidos) AS empleado,
  edad(e.fecha_nacimiento) AS edad_actual
FROM empleado e
ORDER BY edad_actual DESC;

--    b) Contar cuántos departamentos tiene cada posible ubicación
SELECT ubicacion, COUNT(*) AS total_departamentos
FROM departamento
GROUP BY ubicacion;
