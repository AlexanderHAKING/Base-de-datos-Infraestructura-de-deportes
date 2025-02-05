USE inventario_deportivo_v2;
-- verificaion de archivos bin 
SHOW VARIABLES LIKE 'log_bin_basename';
-- verificacion de posicion archivos bin
SHOW MASTER STATUS;
SHOW BINARY LOGS;
SHOW BINLOG EVENTS IN 'DESKTOP-U4TK5KI-bin.000018' LIMIT 10;

-- Parte 4 optimizacion 
CREATE INDEX idx_infraestructura_propietario ON infraestructura_deportiva(id_propietario);
CREATE INDEX idx_infraestructura_ubicacion ON infraestructura_deportiva(id_ubicacion);
CREATE INDEX idx_mantenimiento_fecha ON mantenimiento(fecha);
-- optimizacion de consultas 
EXPLAIN SELECT * FROM infraestructura_deportiva
WHERE id_ubicacion = 1 AND estado = 'Bueno';

-- uso de join con index
SELECT 
    i.id_infraestructura,
    i.estado,
    i.caracteristicas_cubierta,
    p.nombre AS propietario,
    u.provincia AS ubicacion,
    m.fecha AS mantenimiento_fecha
FROM 
    infraestructura_deportiva i
JOIN 
    propietarios p ON i.id_propietario = p.id_propietario
JOIN 
    ubicaciones u ON i.id_ubicacion = u.id_ubicacion
LEFT JOIN 
    mantenimiento m ON i.id_infraestructura = m.id_infraestructura
WHERE 
    i.estado = 'Bueno' AND m.fecha >= CURDATE() - INTERVAL 30 DAY;

-- Particion de tablas 

CREATE TABLE mantenimiento_new (
    id_mantenimiento INT NOT NULL,
    id_infraestructura INT NOT NULL,
    fecha DATE NOT NULL,
    descripcion TEXT,
    costo DECIMAL(10,2),
    PRIMARY KEY (id_mantenimiento, fecha), 
    INDEX idx_infraestructura (id_infraestructura) 
) PARTITION BY RANGE (TO_DAYS(fecha) )(
    PARTITION p2021_q1 VALUES LESS THAN (TO_DAYS('2021-02-01')),  
    PARTITION p2021_q2 VALUES LESS THAN (TO_DAYS('2021-04-01')),  
    PARTITION p2021_q3 VALUES LESS THAN (TO_DAYS('2021-06-01')),  
    PARTITION p2021_q4 VALUES LESS THAN (TO_DAYS('2022-08-01')) 
);

-- Migracion de datos 
INSERT INTO mantenimiento_new SELECT * FROM mantenimiento;
-- Eliminacion de la tabla original 
DROP TABLE mantenimiento;
-- renombre de la tabla nueva 
RENAME TABLE mantenimiento_new TO mantenimiento;