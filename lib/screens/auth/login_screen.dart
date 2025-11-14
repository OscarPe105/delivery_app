
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';      // Gestión de autenticación
import '../../providers/theme_provider.dart';    // Gestión de temas
import '../../widgets/animated_components.dart'; //Componentes animados
import '../../utils/navigation_transitions.dart'; //Transiciones de navegación
import '../../constants/app_assets.dart';       // Recursos gráficos
import 'register_screen.dart';                  // Pantalla de registro
import '../main_navigation.dart';               // Navegación principal


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // CONTROLADORES DE FORMULARIO
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // CONTROL DE VISIBILIDAD DE CONTRASEÑA
  bool _obscurePassword = true;
  
  // ESTADO DE CARGA
  bool _isLoading = false;
  
  // CONTROLADORES DE ANIMACIÓN
  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Controlador de animación del logo
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Controlador de animación del formulario
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animaciones del formulario
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutBack,
    ));

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    //Iniciar animación del logo
    _logoAnimationController.forward();
    
    //Iniciar animación del formulario con delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _formAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    //LIMPIEZA DE CONTROLADORES
    _emailController.dispose();
    _passwordController.dispose();
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }


  //MÉTODO DE INICIO DE SESIÓN
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ok = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;

      if (ok) {
        Navigator.of(context).pushReplacement(
          ScaleFadeRoute(page: const MainNavigation()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Credenciales inválidas o error de servidor'),
            backgroundColor: ThemeProvider.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: ThemeProvider.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: ThemeProvider.primaryGradient,
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
                    child: _buildBackgroundOrb(70, ThemeProvider.primaryColorLight.withValues(alpha: 0.18)),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: AnimatedBuilder(
                          animation: _formAnimationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _formFadeAnimation,
                              child: SlideTransition(
                                position: _formSlideAnimation,
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
                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          AnimatedBuilder(
                                            animation: _logoAnimationController,
                                            builder: (context, child) {
                                              return FadeTransition(
                                                opacity: _logoAnimationController,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: _buildLogoBadge(),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildBrandTitle(context),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Todo lo que buscas, cerca y rápido',
                                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                        color: ThemeProvider.secondaryTextColor,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      'Inicia sesión y descubre negocios cerca de ti',
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: ThemeProvider.secondaryTextColor.withValues(alpha: 0.85),
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 32),
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
                                                foregroundColor: ThemeProvider.primaryColor,
                                                padding: EdgeInsets.zero,
                                                visualDensity: VisualDensity.compact,
                                              ),
                                              child: const Text('¿Olvidaste tu contraseña?'),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          AnimatedButton(
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
                                          AnimatedButton(
                                            text: 'Crear cuenta',
                                            onPressed: () {
                                              NavigationUtils.slideRight(
                                                context,
                                                const RegisterScreen(),
                                              );
                                            },
                                            backgroundColor: Colors.transparent,
                                            textColor: ThemeProvider.primaryColor,
                                            hasShadow: false,
                                            height: 50,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            ThemeProvider.primaryColor,
            ThemeProvider.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeProvider.primaryColor.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipOval(
          child: Image.network(
            AppAssets.ready2GoLogoFallbackUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildBrandTitle(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ) ??
        const TextStyle(fontSize: 36, fontWeight: FontWeight.w800);

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: 'Ready',
            style: baseStyle.copyWith(color: ThemeProvider.primaryTextColor),
          ),
          TextSpan(
            text: '2',
            style: baseStyle.copyWith(
              color: ThemeProvider.primaryColor,
              shadows: [
                Shadow(
                  color: ThemeProvider.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          TextSpan(
            text: 'Go',
            style: baseStyle.copyWith(color: ThemeProvider.secondaryTextColor),
          ),
        ],
      ),
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
        prefixIcon: Icon(icon, color: ThemeProvider.primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: ThemeProvider.primaryColor, width: 1.6),
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
        prefixIcon: Icon(Icons.lock_outline, color: ThemeProvider.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: ThemeProvider.primaryColor,
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
          borderSide: BorderSide(color: ThemeProvider.primaryColor, width: 1.6),
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
