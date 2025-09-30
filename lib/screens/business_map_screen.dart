import 'package:flutter/material.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // Comentado temporalmente
import '../widgets/delivery_map.dart';
import '../providers/theme_provider.dart';
import '../models/business.dart';

class BusinessMapScreen extends StatelessWidget {
  final Business business;
  
  const BusinessMapScreen({
    Key? key,
    required this.business,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Crear punto de ubicación del negocio
    final businessLocation = Point(
      coordinates: Position(
        business.longitude ?? -87.2068, // Coordenada por defecto de Honduras
        business.latitude ?? 14.0723,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          business.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeProvider.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showBusinessInfo(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa del negocio
          DeliveryMap(
            businessLocation: businessLocation,
            showBusinessMarker: true,
            businessName: business.name,
            isBusinessView: true,
            showCurrentLocation: true,
            initialZoom: 15.0,
          ),
          
          // Panel de información del negocio
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        color: ThemeProvider.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          business.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (business.address != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            business.address!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  if (business.phone != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            business.phone!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openDirections(context, businessLocation),
                          icon: const Icon(Icons.directions),
                          label: const Text('Cómo llegar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeProvider.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _callBusiness(context),
                          icon: const Icon(Icons.call),
                          label: const Text('Llamar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ThemeProvider.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBusinessInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(business.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (business.description != null)
              Text(business.description!),
            const SizedBox(height: 8),
            Text('Categoría: ${business.category}'),
            if (business.rating != null)
              Text('Calificación: ${business.rating}/5'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _openDirections(BuildContext context, Point businessLocation) {
    // Aquí puedes implementar la apertura de Google Maps o Waze
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abriendo direcciones...'),
      ),
    );
  }

  void _callBusiness(BuildContext context) {
    if (business.phone != null) {
      // Aquí puedes implementar la llamada telefónica
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Llamando a ${business.phone}...'),
        ),
      );
    }
  }
}