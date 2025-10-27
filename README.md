# 🛒 Delivery App - Aplicación de Delivery Comunitario

Plataforma de delivery que conecta negocios locales con clientes mediante una aplicación móvil desarrollada en Flutter y un backend REST API en Django.

## 📋 Tabla de Contenidos

- [Descripción del Proyecto](#descripción-del-proyecto)
- [Tecnologías Utilizadas](#tecnologías-utilizadas)
- [Arquitectura del Sistema](#arquitectura-del-sistema)
- [Instalación y Configuración](#instalación-y-configuración)
- [Uso de la API](#uso-de-la-api)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Funcionalidades Implementadas](#funcionalidades-implementadas)
- [Próximas Mejoras](#próximas-mejoras)

## 📱 Descripción del Proyecto

**Delivery App** es una aplicación de delivery comunitario que permite a los usuarios:

- 📍 Explorar negocios locales y sus productos
- 🛒 Agregar productos al carrito
- 📦 Realizar pedidos y hacer seguimiento
- 💳 Gestionar direcciones de entrega
- ⭐ Guardar negocios favoritos
- 🔔 Recibir notificaciones de estado de pedidos

### Roles del Sistema

- **Cliente**: Busca productos, realiza pedidos y hace seguimiento
- **Negocio**: Gestiona productos, recibe pedidos y actualiza estados

## 🛠 Tecnologías Utilizadas

### Frontend (Flutter)

```yaml
- Flutter SDK: ^3.0.0
- Provider: ^6.0.5 (Estado global)
- Firebase: Auth, Firestore, Storage, Messaging
- HTTP: ^1.2.0 (Comunicación con API)
- Geolocator: ^9.0.2
```

### Backend (Django)

```python
- Django: ^5.2.7
- Django REST Framework: ^3.14.0
- PostgreSQL: Base de datos
- JWT: Autenticación
- Firebase Admin SDK: Validación de tokens
```

## 🏗 Arquitectura del Sistema

```
┌─────────────────┐
│   Flutter App   │
│  (Provider +    │
│   Firebase)     │
└────────┬────────┘
         │ HTTP REST API
         ▼
┌─────────────────┐
│  Django REST    │
│  Framework      │
│  (JWT + CORS)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   PostgreSQL    │
│   Database      │
└─────────────────┘
```

### Flujo de Datos

1. **Usuario inicia sesión** → Firebase Authentication
2. **App consulta negocios** → Django API (GET /businesses/)
3. **Usuario agrega al carrito** → Estado local (Provider)
4. **Usuario confirma pedido** → Django API (POST /orders/)
5. **Sistema notifica** → Firebase Cloud Messaging

## ⚙️ Instalación y Configuración

### Prerrequisitos

- Python 3.11+
- Flutter 3.0+
- PostgreSQL 14+
- Node.js (para Firebase)

### Backend (Django)

```bash
# 1. Clonar repositorio
git clone <repo-url>
cd delivery_app/django_backend

# 2. Crear entorno virtual
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 3. Instalar dependencias
pip install -r requirements.txt

# 4. Configurar base de datos
createdb delivery_db
python manage.py migrate

# 5. Crear superusuario
python manage.py createsuperuser

# 6. Cargar datos de prueba
python scripts/create_test_data.py

# 7. Ejecutar servidor
python manage.py runserver
```

**Servidor disponible en:** `http://localhost:8000`  
**Admin panel:** `http://localhost:8000/admin`

### Frontend (Flutter)

```bash
# 1. Navegar a directorio Flutter
cd ..

# 2. Instalar dependencias
flutter pub get

# 3. Configurar Firebase
# - Agregar google-services.json (Android)
# - Agregar GoogleService-Info.plist (iOS)
# - Configurar firebase_options.dart

# 4. Ejecutar en dispositivo/emulador
flutter run
```

## 🔌 Uso de la API

### Endpoints Principales

#### Negocios

```http
GET /api/businesses/
GET /api/businesses/{id}/
POST /api/businesses/ (requiere auth)
```

#### Productos

```http
GET /api/products/
GET /api/products/{id}/
GET /api/products/?business={business_id}
```

#### Pedidos

```http
GET /api/orders/
POST /api/orders/ (crear pedido)
GET /api/orders/{id}/
PATCH /api/orders/{id}/status/
```

### Ejemplo de Uso

```python
import requests

# Obtener lista de negocios
response = requests.get('http://localhost:8000/api/businesses/')
businesses = response.json()

# Obtener productos de un negocio
response = requests.get('http://localhost:8000/api/products/?business=1')
products = response.json()

# Crear un pedido
headers = {'Authorization': 'Bearer YOUR_JWT_TOKEN'}
data = {
    'business': 1,
    'delivery_address': 'Calle Principal 123',
    'items': [
        {'product': 1, 'quantity': 2},
        {'product': 2, 'quantity': 1}
    ]
}
response = requests.post('http://localhost:8000/api/orders/', 
                         json=data, headers=headers)
order = response.json()
```

## 📁 Estructura del Proyecto

```
delivery_app/
├── django_backend/          # Backend Django
│   ├── apps/
│   │   ├── users/           # Gestión de usuarios
│   │   ├── businesses/      # Gestión de negocios
│   │   ├── products/        # Gestión de productos
│   │   └── orders/          # Gestión de pedidos
│   ├── delivery_backend/    # Configuración principal
│   └── scripts/             # Scripts de utilidad
│
├── lib/                     # Código fuente Flutter
│   ├── models/              # Modelos de datos
│   ├── providers/           # Gestión de estado
│   ├── screens/             # Pantallas de la app
│   ├── services/            # Servicios (API, Auth)
│   └── widgets/             # Widgets reutilizables
│
├── assets/                  # Recursos (imágenes, etc.)
└── README.md
```

### Modelos de Datos Principales

**Business** (Negocio)
```dart
- id, name, category
- description, address, phone
- latitude, longitude, rating
- imageUrl, isActive, isOpen
```

**Product** (Producto)
```dart
- id, name, description
- price, imageUrl
- businessId, available, isPopular
```

**Order** (Pedido)
```dart
- id, customerId, products
- total, status, createdAt
- deliveryAddress
```

## ✨ Funcionalidades Implementadas

### ✅ Completadas

- [x] Autenticación con Firebase
- [x] Listado y búsqueda de negocios
- [x] Catálogo de productos
- [x] Carrito de compras (básico)
- [x] Perfil de usuario
- [x] Gestión de direcciones
- [x] Integración con Django API
- [x] UI responsive con temas

### 🚧 En Desarrollo

- [ ] Persistencia de carrito
- [ ] Creación completa de pedidos
- [ ] Seguimiento de pedidos en tiempo real
- [ ] Notificaciones push
- [ ] Sistema de mapas
- [ ] Métodos de pago

## 🎯 Próximas Mejoras

1. **Testing**: Unit tests y integration tests
2. **Optimización**: Caché de imágenes, lazy loading
3. **Seguimiento**: Real-time order tracking
4. **Pagos**: Integración con pasarelas de pago
5. **Analytics**: Dashboard de métricas

## 👥 Contribuidores

- [Tu Nombre] - Desarrollador Full Stack

## 📄 Licencia

Este proyecto es un trabajo académico para [Institución Educativa].

## 📞 Contacto

Para consultas o soporte, contactar a: [tu-email@ejemplo.com]

---

**Version:** 1.0.0  
**Última actualización:** Octubre 2025