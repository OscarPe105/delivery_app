import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_components.dart' as animated_components;
import '../../widgets/app_animations.dart';
import '../../themes/app_colors.dart';
import '../../constants/app_assets.dart';
import '../../services/firebase_storage_service.dart';
import '../main_navigation.dart';
import '../business/business_dashboard_screen.dart';
import '../driver/driver_dashboard_screen.dart';

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
            return const BusinessDashboardScreen(); // Pantalla de dueño de negocio
          case UserType.driver:
            return const DriverDashboardScreen();
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
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _loadLogoFromStorage();
  }

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
            backgroundColor: AppColors.primary,
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

  Future<void> _loadLogoFromStorage() async {
    try {
      final storageService = FirebaseStorageService();
      final url = await storageService.getDownloadURL(
        AppAssets.ready2GoLogoStoragePath,
      );

      if (!mounted) return;

      if (url != null && url.isNotEmpty) {
        setState(() {
          _logoUrl = url;
        });
        return;
      }
    } catch (_) {
      // Ignorar y usar fallback
    }

    if (!mounted) return;

    if (AppAssets.ready2GoLogoFallbackUrl.isNotEmpty) {
      setState(() {
        _logoUrl = AppAssets.ready2GoLogoFallbackUrl;
      });
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
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -60,
                left: -40,
                child: _buildBackgroundOrb(110, Colors.white.withValues(alpha: 0.12)),
              ),
              Positioned(
                bottom: -80,
                right: -50,
                child: _buildBackgroundOrb(160, Colors.white.withValues(alpha: 0.08)),
              ),
              Positioned(
                bottom: 120,
                left: 30,
                child: _buildBackgroundOrb(70, AppColors.primaryLight.withValues(alpha: 0.18)),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0.90),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 18),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppAnimations.fadeIn(
                                duration: const Duration(milliseconds: 500),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildLogoBadge(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildLabel('Correo electrónico'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _emailController,
                                hint: 'nombre@correo.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
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
                              const SizedBox(height: 20),
                              _buildLabel('Contraseña'),
                              const SizedBox(height: 8),
                              _buildPasswordField(),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Recuperación de contraseña próximamente'),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Text('¿Olvidaste tu contraseña?'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              animated_components.AnimatedButton(
                                text: 'Iniciar sesión',
                                onPressed: _isLoading ? null : _login,
                                isLoading: _isLoading,
                                icon: Icons.login,
                                width: double.infinity,
                                height: 52,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey[300])),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      '¿Eres nuevo?',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey[300])),
                                ],
                              ),
                              const SizedBox(height: 16),
                              animated_components.AnimatedButton(
                                text: 'Crear cuenta',
                                onPressed: () => Navigator.of(context).pushNamed('/register'),
                                backgroundColor: Colors.transparent,
                                textColor: AppColors.primary,
                                hasShadow: false,
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildLogoBadge() {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: FittedBox(
          key: ValueKey(_logoUrl ?? 'logo_asset'),
          fit: BoxFit.contain,
          child: SizedBox(
            width: 780,
            height: 620,
            child: _buildLogoImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoImage() {
    final placeholder = Image.asset(
      AppAssets.ready2GoLogoAsset,
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );

    if (_logoUrl == null || _logoUrl!.isEmpty) {
      return placeholder;
    }

    return Image.network(
      _logoUrl!,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) => placeholder,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2.4,
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: AppColors.primary,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
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
    );
  }
}
