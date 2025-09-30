/**
 * 🧪 PANTALLA DE PRUEBA
 * 
 * Pantalla simple para verificar que los cambios se estén aplicando
 */

import 'package:flutter/material.dart';
import '../widgets/improved_buttons.dart';
import '../widgets/advanced_visual_effects.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título
                const Text(
                  '¡Cambios Aplicados!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Efecto de partículas
                FloatingParticles(
                  particleCount: 20,
                  particleColor: Colors.white.withOpacity(0.3),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Botones mejorados
                PrimaryGradientButton(
                  text: 'Botón Principal',
                  icon: Icons.star,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Botón principal funcionando!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: 16),
                
                SecondaryButton(
                  text: 'Botón Secundario',
                  icon: Icons.favorite,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Botón secundario funcionando!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: 16),
                
                // Efecto de shimmer
                ShimmerEffect(
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Efecto Shimmer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Botón para volver
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
