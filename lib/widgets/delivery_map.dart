import 'package:flutter/material.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // Comentado temporalmente
import '../config/mapbox_config.dart';
import '../services/location_service.dart';


// Tipos temporales para reemplazar los de Mapbox
class Point {
  final Position coordinates;
  Point({required this.coordinates});
}

class Position {
  final double lng;
  final double lat;
  Position(this.lng, this.lat);
}

class DeliveryMap extends StatefulWidget {
  final Function(Point)? onLocationSelected;
  final List<Point>? deliveryPoints;
  final Point? currentLocation;
  final Point? businessLocation; // Nueva propiedad para ubicación del negocio
  final bool showCurrentLocation;
  final bool showBusinessMarker; // Nueva propiedad para mostrar marcador del negocio
  final String? businessName; // Nombre del negocio para el marcador
  final double initialZoom;
  final bool isBusinessView; // Modo de vista para negocios

  const DeliveryMap({
    Key? key,
    this.onLocationSelected,
    this.deliveryPoints,
    this.currentLocation,
    this.businessLocation,
    this.showCurrentLocation = true,
    this.showBusinessMarker = false,
    this.businessName,
    this.initialZoom = 14.0,
    this.isBusinessView = false,
  }) : super(key: key);

  @override
  State<DeliveryMap> createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<DeliveryMap> {
  Point? userLocation;

  @override
  void initState() {
    super.initState();
    if (widget.showCurrentLocation) {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Mapa temporal (placeholder)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mapa temporalmente no disponible',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Obtén un token de Mapbox para habilitar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (widget.businessLocation != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Ubicación del negocio: ${widget.businessName ?? 'Negocio'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Botones de ubicación
          if (widget.showCurrentLocation && !widget.isBusinessView)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                onPressed: _centerOnUserLocation,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          
          if (widget.isBusinessView && widget.businessLocation != null)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                onPressed: _centerOnBusinessLocation,
                backgroundColor: Colors.orange,
                child: const Icon(Icons.store, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _centerOnUserLocation() async {
    if (userLocation == null) {
      await _getCurrentLocation();
    }

    if (userLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ubicación: ${userLocation!.coordinates.lat.toStringAsFixed(4)}, '
            '${userLocation!.coordinates.lng.toStringAsFixed(4)}',
          ),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _centerOnBusinessLocation() async {
    if (widget.businessLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ubicación del negocio: ${widget.businessLocation!.coordinates.lat.toStringAsFixed(4)}, '
            '${widget.businessLocation!.coordinates.lng.toStringAsFixed(4)}',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          userLocation = Point(
            coordinates: Position(location.longitude, location.latitude),
          );
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }
}
