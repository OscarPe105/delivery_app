import 'package:flutter/material.dart';
import '../../scripts/add_coordinates_to_businesses.dart';

/// Pantalla administrativa para agregar coordenadas automáticamente
class AddCoordinatesScreen extends StatefulWidget {
  const AddCoordinatesScreen({super.key});

  @override
  State<AddCoordinatesScreen> createState() => _AddCoordinatesScreenState();
}

class _AddCoordinatesScreenState extends State<AddCoordinatesScreen> {
  bool _isRunning = false;
  String _status = 'Listo para ejecutar';
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    debugPrint(message);
  }

  Future<void> _runScript() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _status = 'Ejecutando...';
      _logs.clear();
    });

    try {
      _addLog('🚀 Iniciando script para agregar coordenadas...\n');

      // Obtener todos los negocios
      final script = AddCoordinatesScript(onLog: _addLog);
      
      // Ejecutar el script con callback de logs
      await script.run();

      setState(() {
        _status = '✅ Script completado';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Coordenadas agregadas exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _status = '❌ Error en el script';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Coordenadas Automáticas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Información
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Información',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Este script buscará automáticamente las coordenadas de todos los negocios '
                  'que no las tengan, basándose en su dirección.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estado: $_status',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botón de ejecutar
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _isRunning ? null : _runScript,
              icon: _isRunning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isRunning ? 'Ejecutando...' : 'Ejecutar Script'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          // Logs
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Sin logs aún',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

