# Proyecto de Base de Datos para Infraestructura de Inventarios

## Descripción
Este proyecto tiene como objetivo diseñar y documentar una base de datos eficiente para gestionar inventarios, incluyendo el modelado de datos, la seguridad y la auditoría del sistema.

## Contenido
### 1. Modelado de Base de Datos y Diccionario de Datos
- **Objetivo:** Diseñar una base de datos bien estructurada utilizando un modelo entidad-relación (ER).
- **Actividades:**
  - Creación del modelo entidad-relación (Clientes, Productos, Proveedores, Pedidos, Inventarios).
  - Desarrollo del diccionario de datos.
  - Implementación de restricciones de integridad referencial.

### 2. Seguridad, Auditoría y Control de Acceso
- **Objetivo:** Proteger los datos y gestionar el acceso adecuado a la base de datos.
- **Actividades:**
  - Implementación de roles y permisos (Administrador, Usuario, Auditor).
  - Aplicación de cifrado en datos sensibles.
  - Habilitación de auditoría y registro de eventos.

## Entidades Claves y Relaciones
### Modelo Entidad-Relación (MER)
```plaintext
Clientes: ClienteID (PK), Nombre, Correo, Teléfono
Productos: ProductoID (PK), Nombre, Precio, Stock
Proveedores: ProveedorID (PK), Nombre, Contacto
Pedidos: PedidoID (PK), ClienteID (FK), Fecha
Inventarios: InventarioID (PK), ProductoID (FK), Cantidad
```

## Implementación en SQL
### Ejemplo de Creación de Tablas
```sql
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY,
    Nombre VARCHAR(100),
    Correo VARCHAR(100),
    Telefono VARCHAR(15)
);
```

### Seguridad y Permisos
```sql
CREATE USER 'auditor'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON inventarios.* TO 'auditor'@'localhost';
```

## Autores
- Proyecto desarrollado por estudiantes de la **Escuela Politécnica Nacional - ESFOT**.

## Notas
- Se recomienda seguir buenas prácticas en el diseño de bases de datos.
- Considerar estrategias de escalabilidad y optimización.
