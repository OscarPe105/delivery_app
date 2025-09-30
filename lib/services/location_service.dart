import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Verificar y solicitar permisos de ubicación
  static Future<bool> requestLocationPermission() async {
    PermissionStatus permission = await Permission.location.status;
    
    if (permission.isDenied) {
      permission = await Permission.location.request();
    }
    
    return permission.isGranted;
  }
  
  // Verificar si el servicio de ubicación está habilitado
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  // Obtener ubicación actual
  static Future<Position?> getCurrentLocation() async {
    try {
      // Verificar permisos
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Permisos de ubicación denegados');
      }
      
      // Verificar si el servicio está habilitado
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Servicio de ubicación deshabilitado');
      }
      
      // Obtener ubicación
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      
      return position;
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }
  
  // Convertir coordenadas a dirección
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        String address = '';
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += address.isEmpty ? place.locality! : ', ${place.locality!}';
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          address += address.isEmpty ? place.administrativeArea! : ', ${place.administrativeArea!}';
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += address.isEmpty ? place.country! : ', ${place.country!}';
        }
        
        return address.isEmpty ? 'Dirección no disponible' : address;
      }
      
      return 'Dirección no encontrada';
    } catch (e) {
      print('Error obteniendo dirección: $e');
      return 'Error al obtener dirección';
    }
  }
  
  // Calcular distancia entre dos puntos
  static double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }
  
  // Formatear distancia para mostrar
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }
}