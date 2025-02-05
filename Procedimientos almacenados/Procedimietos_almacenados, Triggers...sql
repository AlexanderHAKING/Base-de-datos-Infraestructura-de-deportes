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
-- Procedimientos almacenados
CREATE TABLE reservas (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_infraestructura INT,
    fecha_reserva DATE,
    precio_base DECIMAL(10,2),
    descuento DECIMAL(5,2),   
    cargo_adicional DECIMAL(10,2),
    FOREIGN KEY (id_infraestructura) REFERENCES infraestructura_deportiva(id_infraestructura)
);
DELIMITER //
CREATE PROCEDURE calcular_precio_total_reserva(
    IN id_reserva INT,
    OUT precio_total DECIMAL(10,2)
)
BEGIN
    DECLARE precio_base DECIMAL(10,2);
    DECLARE descuento DECIMAL(5,2);
    DECLARE cargo_adicional DECIMAL(10,2);
    -- Valor de la reserva
    SELECT r.precio_base, r.descuento, r.cargo_adicional
    INTO precio_base, descuento, cargo_adicional
    FROM reservas r
    WHERE r.id_reserva = id_reserva;
    -- Calcular el precio total
    SET precio_total = precio_base - (precio_base * descuento / 100) + cargo_adicional;
END //
DELIMITER ;
-- Mostrar el procedimiento almacenado creado
CALL calcular_precio_total_reserva(1, @precio_total);

CALL calcular_precio_total_reserva(1, @precio_total);
SELECT @precio_total AS PrecioTotal;

SHOW PROCEDURE STATUS WHERE Db = 'inventario_deportivo_v2';
-- Creacion de vistas (ubicaciones,infraestructura_deportiva,mantenimiento)
DELIMITER //
CREATE VIEW vista_infraestructura_mantenimiento_ubicacion AS
SELECT 
    u.provincia AS ubicacion_provincia,
    u.canton AS ubicacion_canton,
    u.coordinacion_zonal AS ubicacion_coordinacion_zonal,
    i.estado AS infraestructura_estado,
    i.caracteristicas_cubierta AS infraestructura_caracteristicas,
    i.costo_uso AS infraestructura_costo_uso,
    m.fecha AS mantenimiento_fecha,
    m.descripcion AS mantenimiento_descripcion,
    m.costo AS mantenimiento_costo
FROM 
    infraestructura_deportiva i
JOIN 
    ubicaciones u ON i.id_ubicacion = u.id_ubicacion
LEFT JOIN 
    mantenimiento m ON i.id_infraestructura = m.id_infraestructura;
DELIMITER ;
-- Verificación de ejecución de vista
SHOW FULL TABLES LIKE 'vista_infraestructura_mantenimiento_ubicacion';
-- Triggers
CREATE TABLE pagos (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT,
    monto DECIMAL(10,2),
    fecha_pago DATE,
    FOREIGN KEY (id_reserva) REFERENCES reservas(id_reserva)
);
CREATE TABLE auditoria_reservas (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT,
    accion VARCHAR(50),
    fecha_accion DATETIME,
    campo_modificado VARCHAR(50),
    valor_anterior VARCHAR(255),
    valor_nuevo VARCHAR(255)
);
CREATE TABLE auditoria_pagos (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_pago INT,
    accion VARCHAR(50),
    fecha_accion DATETIME,
    campo_modificado VARCHAR(50),
    valor_anterior VARCHAR(255),
    valor_nuevo VARCHAR(255)
);
DELIMITER //

CREATE TRIGGER auditoria_reservas_update
AFTER UPDATE ON reservas
FOR EACH ROW
BEGIN
    DECLARE campo VARCHAR(50);
    DECLARE valor_anterior VARCHAR(255);
    DECLARE valor_nuevo VARCHAR(255);
    -- Verificar cada campo actualizado
    IF OLD.precio_base != NEW.precio_base THEN
        SET campo = 'precio_base';
        SET valor_anterior = OLD.precio_base;
        SET valor_nuevo = NEW.precio_base;
        INSERT INTO auditoria_reservas (id_reserva, accion, fecha_accion, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (NEW.id_reserva, 'UPDATE', NOW(), campo, valor_anterior, valor_nuevo);
    END IF;
    
    IF OLD.descuento != NEW.descuento THEN
        SET campo = 'descuento';
        SET valor_anterior = OLD.descuento;
        SET valor_nuevo = NEW.descuento;
        INSERT INTO auditoria_reservas (id_reserva, accion, fecha_accion, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (NEW.id_reserva, 'UPDATE', NOW(), campo, valor_anterior, valor_nuevo);
    END IF;

    IF OLD.cargo_adicional != NEW.cargo_adicional THEN
        SET campo = 'cargo_adicional';
        SET valor_anterior = OLD.cargo_adicional;
        SET valor_nuevo = NEW.cargo_adicional;
        INSERT INTO auditoria_reservas (id_reserva, accion, fecha_accion, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (NEW.id_reserva, 'UPDATE', NOW(), campo, valor_anterior, valor_nuevo);
    END IF;
    
END //

DELIMITER ;
-- Triggers cuando se elimine un registro
DELIMITER //

CREATE TRIGGER auditoria_reservas_delete
AFTER DELETE ON reservas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_reservas (id_reserva, accion, fecha_accion)
    VALUES (OLD.id_reserva, 'DELETE', NOW());
END //

DELIMITER ;
-- Trigger para auditoria de pago
DELIMITER //

CREATE TRIGGER auditoria_pagos_update
AFTER UPDATE ON pagos
FOR EACH ROW
BEGIN
    DECLARE campo VARCHAR(50);
    DECLARE valor_anterior VARCHAR(255);
    DECLARE valor_nuevo VARCHAR(255);
    
    -- Verificar cada campo actualizado
    IF OLD.monto != NEW.monto THEN
        SET campo = 'monto';
        SET valor_anterior = OLD.monto;
        SET valor_nuevo = NEW.monto;
        INSERT INTO auditoria_pagos (id_pago, accion, fecha_accion, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (NEW.id_pago, 'UPDATE', NOW(), campo, valor_anterior, valor_nuevo);
    END IF;

    IF OLD.fecha_pago != NEW.fecha_pago THEN
        SET campo = 'fecha_pago';
        SET valor_anterior = OLD.fecha_pago;
        SET valor_nuevo = NEW.fecha_pago;
        INSERT INTO auditoria_pagos (id_pago, accion, fecha_accion, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (NEW.id_pago, 'UPDATE', NOW(), campo, valor_anterior, valor_nuevo);
    END IF;
    
END //

DELIMITER ;
-- Trigger eliminacion
DELIMITER //

CREATE TRIGGER auditoria_pagos_delete
AFTER DELETE ON pagos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_pagos (id_pago, accion, fecha_accion)
    VALUES (OLD.id_pago, 'DELETE', NOW());
END //

DELIMITER ;

   

DROP PROCEDURE IF EXISTS calcular_precio_mantenimiento;

select * from ubicaciones;


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

-- Optimización
SHOW PROCESSLIST;
CREATE INDEX idx_estado ON infraestructura_deportiva (estado);


