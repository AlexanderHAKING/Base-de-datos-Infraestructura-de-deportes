-- Configuración de Relaciones de Integridad en la Base de Datos

-- Crear claves foráneas para garantizar la integridad referencial

ALTER TABLE infraestructura_deportiva 
ADD CONSTRAINT fk_infraestructura_ubicacion 
FOREIGN KEY (id_ubicacion) REFERENCES ubicaciones(id_ubicacion) 
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE infraestructura_deportiva 
ADD CONSTRAINT fk_infraestructura_propietario 
FOREIGN KEY (id_propietario) REFERENCES propietarios(id_propietario) 
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE infraestructura_deportiva 
ADD CONSTRAINT fk_infraestructura_administrador 
FOREIGN KEY (id_administrador) REFERENCES administradores(id_administrador) 
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE mantenimiento 
ADD CONSTRAINT fk_mantenimiento_infraestructura 
FOREIGN KEY (id_infraestructura) REFERENCES infraestructura_deportiva(id_infraestructura) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Verificación de claves foráneas en la base de datos
SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'inventario_deportivo_v2' AND REFERENCED_TABLE_NAME IS NOT NULL;
