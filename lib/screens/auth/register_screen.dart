// 📝 PANTALLA DE REGISTRO
// Esta pantalla permite a nuevos usuarios crear una cuenta
// Incluye validación de formularios, confirmación de contraseña y términos

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

/// 📋 Pantalla de registro de nuevos usuarios
/// Permite crear cuenta con email, contraseña y datos personales
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 📝 CONTROLADORES DE FORMULARIO
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // 👁️ CONTROL DE VISIBILIDAD DE CONTRASEÑAS
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // ✅ ACEPTACIÓN DE TÉRMINOS
  bool _acceptTerms = false;
  
  // ⏳ ESTADO DE CARGA
  bool _isLoading = false;

  @override
  void dispose() {
    // 🧹 LIMPIEZA DE CONTROLADORES
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // 📝 MÉTODO DE REGISTRO
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes aceptar los términos y condiciones'),
          backgroundColor: ThemeProvider.errorColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 🔄 Simular proceso de registro
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // 🎉 ÉXITO - Mostrar mensaje y volver al login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Cuenta creada exitosamente!'),
            backgroundColor: ThemeProvider.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // ❌ ERROR - Mostrar mensaje
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ThemeProvider.errorColor,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          // 🎨 FONDO CON GRADIENTE
          body: Container(
            decoration: BoxDecoration(
              gradient: ThemeProvider.primaryGradient,
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeProvider.radiusLarge),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🎯 LOGO Y TÍTULO
                            Icon(
                              Icons.person_add,
                              size: 64,
                              color: ThemeProvider.primaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Crear Cuenta',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: ThemeProvider.primaryTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Completa los datos para registrarte',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: ThemeProvider.secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // 👤 CAMPO DE NOMBRE
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Nombre completo',
                                prefixIcon: const Icon(Icons.person_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(ThemeProvider.radiusMedium),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu nombre';
                                }
                                if (value.length < 2) {
                                  return 'El nombre debe tener al menos 2 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // 📧 CAMPO DE EMAIL
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(ThemeProvider.radiusMedium),
                                ),
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
                            const SizedBox(height: 16),
                            
                            // 📱 CAMPO DE TELÉFONO
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Teléfono',
                                prefixIcon: const Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(ThemeProvider.radiusMedium),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu teléfono';
                                }
                                if (value.length < 10) {
                                  return 'El teléfono debe tener al menos 10 dígitos';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // 🔒 CAMPO DE CONTRASEÑA
                            TextFormField(
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(ThemeProvider.radiusMedium),
                                ),
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
                            const SizedBox(height: 16),
                            
                            // 🔒 CAMPO DE CONFIRMACIÓN DE CONTRASEÑA
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirmar contraseña',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(ThemeProvider.radiusMedium),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor confirma tu contraseña';
                                }
                                if (value != _passwordController.text) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // ✅ CHECKBOX DE TÉRMINOS Y CONDICIONES
                            Row(
                              children: [
                                Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptTerms = value ?? false;
                                    });
                                  },
                                  activeColor: ThemeProvider.primaryColor,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _acceptTerms = !_acceptTerms;
                                      });
                                    },
                                    child: Text(
                                      'Acepto los términos y condiciones',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: ThemeProvider.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // 🔘 BOTÓN DE REGISTRO
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text('Crear Cuenta'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // 🔗 ENLACE A LOGIN
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
      },
    );
  }
}