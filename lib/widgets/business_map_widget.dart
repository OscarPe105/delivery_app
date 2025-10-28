import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/business.dart';
import '../../themes/app_colors.dart';

/// Widget de mapa individual para cada negocio
class BusinessMapWidget extends StatefulWidget {
  final Business business;
  final double? height;
  final bool showInfoWindow;
  final bool allowInteraction;
  final VoidCallback? onTap;

  const BusinessMapWidget({
    super.key,
    required this.business,
    this.height = 200,
    this.showInfoWindow = true,
    this.allowInteraction = true,
    this.onTap,
  });

  @override
  State<BusinessMapWidget> createState() => _BusinessMapWidgetState();
}

class _BusinessMapWidgetState extends State<BusinessMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    if (widget.business.latitude != null && widget.business.longitude != null) {
      _markers = {
        Marker(
          markerId: MarkerId(widget.business.id),
          position: LatLng(
            widget.business.latitude!,
            widget.business.longitude!,
          ),
          infoWindow: widget.showInfoWindow
              ? InfoWindow(
                  title: widget.business.name,
                  snippet: widget.business.description,
                )
              : const InfoWindow(),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange, // Usar color dorado/naranja
          ),
        ),
      };
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.business.latitude == null || widget.business.longitude == null) {
      return _buildNoLocationWidget();
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.business.latitude!,
                  widget.business.longitude!,
                ),
                zoom: 15.0,
              ),
              markers: _markers,
              zoomControlsEnabled: widget.allowInteraction,
              scrollGesturesEnabled: widget.allowInteraction,
              zoomGesturesEnabled: widget.allowInteraction,
              rotateGesturesEnabled: widget.allowInteraction,
              tiltGesturesEnabled: widget.allowInteraction,
              mapType: MapType.normal,
              onTap: widget.onTap != null ? (LatLng position) => widget.onTap!() : null,
            ),
            if (!widget.allowInteraction)
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            // Botón de vista satelital
            if (widget.allowInteraction)
              Positioned(
                top: 10,
                right: 10,
                child: FloatingActionButton.small(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  onPressed: _toggleMapType,
                  child: const Icon(Icons.layers),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleMapType() {
    if (_mapController != null) {
      // Cambiar entre vista normal y satelital
      // Esto se puede implementar con un estado para alternar
    }
  }

  Widget _buildNoLocationWidget() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Ubicación no disponible',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Este negocio no tiene ubicación registrada',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de mapa expandido para vista completa del negocio
class BusinessMapExpanded extends StatefulWidget {
  final Business business;
  final LatLng? userLocation;

  const BusinessMapExpanded({
    super.key,
    required this.business,
    this.userLocation,
  });

  @override
  State<BusinessMapExpanded> createState() => _BusinessMapExpandedState();
}

class _BusinessMapExpandedState extends State<BusinessMapExpanded> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    _markers = {};

    // Marcador del negocio
    if (widget.business.latitude != null && widget.business.longitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('business'),
          position: LatLng(
            widget.business.latitude!,
            widget.business.longitude!,
          ),
          infoWindow: InfoWindow(
            title: widget.business.name,
            snippet: widget.business.description,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    // Marcador del usuario (si está disponible)
    if (widget.userLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: widget.userLocation!,
          infoWindow: const InfoWindow(
            title: 'Tu ubicación',
            snippet: 'Ubicación actual',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  void _centerOnBusiness() {
    if (_mapController != null && 
        widget.business.latitude != null && 
        widget.business.longitude != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.business.latitude!, widget.business.longitude!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.business.latitude == null || widget.business.longitude == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.business.name} - Ubicación'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Ubicación no disponible'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.business.name} - Ubicación'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnBusiness,
            tooltip: 'Centrar en negocio',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.business.latitude!,
                widget.business.longitude!,
              ),
              zoom: 15.0,
            ),
            markers: _markers,
            mapType: _mapType,
            zoomControlsEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          // Controles personalizados
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  onPressed: _toggleMapType,
                  child: Icon(
                    _mapType == MapType.normal 
                        ? Icons.satellite 
                        : Icons.map,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  onPressed: _centerOnBusiness,
                  child: const Icon(Icons.center_focus_strong),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
