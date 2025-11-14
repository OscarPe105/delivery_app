import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Subir imagen de perfil de usuario
  Future<String?> uploadUserProfileImage(String userId, XFile imageFile) async {
    try {
      final path = 'users/$userId/profile/profile.jpg';
      Reference ref = _storage.ref().child(path);

      final metadata = SettableMetadata(
        contentType: imageFile.mimeType ?? 'image/jpeg',
      );

      UploadTask uploadTask;
      if (kIsWeb) {
        // En web, usar putData con bytes
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(bytes, metadata);
      } else {
        // En móvil, usar putFile
        uploadTask = ref.putFile(File(imageFile.path), metadata);
      }
      
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        debugPrint('✅ Imagen de perfil subida: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error subiendo imagen de perfil: $e');
      }
      return null;
    }
  }

  /// Subir imagen de negocio
  Future<String?> uploadBusinessImage(String businessId, XFile imageFile) async {
    try {
      final path = 'businesses/$businessId/business.jpg';
      Reference ref = _storage.ref().child(path);

      final metadata = SettableMetadata(
        contentType: imageFile.mimeType ?? 'image/jpeg',
      );

      UploadTask uploadTask;
      if (kIsWeb) {
        // En web, usar putData con bytes
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(bytes, metadata);
      } else {
        // En móvil, usar putFile
        uploadTask = ref.putFile(File(imageFile.path), metadata);
      }
      
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        debugPrint('✅ Imagen de negocio subida: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error subiendo imagen de negocio: $e');
      }
      return null;
    }
  }

  /// Subir imagen de producto
  Future<String?> uploadProductImage(String productId, XFile imageFile) async {
    try {
      final path = 'products/$productId/product.jpg';
      if (kDebugMode) {
        debugPrint('📤 Subiendo imagen de producto: $path');
      }

      Reference ref = _storage.ref().child(path);
      
      UploadTask uploadTask;
      if (kIsWeb) {
        // En web, usar putData con bytes
        final bytes = await imageFile.readAsBytes();
        if (kDebugMode) {
          debugPrint('📦 Bytes a subir (web): ${bytes.length}');
        }
        uploadTask = ref.putData(bytes, SettableMetadata(contentType: imageFile.mimeType ?? 'image/jpeg'));
      } else {
        // En móvil, usar putFile
        uploadTask = ref.putFile(
          File(imageFile.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }
      
      if (kDebugMode) {
        debugPrint('⏳ Esperando resultado de subida...');
      }

      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        debugPrint('✅ Imagen de producto subida: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error subiendo imagen de producto: $e');
      }
      return null;
    }
  }

  /// Subir imagen desde galería
  Future<XFile?> pickImageFromGallery() async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (kDebugMode) {
          debugPrint('✅ Imagen seleccionada desde galería');
        }
      }
      
      return image;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error seleccionando imagen: $e');
      }
      return null;
    }
  }

  /// Subir imagen desde cámara
  Future<XFile?> pickImageFromCamera() async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (kDebugMode) {
          debugPrint('✅ Imagen tomada con cámara');
        }
      }
      
      return image;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tomando imagen: $e');
      }
      return null;
    }
  }

  /// Mostrar opciones de selección de imagen
  Future<XFile?> pickImage() async {
    try {
      // Por ahora, usamos galería por defecto
      return await pickImageFromGallery();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error seleccionando imagen: $e');
      }
      return null;
    }
  }
  
  /// Mostrar diálogo para elegir fuente de imagen
  Future<XFile?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Galería'),
                onTap: () async {
                  final image = await pickImageFromGallery();
                  if (context.mounted) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.green),
                title: const Text('Cámara'),
                onTap: () async {
                  final image = await pickImageFromCamera();
                  if (context.mounted) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancelar'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Eliminar imagen
  Future<bool> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      
      if (kDebugMode) {
        debugPrint('✅ Imagen eliminada exitosamente');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error eliminando imagen: $e');
      }
      return false;
    }
  }

  /// Obtener URL de descarga
  Future<String?> getDownloadURL(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error obteniendo URL de descarga: $e');
      }
      return null;
    }
  }

  /// Subir archivo genérico
  Future<String?> uploadFile(String path, File file) async {
    try {
      Reference ref = _storage.ref().child(path);
      
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        debugPrint('✅ Archivo subido: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error subiendo archivo: $e');
      }
      return null;
    }
  }

  /// Subir múltiples imágenes
  Future<List<String>> uploadMultipleImages(
    String folderPath, 
    List<XFile> imageFiles
  ) async {
    List<String> uploadedUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        String fileName = 'image_${i + 1}.jpg';
        String path = '$folderPath/$fileName';
        
        String? url = await uploadFile(path, File(imageFiles[i].path));
        if (url != null) {
          uploadedUrls.add(url);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error subiendo imagen $i: $e');
        }
      }
    }
    
    return uploadedUrls;
  }

  /// Comprimir imagen antes de subir
  Future<File?> compressImage(XFile imageFile) async {
    try {
      // En un caso real, usarías un paquete como flutter_image_compress
      // Por ahora, retornamos el archivo original
      return File(imageFile.path);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error comprimiendo imagen: $e');
      }
      return null;
    }
  }
}
