import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../config/google_maps_config.dart';

/// Servicio para manejar mapas y geolocalización
class MapService {

  /// Obtener la ubicación actual del usuario
  static Future<Position?> getCurrentLocation() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Obtener ubicación actual
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
      return null;
    }
  }

  /// Convertir dirección a coordenadas
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
    } catch (e) {
      debugPrint('Error convirtiendo dirección a coordenadas: $e');
    }
    return null;
  }

  /// Convertir coordenadas a dirección
  static Future<String?> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
    } catch (e) {
      debugPrint('Error convirtiendo coordenadas a dirección: $e');
    }
    return null;
  }

  /// Calcular distancia entre dos puntos
  static double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Calcular tiempo estimado de entrega (en minutos)
  static int calculateDeliveryTime(LatLng from, LatLng to) {
    double distance = calculateDistance(from, to);
    
    // Estimación: 2 minutos por km en ciudad
    int timeInMinutes = (distance / 1000 * 2).round();
    
    // Mínimo 5 minutos, máximo 60 minutos
    return timeInMinutes.clamp(5, 60);
  }

  /// Verificar si una ubicación está dentro del área de cobertura
  static bool isWithinDeliveryArea(LatLng businessLocation, LatLng customerLocation, double maxDistanceKm) {
    double distance = calculateDistance(businessLocation, customerLocation);
    return distance <= (maxDistanceKm * 1000); // Convertir km a metros
  }

  /// Crear marcador personalizado para el negocio
  static Future<BitmapDescriptor> createBusinessMarker() async {
    // Por ahora usamos el marcador por defecto
    // En el futuro se puede personalizar con un icono específico
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  }

  /// Crear marcador personalizado para el usuario
  static Future<BitmapDescriptor> createUserMarker() async {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }

  /// Obtener la API key de Google Maps
  static String get googleMapsApiKey => GoogleMapsConfig.apiKey;

  /// Configurar la cámara para mostrar múltiples marcadores
  static CameraPosition getCameraPositionForMarkers(List<LatLng> positions) {
    if (positions.isEmpty) {
      return const CameraPosition(
        target: LatLng(19.4326, -99.1332), // Ciudad de México por defecto
        zoom: 10.0,
      );
    }

    if (positions.length == 1) {
      return CameraPosition(
        target: positions.first,
        zoom: 15.0,
      );
    }

    // Calcular el centro y zoom para mostrar todos los marcadores
    double minLat = positions.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = positions.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = positions.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = positions.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    double centerLat = (minLat + maxLat) / 2;
    double centerLng = (minLng + maxLng) / 2;

    // Calcular zoom basado en la distancia
    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;
    double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    double zoom = 10.0;
    if (maxDiff > 0.1) zoom = 8.0;
    else if (maxDiff > 0.05) zoom = 10.0;
    else if (maxDiff > 0.01) zoom = 12.0;
    else zoom = 14.0;

    return CameraPosition(
      target: LatLng(centerLat, centerLng),
      zoom: zoom,
    );
  }
}
