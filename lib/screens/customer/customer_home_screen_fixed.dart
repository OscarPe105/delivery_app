// 🏠 PANTALLA PRINCIPAL DEL CLIENTE
// Esta pantalla muestra la interfaz principal para los clientes

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';      // 🔑 Datos del usuario autenticado
import '../../providers/business_provider.dart'; // 🏪 Gestión de negocios
import '../../widgets/delivery_map.dart';        // 🗺️ Widget de mapa interactivo
import '../../widgets/animated_components.dart'; // 🎨 Componentes animados
import '../../widgets/improved_buttons.dart';    // 🎨 Botones mejorados
import '../../widgets/advanced_visual_effects.dart'; // ✨ Efectos visuales
import '../../utils/navigation_transitions.dart'; // 🚀 Transiciones de navegación
import '../search_screen.dart';                 // 🔍 Pantalla de búsqueda

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    // 🎨 Inicializar animaciones
    _initializeAnimations();
    _startAnimations();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false).loadBusinesses();
    });
  }

  void _initializeAnimations() {
    // 🎨 Controlador de animación del header
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 🎨 Controlador de animación del contenido
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 🎨 Animaciones del header
    _headerSlideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    ));

    // 🎨 Animación del contenido
    _contentSlideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final businessProvider = Provider.of<BusinessProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎨 HEADER DE BIENVENIDA
              _buildWelcomeHeader(authProvider),
              
              // 🔍 BARRA DE BÚSQUEDA
              _buildSearchBar(),
              
              // 🗺️ MAPA INTERACTIVO - NUEVA SECCIÓN
              _buildMapSection(businessProvider),
              
              // 🏪 NEGOCIOS DESTACADOS
              _buildFeaturedBusinesses(businessProvider),
              
              // 📋 ACCESOS RÁPIDOS
              _buildQuickActions(),
              
              // 🎯 PROMOCIONES
              _buildPromotions(),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 HEADER DE BIENVENIDA ANIMADO
  Widget _buildWelcomeHeader(AuthProvider authProvider) {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlideAnimation.value),
          child: FadeTransition(
            opacity: _headerFadeAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBF360C), Color(0xFFD84315)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBF360C).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingParticles(
                particleCount: 15,
                particleColor: Colors.white.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saludo personalizado animado
                      ShimmerEffect(
                        child: Text(
                          '¡Hola, ${authProvider.user?.name ?? 'Usuario'}! 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Descubre los mejores negocios de tu barrio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Ubicación actual animada
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'Tu ubicación actual',
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 14,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // 🔍 BARRA DE BÚSQUEDA ANIMADA
  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _contentAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _contentSlideAnimation.value),
          child: FadeTransition(
            opacity: _contentAnimationController,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF8F9FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ShimmerEffect(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar productos, negocios...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF667eea)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onTap: () {
                    NavigationUtils.slideUp(context, const SearchScreen());
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // 🏪 NEGOCIOS DESTACADOS
  Widget _buildFeaturedBusinesses(BusinessProvider businessProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ShimmerEffect(
            child: Text(
              'Negocios Destacados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                background: Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: businessProvider.businesses.length,
            itemBuilder: (context, index) {
              final business = businessProvider.businesses[index];
              return AnimatedCard(
                delayMilliseconds: 300 + (index * 100),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del negocio animada
                      WaveEffect(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF667eea + (index * 0x1000000)),
                                Color(0xFF764ba2 + (index * 0x1000000)),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: FloatingParticles(
                            particleCount: 5,
                            particleColor: Colors.white.withOpacity(0.3),
                            child: const Center(
                              child: Icon(
                                Icons.store,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Información del negocio
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              business.category,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '4.5',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  // 📋 ACCESOS RÁPIDOS
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerEffect(
            child: Text(
              'Accesos Rápidos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                background: Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryGradientButton(
                  text: 'Tienda',
                  icon: Icons.store,
                  onPressed: () {
                    // Cambiar a pestaña de tienda
                  },
                  width: double.infinity,
                  height: 80,
                  gradientColors: const [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryGradientButton(
                  text: 'Mis Pedidos',
                  icon: Icons.receipt_long,
                  onPressed: () {
                    // Cambiar a pestaña de pedidos
                  },
                  width: double.infinity,
                  height: 80,
                  gradientColors: const [Color(0xFFf093fb), Color(0xFFf5576c)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🗺️ SECCIÓN DEL MAPA
  Widget _buildMapSection(BusinessProvider businessProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: const DeliveryMap(),
      ),
    );
  }

  // 🎯 PROMOCIONES
  Widget _buildPromotions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎉 ¡Ofertas Especiales!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Descuentos exclusivos en tus negocios favoritos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

