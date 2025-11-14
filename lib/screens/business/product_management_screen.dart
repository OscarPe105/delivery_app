import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../models/product.dart';
import '../../services/firebase_storage_service.dart';
import '../../widgets/optimized_image.dart';
import '../../themes/app_colors.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProductManagementScreen extends StatefulWidget {
  final Product? product;
  const ProductManagementScreen({super.key, this.product});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  
  bool _isAvailable = true;
  bool _isPopular = false;
  XFile? _selectedXFile;
  bool _isLoading = false;
  Product? _editingProduct;

  @override
  void initState() {
    super.initState();
    _editingProduct = widget.product;

    if (_editingProduct != null) {
      final product = _editingProduct!;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(2);
      _stockController.text = product.stock.toString();
      _isAvailable = product.available;
      _isPopular = product.isPopular;
    } else {
      _stockController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingProduct == null ? 'Agregar Producto' : 'Editar Producto'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_editingProduct != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProduct,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección de imagen
              _buildImageSection(),
              const SizedBox(height: 24),
              
              // Campos del formulario
              _buildFormFields(),
              const SizedBox(height: 24),
              
              // Switches de configuración
              _buildConfigurationSwitches(),
              const SizedBox(height: 32),
              
              // Botón de guardar
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagen del Producto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Preview de imagen o placeholder
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _selectedXFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? FutureBuilder<List<int>>(
                          future: _selectedXFile!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                Uint8List.fromList(snapshot.data!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              );
                            }
                            return const Center(child: CircularProgressIndicator());
                          },
                        )
                      : Image.file(
                          File(_selectedXFile!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                )
              : _editingProduct?.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: OptimizedImage(
                        imageUrl: _editingProduct!.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Seleccionar imagen',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
        
        const SizedBox(height: 12),
        
        // Botones de imagen
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
              ),
            ),
            if (_selectedXFile != null || _editingProduct?.imageUrl != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del producto
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Producto',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.fastfood),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Descripción
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La descripción es requerida';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Precio y Stock en fila
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El precio es requerido';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un precio válido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El stock es requerido';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un stock válido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfigurationSwitches() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Disponible
            SwitchListTile(
              title: const Text('Disponible'),
              subtitle: const Text('El producto está disponible para la venta'),
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
              secondary: const Icon(Icons.check_circle),
            ),
            
            // Popular
            SwitchListTile(
              title: const Text('Producto Popular'),
              subtitle: const Text('Mostrar como producto destacado'),
              value: _isPopular,
              onChanged: (value) {
                setState(() {
                  _isPopular = value;
                });
              },
              secondary: const Icon(Icons.star),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveProduct,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Guardando...'),
              ],
            )
          : Text(_editingProduct == null ? 'Agregar Producto' : 'Actualizar Producto'),
    );
  }

  Future<void> _selectImage() async {
    final storageService = FirebaseStorageService();
    final image = await storageService.showImageSourceDialog(context);
    if (image != null) {
      setState(() {
        _selectedXFile = image;
      });
    }
  }

  Future<void> _takePhoto() async {
    final storageService = FirebaseStorageService();
    final image = await storageService.pickImageFromCamera();
    if (image != null) {
      setState(() {
        _selectedXFile = image;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedXFile = null;
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el ID del documento del negocio (para relacionar productos correctamente)
      String effectiveBusinessId = widget.product?.businessId ?? currentUser.uid;
      String? businessFirestoreId = widget.product?.firestoreBusinessId;
      try {
        final businessQuery = await FirebaseFirestore.instance
            .collection('businesses')
            .where('ownerUid', isEqualTo: currentUser.uid)
            .limit(1)
            .get();

        if (businessQuery.docs.isNotEmpty) {
          final businessDoc = businessQuery.docs.first;
          businessFirestoreId = businessDoc.id;
          final businessData = businessDoc.data();
          final djangoBusinessId = businessData['django_id']?.toString();

          if (djangoBusinessId != null && djangoBusinessId.isNotEmpty) {
            effectiveBusinessId = djangoBusinessId;
          } else if (businessData['businessId'] != null) {
            effectiveBusinessId = businessData['businessId'].toString();
          }
        } else if (_editingProduct != null && _editingProduct!.businessId.isNotEmpty) {
          effectiveBusinessId = _editingProduct!.businessId;
          businessFirestoreId ??= _editingProduct!.firestoreBusinessId;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ No se pudo obtener el negocio del usuario: $e');
        }
        // Mantener fallback al UID del usuario
      }

      businessFirestoreId ??= widget.product?.firestoreBusinessId ?? currentUser.uid;

      String? imageUrl;

      // Si hay una nueva imagen, subirla a Firebase Storage
      if (_selectedXFile != null) {
        final storageService = FirebaseStorageService();
        imageUrl = await storageService.uploadProductImage(
          _editingProduct?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          _selectedXFile!,
        );
        if (kDebugMode) {
          debugPrint('📸 Imagen subida: $imageUrl');
        }
      } else if (_editingProduct?.imageUrl != null) {
        // Si estamos editando y no hay nueva imagen, mantener la existente
        imageUrl = _editingProduct!.imageUrl;
      }

      // Crear objeto Product
      final product = Product(
        id: _editingProduct?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        businessId: effectiveBusinessId,
        available: _isAvailable,
        isPopular: _isPopular,
        imageUrl: imageUrl,
        stock: int.tryParse(_stockController.text) ?? 0,
        firestoreBusinessId: businessFirestoreId,
      );

      // Guardar en Firestore
      final firestore = FirebaseFirestore.instance;
      if (_editingProduct == null) {
        // Crear nuevo producto
        await firestore.collection('products').doc(product.id).set({
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'businessId': product.businessId,
          'businessFirestoreId': businessFirestoreId,
          'ownerUid': currentUser.uid,
          'available': product.available,
          'isPopular': product.isPopular,
          'imageUrl': product.imageUrl ?? '',
          'stock': product.stock,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // También agregar al provider local para la UI
        businessProvider.addProduct(product);
        
        if (kDebugMode) {
          debugPrint('✅ Producto agregado a Firestore');
        }
      } else {
        // Actualizar producto existente
        await firestore.collection('products').doc(product.id).update({
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'businessId': product.businessId,
          'businessFirestoreId': businessFirestoreId,
          'ownerUid': currentUser.uid,
          'available': product.available,
          'isPopular': product.isPopular,
          'imageUrl': product.imageUrl ?? '',
          'stock': product.stock,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // También actualizar en el provider local
        businessProvider.updateProduct(product);
        
        if (kDebugMode) {
          debugPrint('✅ Producto actualizado en Firestore');
        }
      }

      // Mostrar mensaje de éxito
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editingProduct == null 
              ? 'Producto agregado exitosamente' 
              : 'Producto actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Regresar a la pantalla anterior
      Navigator.of(context).pop();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error guardando producto: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = Provider.of<BusinessProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: const Text('¿Estás seguro de que quieres eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && _editingProduct != null) {
      try {
        final success = await provider.deleteProduct(_editingProduct!);

        if (!context.mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Producto eliminado exitosamente'
                : 'No se pudo eliminar el producto. Intenta nuevamente'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          if (!navigator.mounted) return;
          navigator.pop();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error eliminando producto: $e');
        }

        if (!context.mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
