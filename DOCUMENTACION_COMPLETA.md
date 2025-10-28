# 📱 DELIVERY APP - DOCUMENTACIÓN COMPLETA DEL PROYECTO

## 📋 ÍNDICE
1. [Descripción General](#descripción-general)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Backend (Django)](#backend-django)
4. [Frontend (Flutter)](#frontend-flutter)
5. [Funcionalidades Principales](#funcionalidades-principales)
6. [Estructura de Archivos](#estructura-de-archivos)
7. [Configuración y Despliegue](#configuración-y-despliegue)
8. [APIs y Endpoints](#apis-y-endpoints)
9. [Base de Datos](#base-de-datos)
10. [Autenticación y Seguridad](#autenticación-y-seguridad)
11. [Animaciones y UI](#animaciones-y-ui)
12. [Testing](#testing)
13. [Próximas Mejoras](#próximas-mejoras)

---

## 🎯 DESCRIPCIÓN GENERAL

**Delivery App** es una aplicación móvil desarrollada en Flutter con backend en Django REST Framework que permite a los usuarios hacer pedidos de comida y otros productos a negocios locales, mientras que los dueños de negocios pueden gestionar sus pedidos y productos a través de un dashboard especializado.

### 🎨 Características Principales:
- **Multi-rol**: Clientes, Dueños de Negocio, Administradores
- **Categorías Diversas**: Comida, Farmacias, Electrónicos, Moda, Hogar, etc.
- **Dashboard de Negocios**: Gestión completa de pedidos y productos
- **Sistema de Autenticación**: JWT con detección automática de roles
- **Animaciones UI**: Transiciones suaves y micro-interacciones
- **Optimización de Imágenes**: Carga eficiente y lazy loading

---

## 🏗️ ARQUITECTURA DEL SISTEMA

### 📊 Diagrama de Arquitectura
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Django API    │    │   PostgreSQL    │
│   (Frontend)    │◄──►│   (Backend)     │◄──►│   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
    ┌─────────┐            ┌─────────┐            ┌─────────┐
    │Provider │            │  JWT    │            │ Models  │
    │(State)  │            │ Auth    │            │ & Data  │
    └─────────┘            └─────────┘            └─────────┘
```

### 🔄 Flujo de Datos:
1. **Usuario** interactúa con la app Flutter
2. **Provider** gestiona el estado local
3. **API Service** comunica con Django backend
4. **Django** procesa la lógica de negocio
5. **PostgreSQL** almacena los datos
6. **Respuesta** regresa al frontend

---

## 🐍 BACKEND (DJANGO)

### 📁 Estructura del Backend
```
django_backend/
├── delivery_backend/          # Configuración principal
│   ├── settings.py           # Configuraciones del proyecto
│   ├── urls.py              # URLs principales
│   └── wsgi.py              # Configuración WSGI
├── apps/                    # Aplicaciones Django
│   ├── authentication/      # Autenticación y usuarios
│   ├── businesses/         # Gestión de negocios
│   ├── products/           # Gestión de productos
│   ├── orders/             # Gestión de pedidos
│   └── users/              # Modelos de usuario
├── manage.py               # Script de gestión Django
└── requirements.txt        # Dependencias Python
```

### 🔧 Configuración Principal (`settings.py`)

#### **Aplicaciones Instaladas:**
```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',           # Django REST Framework
    'rest_framework_simplejwt', # JWT Authentication
    'corsheaders',             # CORS para Flutter
    'apps.authentication',     # Autenticación personalizada
    'apps.businesses',         # Gestión de negocios
    'apps.products',           # Gestión de productos
    'apps.orders',             # Gestión de pedidos
    'apps.users',              # Usuarios personalizados
]
```

#### **Configuración REST Framework:**
```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}
```

#### **Configuración JWT:**
```python
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
}
```

### 🗄️ Modelos de Base de Datos

#### **Usuario Personalizado (`apps/users/models.py`):**
```python
class User(AbstractUser):
    USER_TYPE_CHOICES = [
        ('customer', 'Cliente'),
        ('business', 'Comerciante'),
        ('admin', 'Administrador'),
    ]
    
    firebase_uid = models.CharField(max_length=128, null=True, blank=True)
    user_type = models.CharField(max_length=10, choices=USER_TYPE_CHOICES, default='customer')
    phone = models.CharField(max_length=15)
    profile_image = models.ImageField(upload_to='profiles/', null=True, blank=True)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

#### **Negocio (`apps/businesses/models.py`):**
```python
class Business(models.Model):
    owner = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=200)
    category = models.ForeignKey(Category, on_delete=models.PROTECT)
    description = models.TextField(blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    phone = models.CharField(max_length=15, blank=True, null=True)
    latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.0)
    image_url = models.ImageField(upload_to='businesses/', null=True, blank=True)
    is_active = models.BooleanField(default=True)
    is_open = models.BooleanField(default=True)
    opening_time = models.TimeField(null=True, blank=True)
    closing_time = models.TimeField(null=True, blank=True)
    tags = models.JSONField(default=list, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

#### **Producto (`apps/products/models.py`):**
```python
class Product(models.Model):
    business = models.ForeignKey(Business, on_delete=models.CASCADE, related_name='products')
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True, null=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    image_url = models.ImageField(upload_to='products/', null=True, blank=True)
    available = models.BooleanField(default=True)
    is_popular = models.BooleanField(default=False)
    preparation_time = models.IntegerField(default=15)  # minutos
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

#### **Pedido (`apps/orders/models.py`):**
```python
class Order(models.Model):
    ORDER_STATUS_CHOICES = [
        ('pending', 'Pendiente'),
        ('in_progress', 'En Proceso'),
        ('delivered', 'Entregado'),
        ('cancelled', 'Cancelado'),
    ]
    
    customer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='orders')
    business = models.ForeignKey(Business, on_delete=models.CASCADE, related_name='orders')
    delivery_address = models.ForeignKey(Address, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=ORDER_STATUS_CHOICES, default='pending')
    subtotal = models.DecimalField(max_digits=10, decimal_places=2)
    delivery_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    tax = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    total = models.DecimalField(max_digits=10, decimal_places=2)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

### 🔌 APIs y Endpoints

#### **Autenticación (`apps/authentication/urls.py`):**
```python
urlpatterns = [
    path('login/', views.login_view, name='login'),
    path('register/', views.register_view, name='register'),
    path('refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('logout/', TokenBlacklistView.as_view(), name='logout'),
]
```

#### **Negocios (`apps/businesses/urls.py`):**
```python
urlpatterns = [
    path('', views.BusinessListView.as_view(), name='business_list'),
    path('categories/', views.CategoryListView.as_view(), name='category_list'),
    path('my-business/', views.my_business, name='my_business'),
    path('<int:pk>/', views.BusinessDetailView.as_view(), name='business_detail'),
]
```

#### **Productos (`apps/products/urls.py`):**
```python
urlpatterns = [
    path('', views.ProductListView.as_view(), name='product_list'),
    path('<int:pk>/', views.ProductDetailView.as_view(), name='product_detail'),
    path('business/<int:business_id>/', views.BusinessProductListView.as_view(), name='business_products'),
]
```

#### **Pedidos (`apps/orders/urls.py`):**
```python
urlpatterns = [
    path('', views.OrderListView.as_view(), name='order_list'),
    path('<int:pk>/', views.OrderDetailView.as_view(), name='order_detail'),
    path('create/', views.OrderListView.as_view(), name='order_create'),
]
```

### 🔐 Sistema de Autenticación

#### **Login Endpoint:**
```python
@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    email = request.data.get('email')
    password = request.data.get('password')
    
    user = authenticate(request, username=email, password=password)
    if user:
        tokens = RefreshToken.for_user(user)
        return Response({
            'tokens': {
                'access': str(tokens.access_token),
                'refresh': str(tokens),
            },
            'user': {
                'id': user.id,
                'name': user.get_full_name(),
                'email': user.email,
                'user_type': user.user_type,
            }
        })
    return Response({'error': 'Credenciales inválidas'}, status=401)
```

#### **Registro Endpoint:**
```python
@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        tokens = RefreshToken.for_user(user)
        return Response({
            'tokens': {
                'access': str(tokens.access_token),
                'refresh': str(tokens),
            },
            'user': {
                'id': user.id,
                'name': user.get_full_name(),
                'email': user.email,
                'user_type': user.user_type,
            }
        }, status=201)
    return Response(serializer.errors, status=400)
```

---

## 📱 FRONTEND (FLUTTER)

### 📁 Estructura del Frontend
```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── config/                   # Configuraciones
│   ├── category_config.dart  # Configuración de categorías
│   └── mapbox_config.dart    # Configuración de mapas
├── models/                   # Modelos de datos
│   ├── user.dart            # Modelo de usuario
│   ├── business.dart        # Modelo de negocio
│   ├── product.dart         # Modelo de producto
│   ├── order.dart           # Modelo de pedido
│   └── category.dart        # Modelo de categoría
├── providers/               # Gestión de estado (Provider)
│   ├── auth_provider.dart   # Estado de autenticación
│   ├── business_provider.dart # Estado de negocios
│   ├── community_store_provider.dart # Estado de la tienda
│   ├── customer_provider.dart # Estado del cliente
│   └── theme_provider.dart  # Estado del tema
├── screens/                 # Pantallas de la aplicación
│   ├── auth/               # Pantallas de autenticación
│   ├── business/           # Pantallas de negocios
│   ├── customer/           # Pantallas de clientes
│   └── admin/              # Pantallas de administración
├── services/               # Servicios y APIs
│   ├── api_service.dart    # Servicio principal de API
│   ├── image_service.dart  # Servicio de imágenes
│   └── notification_service.dart # Servicio de notificaciones
├── widgets/                # Widgets reutilizables
│   ├── app_animations.dart # Sistema de animaciones
│   ├── optimized_image.dart # Widgets de imágenes optimizadas
│   └── animated_components.dart # Componentes animados
└── utils/                   # Utilidades
    └── navigation_transitions.dart # Transiciones de navegación
```

### 🎨 Sistema de Animaciones (`lib/widgets/app_animations.dart`)

#### **Clase Principal:**
```dart
class AppAnimations {
  // Duración estándar de animaciones
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Curvas de animación
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
}
```

#### **Animaciones Disponibles:**
- **fadeIn**: Desvanecimiento suave
- **slideIn**: Deslizamiento desde diferentes direcciones
- **scaleIn**: Escalado con efecto elástico
- **rotateIn**: Rotación suave
- **fadeSlideIn**: Combinación de fade + slide
- **pulse**: Efecto de pulso
- **shimmer**: Efecto de carga
- **bounceButton**: Botón con efecto bounce
- **staggeredList**: Lista con delay escalonado
- **pageTransition**: Transición de página completa

#### **Widgets Animados:**
- **AnimatedButton**: Botón con animación de escala
- **AnimatedCard**: Tarjeta con fade + slide

### 🔄 Gestión de Estado (Provider)

#### **AuthProvider (`lib/providers/auth_provider.dart`):**
```dart
class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  UserType _userType = UserType.customer;
  String _userId = '';
  User? _currentUser;
  String? _token;

  // Detección automática de tipo de usuario
  Future<void> _detectUserType() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/businesses/my-business/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _userType = UserType.business;
      } else if (response.statusCode == 404) {
        _userType = UserType.customer;
      } else {
        _userType = UserType.customer;
      }
    } catch (e) {
      _userType = UserType.customer;
    }
  }
}
```

#### **BusinessProvider (`lib/providers/business_provider.dart`):**
```dart
class BusinessProvider with ChangeNotifier {
  final List<Product> _products = [];
  final List<Order> _orders = [];
  final List<Business> _businesses = [];
  String? _token;

  // Cargar pedidos del negocio
  Future<void> loadOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/orders/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _orders = (data['results'] as List)
            .map((order) => Order.fromJson(order))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al cargar pedidos: $e');
    }
  }
}
```

### 🌐 Servicio de API (`lib/services/api_service.dart`)

#### **Configuración Base:**
```dart
class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  String? _djangoToken;

  void setDjangoToken(String token) {
    _djangoToken = token;
  }

  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_djangoToken != null) 'Authorization': 'Bearer $_djangoToken',
      ...?headers,
    };

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders).timeout(
            const Duration(seconds: 10),
          );
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          ).timeout(const Duration(seconds: 10));
          break;
        // ... otros métodos
      }
      return response;
    } catch (e) {
      debugPrint('Error en API request: $e');
      rethrow;
    }
  }
}
```

### 🎨 Sistema de Categorías (`lib/config/category_config.dart`)

#### **Mapeo de Categorías:**
```dart
class CategoryConfig {
  static const Map<String, List<String>> categoryMapping = {
    'food': [
      'Restaurante', 'Cafetería', 'Pizzería', 'Comida Rápida',
      'Postres', 'Bebidas', 'Carnicería', 'Panadería',
    ],
    'groceries': [
      'Supermercado', 'Abarrotes', 'Frutas y Verduras',
      'Carnicería', 'Panadería',
    ],
    'pharmacy': [
      'Farmacia', 'Óptica', 'Laboratorio',
    ],
    'electronics': [
      'Electrónicos', 'Computadoras', 'Teléfonos', 'Reparaciones',
    ],
    'fashion': [
      'Ropa', 'Calzado', 'Joyería', 'Relojes',
    ],
    'home': [
      'Hogar', 'Decoración', 'Muebles', 'Jardín',
    ],
    'hardware': [
      'Ferretería', 'Construcción', 'Plomería', 'Electricidad',
    ],
    'beauty': [
      'Belleza', 'Salón', 'Spa', 'Gimnasio',
    ],
    'automotive': [
      'Automotriz', 'Taller', 'Gasolinera',
    ],
    'services': [
      'Abogados', 'Contadores', 'Seguros', 'Inmobiliaria',
      'Educación', 'Librería', 'Fotografía', 'Impresiones', 'Lavandería',
    ],
  };
}
```

---

## ⚙️ FUNCIONALIDADES PRINCIPALES

### 👤 Sistema de Usuarios Multi-Rol

#### **Tipos de Usuario:**
1. **Cliente (`customer`)**
   - Hacer pedidos
   - Ver historial de pedidos
   - Gestionar direcciones
   - Calificar negocios

2. **Dueño de Negocio (`business`)**
   - Dashboard de gestión
   - Gestionar productos
   - Recibir y procesar pedidos
   - Ver estadísticas

3. **Administrador (`admin`)**
   - Panel de administración
   - Gestionar usuarios
   - Moderar contenido
   - Ver métricas globales

#### **Detección Automática de Roles:**
```dart
// En AuthProvider
Future<void> _detectUserType() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/businesses/my-business/'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      _userType = UserType.business; // Usuario tiene negocio
    } else if (response.statusCode == 404) {
      _userType = UserType.customer; // Usuario es cliente
    }
  } catch (e) {
    _userType = UserType.customer; // Error, asumir cliente
  }
}
```

### 🏪 Dashboard de Negocios

#### **Funcionalidades del Dashboard:**
1. **Pestaña de Pedidos**
   - Lista de pedidos recibidos
   - Estados: Pendiente, En Proceso, Entregado, Cancelado
   - Acciones: Aceptar, Rechazar, Marcar como entregado
   - Información detallada del cliente y productos

2. **Pestaña de Productos**
   - Lista de productos del negocio
   - Agregar nuevos productos
   - Editar productos existentes
   - Eliminar productos
   - Gestión de disponibilidad

3. **Pestaña de Estadísticas**
   - Métricas de ventas
   - Pedidos por día/semana/mes
   - Productos más vendidos
   - Análisis de rendimiento

#### **Código del Dashboard:**
```dart
class BusinessHomeScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Negocio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Estadísticas'),
        ],
      ),
    );
  }
}
```

### 🛒 Sistema de Pedidos

#### **Flujo de Pedidos:**
1. **Cliente** selecciona productos del negocio
2. **Sistema** calcula totales (subtotal + delivery + tax)
3. **Cliente** confirma pedido con dirección
4. **Negocio** recibe notificación del pedido
5. **Negocio** acepta/rechaza el pedido
6. **Sistema** actualiza estado del pedido
7. **Cliente** recibe notificaciones de cambios

#### **Modelo de Pedido:**
```dart
class Order {
  final int id;
  final String customerName;
  final String businessName;
  final String deliveryAddress;
  final List<OrderItem> products;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.customerName,
    required this.businessName,
    required this.deliveryAddress,
    required this.products,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

### 📱 Optimización de Imágenes

#### **Widget OptimizedImage:**
```dart
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }
}
```

---

## 📁 ESTRUCTURA DE ARCHIVOS

### 🐍 Backend (Django)
```
django_backend/
├── delivery_backend/          # Configuración principal
│   ├── __init__.py
│   ├── settings.py           # Configuraciones del proyecto
│   ├── urls.py              # URLs principales
│   ├── wsgi.py              # Configuración WSGI
│   └── asgi.py              # Configuración ASGI
├── apps/                    # Aplicaciones Django
│   ├── authentication/      # Autenticación y usuarios
│   │   ├── __init__.py
│   │   ├── models.py        # Modelos de autenticación
│   │   ├── views.py         # Vistas de autenticación
│   │   ├── serializers.py   # Serializers de autenticación
│   │   ├── urls.py          # URLs de autenticación
│   │   └── firebase_auth.py # Integración Firebase (deshabilitada)
│   ├── businesses/          # Gestión de negocios
│   │   ├── __init__.py
│   │   ├── models.py        # Modelos de negocios y categorías
│   │   ├── views.py         # Vistas de negocios
│   │   ├── serializers.py   # Serializers de negocios
│   │   ├── urls.py          # URLs de negocios
│   │   └── tests.py         # Tests de negocios
│   ├── products/            # Gestión de productos
│   │   ├── __init__.py
│   │   ├── models.py        # Modelos de productos
│   │   ├── views.py         # Vistas de productos
│   │   ├── serializers.py   # Serializers de productos
│   │   ├── urls.py          # URLs de productos
│   │   └── tests.py         # Tests de productos
│   ├── orders/              # Gestión de pedidos
│   │   ├── __init__.py
│   │   ├── models.py        # Modelos de pedidos
│   │   ├── views.py         # Vistas de pedidos
│   │   ├── serializers.py   # Serializers de pedidos
│   │   ├── urls.py          # URLs de pedidos
│   │   └── tests.py         # Tests de pedidos
│   └── users/               # Usuarios personalizados
│       ├── __init__.py
│       ├── models.py        # Modelo de usuario personalizado
│       ├── views.py         # Vistas de usuarios
│       ├── serializers.py   # Serializers de usuarios
│       └── urls.py          # URLs de usuarios
├── manage.py                # Script de gestión Django
├── requirements.txt         # Dependencias Python
├── create_test_data.py      # Script para crear datos de prueba
├── create_diverse_categories.py # Script para crear categorías
└── update_business_categories.py # Script para actualizar categorías
```

### 📱 Frontend (Flutter)
```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── config/                   # Configuraciones
│   ├── category_config.dart  # Configuración de categorías
│   └── mapbox_config.dart    # Configuración de mapas
├── models/                   # Modelos de datos
│   ├── user.dart            # Modelo de usuario
│   ├── business.dart        # Modelo de negocio
│   ├── product.dart         # Modelo de producto
│   ├── order.dart           # Modelo de pedido
│   ├── category.dart        # Modelo de categoría
│   ├── cart_item.dart       # Modelo de item del carrito
│   └── address.dart         # Modelo de dirección
├── providers/               # Gestión de estado (Provider)
│   ├── auth_provider.dart   # Estado de autenticación
│   ├── business_provider.dart # Estado de negocios
│   ├── community_store_provider.dart # Estado de la tienda
│   ├── customer_provider.dart # Estado del cliente
│   └── theme_provider.dart  # Estado del tema
├── screens/                 # Pantallas de la aplicación
│   ├── auth/               # Pantallas de autenticación
│   │   ├── user_type_router.dart # Router de tipos de usuario
│   │   └── register_screen.dart # Pantalla de registro
│   ├── business/           # Pantallas de negocios
│   │   ├── business_home_screen.dart # Dashboard principal
│   │   ├── business_onboarding_screen.dart # Onboarding de negocio
│   │   ├── business_detail_screen.dart # Detalle del negocio
│   │   ├── business_map_screen.dart # Mapa del negocio
│   │   ├── business_registration_screen.dart # Registro de negocio
│   │   └── product_management_screen.dart # Gestión de productos
│   ├── customer/           # Pantallas de clientes
│   │   ├── customer_home_screen.dart # Pantalla principal del cliente
│   │   ├── customer_profile_screen.dart # Perfil del cliente
│   │   ├── customer_settings_screen.dart # Configuraciones
│   │   └── customer_support_screen.dart # Soporte al cliente
│   ├── admin/              # Pantallas de administración
│   │   └── admin_home_screen.dart # Dashboard de administrador
│   ├── main_navigation.dart # Navegación principal
│   ├── cart_screen.dart    # Pantalla del carrito
│   ├── checkout_screen.dart # Pantalla de checkout
│   ├── orders_screen.dart  # Pantalla de pedidos
│   ├── favorites_screen.dart # Pantalla de favoritos
│   ├── search_screen.dart  # Pantalla de búsqueda
│   ├── profile_screen.dart # Pantalla de perfil
│   ├── notifications_screen.dart # Pantalla de notificaciones
│   ├── address_management_screen.dart # Gestión de direcciones
│   ├── address_selection_screen.dart # Selección de direcciones
│   └── test_screen.dart    # Pantalla de pruebas
├── services/               # Servicios y APIs
│   ├── api_service.dart    # Servicio principal de API
│   ├── image_service.dart  # Servicio de imágenes
│   ├── notification_service.dart # Servicio de notificaciones
│   ├── firebase_auth_service.dart # Servicio de autenticación Firebase
│   └── location_service.dart # Servicio de ubicación
├── widgets/                # Widgets reutilizables
│   ├── app_animations.dart # Sistema de animaciones
│   ├── optimized_image.dart # Widgets de imágenes optimizadas
│   ├── animated_components.dart # Componentes animados
│   ├── advanced_effects.dart # Efectos avanzados
│   ├── advanced_visual_effects.dart # Efectos visuales avanzados
│   ├── improved_buttons.dart # Botones mejorados
│   └── delivery_map.dart   # Widget de mapa de entrega
├── themes/                 # Temas de la aplicación
├── utils/                  # Utilidades
│   └── navigation_transitions.dart # Transiciones de navegación
└── documentacion.text      # Documentación adicional
```

---

## 🚀 CONFIGURACIÓN Y DESPLIEGUE

### 🐍 Configuración del Backend

#### **1. Instalación de Dependencias:**
```bash
cd django_backend
pip install -r requirements.txt
```

#### **2. Configuración de Base de Datos:**
```python
# En settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'delivery_app_db',
        'USER': 'postgres',
        'PASSWORD': 'password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

#### **3. Migraciones:**
```bash
python manage.py makemigrations
python manage.py migrate
```

#### **4. Crear Superusuario:**
```bash
python manage.py createsuperuser
```

#### **5. Cargar Datos de Prueba:**
```bash
python create_test_data.py
python create_diverse_categories.py
```

#### **6. Ejecutar Servidor:**
```bash
python manage.py runserver
```

### 📱 Configuración del Frontend

#### **1. Instalación de Dependencias:**
```bash
flutter pub get
```

#### **2. Configuración de Firebase (Opcional):**
```bash
flutterfire configure
```

#### **3. Ejecutar Aplicación:**
```bash
flutter run
```

### 🔧 Variables de Entorno

#### **Backend (.env):**
```env
DEBUG=True
SECRET_KEY=your-secret-key
DATABASE_URL=postgresql://user:password@localhost:5432/delivery_app_db
ALLOWED_HOSTS=localhost,127.0.0.1
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
```

#### **Frontend (lib/config/api_config.dart):**
```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000/api';
  static const String webSocketUrl = 'ws://localhost:8000/ws';
  static const int timeoutSeconds = 10;
}
```

---

## 🧪 TESTING

### 🐍 Tests del Backend

#### **Tests de Modelos:**
```python
class OrderModelTestCase(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.business = Business.objects.create(
            owner=self.user,
            name='Test Business',
            category=self.category
        )

    def test_order_creation(self):
        order = Order.objects.create(
            customer=self.user,
            business=self.business,
            delivery_address=self.address,
            subtotal=25.00,
            delivery_fee=5.00,
            tax=3.00,
            total=33.00
        )
        self.assertEqual(order.status, 'pending')
        self.assertEqual(order.total, 33.00)
```

#### **Tests de APIs:**
```python
class OrderAPITestCase(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.token = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token.access_token}')

    def test_create_order(self):
        data = {
            'business': self.business.id,
            'delivery_address': 'Test Address',
            'items': [
                {
                    'product': self.product.id,
                    'quantity': 2,
                    'price': 15.00
                }
            ],
            'notes': 'Test order'
        }
        response = self.client.post('/api/orders/', data, format='json')
        self.assertEqual(response.status_code, 201)
```

### 📱 Tests del Frontend

#### **Tests de Widgets:**
```dart
void main() {
  group('AnimatedButton Tests', () {
    testWidgets('should animate on tap', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedButton(
            onPressed: () => tapped = true,
            child: Text('Test Button'),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedButton));
      await tester.pump();
      
      expect(tapped, true);
    });
  });
}
```

#### **Tests de Providers:**
```dart
void main() {
  group('AuthProvider Tests', () {
    test('should detect user type correctly', () async {
      final provider = AuthProvider();
      
      // Mock successful business API response
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response('{"id": 1, "name": "Test Business"}', 200),
      );
      
      await provider.login('business@test.com', 'password');
      
      expect(provider.userType, UserType.business);
    });
  });
}
```

---

## 🔮 PRÓXIMAS MEJORAS

### 🎯 Funcionalidades Pendientes

#### **1. 🗺️ Mapas Reales**
- Integración con Google Maps o Mapbox
- Tracking en tiempo real de entregas
- Geocodificación de direcciones
- Optimización de rutas de entrega

#### **2. 💳 Métodos de Pago**
- Integración con Stripe/PayPal
- Pagos con tarjeta de crédito/débito
- Pagos móviles (Apple Pay, Google Pay)
- Sistema de wallets digitales

#### **3. 🔔 Notificaciones Push**
- Notificaciones para nuevos pedidos
- Alertas de estado de entrega
- Notificaciones promocionales
- Configuración de preferencias

#### **4. 📊 Dashboard Avanzado**
- Gráficos de ventas interactivos
- Análisis de tendencias
- Reportes exportables (PDF/Excel)
- Métricas de rendimiento en tiempo real

#### **5. 🤖 Inteligencia Artificial**
- Recomendaciones personalizadas
- Predicción de demanda
- Optimización de inventario
- Chatbot de soporte

#### **6. 🌐 Multi-idioma**
- Soporte para múltiples idiomas
- Localización de contenido
- Adaptación cultural
- Traducción automática

#### **7. 📱 Funcionalidades Móviles**
- Cámara para escanear códigos QR
- Geolocalización automática
- Modo offline con sincronización
- Integración con contactos

#### **8. 🔒 Seguridad Avanzada**
- Autenticación de dos factores
- Encriptación end-to-end
- Auditoría de transacciones
- Cumplimiento GDPR

### 🚀 Optimizaciones Técnicas

#### **1. Performance**
- Lazy loading de imágenes
- Caché inteligente
- Compresión de datos
- Optimización de consultas

#### **2. Escalabilidad**
- Microservicios
- Load balancing
- CDN para assets
- Base de datos distribuida

#### **3. Monitoreo**
- Logging centralizado
- Métricas de performance
- Alertas automáticas
- Dashboard de salud del sistema

---

## 📞 CONTACTO Y SOPORTE

### 👨‍💻 Desarrollo
- **Tecnologías**: Flutter, Django, PostgreSQL
- **Arquitectura**: REST API, Provider Pattern
- **Despliegue**: Docker, AWS/GCP

### 📚 Recursos Adicionales
- [Documentación Flutter](https://flutter.dev/docs)
- [Documentación Django](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Provider Pattern](https://pub.dev/packages/provider)

### 🐛 Reporte de Bugs
Para reportar bugs o solicitar nuevas funcionalidades, crear un issue en el repositorio del proyecto.

---

**📝 Documentación generada automáticamente - Última actualización: $(date)**

**🎯 Proyecto Delivery App - Sistema completo de delivery con gestión multi-rol**
