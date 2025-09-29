-- =========================================================
--  EMPRESA DEMO - Consultas avanzadas (MySQL 8+)
--  Requiere el esquema del reto previo (empleado, departamento, empleado_departamento)
-- =========================================================
USE empresa_demo;

-- 1) Empleados cuyo salario es MAYOR al salario PROMEDIO de la empresa
SELECT 
  e.id_empleado,
  CONCAT(e.nombres, ' ', e.apellidos) AS empleado,
  e.salario
FROM empleado e
WHERE e.salario > (SELECT AVG(salario) FROM empleado)
ORDER BY e.salario DESC;

-- 2) Empleado(s) con el SEGUNDO salario MÁS ALTO (DISTINTO).
--    Si hay empates en ese segundo salario, retorna a todos.
SELECT 
  CONCAT(e.nombres, ' ', e.apellidos) AS empleado,
  e.salario
FROM empleado e
WHERE e.salario = (
  SELECT s.salario
  FROM (
    SELECT DISTINCT salario
    FROM empleado
    ORDER BY salario DESC
    LIMIT 1 OFFSET 1
  ) AS s
);

-- 3) Departamentos SIN empleados (LEFT JOIN)
SELECT 
  d.id_departamento,
  d.nombre AS departamento,
  d.ubicacion
FROM departamento d
LEFT JOIN empleado_departamento ed 
  ON ed.departamento_id = d.id_departamento
WHERE ed.empleado_id IS NULL
ORDER BY d.nombre;

-- 4) Total de empleados por DEPARTAMENTO (incluye 0)
SELECT 
  d.id_departamento,
  d.nombre AS departamento,
  COUNT(ed.empleado_id) AS total_empleados
FROM departamento d
LEFT JOIN empleado_departamento ed 
  ON ed.departamento_id = d.id_departamento
GROUP BY d.id_departamento, d.nombre
ORDER BY d.nombre;
