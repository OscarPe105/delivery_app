/// Configuración para Google Maps
class GoogleMapsConfig {
  // IMPORTANTE: Reemplaza esta clave con tu propia API key de Google Maps
  // Para obtener una API key:
  // 1. Ve a https://console.cloud.google.com/
  // 2. Crea un nuevo proyecto o selecciona uno existente
  // 3. Habilita la API de Google Maps
  // 4. Crea credenciales (API key)
  // 5. Configura las restricciones de la API key para seguridad
  
  static const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
  
  // Configuraciones adicionales
  static const double defaultZoom = 15.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;
  
  // Área de cobertura por defecto (en kilómetros)
  static const double defaultDeliveryRadius = 10.0;
  
  // Configuración de marcadores
  static const double markerSize = 1.0;
  static const bool showInfoWindows = true;
  
  // Configuración de controles
  static const bool showZoomControls = true;
  static const bool showMyLocationButton = true;
  static const bool showCompass = true;
  static const bool showMapToolbar = true;
}
