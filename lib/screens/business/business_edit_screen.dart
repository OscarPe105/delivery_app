import 'package:flutter/material.dart';
import '../../services/firebase_storage_service.dart';
import '../../widgets/address_autocomplete_field.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../themes/app_colors.dart';
import '../../config/category_config.dart';
import '../../services/map_service.dart';

class BusinessEditScreen extends StatefulWidget {
  const BusinessEditScreen({super.key});

  @override
  State<BusinessEditScreen> createState() => _BusinessEditScreenState();
}

class _BusinessEditScreenState extends State<BusinessEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedCategory = '';
  List<String> _categories = [];
  bool _isLoading = false;
  bool _isOpen = true;
  
  // Coordenadas de ubicación del negocio
  double? _latitude;
  double? _longitude;
  
  // Imagen del negocio
  XFile? _selectedImage;
  String? _currentImageUrl;
  
  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll(',', '.');
      return double.tryParse(normalized);
    }
    return null;
  }

  List<double?> _parseLocation(dynamic value) {
    double? latitude;
    double? longitude;

    if (value is GeoPoint) {
      latitude = value.latitude;
      longitude = value.longitude;
    } else if (value is List && value.length >= 2) {
      latitude = _parseCoordinate(value[0]);
      longitude = _parseCoordinate(value[1]);
    } else if (value is Map) {
      final normalized = value.map(
        (key, val) => MapEntry(key.toString().toLowerCase(), val),
      );
      latitude = _parseCoordinate(
        normalized['latitude'] ??
            normalized['lat'] ??
            normalized['_latitude'] ??
            normalized['latitud'],
      );
      longitude = _parseCoordinate(
        normalized['longitude'] ??
            normalized['lng'] ??
            normalized['lon'] ??
            normalized['long'] ??
            normalized['_longitude'] ??
            normalized['longitud'],
      );
    } else if (value is String) {
      final parts = value.split(',');
      if (parts.length >= 2) {
        latitude = _parseCoordinate(parts[0]);
        longitude = _parseCoordinate(parts[1]);
      } else {
        final numeric = _parseCoordinate(value);
        latitude = numeric;
        longitude = numeric;
      }
    }

    return [latitude, longitude];
  }

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessData() async {
    setState(() { _isLoading = true; });
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Cargar datos del negocio desde Firestore
        final firestore = FirebaseFirestore.instance;
        final querySnapshot = await firestore
            .collection('businesses')
            .where('ownerUid', isEqualTo: currentUser.uid)
            .limit(1)
            .get();
        
        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data();
          
          if (kDebugMode) {
            debugPrint('📍 Datos cargados del negocio: $data');
            debugPrint('📍 Latitude: ${data['latitude']}, Longitude: ${data['longitude']}');
          }
          
          final loadedCategories = List<String>.from(CategoryConfig.getAllSubcategories());
          final categoryValue = (data['category'] ?? '').toString();
          if (categoryValue.isNotEmpty && !loadedCategories.contains(categoryValue)) {
            loadedCategories.add(categoryValue);
          }
          final normalizedCategories = loadedCategories.toSet().toList()..sort();

          double? latitude = _parseCoordinate(data['latitude']);
          double? longitude = _parseCoordinate(data['longitude']);
          if (latitude == null || longitude == null) {
            final locationField = data['location'] ?? data['coords'] ?? data['coordinates'];
            final parsed = _parseLocation(locationField);
            latitude ??= parsed[0];
            longitude ??= parsed[1];
          }

          setState(() {
            _businessNameController.text = data['name'] ?? '';
            _descriptionController.text = data['description'] ?? '';
            final rawAddress = data['address']?.toString() ?? '';
            _addressController.text = rawAddress.isNotEmpty
                ? MapService.normalizeAddress(rawAddress)
                : '';
            _phoneController.text = data['phone'] ?? '';
            _selectedCategory = data['category'] ?? '';
            _isOpen = data['isOpen'] ?? data['is_open'] ?? true;
            _latitude = latitude;
            _longitude = longitude;
            _currentImageUrl = data['imageUrl'] ?? data['image_url'];
            _categories = normalizedCategories;
          });
          
          if (kDebugMode) {
            debugPrint('📍 Coordenadas cargadas: $_latitude, $_longitude');
          }

          if ((_latitude == null || _longitude == null) &&
              _addressController.text.trim().isNotEmpty) {
            final coords = await MapService.getCoordinatesFromAddress(
              _addressController.text.trim(),
            );
            if (coords != null && mounted) {
              setState(() {
                _latitude = coords.latitude;
                _longitude = coords.longitude;
              });

              try {
                await firestore.collection('businesses').doc(querySnapshot.docs.first.id).update({
                  'latitude': coords.latitude,
                  'longitude': coords.longitude,
                  'location': GeoPoint(coords.latitude, coords.longitude),
                });
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('ℹ️ No se pudo persistir ubicación al cargar negocio: $e');
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error cargando datos del negocio: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _onAddressSelected(Map<String, dynamic> placeData) {
    if (kDebugMode) {
      debugPrint('📍 Dirección seleccionada: ${placeData['address']}');
      debugPrint('📍 Coordenadas recibidas: ${placeData['latitude']}, ${placeData['longitude']}');
    }

    final normalizedAddress = MapService.normalizeAddress(placeData['address']?.toString() ?? '');

    setState(() {
      _latitude = _parseCoordinate(placeData['latitude']);
      _longitude = _parseCoordinate(placeData['longitude']);
      _addressController.text = normalizedAddress;
    });

    if (kDebugMode) {
      debugPrint('📍 Coordenadas guardadas en estado: $_latitude, $_longitude');
    }
  }

  Future<void> _selectImage() async {
    final storageService = FirebaseStorageService();
    final image = await storageService.showImageSourceDialog(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _currentImageUrl = null; // Limpiar URL actual cuando se selecciona nueva imagen
      });
    }
  }

  Future<void> _updateBusiness() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una categoría'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() { _isLoading = true; });

    try {
      if ((_latitude == null || _longitude == null) &&
          _addressController.text.trim().isNotEmpty) {
        final coords = await MapService.getCoordinatesFromAddress(
          MapService.normalizeAddress(_addressController.text.trim()),
        );
        if (coords != null) {
          _latitude = coords.latitude;
          _longitude = coords.longitude;
        }
      }

      // Primero subir la imagen si existe
      String? imageUrl = _currentImageUrl; // Mantener la URL actual si no hay nueva imagen
      if (_selectedImage != null) {
        try {
          final storageService = FirebaseStorageService();
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            imageUrl = await storageService.uploadBusinessImage(
              currentUser.uid,
              _selectedImage!,
            );
            if (kDebugMode) {
              debugPrint('📸 Nueva imagen subida: $imageUrl');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Error subiendo imagen: $e');
          }
        }
      }
      
      final businessData = {
        'name': _businessNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': MapService.normalizeAddress(_addressController.text.trim()),
        'phone': _phoneController.text.trim(),
        'category': _selectedCategory,
        'is_open': _isOpen,
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
        if (_latitude != null && _longitude != null)
          'location': GeoPoint(_latitude!, _longitude!),
        if (imageUrl != null) 'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (kDebugMode) {
        debugPrint('📍 Datos a guardar: $businessData');
        debugPrint('📍 Coordenadas a guardar: $_latitude, $_longitude');
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Actualizar en Firestore
        final firestore = FirebaseFirestore.instance;
        final querySnapshot = await firestore
            .collection('businesses')
            .where('ownerUid', isEqualTo: currentUser.uid)
            .limit(1)
            .get();
        
        if (querySnapshot.docs.isNotEmpty) {
          await firestore
              .collection('businesses')
              .doc(querySnapshot.docs.first.id)
              .update(businessData);
          
          if (kDebugMode) {
            debugPrint('✅ Negocio actualizado en Firestore');
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Información del negocio actualizada!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error actualizando negocio: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Negocio'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _businessNameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen del negocio
                    const Text(
                      'Imagen del Negocio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _selectImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[50],
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? FutureBuilder<List<int>>(
                                        future: _selectedImage!.readAsBytes(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Image.memory(
                                              Uint8List.fromList(snapshot.data!),
                                              fit: BoxFit.cover,
                                            );
                                          }
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                      )
                                    : Image.file(
                                        File(_selectedImage!.path),
                                        fit: BoxFit.cover,
                                      ),
                              )
                            : _currentImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _currentImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey[400]),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Toca para cambiar imagen',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey[400]),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Toca para agregar imagen',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nombre del negocio
                    TextFormField(
                      controller: _businessNameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del negocio',
                        prefixIcon: const Icon(Icons.store),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el nombre del negocio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Descripción del negocio',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Categoría
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Colors.white,
                      menuMaxHeight: 360,
                      isExpanded: true,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      items: _categories.map((category) {
                        final icon = CategoryConfig.getIconForBusinessCategory(category);
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(icon, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: Color(0xFF2C3E50),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor selecciona una categoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dirección
                    AddressAutocompleteField(
                      controller: _addressController,
                      label: 'Dirección',
                      hint: 'Escribe una dirección',
                      onPlaceSelected: _onAddressSelected,
                      prefixIcon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la dirección';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Teléfono
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el teléfono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateBusiness,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Guardar Cambios',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

