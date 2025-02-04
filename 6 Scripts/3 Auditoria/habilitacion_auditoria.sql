-- Habilitación de Auditoría y Registro de Eventos en MySQL

-- Crear la tabla de auditoría si no existe
CREATE TABLE IF NOT EXISTS auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50),
    tabla_afectada VARCHAR(50),
    id_afectado INT,
    accion VARCHAR(100),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear Trigger para Insert en infraestructura_deportiva
CREATE TRIGGER log_infraestructura_insert
AFTER INSERT ON infraestructura_deportiva
FOR EACH ROW
INSERT INTO auditoria (usuario, tabla_afectada, id_afectado, accion)
VALUES (CURRENT_USER(), 'infraestructura_deportiva', NEW.id_infraestructura, 'INSERT');

-- Crear Trigger para Update en infraestructura_deportiva
CREATE TRIGGER log_infraestructura_update
AFTER UPDATE ON infraestructura_deportiva
FOR EACH ROW
INSERT INTO auditoria (usuario, tabla_afectada, id_afectado, accion)
VALUES (CURRENT_USER(), 'infraestructura_deportiva', OLD.id_infraestructura, 'UPDATE');

-- Crear Trigger para Delete en infraestructura_deportiva
CREATE TRIGGER log_infraestructura_delete
AFTER DELETE ON infraestructura_deportiva
FOR EACH ROW
INSERT INTO auditoria (usuario, tabla_afectada, id_afectado, accion)
VALUES (CURRENT_USER(), 'infraestructura_deportiva', OLD.id_infraestructura, 'DELETE');

-- Consulta para revisar los registros de auditoría
SELECT * FROM auditoria ORDER BY fecha DESC;
