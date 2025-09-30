class MapboxConfig {
  // Reemplaza con tu NUEVO token público
  static const String accessToken = 'pk.eyJ1Ijoib3NjYXJlbGlhczQxNCIsImEiOiJjbWZuOTlncDcwYXdxMmxvaHRtNHZlYmE0In0.SQeR4XSGCE1LqwnHyDcknQ';
  
  // Estilos de mapa disponibles
  static const String streetsStyle = 'mapbox://styles/mapbox/streets-v11';
  static const String satelliteStyle = 'mapbox://styles/mapbox/satellite-v9';
  static const String lightStyle = 'mapbox://styles/mapbox/light-v10';
  static const String darkStyle = 'mapbox://styles/mapbox/dark-v10';
  
  // Configuración por defecto
  static const String defaultStyle = streetsStyle;
  
  // Coordenadas por defecto (Honduras)
  static const double defaultLatitude = 14.0723;
  static const double defaultLongitude = -87.1921;
  static const double defaultZoom = 10.0;
}