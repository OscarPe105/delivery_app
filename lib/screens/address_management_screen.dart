import 'package:flutter/material.dart';
import '../models/address.dart';
import '../providers/theme_provider.dart';
import 'address_selection_screen.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({Key? key}) : super(key: key);
  
  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  List<Address> addresses = [];
  
  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }
  
  void _loadAddresses() {
    // Aquí cargarías las direcciones desde tu base de datos o storage local
    // Por ahora, usamos datos de ejemplo
    setState(() {
      addresses = [
        Address(
          id: '1',
          title: 'Casa',
          fullAddress: 'Colonia Palmira, Tegucigalpa, Honduras',
          latitude: 14.0723,
          longitude: -87.1921,
          isDefault: true,
          createdAt: DateTime.now().subtract(Duration(days: 30)),
        ),
        Address(
          id: '2',
          title: 'Trabajo',
          fullAddress: 'Centro Comercial Cascadas, Tegucigalpa, Honduras',
          latitude: 14.0850,
          longitude: -87.2063,
          createdAt: DateTime.now().subtract(Duration(days: 15)),
        ),
      ];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Direcciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeProvider.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: addresses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                return _buildAddressCard(addresses[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewAddress,
        backgroundColor: ThemeProvider.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes direcciones guardadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primera dirección para hacer pedidos más rápido',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewAddress,
            icon: const Icon(Icons.add_location),
            label: const Text('Agregar Dirección'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeProvider.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddressCard(Address address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  address.title == 'Casa' ? Icons.home :
                  address.title == 'Trabajo' ? Icons.work :
                  Icons.location_on,
                  color: ThemeProvider.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeProvider.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Principal',
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeProvider.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editAddress(address);
                        break;
                      case 'delete':
                        _deleteAddress(address);
                        break;
                      case 'default':
                        _setAsDefault(address);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    if (!address.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 18),
                            SizedBox(width: 8),
                            Text('Marcar como principal'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.fullAddress,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (address.instructions != null && address.instructions!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Instrucciones: ${address.instructions}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _addNewAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressSelectionScreen(),
      ),
    );
    
    if (result != null) {
      _showAddressDetailsDialog(result);
    }
  }
  
  void _showAddressDetailsDialog(Map<String, dynamic> locationData) {
    final titleController = TextEditingController();
    final instructionsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de la Dirección'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Nombre (ej: Casa, Trabajo)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instrucciones de entrega (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _saveNewAddress(
                  titleController.text,
                  locationData['address'],
                  locationData['latitude'],
                  locationData['longitude'],
                  instructionsController.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeProvider.primaryColor,
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _saveNewAddress(String title, String fullAddress, double latitude, double longitude, String instructions) {
    final newAddress = Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      fullAddress: fullAddress,
      latitude: latitude,
      longitude: longitude,
      instructions: instructions.isEmpty ? null : instructions,
      isDefault: addresses.isEmpty, // Primera dirección es principal por defecto
      createdAt: DateTime.now(),
    );
    
    setState(() {
      addresses.add(newAddress);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dirección guardada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _editAddress(Address address) {
    // Implementar edición de dirección
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de edición próximamente')),
    );
  }
  
  void _deleteAddress(Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Dirección'),
        content: Text('¿Estás seguro de que quieres eliminar "${address.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                addresses.removeWhere((a) => a.id == address.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dirección eliminada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _setAsDefault(Address address) {
    setState(() {
      // Quitar default de todas las direcciones
      addresses = addresses.map((a) => a.copyWith(isDefault: false)).toList();
      // Establecer la seleccionada como default
      int index = addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        addresses[index] = addresses[index].copyWith(isDefault: true);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${address.title}" establecida como dirección principal'),
        backgroundColor: Colors.green,
      ),
    );
  }
}