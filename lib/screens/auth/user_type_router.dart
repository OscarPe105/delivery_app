import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_animations.dart';
import '../main_navigation.dart';
import '../business/business_home_screen.dart';

/// Widget que determina qué pantalla mostrar según el tipo de usuario
class UserTypeRouter extends StatelessWidget {
  const UserTypeRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Si no está autenticado, mostrar login
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Determinar qué pantalla mostrar según el tipo de usuario
        switch (authProvider.userType) {
          case UserType.customer:
            return const MainNavigation(); // Pantalla de cliente
          case UserType.business:
            return const BusinessHomeScreen(); // Pantalla de dueño de negocio
        }
      },
    );
  }
}

/// Pantalla de login mejorada con modo discreto
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _isLoading = true; });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ok = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
        // No pasamos tipo de usuario - se detectará automáticamente
      );
      
      if (!mounted) return;

      if (ok) {
        // La navegación se manejará automáticamente por UserTypeRouter
        // El tipo de usuario se detectará automáticamente según si tiene negocio registrado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.userType == UserType.business 
                ? '¡Bienvenido! Acceso completo al panel de gestión'
                : '¡Bienvenido! Explora nuestros restaurantes'
            ),
            backgroundColor: const Color(0xFFE8B86D),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales inválidas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
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
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8B86D), Color(0xFFD4A574)],
          ),
        ),
        child: SafeArea(
          child: Center(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo simple
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.delivery_dining,
                            size: 64,
                            color: Color(0xFFE8B86D),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Delivery App',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Inicia sesión para continuar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Campo de email con animación
                        AppAnimations.fadeIn(
                          duration: const Duration(milliseconds: 400),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu email';
                              }
                              if (!value.contains('@')) {
                                return 'Por favor ingresa un email válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Campo de contraseña con animación
                        AppAnimations.fadeIn(
                          duration: const Duration(milliseconds: 600),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón de inicio de sesión con animación
                        AppAnimations.scaleIn(
                          duration: const Duration(milliseconds: 800),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: AnimatedButton(
                              onPressed: _isLoading ? null : _login,
                              backgroundColor: const Color(0xFFE8B86D),
                              foregroundColor: Colors.white,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Opción para crear cuenta con animación
                        AppAnimations.fadeIn(
                          duration: const Duration(milliseconds: 1000),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿No tienes cuenta? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/register');
                                },
                                child: const Text(
                                  'Crear cuenta',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFE8B86D),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}