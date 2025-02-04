CREATE DATABASE IF NOT EXISTS inventario_deportivo_v2;
USE inventario_deportivo_v2;

-- Tabla de Propietarios
CREATE TABLE propietarios (
    id_propietario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- Tabla de Administradores
CREATE TABLE administradores (
    id_administrador INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARBINARY(255) -- Para almacenar correos cifrados
);

-- Tabla de Ubicación
CREATE TABLE ubicaciones (
    id_ubicacion INT AUTO_INCREMENT PRIMARY KEY,
    provincia VARCHAR(50),
    canton VARCHAR(50),
    coordinacion_zonal VARCHAR(50)
);

-- Tabla de Infraestructura Deportiva (Optimizada para CSV)
CREATE TABLE infraestructura_deportiva (
    id_infraestructura INT AUTO_INCREMENT PRIMARY KEY,
    fecha_actualizacion DATETIME,
    id_ubicacion INT,
    estado ENUM('Bueno', 'Regular', 'Malo'),
    caracteristicas_cubierta VARCHAR(50),
    longitud DECIMAL(12,6),
    latitud DECIMAL(12,6),
    fotografia_principal TEXT,
    otras_fotografias TEXT,
    id_propietario INT,
    id_administrador INT,
    tipo_propiedad ENUM('Publico', 'Privado'),
    hora_apertura TIME,
    hora_cierre TIME,
    uso_escenario VARCHAR(50),
    costo_uso DECIMAL(10,2),
    FOREIGN KEY (id_propietario) REFERENCES propietarios(id_propietario),
    FOREIGN KEY (id_administrador) REFERENCES administradores(id_administrador),
    FOREIGN KEY (id_ubicacion) REFERENCES ubicaciones(id_ubicacion)
);

-- Tabla de Mantenimiento (Relacionada correctamente con la nueva estructura)
CREATE TABLE mantenimiento (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_infraestructura INT,
    fecha DATE,
    descripcion TEXT,
    costo DECIMAL(10,2),
    FOREIGN KEY (id_infraestructura) REFERENCES infraestructura_deportiva(id_infraestructura)
);

-- Tabla de Auditoría
CREATE TABLE auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(100),
    usuario VARCHAR(50),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger para Auditoría en Infraestructura
CREATE TRIGGER log_infraestructura_insert
AFTER INSERT ON infraestructura_deportiva
FOR EACH ROW
INSERT INTO auditoria (accion, usuario)
VALUES ('Se agregó un nuevo escenario', CURRENT_USER());

-- Configuración para permitir carga de archivos CSV
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/inventario_deportivo_sin_id.csv'
INTO TABLE infraestructura_deportiva
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(fecha_actualizacion, coordinacion_zonal, provincia, canton, estado, caracteristicas_cubierta, longitud, latitud, fotografia_principal, otras_fotografias, nombre_propietario, nombre_administrador, tipo_propiedad, hora_apertura, hora_cierre, uso_escenario, costo_uso);

