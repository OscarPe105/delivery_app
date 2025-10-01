// 🏠 PANTALLA PRINCIPAL DEL CLIENTE - VERSIÓN SIMPLIFICADA
// Esta pantalla muestra la interfaz principal para los clientes
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';      // 🔑 Datos del usuario autenticado
import '../../providers/business_provider.dart'; // 🏪 Gestión de negocios
import '../../providers/theme_provider.dart';    // 🎨 Paleta de colores
import '../../widgets/delivery_map.dart';        // 🗺️ Widget de mapa interactivo
import '../../widgets/animated_components.dart'; // 🎨 Componentes animados
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
  
  bool _showHeader = true;

  @override
  void initState() {
    super.initState();
    
    // 🎨 Inicializar animaciones
    _initializeAnimations();
    _startAnimations();
    
    // Programar ocultar el header después de unos segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      _headerAnimationController.reverse();
    });

    // Cuando la animación del header termine al retroceder, ocultarlo del árbol
    _headerAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() {
          _showHeader = false;
        });
      }
    });
    
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

  // 🏪 NAVEGACIÓN A DETALLE DE NEGOCIO
  void _navigateToBusinessDetail(dynamic business) {
    Navigator.pushNamed(
      context, 
      '/business-detail',
      arguments: business,
    ).catchError((error) {
      // Fallback si la ruta no existe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detalle de ${business.name} - Próximamente'),
          backgroundColor: ThemeProvider.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return null;
    });
  }

  // 🏪 NAVEGACIÓN A LISTA DE NEGOCIOS
  void _navigateToBusinesses() {
    Navigator.pushNamed(context, '/businesses').catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lista de negocios - Próximamente'),
          backgroundColor: ThemeProvider.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return null;
    });
  }

  // 📋 NAVEGACIÓN A PEDIDOS
  void _navigateToOrders() {
    Navigator.pushNamed(context, '/orders').catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mis pedidos - Próximamente'),
          backgroundColor: ThemeProvider.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final businessProvider = Provider.of<BusinessProvider>(context);

    return Scaffold(
      backgroundColor: ThemeProvider.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎨 HEADER DE BIENVENIDA (solo visible si _showHeader es true)
              if (_showHeader) _buildWelcomeHeader(authProvider),
              
              // 🔍 BARRA DE BÚSQUEDA
              _buildSearchBar(),
              
              // 🗺️ MAPA INTERACTIVO
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
                gradient: ThemeProvider.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeProvider.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con avatar y saludo
                    Row(
                      children: [
                        // Avatar del usuario
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: authProvider.user?.profileImage != null 
                            ? NetworkImage(authProvider.user!.profileImage!) 
                            : null,
                          child: authProvider.user?.profileImage == null 
                            ? const Icon(
                                Icons.person, 
                                color: Colors.white, 
                                size: 30,
                              ) 
                            : null,
                        ),
                        const SizedBox(width: 16),
                        // Texto de bienvenida
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Hola, ${authProvider.user?.name ?? 'Usuario'}! ',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Descubre los mejores negocios de tu barrio',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Roboto',
                                  
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar productos, negocios...',
                  prefixIcon: Icon(Icons.search, color: ThemeProvider.primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onTap: () {
                  NavigationUtils.slideUp(context, const SearchScreen());
                },
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Negocios Destacados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
                child: GestureDetector(
                  onTap: () {
                    _navigateToBusinessDetail(business);
                  },
                  child: Container(
                    width: 140,
                    height: 180,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del negocio animada
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: ThemeProvider.primaryGradient,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.store,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Información del negocio
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                business.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                business.category,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    '4.5',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
          const Text(
            'Accesos Rápidos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.store,
                  title: 'Tienda',
                  subtitle: 'Explorar productos',
                  delay: 0,
                  onTap: () {
                    _navigateToBusinesses();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.receipt_long,
                  title: 'Mis Pedidos',
                  subtitle: 'Ver historial',
                  delay: 100,
                  onTap: () {
                    _navigateToOrders();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int delay = 0,
  }) {
    return AnimatedCard(
      delayMilliseconds: 500 + delay,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: ThemeProvider.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeProvider.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
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

  //  PROMOCIONES
  Widget _buildPromotions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ThemeProvider.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeProvider.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            ' ¡Ofertas Especiales!',
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
