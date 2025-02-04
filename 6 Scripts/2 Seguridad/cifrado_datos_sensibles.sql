-- Cifrado de Datos Sensibles en MySQL

-- Modificar la columna de correos para permitir cifrado
ALTER TABLE administradores MODIFY correo VARBINARY(255);

-- Insertar un correo cifrado para un administrador
UPDATE administradores 
SET correo = AES_ENCRYPT('correo@example.com', 'llave_secreta') 
WHERE id_administrador = 1;

-- Consulta para descifrar los correos almacenados
SELECT nombre, 
       CAST(AES_DECRYPT(correo, 'llave_secreta') AS CHAR) AS correo_descifrado
FROM administradores;

-- Verificación de que el cifrado funciona correctamente
SELECT id_administrador, correo FROM administradores;
