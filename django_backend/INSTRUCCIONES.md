# 🚀 Instrucciones de Instalación y Uso - Django Backend

## 📋 Resumen del Proyecto

He creado un backend completo en Django para tu aplicación de delivery comunitario Flutter. El backend incluye:

### 🏗️ Estructura del Proyecto:
- **Autenticación**: Sistema de login/registro con JWT
- **Usuarios**: Gestión de perfiles y direcciones
- **Negocios**: CRUD de comercios con geolocalización
- **Productos**: Catálogo de productos por negocio
- **Pedidos**: Sistema completo de pedidos con estados
- **APIs REST**: Endpoints para comunicación con Flutter

### 📊 Modelos Implementados:
- `User`: Usuarios (clientes y comerciantes)
- `Address`: Direcciones de entrega
- `Category`: Categorías de productos
- `Business`: Negocios/comercios
- `Product`: Productos
- `Order`: Pedidos
- `OrderItem`: Items de pedidos

## 🛠️ Instalación

### Opción 1: Instalación Automática (Recomendada)
```bash
# En Windows
django_backend\install.bat

# En Linux/Mac
cd django_backend
chmod +x install.sh
./install.sh
```

### Opción 2: Instalación Manual
```bash
# 1. Crear entorno virtual
python -m venv venv

# 2. Activar entorno virtual
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# 3. Instalar dependencias
pip install -r requirements.txt

# 4. Configurar variables de entorno
copy env_example.txt .env
# Editar .env con tus configuraciones

# 5. Ejecutar migraciones
python manage.py makemigrations
python manage.py migrate

# 6. Crear superusuario
python manage.py createsuperuser

# 7. Ejecutar servidor
python manage.py runserver
```

## 🐳 Instalación con Docker (Opcional)
```bash
cd django_backend
docker-compose up --build
```

## 🌐 APIs Disponibles

### Autenticación
- `POST /api/auth/register/` - Registro de usuarios
- `POST /api/auth/login/` - Inicio de sesión
- `POST /api/auth/refresh/` - Renovar token JWT
- `GET /api/auth/profile/` - Perfil del usuario

### Usuarios
- `GET /api/users/profile/` - Obtener/actualizar perfil
- `GET /api/users/addresses/` - Listar direcciones
- `POST /api/users/addresses/` - Crear dirección
- `PUT /api/users/addresses/{id}/` - Actualizar dirección

### Negocios
- `GET /api/businesses/` - Listar negocios
- `POST /api/businesses/` - Crear negocio
- `GET /api/businesses/nearby/` - Negocios cercanos
- `GET /api/businesses/{id}/` - Detalle de negocio

### Productos
- `GET /api/products/` - Listar productos
- `GET /api/products/popular/` - Productos populares
- `GET /api/products/business/{id}/` - Productos por negocio
- `POST /api/products/` - Crear producto

### Pedidos
- `GET /api/orders/` - Listar pedidos
- `POST /api/orders/` - Crear pedido
- `GET /api/orders/{id}/` - Detalle de pedido
- `PUT /api/orders/{id}/update-status/` - Actualizar estado

## 🔧 Configuración para Flutter

### Variables de Entorno (.env)
```env
# Base de datos
DATABASE_URL=sqlite:///db.sqlite3  # Para desarrollo
# DATABASE_URL=postgresql://usuario:password@localhost:5432/delivery_db

# Django
SECRET_KEY=tu-clave-secreta-muy-segura-aqui
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# CORS para Flutter
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
```

### Configuración en Flutter
En tu aplicación Flutter, actualiza la URL base de la API:
```dart
// En tu servicio HTTP
const String BASE_URL = 'http://localhost:8000/api/';
```

## 📱 Integración con Flutter

### 1. Actualizar Dependencies
Asegúrate de que tu `pubspec.yaml` incluya:
```yaml
dependencies:
  http: ^1.2.0
  shared_preferences: ^2.3.2
```

### 2. Servicio de API
Crea un servicio para comunicarte con Django:
```dart
class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/';
  
  // Métodos para autenticación, negocios, productos, etc.
}
```

### 3. Modelos Compatibles
Los modelos Django están diseñados para ser compatibles con tus modelos Flutter existentes.

## 🗄️ Base de Datos

### SQLite (Desarrollo)
Por defecto, el proyecto usa SQLite para desarrollo fácil.

### PostgreSQL (Producción)
Para producción, configura PostgreSQL:
```env
DATABASE_URL=postgresql://usuario:password@localhost:5432/delivery_db
```

## 📊 Datos de Ejemplo

Para crear datos de prueba:
```bash
python manage.py shell < scripts/create_sample_data.py
```

Esto creará:
- Usuarios de ejemplo (cliente y comerciantes)
- Categorías de productos
- Negocios de ejemplo
- Productos de muestra
- Direcciones de entrega

## 🔒 Seguridad

- Autenticación JWT implementada
- CORS configurado para Flutter
- Validación de datos en todos los endpoints
- Permisos por tipo de usuario (cliente/comerciante)

## 🚀 Despliegue

### Variables de Producción
```env
DEBUG=False
SECRET_KEY=clave-super-secreta-para-produccion
ALLOWED_HOSTS=tu-dominio.com
DATABASE_URL=postgresql://usuario:password@host:5432/delivery_db
```

### Comandos de Despliegue
```bash
python manage.py collectstatic
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

## 📞 Soporte

Si tienes problemas:
1. Verifica que Python 3.9+ esté instalado
2. Asegúrate de que todas las dependencias estén instaladas
3. Revisa el archivo `.env` para configuraciones correctas
4. Consulta los logs en `logs/django.log`

## ✅ Próximos Pasos

1. **Instalar el backend**: Ejecuta `install.bat` o `install.sh`
2. **Configurar Flutter**: Actualiza las URLs de API en tu app
3. **Probar APIs**: Usa herramientas como Postman o curl
4. **Integrar**: Conecta tu app Flutter con los nuevos endpoints
5. **Personalizar**: Ajusta los modelos según tus necesidades específicas

¡Tu backend Django está listo para funcionar con tu aplicación Flutter! 🎉
