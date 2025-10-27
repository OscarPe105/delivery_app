# 🚀 Django Backend para Delivery App

## 📋 Descripción
Backend API desarrollado en Django para la aplicación de delivery comunitario Flutter.

## 🏗️ Arquitectura del Sistema

### Modelos Principales:
- **User**: Usuarios del sistema (clientes y comerciantes)
- **Business**: Negocios y comercios
- **Product**: Productos ofrecidos por los negocios
- **Order**: Pedidos del sistema
- **OrderItem**: Items individuales de cada pedido
- **Address**: Direcciones de entrega
- **Category**: Categorías de productos

### APIs Principales:
- **Autenticación**: Login, registro, JWT tokens
- **Negocios**: CRUD de negocios, búsqueda por ubicación
- **Productos**: CRUD de productos, filtros por categoría
- **Pedidos**: Creación, seguimiento, actualización de estado
- **Usuarios**: Perfil, direcciones, historial

## 🔧 Instalación y Configuración

### Prerrequisitos:
- Python 3.9+
- PostgreSQL 13+ (recomendado) o SQLite para desarrollo
- Redis (para Celery)

### Instalación:
```bash
# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus configuraciones

# Ejecutar migraciones
python manage.py migrate

# Crear superusuario
python manage.py createsuperuser

# Ejecutar servidor
python manage.py runserver
```

## 🌐 Endpoints API

### Autenticación:
- `POST /api/auth/register/` - Registro de usuarios
- `POST /api/auth/login/` - Inicio de sesión
- `POST /api/auth/refresh/` - Renovar token JWT

### Negocios:
- `GET /api/businesses/` - Listar negocios
- `POST /api/businesses/` - Crear negocio
- `GET /api/businesses/{id}/` - Detalle de negocio
- `PUT /api/businesses/{id}/` - Actualizar negocio

### Productos:
- `GET /api/products/` - Listar productos
- `POST /api/products/` - Crear producto
- `GET /api/products/{id}/` - Detalle de producto

### Pedidos:
- `GET /api/orders/` - Listar pedidos del usuario
- `POST /api/orders/` - Crear nuevo pedido
- `GET /api/orders/{id}/` - Detalle de pedido

## 🔒 Seguridad
- Autenticación JWT
- CORS configurado para Flutter
- Validación de datos
- Rate limiting
- HTTPS en producción

## 📱 Integración con Flutter
El backend está diseñado para trabajar directamente con la aplicación Flutter existente, manteniendo la compatibilidad con los modelos y estructuras de datos actuales.
