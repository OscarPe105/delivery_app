# 🛒 Delivery App - Aplicación de Delivery Comunitario

Plataforma de delivery que conecta negocios locales con clientes mediante una aplicación Flutter (Android, iOS, Web) respaldada 100% por Firebase (Auth, Firestore, Storage, Cloud Messaging y Analytics).

## 📋 Tabla de Contenidos

- [Descripción del Proyecto](#descripción-del-proyecto)
- [Tecnologías Utilizadas](#tecnologías-utilizadas)
- [Requisitos Previos](#requisitos-previos)
- [Instalación y Configuración](#instalación-y-configuración)
  - [1. Clonar el Repositorio](#1-clonar-el-repositorio)
  - [2. Instalar Dependencias de Flutter](#2-instalar-dependencias-de-flutter)
  - [3. Configurar Firebase](#3-configurar-firebase)
  - [4. Configurar Google Maps API](#4-configurar-google-maps-api)
  - [5. Crear Índices de Firestore](#5-crear-índices-de-firestore)
  - [6. Ejecutar la Aplicación](#6-ejecutar-la-aplicación)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [APIs y Servicios Necesarios](#apis-y-servicios-necesarios)
- [Configuración de Archivos Clave](#configuración-de-archivos-clave)
- [Troubleshooting](#troubleshooting)
- [Funcionalidades Implementadas](#funcionalidades-implementadas)

## 📱 Descripción del Proyecto

**Delivery App** permite a los usuarios:

- 📍 Explorar negocios locales y sus productos.
- 🛒 Agregar productos al carrito.
- 📦 Realizar pedidos y dar seguimiento en tiempo real.
- 💳 Gestionar direcciones de entrega.
- ⭐ Guardar negocios favoritos.
- 🔔 Recibir notificaciones de estado de pedidos.
- 💬 Chatear con negocios y repartidores.

### Roles del Sistema

- **Cliente**: Busca productos, realiza pedidos y monitorea sus órdenes.
- **Negocio**: Gestiona productos, recibe pedidos y actualiza estados en vivo.
- **Repartidor**: Ve entregas disponibles, acepta pedidos y actualiza estado de entregas.

## 🛠 Tecnologías Utilizadas

```yaml
- Flutter SDK: ^3.0.0
- Provider: ^6.0.5 (estado global)
- Firebase:
  - Auth (Autenticación)
  - Cloud Firestore (Base de datos)
  - Cloud Storage (Almacenamiento de imágenes)
  - Cloud Messaging (Notificaciones push)
  - Analytics (Métricas)
- Google Maps: Mapas y geolocalización
- Geolocator: Ubicación del usuario
- PDF: Generación de comprobantes
```

## ✅ Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- **Flutter SDK** 3.0.0 o superior
  - Verifica: `flutter --version`
  - Instalación: [Flutter Docs](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (incluido con Flutter)
- **Android Studio** (para desarrollo Android)
- **Xcode** (para desarrollo iOS, solo en macOS)
- **Git** para clonar el repositorio
- **Cuenta de Google** para:
  - Firebase Console
  - Google Cloud Platform (para APIs)

## ⚙️ Instalación y Configuración

### 🚀 Setup Rápido (si los archivos de Firebase ya están en el repo)

**Si el repositorio ya incluye los archivos de configuración de Firebase** (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`), el setup es mucho más rápido:

```bash
# 1. Clonar el repositorio
git clone <url-del-repositorio>
cd delivery_app

# 2. Instalar dependencias
flutter pub get

# 3. Verificar que no haya errores
flutter analyze

# 4. Ejecutar la aplicación
flutter run
```

**¡Eso es todo!** Los archivos de Firebase ya están configurados, solo necesitas:
- ✅ Verificar que los índices compuestos estén creados en Firestore (ver sección 5)
- ✅ Configurar Google Maps API key (ver sección 4) si planeas usar mapas

**Nota de Seguridad**: Los archivos de Firebase contienen credenciales sensibles. Si el repositorio es **público**, deberías remover estos archivos y seguir las instrucciones completas de setup abajo.

---

### 📋 Setup Completo (si NO tienes los archivos de Firebase)

Si necesitas configurar Firebase desde cero, sigue estas instrucciones detalladas:

### 1. Clonar el Repositorio

```bash
# Clonar el repositorio
git clone <url-del-repositorio>
cd delivery_app

# Si usas una rama específica
git checkout feature/catalogo-carruseles  # o la rama que necesites
```

### 2. Instalar Dependencias de Flutter

```bash
# Instalar todas las dependencias
flutter pub get

# Verificar que no haya errores
flutter analyze

# Limpiar build anterior (opcional)
flutter clean
```

### 3. Configurar Firebase

Firebase es **esencial** para que la aplicación funcione. Sigue estos pasos:

#### 3.1. Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en **"Agregar proyecto"**
3. Nombre del proyecto: `delivery-app-15f53` (o el que prefieras)
4. Configura Google Analytics (opcional pero recomendado)
5. Completa la configuración

#### 3.2. Registrar Aplicaciones

Para cada plataforma, necesitas registrar la app:

**Android:**
1. En Firebase Console → Configuración del proyecto → Tus apps
2. Haz clic en el ícono de Android
3. **Nombre del paquete**: `com.example.delivery_app` (verifica en `android/app/build.gradle`)
4. Descarga el archivo `google-services.json`
5. Colócalo en: `android/app/google-services.json`

**iOS:**
1. En Firebase Console → Configuración del proyecto → Tus apps
2. Haz clic en el ícono de iOS
3. **Bundle ID**: `com.example.deliveryApp` (verifica en `ios/Runner/Info.plist`)
4. Descarga el archivo `GoogleService-Info.plist`
5. Colócalo en: `ios/Runner/GoogleService-Info.plist`

**Web:**
1. En Firebase Console → Configuración del proyecto → Tus apps
2. Haz clic en el ícono de web (</>)
3. Registra la app con un nombre
4. Copia la configuración que aparece

#### 3.3. Generar `firebase_options.dart`

**Opción A: Usar FlutterFire CLI (Recomendado)**

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase (esto genera firebase_options.dart automáticamente)
flutterfire configure
```

Este comando:
- Detecta tus plataformas (Android, iOS, Web)
- Te permite seleccionar el proyecto de Firebase
- Genera automáticamente `lib/firebase_options.dart`

**Opción B: Configuración Manual**

Si ya tienes los archivos de configuración, puedes crear `lib/firebase_options.dart` manualmente basándote en el archivo existente, pero actualizando las credenciales de tu proyecto.

#### 3.4. Habilitar Servicios de Firebase

En Firebase Console, habilita estos servicios:

1. **Authentication**:
   - Ve a Authentication → Métodos de inicio de sesión
   - Habilita **Correo electrónico/Contraseña**
   - Habilita **Google** (configura el OAuth consent screen)

2. **Firestore Database**:
   - Ve a Firestore Database → Crear base de datos
   - Modo: **Producción** (o Prueba para desarrollo)
   - Región: Elige la más cercana (ej: `us-central`)

3. **Cloud Storage**:
   - Ve a Storage → Empezar
   - Configura las reglas de seguridad
   - Región: La misma que Firestore

4. **Cloud Messaging**:
   - Se habilita automáticamente al usar Firebase

#### 3.5. Configurar Reglas de Seguridad

**Firestore Rules** (`firestore.rules`):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios: Solo pueden leer/escribir su propio documento
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Negocios: Todos pueden leer, solo el dueño puede escribir
    match /businesses/{businessId} {
      allow read: if true;
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.ownerUid;
    }
    
    // Productos: Todos pueden leer
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Pedidos: Cliente y negocio pueden leer/escribir
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
    
    // Entregas: Repartidor y negocio pueden leer/escribir
    match /deliveries/{deliveryId} {
      allow read, write: if request.auth != null;
    }
    
    // Conversaciones: Solo participantes pueden leer/escribir
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.userId1 || 
         request.auth.uid == resource.data.userId2);
    }
  }
}
```

**Storage Rules** (`storage.rules`):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /businesses/{businessId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /products/{productId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 4. Configurar Google Maps API

La aplicación usa Google Maps para mostrar ubicaciones. Necesitas una API key.

#### 4.1. Obtener API Key de Google Maps

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto (o crea uno nuevo)
3. Ve a **APIs y servicios** → **Biblioteca**
4. Habilita estas APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Maps JavaScript API** (para web)
   - **Geocoding API**
   - **Places API** (opcional, para autocompletado de direcciones)

5. Ve a **APIs y servicios** → **Credenciales**
6. Haz clic en **"Crear credenciales"** → **"Clave de API"**
7. Copia la API key generada

#### 4.2. Configurar la API Key

**Android:**
Edita `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI"/>
```

**iOS:**
1. Edita `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

GMSServices.provideAPIKey("TU_API_KEY_AQUI")
```

2. O edita `ios/Runner/Info.plist` y agrega:
```xml
<key>GMSApiKey</key>
<string>TU_API_KEY_AQUI</string>
```

**En el código:**
Edita `lib/config/google_maps_config.dart`:
```dart
static const String apiKey = 'TU_API_KEY_AQUI';
```

**⚠️ IMPORTANTE**: Configura restricciones de la API key en Google Cloud Console para mayor seguridad:
- Restricciones de aplicación (Android: SHA-1, iOS: Bundle ID, Web: dominio)
- Restricciones de API (selecciona solo las APIs necesarias)

### 5. Crear Índices de Firestore

La aplicación necesita índices compuestos en Firestore para consultas eficientes. **Esto es crítico** o verás errores al cargar entregas.

#### 5.1. Índices Necesarios

Ve a Firebase Console → Firestore Database → Índices → Índices compuestos.

Crea estos índices:

**Índice 1: Entregas disponibles**
- **Colección**: `deliveries`
- **Campos**:
  1. `status` - Ascendente
  2. `createdAt` - Descendente
- **Alcance**: Colección

**Índice 2: Entregas asignadas a repartidor**
- **Colección**: `deliveries`
- **Campos**:
  1. `driverId` - Ascendente
  2. `createdAt` - Descendente
- **Alcance**: Colección

**Índice 3: Conversaciones por usuario 1**
- **Colección**: `conversations`
- **Campos**:
  1. `userId1` - Ascendente
  2. `updatedAt` - Descendente
- **Alcance**: Colección

**Índice 4: Conversaciones por usuario 2**
- **Colección**: `conversations`
- **Campos**:
  1. `userId2` - Ascendente
  2. `updatedAt` - Descendente
- **Alcance**: Colección

**Nota**: Los índices pueden tardar varios minutos en crearse. Espera hasta que estén en estado **"Habilitado"**.

#### 5.2. URLs Directas de Creación

Si prefieres, puedes usar estos enlaces (reemplaza `delivery-app-15f53` con tu project ID):

**Índice 1 (Entregas disponibles)**:
```
https://console.firebase.google.com/v1/r/project/delivery-app-15f53/firestore/indexes?create_composite=ClVwcm9qZWN0cy9kZWxpdmVyeS1hcHAtMTVmNTMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2RlbGl2ZXJpZXMvaW5kZXhlcy9fEAEaCgoGc3RhdHVzEAEaDQoJY3JlYXRlZEF0EAEaDAoIX19uYW1lX18QAQ
```

**Índice 2 (Entregas por repartidor)**:
```
https://console.firebase.google.com/v1/r/project/delivery-app-15f53/firestore/indexes?create_composite=ClVwcm9qZWN0cy9kZWxpdmVyeS1hcHAtMTVmNTMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2RlbGl2ZXJpZXMvaW5kZXhlcy9fEAEaDAoIZHJpdmVySWQQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC
```

### 6. Ejecutar la Aplicación

Una vez configurado todo, ejecuta:

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar en dispositivo Android/iOS conectado
flutter run

# Ejecutar en emulador Android
flutter run -d emulator-5554

# Ejecutar en navegador web
flutter run -d chrome

# Ejecutar en modo release (producción)
flutter run --release
```

## 📁 Estructura del Proyecto

```
delivery_app/
├── lib/                     # Código fuente Flutter
│   ├── config/             # Configuraciones (Google Maps, etc.)
│   ├── models/             # Modelos de datos
│   ├── providers/          # Gestión de estado (Provider)
│   ├── screens/            # Pantallas principales
│   │   ├── auth/          # Autenticación
│   │   ├── business/      # Dashboard de negocio
│   │   ├── customer/      # Pantallas de cliente
│   │   ├── driver/        # Dashboard de repartidor
│   │   ├── chat/          # Chat y mensajería
│   │   └── orders/        # Gestión de pedidos
│   ├── services/          # Integraciones Firebase y utilidades
│   ├── widgets/           # Widgets reutilizables
│   ├── themes/            # Temas y colores
│   └── main.dart          # Punto de entrada
├── android/               # Configuración Android
│   └── app/
│       └── google-services.json  # ⚠️ Archivo de Firebase (NO subir a git)
├── ios/                   # Configuración iOS
│   └── Runner/
│       └── GoogleService-Info.plist  # ⚠️ Archivo de Firebase (NO subir a git)
├── web/                   # Archivos específicos para web
│   └── firebase-messaging-sw.js  # Service worker para FCM
├── assets/                # Recursos estáticos (imágenes, iconos)
├── test/                  # Tests unitarios/widget
└── pubspec.yaml           # Dependencias del proyecto
```

## 🔑 APIs y Servicios Necesarios

### Firebase (Requerido)
- ✅ **Authentication**: Email/Password, Google Sign-In
- ✅ **Cloud Firestore**: Base de datos NoSQL
- ✅ **Cloud Storage**: Almacenamiento de imágenes
- ✅ **Cloud Messaging**: Notificaciones push
- ✅ **Analytics**: Métricas y uso

### Google Cloud Platform
- ✅ **Google Maps SDK** (Android, iOS, Web): Mapas y ubicaciones
- ✅ **Geocoding API**: Conversión dirección ↔ coordenadas
- ✅ **Places API** (Opcional): Autocompletado de direcciones

### Costos Estimados
- **Firebase**: Plan Spark (gratis) hasta 50,000 usuarios
- **Google Maps**: 
  - Primeros 28,000 mapas/mes: **Gratis**
  - Adicionales: ~$7 por cada 1,000 mapas
  - Geocoding: Primeros 40,000/mes: **Gratis**

## 📝 Configuración de Archivos Clave

### Archivos que DEBES configurar:

1. **`lib/firebase_options.dart`**
   - Se genera automáticamente con `flutterfire configure`
   - Contiene credenciales de Firebase

2. **`android/app/google-services.json`**
   - Descargar de Firebase Console
   - Colocar en `android/app/`

3. **`ios/Runner/GoogleService-Info.plist`**
   - Descargar de Firebase Console
   - Colocar en `ios/Runner/`

4. **`lib/config/google_maps_config.dart`**
   - Actualizar `apiKey` con tu clave de Google Maps

5. **`android/app/src/main/AndroidManifest.xml`**
   - Verificar que tenga la API key de Google Maps

6. **`ios/Runner/AppDelegate.swift`** (iOS)
   - Agregar inicialización de Google Maps si es necesario

### Archivos que NO debes subir a Git:

Asegúrate de que `.gitignore` incluya:
- `android/app/google-services.json` (contiene credenciales sensibles)
- `ios/Runner/GoogleService-Info.plist` (contiene credenciales sensibles)
- `.env` o archivos con API keys
- `firebase-service-account.json` (si existe)

## 🔧 Troubleshooting

### Error: "Failed to load Firebase options"
- **Solución**: Ejecuta `flutterfire configure` o verifica que `lib/firebase_options.dart` existe.

### Error: "The query requires an index"
- **Solución**: Ve a Firebase Console → Firestore → Índices y crea los índices necesarios (ver sección 5).

### Error: "API key not found" (Google Maps)
- **Solución**: Verifica que la API key esté configurada en:
  - `lib/config/google_maps_config.dart`
  - `android/app/src/main/AndroidManifest.xml` (Android)
  - `ios/Runner/AppDelegate.swift` o `Info.plist` (iOS)

### Error: "Firebase not initialized"
- **Solución**: Verifica que `Firebase.initializeApp()` se llame en `main.dart` antes de usar Firebase.

### La app no compila después de clonar
- **Solución**: 
  1. `flutter clean`
  2. `flutter pub get`
  3. Verifica que todos los archivos de Firebase estén en su lugar
  4. Ejecuta `flutterfire configure` si falta `firebase_options.dart`

### No aparecen las entregas para el repartidor
- **Solución**: Asegúrate de que los índices compuestos de Firestore estén creados (sección 5.1).

## ✨ Funcionalidades Implementadas

- [x] Autenticación con Firebase (Email/Password + Google)
- [x] Gestión completa de negocios y productos
- [x] Carrito de compras y creación de pedidos
- [x] Seguimiento de pedidos en tiempo real (Firestore + FCM)
- [x] Almacenamiento de imágenes en Firebase Storage
- [x] Notificaciones push para cambios de estado
- [x] Chat y mensajería en tiempo real entre cliente, negocio y repartidor
- [x] Sistema de reviews y valoraciones
- [x] Dashboard para negocio con métricas e historial
- [x] Dashboard para repartidor con gestión de entregas
- [x] Generación de comprobantes PDF
- [x] Mapas interactivos con Google Maps
- [x] Geocodificación de direcciones
- [x] UI responsiva para Android, iOS y Web

## 📞 Soporte

Si tienes problemas durante la instalación:

1. Revisa los logs: `flutter run -v` (modo verbose)
2. Verifica la configuración de Firebase en la consola
3. Asegúrate de que todos los índices estén creados
4. Consulta la [documentación oficial de Flutter](https://flutter.dev/docs)
5. Consulta la [documentación oficial de Firebase](https://firebase.google.com/docs)

## 📄 Licencia

Proyecto académico. Uso educativo y demostrativo.

---

**Versión**: 1.0.0+1  
**Última actualización**: Diciembre 2024  
**Estado**: 🚀 Producción Ready (Firebase-first)
