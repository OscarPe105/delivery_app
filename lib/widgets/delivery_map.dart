import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../providers/community_store_provider.dart';
import 'package:provider/provider.dart';
import 'web_map_widget.dart';

class DeliveryMap extends StatefulWidget {
  final Function(LatLng)? onLocationSelected;
  final List<LatLng>? deliveryPoints;
  final LatLng? currentLocation;
  final LatLng? businessLocation;
  final bool showCurrentLocation;
  final bool showBusinessMarker;
  final String? businessName;
  final double initialZoom;
  final bool isBusinessView;

  const DeliveryMap({
    super.key,
    this.onLocationSelected,
    this.deliveryPoints,
    this.currentLocation,
    this.businessLocation,
    this.showCurrentLocation = true,
    this.showBusinessMarker = false,
    this.businessName,
    this.initialZoom = 14.0,
    this.isBusinessView = false,
  });

  @override
  State<DeliveryMap> createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<DeliveryMap> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _userLocation;

  // Coordenadas central de San Salvador, El Salvador
  static const LatLng sanSalvadorCenter = LatLng(13.6929, -89.2182);

  @override
  void initState() {
    super.initState();
    if (widget.showCurrentLocation) {
      _getCurrentLocation();
    }
    _initializeMarkers();
  }

  Future<void> _getCurrentLocation() async {
    final location = await LocationService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _userLocation = LatLng(location.latitude, location.longitude);
      });
      _initializeMarkers();
    }
  }

  void _initializeMarkers() {
    _markers.clear();

    // Agregar marcadores de negocios desde el provider
    if (!widget.isBusinessView) {
      final storeProvider = Provider.of<CommunityStoreProvider>(context, listen: false);
      for (var business in storeProvider.businesses) {
        if (business.latitude != null && business.longitude != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(business.id),
              position: LatLng(business.latitude!, business.longitude!),
              infoWindow: InfoWindow(
                title: business.name,
                snippet: business.description,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          );
        }
      }
    }

    // Agregar ubicación actual del usuario
    if (widget.showCurrentLocation && _userLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Agregar ubicación del negocio si se especifica
    if (widget.showBusinessMarker && widget.businessLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('businessLocation'),
          position: widget.businessLocation!,
          infoWindow: InfoWindow(
            title: widget.businessName ?? 'Negocio',
            snippet: 'Ubicación del negocio',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // Agregar puntos de entrega
    if (widget.deliveryPoints != null) {
      for (int i = 0; i < widget.deliveryPoints!.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('deliveryPoint_$i'),
            position: widget.deliveryPoints![i],
            infoWindow: InfoWindow(title: 'Punto de Entrega ${i + 1}'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          ),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _adjustCameraToFitMarkers();
  }

  void _adjustCameraToFitMarkers() {
    if (_markers.isEmpty) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(sanSalvadorCenter, 13.0),
      );
      return;
    }

    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (var marker in _markers) {
      minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
      maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si estamos en web, usar WebMapWidget como fallback
    if (kIsWeb) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: WebMapWidget(
            businessName: widget.businessName ?? 'Ubicación',
            address: 'San Salvador, El Salvador',
            latitude: widget.businessLocation?.latitude ?? sanSalvadorCenter.latitude,
            longitude: widget.businessLocation?.longitude ?? sanSalvadorCenter.longitude,
            height: 400,
            onTap: widget.onLocationSelected != null
                ? () {
                    if (widget.onLocationSelected != null) {
                      widget.onLocationSelected!(widget.businessLocation ?? sanSalvadorCenter);
                    }
                  }
                : null,
          ),
        ),
      );
    }

    // Para Android/iOS, usar Google Maps normal
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _userLocation ?? widget.businessLocation ?? sanSalvadorCenter,
            zoom: widget.initialZoom,
          ),
          onMapCreated: _onMapCreated,
          markers: _markers,
          zoomControlsEnabled: true,
          myLocationEnabled: widget.showCurrentLocation,
          myLocationButtonEnabled: widget.showCurrentLocation,
          mapType: MapType.normal,
          onTap: widget.onLocationSelected != null
              ? (position) => widget.onLocationSelected!(position)
              : null,
        ),
      ),
    );
  }
}
