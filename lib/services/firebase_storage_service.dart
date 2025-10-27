import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
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
      Reference ref = _storage.ref().child('users/$userId/profile/profile.jpg');
      
      UploadTask uploadTask = ref.putFile(File(imageFile.path));
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('✅ Imagen de perfil subida: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subiendo imagen de perfil: $e');
      }
      return null;
    }
  }

  /// Subir imagen de negocio
  Future<String?> uploadBusinessImage(String businessId, XFile imageFile) async {
    try {
      Reference ref = _storage.ref().child('businesses/$businessId/business.jpg');
      
      UploadTask uploadTask = ref.putFile(File(imageFile.path));
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('✅ Imagen de negocio subida: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subiendo imagen de negocio: $e');
      }
      return null;
    }
  }

  /// Subir imagen de producto
  Future<String?> uploadProductImage(String productId, XFile imageFile) async {
    try {
      Reference ref = _storage.ref().child('products/$productId/product.jpg');
      
      UploadTask uploadTask = ref.putFile(File(imageFile.path));
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('✅ Imagen de producto subida: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subiendo imagen de producto: $e');
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
          print('✅ Imagen seleccionada desde galería');
        }
      }
      
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error seleccionando imagen: $e');
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
          print('✅ Imagen tomada con cámara');
        }
      }
      
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error tomando imagen: $e');
      }
      return null;
    }
  }

  /// Mostrar opciones de selección de imagen
  Future<XFile?> pickImage() async {
    try {
      // En un caso real, mostrarías un diálogo con opciones
      // Por ahora, usamos galería por defecto
      return await pickImageFromGallery();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error seleccionando imagen: $e');
      }
      return null;
    }
  }

  /// Eliminar imagen
  Future<bool> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      
      if (kDebugMode) {
        print('✅ Imagen eliminada exitosamente');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error eliminando imagen: $e');
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
        print('❌ Error obteniendo URL de descarga: $e');
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
        print('✅ Archivo subido: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subiendo archivo: $e');
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
          print('❌ Error subiendo imagen $i: $e');
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
        print('❌ Error comprimiendo imagen: $e');
      }
      return null;
    }
  }
}
