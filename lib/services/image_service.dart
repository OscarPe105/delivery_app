import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Servicio para gestión y optimización de imágenes
class ImageService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Seleccionar imagen desde galería
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85, // Calidad optimizada
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error seleccionando imagen: $e');
      return null;
    }
  }
  
  /// Seleccionar imagen desde cámara
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error tomando foto: $e');
      return null;
    }
  }
  
  /// Mostrar diálogo para seleccionar fuente de imagen
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final image = await pickImageFromGallery();
                  Navigator.of(context).pop(image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final image = await pickImageFromCamera();
                  Navigator.of(context).pop(image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Comprimir imagen antes de subir
  static Future<File?> compressImage(File imageFile) async {
    try {
      // Para este ejemplo, simplemente retornamos el archivo original
      // En una implementación real, usarías un paquete como flutter_image_compress
      return imageFile;
    } catch (e) {
      debugPrint('Error comprimiendo imagen: $e');
      return null;
    }
  }
  
  /// Subir imagen al servidor Django
  static Future<String?> uploadImage(File imageFile, String endpoint) async {
    try {
      // Crear multipart request
      var request = http.MultipartRequest('POST', Uri.parse(endpoint));
      
      // Agregar archivo
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      // Agregar headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
      });
      
      // Enviar request
      var response = await request.send();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = await response.stream.bytesToString();
        var data = json.decode(responseBody);
        
        // Retornar URL de la imagen subida
        return data['image_url'] ?? data['url'];
      } else {
        debugPrint('Error subiendo imagen: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    }
  }
  
  /// Generar URL optimizada para diferentes tamaños
  static String getOptimizedImageUrl(String baseUrl, {int? width, int? height}) {
    if (baseUrl.isEmpty) return '';
    
    // Si es una imagen local, retornar tal como está
    if (baseUrl.startsWith('assets/')) {
      return baseUrl;
    }
    
    // Para imágenes de red, agregar parámetros de optimización
    String optimizedUrl = baseUrl;
    
    if (width != null || height != null) {
      final separator = baseUrl.contains('?') ? '&' : '?';
      optimizedUrl += '$separator';
      
      if (width != null) optimizedUrl += 'w=$width';
      if (height != null) optimizedUrl += '&h=$height';
      
      // Agregar parámetros de calidad
      optimizedUrl += '&q=85&f=auto';
    }
    
    return optimizedUrl;
  }
  
  /// Validar tamaño de imagen
  static bool validateImageSize(File imageFile, {int maxSizeKB = 2048}) {
    try {
      final sizeInBytes = imageFile.lengthSync();
      final sizeInKB = sizeInBytes / 1024;
      
      return sizeInKB <= maxSizeKB;
    } catch (e) {
      debugPrint('Error validando tamaño: $e');
      return false;
    }
  }
  
  /// Validar tipo de imagen
  static bool validateImageType(File imageFile) {
    try {
      final extension = imageFile.path.toLowerCase().split('.').last;
      const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      
      return allowedExtensions.contains(extension);
    } catch (e) {
      debugPrint('Error validando tipo: $e');
      return false;
    }
  }
  
  /// Obtener información de la imagen
  static Future<Map<String, dynamic>?> getImageInfo(File imageFile) async {
    try {
      final sizeInBytes = imageFile.lengthSync();
      final sizeInKB = (sizeInBytes / 1024).round();
      final extension = imageFile.path.toLowerCase().split('.').last;
      
      return {
        'size_bytes': sizeInBytes,
        'size_kb': sizeInKB,
        'extension': extension,
        'path': imageFile.path,
      };
    } catch (e) {
      debugPrint('Error obteniendo info de imagen: $e');
      return null;
    }
  }
}

/// Widget para mostrar progreso de carga de imagen
class ImageUploadProgress extends StatelessWidget {
  final double progress;
  final String message;
  
  const ImageUploadProgress({
    super.key,
    required this.progress,
    this.message = 'Subiendo imagen...',
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar preview de imagen antes de subir
class ImagePreview extends StatelessWidget {
  final File imageFile;
  final VoidCallback? onRemove;
  final VoidCallback? onUpload;
  final bool isUploading;
  final double? progress;
  
  const ImagePreview({
    super.key,
    required this.imageFile,
    this.onRemove,
    this.onUpload,
    this.isUploading = false,
    this.progress,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Preview de la imagen
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.file(
              imageFile,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          
          // Información y controles
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Información de la imagen
                FutureBuilder<Map<String, dynamic>?>(
                  future: ImageService.getImageInfo(imageFile),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final info = snapshot.data!;
                      return Text(
                        '${info['size_kb']} KB • ${info['extension'].toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Barra de progreso si está subiendo
                if (isUploading && progress != null)
                  Column(
                    children: [
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress! * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 8),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (onRemove != null)
                      TextButton.icon(
                        onPressed: isUploading ? null : onRemove,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Eliminar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    if (onUpload != null)
                      ElevatedButton.icon(
                        onPressed: isUploading ? null : onUpload,
                        icon: const Icon(Icons.upload, size: 18),
                        label: const Text('Subir'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
