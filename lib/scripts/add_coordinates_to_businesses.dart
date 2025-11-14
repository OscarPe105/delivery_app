import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

/// Script para agregar automáticamente coordenadas a negocios en Firestore
/// basándose en su dirección
class AddCoordinatesScript {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Function(String)? onLog;

  AddCoordinatesScript({this.onLog});

  void _log(String message) {
    onLog?.call(message);
    stdout.writeln(message);
  }

  /// Ejecutar el script para todos los negocios sin coordenadas
  Future<void> run() async {
    _log('🚀 Iniciando script para agregar coordenadas...\n');

    try {
      // Obtener todos los negocios
      final businessesSnapshot = await _firestore.collection('businesses').get();
      _log('📊 Total de negocios encontrados: ${businessesSnapshot.docs.length}\n');

      int processedCount = 0;
      int successCount = 0;
      int skipCount = 0;
      int errorCount = 0;

      for (final doc in businessesSnapshot.docs) {
        final data = doc.data();
        final name = data['name'] ?? '';
        final address = data['address'] ?? '';
        final latitude = data['latitude'];
        final longitude = data['longitude'];

        // Verificar si ya tiene coordenadas
        if (latitude != null && longitude != null) {
          _log('⏭️  ${doc.id}: "$name" ya tiene coordenadas → Saltando');
          skipCount++;
          continue;
        }

        // Verificar si tiene dirección
        if (address.isEmpty) {
          _log('⚠️  ${doc.id}: "$name" no tiene dirección → Saltando');
          skipCount++;
          continue;
        }

        processedCount++;
        _log('\n📍 Procesando: "$name"');
        _log('   Dirección: $address');

        try {
          // Usar geocoding para obtener coordenadas
          final coordinates = await _getCoordinatesFromAddress(address);

          if (coordinates != null) {
            // Actualizar el documento en Firestore
            await doc.reference.update({
              'latitude': coordinates['latitude'],
              'longitude': coordinates['longitude'],
              'updatedAt': FieldValue.serverTimestamp(),
            });

            _log('✅ Coordenadas agregadas: ${coordinates['latitude']}, ${coordinates['longitude']}');
            successCount++;

            // Pausa para evitar rate limits
            await Future.delayed(const Duration(milliseconds: 300));
          } else {
            _log('❌ No se pudieron obtener coordenadas');
            errorCount++;
          }
        } catch (e) {
          _log('❌ Error: $e');
          errorCount++;
        }
      }

      // Resumen
      _log('\n${'=' * 50}');
      _log('📊 RESUMEN DEL PROCESO');
      _log('=' * 50);
      _log('Total de negocios: ${businessesSnapshot.docs.length}');
      _log('Procesados: $processedCount');
      _log('Exitosos: $successCount ✅');
      _log('Saltados (ya tenían coordenadas): $skipCount');
      _log('Errores: $errorCount ❌');
      _log('=' * 50);

    } catch (e) {
      _log('\n❌ Error general: $e');
    }
  }

  /// Obtener coordenadas desde una dirección usando Geocoding
  Future<Map<String, double>?> _getCoordinatesFromAddress(String address) async {
    try {
      // Agregar "El Salvador" para mejorar la precisión
      final fullAddress = '$address, El Salvador';
      _log('   Buscando: $fullAddress');

      final locations = await locationFromAddress(fullAddress);

      if (locations.isNotEmpty) {
        final location = locations.first;
        return {
          'latitude': location.latitude,
          'longitude': location.longitude,
        };
      } else {
        // Intentar sin "El Salvador"
        _log('   Reintentando sin país...');
        final locations2 = await locationFromAddress(address);
        if (locations2.isNotEmpty) {
          final location = locations2.first;
          return {
            'latitude': location.latitude,
            'longitude': location.longitude,
          };
        }
      }

      return null;
    } catch (e) {
      _log('   Error en geocoding: $e');
      return null;
    }
  }
}

/// Función principal para ejecutar el script
Future<void> main() async {
  try {
    stdout.writeln('⚠️  IMPORTANTE: Este script requiere que Firebase esté inicializado');
    stdout.writeln('⚠️  Ejecuta desde la app o inicializa Firebase primero\n');
    
    final script = AddCoordinatesScript();
    await script.run();
  } catch (e) {
    stdout.writeln('\n❌ Error fatal: $e');
    stdout.writeln('\n💡 Asegúrate de que Firebase esté inicializado antes de ejecutar este script');
  }
}
