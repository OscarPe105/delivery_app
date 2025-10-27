
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';      // Gestión de autenticación
import '../../providers/theme_provider.dart';    // Gestión de temas
import '../../widgets/animated_components.dart'; //Componentes animados
import '../../utils/navigation_transitions.dart'; //Transiciones de navegación
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
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
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

    // Animaciones del logo
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

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

  //MÉTODO DE INICIO DE SESIÓN CON GOOGLE
  Future<void> _loginWithGoogle() async {
    setState(() { _isLoading = true; });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ok = await authProvider.loginWithGoogle();
      if (!mounted) return;

      if (ok) {
        Navigator.of(context).pushReplacement(
          ScaleFadeRoute(page: const MainNavigation()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al iniciar sesión con Google'),
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
      if (!mounted) return;
      setState(() { _isLoading = false; });
    }
  }

  //MÉTODO DE INICIO DE SESIÓN
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ok = await authProvider.loginWithApi(
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
      if (!mounted) return;
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        return Scaffold(
          //FONDO CON GRADIENTE
          body: Container(
            decoration: BoxDecoration(
              gradient: ThemeProvider.primaryGradient,
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedCard(
                    animationDuration: const Duration(milliseconds: 800),
                    delayMilliseconds: 500,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // LOGO Y TÍTULO ANIMADOS
                          AnimatedBuilder(
                            animation: _logoAnimationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoScaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _logoRotationAnimation.value * 0.1,
                                  child: ParticleEffect(
                                    particleCount: 15,
                                    particleColor: ThemeProvider.primaryColor.withOpacity(0.3),
                                    child: Icon(
                                      Icons.delivery_dining,
                                      size: 64,
                                      color: ThemeProvider.primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: _logoAnimationController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _logoAnimationController,
                                child: Column(
                                  children: [
                                    Text(
                                      'Delivery App',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: ThemeProvider.primaryTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Inicia sesión para continuar',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: ThemeProvider.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                            
                            //CAMPO DE EMAIL
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
                            
                            //CAMPO DE CONTRASEÑA
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
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
                            const SizedBox(height: 24),
                            
                                // BOTÓN DE GOOGLE SIGN-IN (TEMPORALMENTE DESHABILITADO)
                                AnimatedBuilder(
                                  animation: _formAnimationController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity: _formFadeAnimation,
                                      child: SlideTransition(
                                        position: _formSlideAnimation,
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(ThemeProvider.radiusMedium),
                                          ),
                                          child: ElevatedButton.icon(
                                            onPressed: null, // Deshabilitado temporalmente
                                            icon: const Icon(Icons.g_mobiledata, color: Colors.grey),
                                            label: const Text(
                                              'Google Sign-In (Próximamente)',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey.shade100,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(ThemeProvider.radiusMedium),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // DIVISOR
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.grey.shade300)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'o',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Colors.grey.shade300)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                          
                            // BOTÓN DE INICIO DE SESIÓN ANIMADO
                            AnimatedBuilder(
                              animation: _formAnimationController,
                              builder: (context, child) {
                                return FadeTransition(
                                  opacity: _formFadeAnimation,
                                  child: SlideTransition(
                                    position: _formSlideAnimation,
                                    child: AnimatedButton(
                                      text: 'Iniciar Sesión',
                                      onPressed: _isLoading ? null : _login,
                                      isLoading: _isLoading,
                                      icon: Icons.login,
                                      width: double.infinity,
                                      height: 50,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            //ENLACE A REGISTRO ANIMADO
                            AnimatedBuilder(
                              animation: _formAnimationController,
                              builder: (context, child) {
                                return FadeTransition(
                                  opacity: _formFadeAnimation,
                                  child: SlideTransition(
                                    position: _formSlideAnimation,
                                    child: AnimatedButton(
                                      text: 'Crear Cuenta',
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
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // BOTÓN PRINCIPAL (ESTILO NARANJA)
                      
                            
                            //INTERRUPTOR DE TEMA (ACTUALMENTE DESHABILITADO)
                          ],
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
