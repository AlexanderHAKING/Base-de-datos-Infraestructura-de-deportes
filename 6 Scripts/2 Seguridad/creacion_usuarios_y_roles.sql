-- Creación de Usuarios y Asignación de Roles en MySQL

-- Crear usuario con permisos de solo lectura para auditoría
CREATE USER 'auditorEsteban'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON inventario_deportivo_v2.* TO 'auditorEsteban'@'localhost';
FLUSH PRIVILEGES;

-- Crear usuario administrador con permisos completos
CREATE USER 'adminMateo'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON inventario_deportivo_v2.* TO 'adminMateo'@'localhost';
FLUSH PRIVILEGES;

-- Crear usuario de gestión con permisos intermedios
CREATE USER 'gestorJordy'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT, INSERT, UPDATE ON inventario_deportivo_v2.* TO 'gestorJordys'@'localhost';
FLUSH PRIVILEGES;

-- Comprobación de usuarios creados
SELECT user, host FROM mysql.user WHERE user IN ('auditorEsteban', 'adminMateo', 'gestorJordy');
