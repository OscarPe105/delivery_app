# 🗺️ Configuración de Google Maps

## 📋 Pasos para Configurar Google Maps API

### 1. **Crear Proyecto en Google Cloud Console**
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la facturación para el proyecto

### 2. **Habilitar APIs Necesarias**
Habilita las siguientes APIs en tu proyecto:
- **Maps SDK for Android**
- **Maps SDK for iOS** 
- **Maps JavaScript API** (para web)
- **Geocoding API**
- **Places API** (opcional, para búsquedas avanzadas)

### 3. **Crear API Key**
1. Ve a "Credenciales" en el menú lateral
2. Haz clic en "Crear credenciales" → "Clave de API"
3. Copia la API key generada

### 4. **Configurar Restricciones de Seguridad**
**IMPORTANTE**: Configura restricciones para proteger tu API key:

#### Restricciones de aplicación:
- **Android**: Agrega tu SHA-1 fingerprint
- **iOS**: Agrega tu Bundle ID
- **Web**: Agrega tu dominio

#### Restricciones de API:
- Selecciona solo las APIs que necesitas
- Evita usar "Sin restricciones"

### 5. **Configurar la Aplicación**

#### Para Flutter:
1. Abre `lib/config/google_maps_config.dart`
2. Reemplaza `YOUR_GOOGLE_MAPS_API_KEY_HERE` con tu API key real:

```dart
static const String apiKey = 'AIzaSyBvOkBw...'; // Tu API key aquí
```

#### Para Android:
1. Abre `android/app/src/main/AndroidManifest.xml`
2. Agrega la API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI"/>
```

#### Para iOS:
1. Abre `ios/Runner/AppDelegate.swift`
2. Agrega la configuración:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("TU_API_KEY_AQUI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 6. **Verificar Configuración**
1. Ejecuta la aplicación
2. Verifica que los mapas se carguen correctamente
3. Prueba la funcionalidad de geolocalización

## 🔒 **Mejores Prácticas de Seguridad**

### ✅ **Hacer:**
- Usar restricciones de API key
- Rotar las API keys regularmente
- Monitorear el uso de la API
- Usar diferentes API keys para desarrollo y producción

### ❌ **No Hacer:**
- Compartir API keys en repositorios públicos
- Usar la misma API key para múltiples proyectos
- Dejar API keys sin restricciones
- Ignorar las alertas de uso excesivo

## 💰 **Costos de Google Maps**

### **APIs Gratuitas (Límites mensuales):**
- **Maps SDK**: 28,000 cargas de mapa
- **Geocoding**: 40,000 solicitudes
- **Places**: 1,000 solicitudes

### **APIs de Pago:**
- **Maps SDK**: $7 por cada 1,000 cargas adicionales
- **Geocoding**: $5 por cada 1,000 solicitudes adicionales
- **Places**: $17 por cada 1,000 solicitudes adicionales

## 🚨 **Solución de Problemas**

### **Error: "API key not found"**
- Verifica que la API key esté configurada correctamente
- Asegúrate de que las APIs estén habilitadas

### **Error: "This API project is not authorized"**
- Verifica las restricciones de aplicación
- Asegúrate de que el SHA-1 fingerprint esté correcto

### **Mapas no se cargan**
- Verifica la conexión a internet
- Revisa la consola de desarrollador para errores
- Verifica que la API key tenga los permisos correctos

## 📞 **Soporte**

Si tienes problemas con la configuración:
1. Revisa la [documentación oficial de Google Maps](https://developers.google.com/maps/documentation)
2. Consulta el [foro de Google Maps Platform](https://groups.google.com/g/google-maps-js-api-v3)
3. Verifica el estado de las APIs en [Google Cloud Status](https://status.cloud.google.com/)

---

**¡Una vez configurado correctamente, tendrás mapas funcionales en tu aplicación de delivery!** 🎉
