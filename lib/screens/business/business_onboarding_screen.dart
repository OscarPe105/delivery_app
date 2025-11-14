import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/category_config.dart';
import '../../themes/app_colors.dart';
import '../../widgets/address_autocomplete_field.dart';
import '../../services/firebase_storage_service.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class BusinessOnboardingScreen extends StatefulWidget {
  const BusinessOnboardingScreen({super.key});

  @override
  State<BusinessOnboardingScreen> createState() => _BusinessOnboardingScreenState();
}

class _BusinessOnboardingScreenState extends State<BusinessOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _selectedCategory = '';
  List<String> _categories = [];
  bool _isLoading = false;
  bool _isOpen = true;
  
  // Coordenadas de ubicación del negocio
  double? _latitude;
  double? _longitude;
  
  // Imagen del negocio
  XFile? _selectedImage;
  
  // Horarios de trabajo
  final Map<String, Map<String, String>> _schedule = {
    'monday': {'open': '08:00', 'close': '18:00', 'isOpen': 'true'},
    'tuesday': {'open': '08:00', 'close': '18:00', 'isOpen': 'true'},
    'wednesday': {'open': '08:00', 'close': '18:00', 'isOpen': 'true'},
    'thursday': {'open': '08:00', 'close': '18:00', 'isOpen': 'true'},
    'friday': {'open': '08:00', 'close': '18:00', 'isOpen': 'true'},
    'saturday': {'open': '09:00', 'close': '17:00', 'isOpen': 'true'},
    'sunday': {'open': '10:00', 'close': '16:00', 'isOpen': 'false'},
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categories = CategoryConfig.getAllSubcategories();
    });
  }

  void _onAddressSelected(Map<String, dynamic> placeData) {
    setState(() {
      _latitude = placeData['latitude'] as double?;
      _longitude = placeData['longitude'] as double?;
    });
    
    if (kDebugMode) {
      debugPrint('📍 Dirección seleccionada: ${placeData['address']}');
      debugPrint('📍 Coordenadas: $_latitude, $_longitude');
    }
  }

  Future<void> _selectImage() async {
    final storageService = FirebaseStorageService();
    final image = await storageService.showImageSourceDialog(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _registerBusiness() async {
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
      // Primero subir la imagen si existe
      String? imageUrl;
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
              debugPrint('📸 Imagen subida: $imageUrl');
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
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'category': _selectedCategory,
        'isOpen': _isOpen,
        'is_open': _isOpen,
        'schedule': _schedule,
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Debes iniciar sesión para registrar un negocio');
      }

      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('businesses').doc();

      await docRef.set({
        ...businessData,
        'ownerUid': currentUser.uid,
        'ownerEmail': currentUser.email,
        'ownerName': currentUser.displayName,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('✅ Negocio registrado en Firestore: ${docRef.id}');
      }

      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.setUserType(UserType.business);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Negocio registrado exitosamente!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/business/dashboard',
        (route) => false,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Excepción en _registerBusiness: $e');
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

  Widget _buildScheduleCard(String day, String dayName) {
    final daySchedule = _schedule[day]!;
    final isOpen = daySchedule['isOpen'] == 'true';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Switch(
                  value: isOpen,
                  onChanged: (value) {
                    setState(() {
                      _schedule[day]!['isOpen'] = value.toString();
                    });
                  },
                ),
              ],
            ),
            if (isOpen) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Apertura', style: TextStyle(fontSize: 12)),
                        DropdownButtonFormField<String>(
                          initialValue: daySchedule['open'],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          items: List.generate(24, (hour) {
                            final time = '${hour.toString().padLeft(2, '0')}:00';
                            return DropdownMenuItem(value: time, child: Text(time));
                          }),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _schedule[day]!['open'] = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cierre', style: TextStyle(fontSize: 12)),
                        DropdownButtonFormField<String>(
                          initialValue: daySchedule['close'],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          items: List.generate(24, (hour) {
                            final time = '${hour.toString().padLeft(2, '0')}:00';
                            return DropdownMenuItem(value: time, child: Text(time));
                          }),
                          onChanged: (value) {
                            if (value != null) {
    setState(() {
                                _schedule[day]!['close'] = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Mi Negocio'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.orange.withValues(alpha: 0.1),
                              ),
                              child: const Icon(
                                Icons.store,
                                size: 64,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '¡Bienvenido!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Configura tu negocio para comenzar a recibir pedidos',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

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

                      // Información básica del negocio
                      const Text(
                        'Información del Negocio',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 16),

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
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.orange),
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
                                Icon(icon, color: Colors.orange.shade400),
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

                      // Dirección con autocompletado
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
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email del negocio',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el email';
                          }
                          if (!value.contains('@')) {
                            return 'Por favor ingresa un email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Horarios de trabajo
                      const Text(
                        'Horarios de Trabajo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Estado del negocio
                      Row(
                        children: [
                          const Text('Negocio abierto'),
                          const Spacer(),
                          Switch(
                            value: _isOpen,
                            onChanged: (value) {
                              setState(() {
                                _isOpen = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Horarios por día
                      ..._schedule.entries.map((entry) {
                        final dayNames = {
                          'monday': 'Lunes',
                          'tuesday': 'Martes',
                          'wednesday': 'Miércoles',
                          'thursday': 'Jueves',
                          'friday': 'Viernes',
                          'saturday': 'Sábado',
                          'sunday': 'Domingo',
                        };
                        return _buildScheduleCard(entry.key, dayNames[entry.key]!);
                      }).toList(),

                      const SizedBox(height: 32),

                      // Botón de registro
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _registerBusiness,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Registrar Negocio',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
