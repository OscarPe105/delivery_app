import 'package:flutter/material.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // Comentado temporalmente
import '../widgets/delivery_map.dart';
import '../services/location_service.dart';
import '../providers/theme_provider.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({Key? key}) : super(key: key);
  
  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  Point? selectedLocation;
  String selectedAddress = '';
  bool isLoadingAddress = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seleccionar Dirección',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeProvider.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Mapa
          DeliveryMap(
            onLocationSelected: (Point point) async {
              setState(() {
                selectedLocation = point;
                isLoadingAddress = true;
                selectedAddress = 'Obteniendo dirección...';
              });
              
              // Obtener dirección usando las coordenadas correctas
              String address = await LocationService.getAddressFromCoordinates(
                point.coordinates.lat.toDouble(),
                point.coordinates.lng.toDouble(),
                
              );
              
              setState(() {
                selectedAddress = address;
                isLoadingAddress = false;
              });
            },
          ),
          
          // Indicador de selección en el centro del mapa
          Center(
            child: Icon(
              Icons.location_on,
              size: 40,
              color: ThemeProvider.primaryColor,
            ),
          ),
          
          // Instrucciones en la parte superior
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Mueve el mapa para seleccionar tu dirección',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Panel inferior con dirección seleccionada
          if (selectedLocation != null)
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
                    const Text(
                      'Dirección Seleccionada:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    if (isLoadingAddress)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Obteniendo dirección...'),
                        ],
                      )
                    else
                      Text(
                        selectedAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoadingAddress ? null : () {
                          Navigator.pop(context, {
                            'location': selectedLocation,
                            'address': selectedAddress,
                            'latitude': selectedLocation!.coordinates.lat,
                            'longitude': selectedLocation!.coordinates.lng,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirmar Dirección',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}