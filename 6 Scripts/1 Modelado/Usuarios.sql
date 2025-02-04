-- Crear usuario auditor con permisos de solo lectura
CREATE USER 'auditorEsteban'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
GRANT SELECT ON inventario_deportivo_v2.* TO 'auditorEsteban'@'localhost';
FLUSH PRIVILEGES;

-- Crear usuario administrador con permisos completos
CREATE USER 'adminMateo'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON inventario_deportivo_v2.* TO 'adminMateo'@'localhost';
FLUSH PRIVILEGES;

-- Verificar si los usuarios fueron creados correctamente
SELECT user, host FROM mysql.user WHERE user IN ('auditorEsteban', 'adminMateo');

-- Eliminar usuario si es necesario
-- DROP USER 'auditorEsteban'@'localhost';
-- FLUSH PRIVILEGES;

-- Usar la base de datos objetivo
USE inventario_deportivo_v2;
