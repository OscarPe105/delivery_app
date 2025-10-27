import 'package:flutter/material.dart';
import '../../providers/theme_provider.dart';

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Negocio'),
        backgroundColor: ThemeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Tu negocio está en proceso. Pronto verás el panel.'),
      ),
    );
  }
}