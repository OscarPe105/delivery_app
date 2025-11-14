// PANTALLA PRINCIPAL DEL CLIENTE - VERSIÓN SIMPLIFICADA
// Esta pantalla muestra la interfaz principal para los clientes
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';      //  Datos del usuario autenticado
import '../../providers/community_store_provider.dart'; //  Provider principal de la tienda
import '../../models/business.dart';
import '../../models/promotion.dart';
import '../../providers/theme_provider.dart';    //  Paleta de colores
import '../../widgets/animated_components.dart'; //  Componentes animados
import '../../utils/navigation_transitions.dart'; //  Transiciones de navegación
import '../search_screen.dart';                 //  Pantalla de búsqueda
import '../community_store_screen.dart';
import '../orders_screen.dart';
import 'promotions_screen.dart';
import '../../widgets/promotion_card.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  
  // Controladores de página para secciones destacadas y locales
  late PageController _featuredPageController;
  late PageController _localPageController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _promotionsSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _featuredPageController = PageController(viewportFraction: 0.92);
    _localPageController = PageController(viewportFraction: 0.92);
    
    //  Inicializar animaciones
    _initializeAnimations();
    _startAnimations();
    
    // Cargar negocios desde CommunityStoreProvider
    final storeProvider = Provider.of<CommunityStoreProvider>(context, listen: false);
    storeProvider.loadData();
  }

  void _initializeAnimations() {
    //  Controlador de animación del header
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
 
    //  Animaciones del header
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
  }

  void _startAnimations() {
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _featuredPageController.dispose();
    _localPageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  //  NAVEGACIÓN A DETALLE DE NEGOCIO
  void _navigateToBusinessDetail(dynamic business) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pushNamed(
      context, 
      '/business-detail',
      arguments: business,
    ).catchError((error) {
      // Fallback si la ruta no existe
      messenger.showSnackBar(
        SnackBar(
          content: Text('Detalle de ${business.name} - Próximamente'),
          backgroundColor: ThemeProvider.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return null;
    });
  }

  //  NAVEGACIÓN A LISTA DE NEGOCIOS
  void _navigateToBusinesses() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CommunityStoreScreen()),
    );
  }

  //  NAVEGACIÓN A PEDIDOS
  void _navigateToOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
    );
  }

  void _openFavorites() {
    Navigator.pushNamed(context, '/favorites');
  }

  void _openStore() {
    _navigateToBusinesses();
  }

  void _openPreorder() {
    _navigateToOrders();
  }

  Widget _buildSectionTitle(
    String title, {
    String? subtitle,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 20.0),
    double topPadding = 0,
  }) {
    final theme = Theme.of(context);
    final effectivePadding = padding.add(EdgeInsets.only(top: topPadding));
    return Padding(
      padding: effectivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final storeProvider = Provider.of<CommunityStoreProvider>(context);

    return Scaffold(
      backgroundColor: ThemeProvider.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER HERO PRINCIPAL
              _buildHeroSection(authProvider),
              
              //  NEGOCIOS DESTACADOS
              _buildFeaturedBusinesses(storeProvider),
              
              //  EMPRENDIMIENTOS LOCALES (SEGUNDO CARRUSEL)
              _buildLocalBusinessesCarousel(storeProvider),
              
              // ACCESOS RÁPIDOS
              _buildQuickActions(),
              
              //  PROMOCIONES
              KeyedSubtree(
                key: _promotionsSectionKey,
                child: _buildPromotionsSection(storeProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  HEADER DE BIENVENIDA ANIMADO
  Widget _buildHeroSection(AuthProvider authProvider) {
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
                    color: ThemeProvider.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage: authProvider.user?.profileImage != null
                              ? NetworkImage(authProvider.user!.profileImage!)
                              : null,
                          child: authProvider.user?.profileImage == null
                              ? const Icon(Icons.person, color: Colors.white, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Hola, ${authProvider.user?.name ?? 'Usuario'}!',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '¿Qué se te antoja hoy?',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pronto podrás establecer direcciones favoritas.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.location_on,
                                  color: ThemeProvider.primaryColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Entrega en',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Ingresa tu dirección',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        NavigationUtils.slideUp(context, const SearchScreen());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              child: Icon(Icons.search,
                                  color: ThemeProvider.primaryColor.withValues(alpha: 0.9)),
                            ),
                            const Expanded(
                              child: Text(
                                'Buscar productos o negocios...',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: ThemeProvider.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.filter_alt_outlined,
                                    color: ThemeProvider.primaryColor),
                                onPressed: () {
                                  NavigationUtils.slideUp(context, const SearchScreen());
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickChip(
                            icon: Icons.schedule_send,
                            label: 'Preorden',
                            backgroundColor: Colors.white,
                            textColor: ThemeProvider.primaryColor,
                            onTap: () {
                              _openPreorder();
                            },
                          ),
                          _buildQuickChip(
                            icon: Icons.local_offer,
                            label: 'Promos',
                            backgroundColor: Colors.orange[50],
                            textColor: Colors.orange[800]!,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PromotionsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildQuickChip(
                            icon: Icons.favorite_border,
                            label: 'Favoritos',
                            backgroundColor: Colors.pink[50],
                            textColor: Colors.pink[600]!,
                            onTap: _openFavorites,
                          ),
                          _buildQuickChip(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Tienda',
                            backgroundColor: Colors.green[50],
                            textColor: Colors.green[700]!,
                            onTap: _openStore,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(minHeight: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB71C1C), Color(0xFFF44336), Color(0xFFFF8A65)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB71C1C).withValues(alpha: 0.32),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Promociones próximamente',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Muy pronto podrás descubrir ofertas exclusivas de tus negocios favoritos aquí.',
                                  style: TextStyle(
                                    color: Color(0xFFFFF1F0),
                                    fontSize: 14,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 92,
                            height: 88,
                            margin: const EdgeInsets.only(left: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.white.withValues(alpha: 0.22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFB71C1C).withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_offer,
                              color: Colors.white,
                              size: 46,
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
        );
      },
    );
  }

  Widget _buildQuickChip({
    required IconData icon,
    required String label,
    required Color? backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🏪 NEGOCIOS DESTACADOS (PRIMER CARRUSEL)
  // Método: _buildFeaturedBusinesses
  Widget _buildFeaturedBusinesses(CommunityStoreProvider storeProvider) {
    final businesses = List<Business>.from(storeProvider.businesses);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Negocios destacados',
          subtitle: 'Recomendados para ti',
          topPadding: 12,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _featuredPageController,
            padEnds: false,
            onPageChanged: (i) => {},
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              return AnimatedCard(
                padding: EdgeInsets.zero,
                delayMilliseconds: 200 + (index * 50),
                child: GestureDetector(
                  onTap: () => _navigateToBusinessDetail(business),
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Imagen del negocio mejorada
                        Stack(
                          children: [
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                image: business.imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(business.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                gradient: business.imageUrl == null
                                    ? ThemeProvider.primaryGradient
                                    : null,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              child: business.imageUrl == null
                                  ? Center(
                                      child: Icon(
                                        Icons.store,
                                        size: 48,
                                        color: Colors.white.withValues(alpha: 0.9),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.3),
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(24),
                                          topRight: Radius.circular(24),
                                        ),
                                      ),
                                    ),
                            ),
                            // Badge de destacado
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Destacado',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Rating badge
                            if (business.rating != null && business.rating! > 0)
                              Positioned(
                                bottom: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        business.rating!.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Contenido mejorado
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        business.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black87,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          business.description ?? 'Negocio destacado',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 11,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Estado y botón mejorado
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: business.isOpen
                                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                              : Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: business.isOpen
                                                ? const Color(0xFF10B981)
                                                : Colors.grey,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              business.isOpen
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              size: 12,
                                              color: business.isOpen
                                                  ? const Color(0xFF10B981)
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              business.isOpen ? 'Abierto' : 'Cerrado',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: business.isOpen
                                                    ? const Color(0xFF10B981)
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        gradient: ThemeProvider.primaryGradient,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ThemeProvider.primaryColor.withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        size: 14,
                                        color: Colors.white,
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
        ),
      ],
    );
  }
  
  // 🏪 NEGOCIOS DESTACADOS
  // Dentro de la clase _CustomerHomeScreenState
  // Método: _buildLocalBusinessesCarousel
  Widget _buildLocalBusinessesCarousel(CommunityStoreProvider storeProvider) {
    final businesses = List<Business>.from(storeProvider.businesses);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Emprendimientos locales',
          subtitle: 'Negocios cercanos a tu ubicación',
          topPadding: 12,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _localPageController,
            padEnds: false,
            onPageChanged: (i) => {},
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              return AnimatedCard(
                padding: EdgeInsets.zero,
                delayMilliseconds: 250 + (index * 50),
                child: GestureDetector(
                  onTap: () => _navigateToBusinessDetail(business),
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Imagen del negocio mejorada
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            image: business.imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(business.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            gradient: business.imageUrl == null
                                ? ThemeProvider.primaryGradient
                                : null,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: business.imageUrl == null
                              ? Center(
                                  child: Icon(
                                    Icons.business,
                                    size: 48,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.3),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                      topRight: Radius.circular(24),
                                    ),
                                  ),
                                ),
                        ),
                        // Contenido mejorado
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        business.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black87,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          business.description ?? 'Negocio local',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 11,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Estado y botón mejorado
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: business.isOpen
                                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                              : Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: business.isOpen
                                                ? const Color(0xFF10B981)
                                                : Colors.grey,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              business.isOpen
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              size: 12,
                                              color: business.isOpen
                                                  ? const Color(0xFF10B981)
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              business.isOpen ? 'Abierto' : 'Cerrado',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: business.isOpen
                                                    ? const Color(0xFF10B981)
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        gradient: ThemeProvider.primaryGradient,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ThemeProvider.primaryColor.withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        size: 14,
                                        color: Colors.white,
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
        ),
      ],
    );
  }
  
  // 📋 ACCESOS RÁPIDOS
  Widget _buildQuickActions() {
    final actions = [
      _QuickActionItem(
        icon: Icons.schedule_send,
        title: 'Preorden',
        subtitle: 'Repite tu pedido',
        onTap: _openPreorder,
      ),
      _QuickActionItem(
        icon: Icons.local_offer_outlined,
        title: 'Promociones',
        subtitle: 'Ofertas activas',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PromotionsScreen(),
            ),
          );
        },
      ),
      _QuickActionItem(
        icon: Icons.favorite_outline,
        title: 'Favoritos',
        subtitle: 'Tus productos guardados',
        onTap: _openFavorites,
      ),
      _QuickActionItem(
        icon: Icons.storefront,
        title: 'Tienda',
        subtitle: 'Explora negocios',
        onTap: _openStore,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                'Accesos rápidos',
                subtitle: 'Vuelve a tus secciones favoritas',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth > 480 ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 10,
                  childAspectRatio: constraints.maxWidth > 480 ? 0.95 : 0.82,
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return _buildQuickActionCard(
                    icon: action.icon,
                    title: action.title,
                    subtitle: action.subtitle,
                    onTap: action.onTap,
                    delay: index * 100,
                  );
                },
              ),
            ],
          );
        },
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: const BoxConstraints(minHeight: 140),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: ThemeProvider.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeProvider.primaryColor.withValues(alpha: 0.3),
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  //  PROMOCIONES
  Widget _buildPromotionsSection(CommunityStoreProvider storeProvider) {
    final promotions = storeProvider.activePromotions;

    if (promotions.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Promociones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los negocios podrán publicar promociones especiales aquí. ¡Mantente atento!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Promociones destacadas',
          subtitle: 'Aprovecha descuentos activos',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PromotionsScreen(),
                  ),
                );
              },
              child: const Text('Ver todas'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              if (index >= promotions.length) {
                return const SizedBox.shrink();
              }
              final promotion = promotions[index];
              return PromotionCard(
                promotion: promotion,
                onTap: () => _openPromotionDetail(context, promotion),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 16),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _openPromotionDetail(BuildContext context, Promotion promotion) {
    final storeProvider = Provider.of<CommunityStoreProvider>(context, listen: false);
    final business = storeProvider.getBusinessById(promotion.businessId);

    final messenger = ScaffoldMessenger.of(context);

    if (business == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No pudimos encontrar el negocio de esta promoción.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/product-detail',
      arguments: {
        'business': business,
        'productId': promotion.productId,
      },
    ).catchError((_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Detalle de ${promotion.productName} aún no disponible. Próximamente.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return null;
    });
  }
}

class _QuickActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
