# ✅ Checklist de Configuración - Delivery App

Este checklist te ayuda a configurar el proyecto paso a paso en una nueva máquina.

## 🚀 Setup Rápido (si los archivos de Firebase ya están en el repo)

**Si el repositorio incluye los archivos de Firebase**, el setup es muy rápido:

- [ ] Repositorio clonado
- [ ] `flutter pub get` ejecutado
- [ ] `flutter analyze` sin errores
- [ ] Verificar que los índices de Firestore estén creados (sección 5)
- [ ] (Opcional) Configurar Google Maps API key (sección 4)
- [ ] `flutter run` ejecutado

**¡Listo!** La app debería funcionar inmediatamente.

**⚠️ Nota**: Estos archivos contienen credenciales. Solo úsalos si el repo es **privado** y para uso académico/desarrollo.

---

## 📋 Setup Completo (si NO tienes los archivos de Firebase)

Si necesitas configurar Firebase desde cero, sigue este checklist completo:

## 📋 Antes de Empezar

- [ ] Flutter SDK 3.0+ instalado (`flutter --version`)
- [ ] Android Studio / Xcode instalado (según plataforma)
- [ ] Git instalado
- [ ] Cuenta de Google activa

## 🔧 Configuración Inicial

### Paso 1: Clonar Repositorio
- [ ] Repositorio clonado
- [ ] Branch correcto seleccionado (`git checkout feature/catalogo-carruseles`)
- [ ] Cambiar al directorio del proyecto (`cd delivery_app`)

### Paso 2: Instalar Dependencias
- [ ] Ejecutar `flutter pub get`
- [ ] Verificar sin errores (`flutter analyze`)
- [ ] (Opcional) Ejecutar `flutter clean`

## 🔥 Configuración Firebase

### Paso 3: Proyecto Firebase
- [ ] Proyecto creado en [Firebase Console](https://console.firebase.google.com/)
- [ ] Project ID anotado: `_________________`
- [ ] Google Analytics configurado (opcional)

### Paso 4: Registrar Aplicaciones

**Android:**
- [ ] App Android registrada en Firebase
- [ ] `google-services.json` descargado
- [ ] `google-services.json` colocado en `android/app/`
- [ ] Package name verificado: `com.example.delivery_app`

**iOS (si aplica):**
- [ ] App iOS registrada en Firebase
- [ ] `GoogleService-Info.plist` descargado
- [ ] `GoogleService-Info.plist` colocado en `ios/Runner/`
- [ ] Bundle ID verificado: `com.example.deliveryApp`

**Web (si aplica):**
- [ ] App Web registrada en Firebase
- [ ] Configuración copiada (para uso futuro)

### Paso 5: Generar firebase_options.dart
- [ ] FlutterFire CLI instalado (`dart pub global activate flutterfire_cli`)
- [ ] `flutterfire configure` ejecutado
- [ ] `lib/firebase_options.dart` generado automáticamente
- [ ] Verificar que el archivo contiene tus credenciales

### Paso 6: Habilitar Servicios Firebase
- [ ] **Authentication** habilitado
  - [ ] Método Email/Password activado
  - [ ] Método Google activado (OAuth configurado)
- [ ] **Firestore Database** creado
  - [ ] Modo seleccionado (Producción/Prueba)
  - [ ] Región seleccionada: `_________________`
- [ ] **Cloud Storage** creado
  - [ ] Reglas de seguridad configuradas
- [ ] **Cloud Messaging** verificado (se habilita automáticamente)

### Paso 7: Configurar Reglas de Seguridad
- [ ] Reglas de Firestore configuradas (ver README.md)
- [ ] Reglas de Storage configuradas (ver README.md)
- [ ] Reglas publicadas en Firebase Console

### Paso 8: Crear Índices Compuestos
Ve a Firebase Console → Firestore → Índices → Índices compuestos

- [ ] **Índice 1**: `deliveries` → `status` (ASC) + `createdAt` (DESC)
- [ ] **Índice 2**: `deliveries` → `driverId` (ASC) + `createdAt` (DESC)
- [ ] **Índice 3**: `conversations` → `userId1` (ASC) + `updatedAt` (DESC)
- [ ] **Índice 4**: `conversations` → `userId2` (ASC) + `updatedAt` (DESC)
- [ ] Todos los índices en estado **"Habilitado"** (esperar 1-5 minutos)

## 🗺️ Configuración Google Maps

### Paso 9: Google Cloud Platform
- [ ] Proyecto creado/seleccionado en [Google Cloud Console](https://console.cloud.google.com/)
- [ ] APIs habilitadas:
  - [ ] Maps SDK for Android
  - [ ] Maps SDK for iOS
  - [ ] Maps JavaScript API (para web)
  - [ ] Geocoding API
  - [ ] Places API (opcional)
- [ ] API Key creada: `_________________`
- [ ] Restricciones de API Key configuradas (recomendado)

### Paso 10: Configurar API Key en el Proyecto
- [ ] `lib/config/google_maps_config.dart` actualizado con tu API key
- [ ] `android/app/src/main/AndroidManifest.xml` actualizado con API key
- [ ] (iOS) `ios/Runner/AppDelegate.swift` o `Info.plist` actualizado con API key

## 🚀 Ejecutar Aplicación

### Paso 11: Verificación Final
- [ ] `flutter analyze` sin errores
- [ ] Dispositivo/Emulador conectado (`flutter devices`)
- [ ] Archivos de Firebase en su lugar:
  - [ ] `android/app/google-services.json` (Android)
  - [ ] `ios/Runner/GoogleService-Info.plist` (iOS)
  - [ ] `lib/firebase_options.dart` (todas las plataformas)

### Paso 12: Primera Ejecución
- [ ] Ejecutar `flutter run`
- [ ] App se abre sin errores
- [ ] Login funciona (crear usuario de prueba)
- [ ] Mapas se cargan correctamente
- [ ] No aparecen errores de índices en consola

## 🐛 Troubleshooting

Si encuentras problemas, verifica:

- [ ] Firebase inicializado correctamente (`lib/main.dart`)
- [ ] API keys válidas y sin restricciones excesivas
- [ ] Índices compuestos creados y habilitados
- [ ] Reglas de seguridad permiten operaciones necesarias
- [ ] Permisos de ubicación configurados (AndroidManifest.xml, Info.plist)

## ✅ Verificación de Funcionalidades

Prueba estas funciones básicas:

- [ ] **Autenticación**: Crear cuenta, iniciar sesión, Google Sign-In
- [ ] **Mapas**: Ver mapas de negocios, buscar ubicaciones
- [ ] **Firestore**: Crear/leer negocios, productos, pedidos
- [ ] **Storage**: Subir imágenes de perfil/productos
- [ ] **Notificaciones**: Recibir notificaciones push (configurar dispositivo)
- [ ] **Chat**: Enviar mensajes entre usuarios
- [ ] **Entregas**: Ver entregas disponibles (repartidor)

## 📝 Notas Importantes

1. **Nunca subas archivos sensibles a Git**:
   - `google-services.json`
   - `GoogleService-Info.plist`
   - API keys hardcodeadas

2. **Los índices de Firestore pueden tardar varios minutos** en crearse. No ejecutes la app hasta que estén "Habilitados".

3. **Para producción**: 
   - Configura restricciones en API keys
   - Revisa reglas de seguridad de Firebase
   - Usa diferentes proyectos Firebase para dev/prod

---

**Fecha de configuración**: ______________  
**Configurado por**: ______________  
**Proyecto Firebase**: ______________

