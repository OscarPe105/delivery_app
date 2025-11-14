# 🔥 Configuración de Firebase para Delivery App

## 📋 Pasos para Configurar Firebase

### 1. Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Crear proyecto"
3. Nombra tu proyecto: `delivery-app-community`
4. Habilita Google Analytics (opcional)
5. Selecciona tu cuenta de Google Cloud

### 2. Configurar Autenticación

1. En el panel lateral, ve a "Authentication"
2. Haz clic en "Comenzar"
3. Ve a la pestaña "Sign-in method"
4. Habilita los siguientes proveedores:
   - **Email/Password**
   - **Google** (opcional)
   - **Teléfono** (opcional)

### 3. Configurar Firestore Database

1. Ve a "Firestore Database"
2. Haz clic en "Crear base de datos"
3. Selecciona "Iniciar en modo de prueba"
4. Elige una ubicación (us-central o la más cercana)

### 4. Configurar Storage

1. Ve a "Storage"
2. Haz clic en "Comenzar"
3. Acepta las reglas de seguridad
4. Elige la misma ubicación que Firestore

### 5. Configurar Cloud Messaging

1. Ve a "Cloud Messaging"
2. Genera o registra la **clave pública VAPID** en la sección "Configuración de aplicaciones web"
3. Descarga el archivo de configuración para web si aún no lo has hecho

### 6. Obtener Credenciales

#### Para Android:
1. Ve a "Configuración del proyecto" (ícono de engranaje)
2. Haz clic en "Agregar app" > "Android"
3. **Nombre del paquete**: `com.example.delivery_app` (ajusta según tu proyecto)
4. Descarga el archivo `google-services.json`
5. Colócalo en `android/app/google-services.json`

#### Para iOS:
1. Haz clic en "Agregar app" > "iOS"
2. **ID del paquete**: `com.example.deliveryApp` (ajusta según tu proyecto)
3. Descarga el archivo `GoogleService-Info.plist`
4. Colócalo en `ios/Runner/GoogleService-Info.plist`

## 🌐 Configuración específica para Flutter Web

### 1. Service worker para Firebase Messaging

1. Crea (o actualiza) `web/firebase-messaging-sw.js` con:
   ```js
   importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
   importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

   firebase.initializeApp({
     apiKey: 'AIzaSyB-dcsAHoET-rg21-C-T0qQIaoxLYqgFTA',
     appId: '1:397640943349:web:46f26f58525316e2a5a7bc',
     messagingSenderId: '397640943349',
     projectId: 'delivery-app-15f53',
     storageBucket: 'delivery-app-15f53.appspot.com',
   });

   const messaging = firebase.messaging();

   messaging.onBackgroundMessage((payload) => {
     const { title, body } = payload.notification ?? {};
     self.registration.showNotification(title ?? 'Nuevo mensaje', {
       body: body ?? 'Tienes una nueva notificación',
       icon: '/icons/Icon-192.png',
     });
   });
   ```
2. Reinicia `flutter run -d chrome` después de modificar el service worker para que el navegador lo recargue.

### 2. Inicialización en `firebase_service.dart`

- `FirebaseService.initialize()` ya evita habilitar Analytics en web para prevenir el error 404 de configuración.
- `FirebaseService._setupMessaging()` obtiene el token web con `FirebaseMessaging.instance.getToken(vapidKey: _webVapidKey)` y sólo se suscribe a tópicos en Android/iOS.
- Revisa `lib/services/firebase_service.dart` si necesitas replicar esta lógica en otro proyecto.

### 3. Clave VAPID

1. Copia la clave pública VAPID desde **Firebase Console → Project settings → Cloud Messaging → Web push certificates**.
2. Declárala en tu código:
   ```dart
   const String _webVapidKey =
       'BEBmZEF5QDOX41JPuZBoovAlWqlYUwhvYehEycFPCcXG7-R6qcHYCLbmD28N9SQ0ZMW916IKKPotuWm6J-FLBC4';
   ```
3. Úsala al solicitar el token (sólo en web):
   ```dart
   final token = await FirebaseMessaging.instance.getToken(
     vapidKey: kIsWeb ? _webVapidKey : null,
   );
   ```

### 4. Configuración de CORS en Firebase Storage

Para servir imágenes en Flutter web sin errores de CORS, habilita los encabezados correspondientes en el bucket `delivery-app-15f53.firebasestorage.app`.

1. Instala Google Cloud CLI (elige una ruta con permisos de usuario, por ejemplo `C:\Users\arman\AppData\Local\Google\Cloud SDK`).
2. Inicializa la CLI y selecciona el proyecto:
   ```powershell
   gcloud init
   ```
3. Crea `cors.json` en la raíz del repo con:
   ```json
   [
     {
       "origin": [
         "http://localhost:5000",
         "http://localhost:61303",
         "http://localhost:61921",
         "http://localhost:62657"
       ],
       "method": ["GET", "POST", "PUT", "HEAD"],
       "responseHeader": ["Content-Type", "Authorization"],
       "maxAgeSeconds": 3600
     }
   ]
   ```
4. Aplica la configuración (si la sesión no encuentra `gsutil`, añade temporalmente la ruta con ` $env:Path += ";$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin"`):
   ```powershell
   gsutil cors set cors.json gs://delivery-app-15f53.firebasestorage.app
   ```
5. Ejecuta Flutter web siempre con un puerto fijo (por ejemplo 5000) para que coincida con la configuración CORS:
   ```bash
   flutter run -d chrome --web-port 5000
   ```
6. Vuelve a subir las imágenes para obtener URLs `...firebasestorage.app...` y verifica que ya se cargan sin bloqueos.

### 5. Metadata de imágenes

`lib/services/firebase_storage_service.dart` establece `SettableMetadata(contentType: 'image/jpeg')` para todos los uploads (usuarios, negocios, productos), evitando problemas de MIME en web.

## 🔧 Configuración de Variables de Entorno

Actualiza tu archivo `.env` con:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=tu-proyecto-firebase-id
FIREBASE_PRIVATE_KEY_ID=tu-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\ntu-private-key\n-----END PRIVATE KEY-----"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@tu-proyecto.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=tu-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_STORAGE_BUCKET=tu-proyecto.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=tu-sender-id
FIREBASE_APP_ID=tu-app-id
```

## 📱 Configuración en Flutter

### 1. Agregar Dependencias

Actualiza tu `pubspec.yaml`:

```yaml
dependencies:
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_messaging: ^14.7.10
  firebase_analytics: ^10.7.4
  
  # Para notificaciones
  flutter_local_notifications: ^16.3.2
  
  # Para imágenes
  image_picker: ^1.0.4
```

### 2. Configurar Android

En `android/app/build.gradle`, agrega:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### 3. Configurar iOS

En `ios/Runner/Info.plist`, agrega:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>tu-reversed-client-id</string>
        </array>
    </dict>
</array>
```

### 4. Ajustar `firebase_options.dart`

Si usaste FlutterFire CLI antes de noviembre de 2023 es probable que el archivo generado haya dejado `storageBucket: '...appspot.com'`. Actualízalo a:

```dart
storageBucket: 'delivery-app-15f53.firebasestorage.app'
```

Hazlo para todas las plataformas definidas (web, android, ios) para que el SDK apunte al bucket canonical y respete la política CORS aplicada.

## 🚀 Funcionalidades Implementadas

### ✅ Autenticación Firebase
- Login/registro con email y contraseña
- Tokens seguros administrados por Firebase

### ✅ Firestore Database
- Sincronización en tiempo real
- Backup de datos críticos
- Cache local

### ✅ Firebase Storage
- Subida de imágenes de perfil
- Imágenes de productos y negocios
- Optimización automática

### ✅ Push Notifications
- Notificaciones de pedidos
- Actualizaciones de estado
- Notificaciones promocionales

### ✅ Analytics
- Tracking de eventos
- Métricas de uso
- Análisis de comportamiento

## 🔒 Seguridad

### Reglas de Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios solo pueden leer/escribir sus propios datos
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Negocios públicos para lectura
    match /businesses/{businessId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.ownerId;
    }
    
    // Productos públicos para lectura
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Reglas de Storage

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /businesses/{businessId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /products/{productId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 📊 Estructura de Datos en Firestore

### Colección `users`
```javascript
{
  uid: "firebase-uid",
  email: "usuario@example.com",
  name: "Nombre Usuario",
  phone: "+1234567890",
  userType: "customer", // o "business"
  profileImage: "https://storage...",
  addresses: [...],
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### Colección `businesses`
```javascript
{
  id: "business-id",
  ownerId: "firebase-uid",
  name: "Nombre Negocio",
  category: "restaurant",
  description: "Descripción...",
  address: "Dirección...",
  location: {
    latitude: 19.4326,
    longitude: -99.1332
  },
  images: [...],
  isActive: true,
  isOpen: true,
  rating: 4.5,
  createdAt: timestamp
}
```

## 🔄 Flujo de Integración

1. **Usuario se registra** → Firebase Auth
2. **Datos sincronizados** → Firestore
3. **Notificaciones** → Firebase Cloud Messaging
4. **Archivos** → Firebase Storage

## 📈 Beneficios de Firebase

- ✅ **Autenticación robusta** con múltiples proveedores
- ✅ **Base de datos en tiempo real** para actualizaciones instantáneas
- ✅ **Almacenamiento escalable** para imágenes y archivos
- ✅ **Notificaciones push** nativas
- ✅ **Analytics integrado** para métricas
- ✅ **Sincronización offline** automática
- ✅ **Escalabilidad automática** sin configuración adicional

## 🚀 Próximos Pasos

1. **Configura Firebase Console** siguiendo esta guía
2. **Descarga los archivos de configuración**
3. **Actualiza las dependencias** en Flutter
4. **Configura las variables de entorno**
5. **Prueba la aplicación** en los entornos deseados

¡Firebase está listo para potenciar tu aplicación de delivery! 🚀
