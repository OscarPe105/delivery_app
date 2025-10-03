import 'package:flutter/material.dart';
import '../../providers/theme_provider.dart';

class BusinessOnboardingScreen extends StatefulWidget {
  const BusinessOnboardingScreen({super.key});

  @override
  State<BusinessOnboardingScreen> createState() => _BusinessOnboardingScreenState();
}

class _BusinessOnboardingScreenState extends State<BusinessOnboardingScreen> {
  int _currentStep = 0;

  void _goNext() {
    setState(() {
      if (_currentStep < 2) {
        _currentStep += 1;
      } else {
        Navigator.pushNamed(context, '/business/register');
      }
    });
  }

  void _goBack() {
    setState(() {
      if (_currentStep > 0) _currentStep -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registra tu Negocio'),
        backgroundColor: ThemeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _goNext,
        onStepCancel: _goBack,
        steps: const [
          Step(
            title: Text('Información'),
            content: Text('Conoce los requisitos y beneficios.'),
          ),
          Step(
            title: Text('Ubicación'),
            content: Text('Configura tu dirección y radio de entrega.'),
          ),
          Step(
            title: Text('Formulario'),
            content: Text('Completa los datos de tu negocio.'),
          ),
        ],
      ),
    );
  }
}